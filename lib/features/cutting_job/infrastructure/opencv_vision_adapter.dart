import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../../core/domain/geometry.dart';
import '../application/ports.dart';

typedef VisionAssetLoader = Future<Uint8List> Function(String path);

final class OpenCvVisionAdapter implements VisionPort {
  OpenCvVisionAdapter({VisionAssetLoader? assetLoader})
    : _assetLoader = assetLoader ?? _loadAsset;

  final VisionAssetLoader _assetLoader;

  @override
  Future<VectorizationResult> vectorize(VectorizationRequest request) async {
    _validate(request);
    final bytes = request.imageBytes ?? await _assetLoader(request.imagePath);
    final source = await cv.imdecodeAsync(bytes, cv.IMREAD_COLOR);
    if (source.isEmpty) {
      source.dispose();
      throw const VisionException('La imagen no tiene un formato compatible.');
    }

    try {
      return await _vectorizeDecoded(source, request);
    } finally {
      source.dispose();
    }
  }

  Future<VectorizationResult> _vectorizeDecoded(
    cv.Mat source,
    VectorizationRequest request,
  ) async {
    final gray = await cv.cvtColorAsync(source, cv.COLOR_BGR2GRAY);
    try {
      final blurred = await cv.gaussianBlurAsync(gray, (5, 5), 1.2);
      try {
        final edges = await cv.cannyAsync(blurred, 45, 135, l2gradient: true);
        try {
          final (contours, hierarchy) = await cv.findContoursAsync(
            edges,
            cv.RETR_LIST,
            cv.CHAIN_APPROX_SIMPLE,
          );
          try {
            final extracted = await _extractContours(contours);
            return _buildResult(
              sourceWidth: source.width.toDouble(),
              sourceHeight: source.height.toDouble(),
              extracted: extracted,
              request: request,
            );
          } finally {
            contours.dispose();
            hierarchy.dispose();
          }
        } finally {
          edges.dispose();
        }
      } finally {
        blurred.dispose();
      }
    } finally {
      gray.dispose();
    }
  }

  Future<List<_ContourCandidate>> _extractContours(cv.Contours contours) async {
    final candidates = <_ContourCandidate>[];
    for (var index = 0; index < contours.length; index++) {
      final contour = contours[index];
      if (contour.length < 4) continue;
      final perimeter = await cv.arcLengthAsync(contour, true);
      if (perimeter < 20) continue;
      final simplified = await cv.approxPolyDPAsync(
        contour,
        math.max(2, perimeter * 0.009),
        true,
      );
      try {
        if (simplified.length < 3) continue;
        final points = <Point2D>[];
        for (var pointIndex = 0; pointIndex < simplified.length; pointIndex++) {
          final point = simplified[pointIndex];
          points.add(Point2D(point.x.toDouble(), point.y.toDouble()));
          point.dispose();
        }
        try {
          final polygon = Polygon2D(points);
          if (polygon.bounds.width >= 8 && polygon.bounds.height >= 8) {
            candidates.add(_ContourCandidate(polygon));
          }
        } on ArgumentError {
          // Open contours and degenerate edge fragments are not mold candidates.
        }
      } finally {
        simplified.dispose();
      }
    }
    return candidates;
  }

  VectorizationResult _buildResult({
    required double sourceWidth,
    required double sourceHeight,
    required List<_ContourCandidate> extracted,
    required VectorizationRequest request,
  }) {
    final imageArea = sourceWidth * sourceHeight;
    final sheetCandidates =
        extracted
            .where((candidate) => candidate.bounds.area >= imageArea * 0.32)
            .toList(growable: false)
          ..sort((a, b) => b.bounds.area.compareTo(a.bounds.area));
    final sheetFound = sheetCandidates.isNotEmpty;
    final sheetBounds = sheetFound
        ? sheetCandidates.first.bounds
        : Bounds2D(minX: 0, minY: 0, maxX: sourceWidth, maxY: sourceHeight);

    final rawParts = _deduplicate(
      extracted
          .where((candidate) {
            final bounds = candidate.bounds;
            final relativeArea = bounds.area / sheetBounds.area;
            final centerX = (bounds.minX + bounds.maxX) / 2;
            final centerY = (bounds.minY + bounds.maxY) / 2;
            return relativeArea >= 0.0025 &&
                relativeArea <= 0.38 &&
                centerX >= sheetBounds.minX &&
                centerX <= sheetBounds.maxX &&
                centerY >= sheetBounds.minY &&
                centerY <= sheetBounds.maxY;
          })
          .toList(growable: false),
    );

    final scaled = rawParts
        .map(
          (candidate) => candidate.scaled(
            sheetBounds: sheetBounds,
            sheetWidthMm: request.sheetWidthMm,
            sheetHeightMm: request.sheetHeightMm,
          ),
        )
        .where(
          (candidate) =>
              candidate.metric.bounds.width <= request.sheetWidthMm &&
              candidate.metric.bounds.height <= request.sheetHeightMm,
        )
        .toList(growable: false);

    if (scaled.length < request.templates.length) {
      throw VisionException(
        'Solo se detectaron ${scaled.length} moldes validos; se esperaban ${request.templates.length}. Usa una foto cenital con mayor contraste.',
      );
    }

    final matches = _matchTemplates(request.templates, scaled);
    final averageScore =
        matches.fold<double>(0, (total, match) => total + match.score) /
        matches.length;
    final confidence = ((sheetFound ? 0.93 : 0.72) - averageScore * 0.06)
        .clamp(0.55, 0.96)
        .toDouble();
    final warnings = <String>[
      if (!sheetFound)
        'No se encontro el borde completo de la lamina; la escala usa el encuadre.',
      if (averageScore > 1.2)
        'Algunas proporciones difieren del trabajo y requieren revision manual.',
      'Confirma la escala y ajusta los vertices antes de optimizar.',
    ];

    return VectorizationResult(
      contours: [for (final match in matches) match.candidate.metric],
      confidence: confidence,
      requiresReview: true,
      templateIds: [for (final match in matches) match.template.id],
      sourceContours: [for (final match in matches) match.candidate.source],
      sourceWidthPx: sourceWidth,
      sourceHeightPx: sourceHeight,
      warnings: warnings,
    );
  }

  List<_ContourCandidate> _deduplicate(List<_ContourCandidate> candidates) {
    final sorted = [...candidates]
      ..sort((a, b) => b.polygon.area.compareTo(a.polygon.area));
    final unique = <_ContourCandidate>[];
    for (final candidate in sorted) {
      if (unique.any((other) => candidate.isSameObject(other))) continue;
      unique.add(candidate);
    }
    return unique;
  }

  List<_TemplateMatch> _matchTemplates(
    List<VectorizationTemplate> templates,
    List<_ScaledCandidate> candidates,
  ) {
    final remaining = [...candidates];
    final orderedTemplates = [...templates]
      ..sort(
        (a, b) => (b.widthMm * b.heightMm).compareTo(a.widthMm * a.heightMm),
      );
    final byId = <String, _TemplateMatch>{};
    for (final template in orderedTemplates) {
      remaining.sort(
        (a, b) => _matchScore(
          template,
          a.metric,
        ).compareTo(_matchScore(template, b.metric)),
      );
      final selected = remaining.removeAt(0);
      byId[template.id] = _TemplateMatch(
        template: template,
        candidate: selected,
        score: _matchScore(template, selected.metric),
      );
    }
    return [for (final template in templates) byId[template.id]!];
  }

  double _matchScore(VectorizationTemplate template, Polygon2D polygon) {
    final targetSides = [template.widthMm, template.heightMm]..sort();
    final candidateSides = [polygon.bounds.width, polygon.bounds.height]
      ..sort();
    final sideScore =
        (math.log(candidateSides[0] / targetSides[0])).abs() +
        (math.log(candidateSides[1] / targetSides[1])).abs();
    final areaScore = (math.log(
      polygon.area / (template.widthMm * template.heightMm),
    )).abs();
    return sideScore + areaScore * 0.35;
  }

  void _validate(VectorizationRequest request) {
    if (request.imagePath.trim().isEmpty && request.imageBytes == null) {
      throw const VisionException('Selecciona una captura para continuar.');
    }
    if (request.referenceLengthMm <= 0 ||
        request.sheetWidthMm <= 0 ||
        request.sheetHeightMm <= 0) {
      throw const VisionException('La referencia de escala no es valida.');
    }
    if (request.templates.isEmpty) {
      throw const VisionException('El trabajo no contiene moldes esperados.');
    }
  }

  static Future<Uint8List> _loadAsset(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

final class _ContourCandidate {
  const _ContourCandidate(this.polygon);

  final Polygon2D polygon;

  Bounds2D get bounds => polygon.bounds;

  bool isSameObject(_ContourCandidate other) {
    final a = bounds;
    final b = other.bounds;
    final toleranceX = math.max(5, math.min(a.width, b.width) * 0.06);
    final toleranceY = math.max(5, math.min(a.height, b.height) * 0.06);
    return (a.minX - b.minX).abs() <= toleranceX &&
        (a.minY - b.minY).abs() <= toleranceY &&
        (a.maxX - b.maxX).abs() <= toleranceX &&
        (a.maxY - b.maxY).abs() <= toleranceY;
  }

  _ScaledCandidate scaled({
    required Bounds2D sheetBounds,
    required double sheetWidthMm,
    required double sheetHeightMm,
  }) {
    final scaleX = sheetWidthMm / sheetBounds.width;
    final scaleY = sheetHeightMm / sheetBounds.height;
    final metric = Polygon2D([
      for (final point in polygon.points)
        Point2D(
          (point.x - sheetBounds.minX) * scaleX,
          (point.y - sheetBounds.minY) * scaleY,
        ),
    ]).normalized;
    return _ScaledCandidate(source: polygon, metric: metric);
  }
}

final class _ScaledCandidate {
  const _ScaledCandidate({required this.source, required this.metric});

  final Polygon2D source;
  final Polygon2D metric;
}

final class _TemplateMatch {
  const _TemplateMatch({
    required this.template,
    required this.candidate,
    required this.score,
  });

  final VectorizationTemplate template;
  final _ScaledCandidate candidate;
  final double score;
}
