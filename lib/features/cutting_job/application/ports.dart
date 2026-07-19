import 'dart:typed_data';

import '../../../core/domain/geometry.dart';
import '../domain/models.dart';

abstract interface class NestingSolver {
  Future<NestingLayout> solve({
    required CuttingJob job,
    required OptimizationObjective objective,
    int seed = 42,
  });
}

abstract interface class LayoutValidator {
  LayoutValidation validate(CuttingJob job, NestingLayout layout);
}

final class LayoutValidation {
  const LayoutValidation({required this.isValid, this.errors = const []});

  final bool isValid;
  final List<String> errors;
}

abstract interface class CuttingJobRepository {
  Stream<List<CuttingJob>> watchAll();
  Future<CuttingJob?> findById(String id);
  Future<void> save(CuttingJob job);
}

abstract interface class RemnantRepository {
  Stream<List<Remnant>> watchAll();
  Future<List<Remnant>> findCompatible({
    required MaterialKind kind,
    required String color,
    required double minAreaMm2,
  });
  Future<void> save(Remnant remnant);
}

abstract interface class ToolInvocationRepository {
  Stream<List<ToolInvocation>> watchForJob(String jobId);
  Future<void> append(ToolInvocation invocation);
}

enum AgentEventType { message, toolStarted, toolCompleted, completed, failed }

final class AgentRequest {
  const AgentRequest({required this.instruction, required this.job});

  final String instruction;
  final CuttingJob job;
}

final class AgentEvent {
  const AgentEvent({
    required this.type,
    required this.message,
    this.tool,
    this.payload = const {},
  });

  final AgentEventType type;
  final String message;
  final String? tool;
  final Map<String, Object?> payload;
}

abstract interface class AgentPort {
  Stream<AgentEvent> run(AgentRequest request);
}

final class VectorizationRequest {
  const VectorizationRequest({
    required this.imagePath,
    required this.referenceLengthMm,
    this.imageBytes,
    this.sheetWidthMm = 0,
    this.sheetHeightMm = 0,
    this.templates = const [],
  });

  final String imagePath;
  final double referenceLengthMm;
  final Uint8List? imageBytes;
  final double sheetWidthMm;
  final double sheetHeightMm;
  final List<VectorizationTemplate> templates;
}

final class VectorizationTemplate {
  const VectorizationTemplate({
    required this.id,
    required this.widthMm,
    required this.heightMm,
  });

  final String id;
  final double widthMm;
  final double heightMm;
}

final class VectorizationResult {
  const VectorizationResult({
    required this.contours,
    required this.confidence,
    required this.requiresReview,
    this.templateIds = const [],
    this.sourceContours = const [],
    this.sourceWidthPx = 0,
    this.sourceHeightPx = 0,
    this.warnings = const [],
  });

  final List<Polygon2D> contours;
  final double confidence;
  final bool requiresReview;
  final List<String> templateIds;
  final List<Polygon2D> sourceContours;
  final double sourceWidthPx;
  final double sourceHeightPx;
  final List<String> warnings;

  VectorizationResult copyWith({
    List<Polygon2D>? contours,
    double? confidence,
    bool? requiresReview,
    List<String>? templateIds,
    List<Polygon2D>? sourceContours,
    double? sourceWidthPx,
    double? sourceHeightPx,
    List<String>? warnings,
  }) => VectorizationResult(
    contours: contours ?? this.contours,
    confidence: confidence ?? this.confidence,
    requiresReview: requiresReview ?? this.requiresReview,
    templateIds: templateIds ?? this.templateIds,
    sourceContours: sourceContours ?? this.sourceContours,
    sourceWidthPx: sourceWidthPx ?? this.sourceWidthPx,
    sourceHeightPx: sourceHeightPx ?? this.sourceHeightPx,
    warnings: warnings ?? this.warnings,
  );
}

final class VisionException implements Exception {
  const VisionException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class VisionPort {
  Future<VectorizationResult> vectorize(VectorizationRequest request);
}

enum ImageCaptureSource { camera, gallery }

final class CapturedImage {
  const CapturedImage({required this.path, required this.bytes});

  final String path;
  final Uint8List bytes;
}

abstract interface class ImageAcquisitionPort {
  Future<CapturedImage?> pick(ImageCaptureSource source);
}

enum LocalModelState { notInstalled, downloading, ready, failed }

final class LocalModelStatus {
  const LocalModelStatus({
    required this.state,
    this.progress = 0,
    this.message = '',
  });

  final LocalModelState state;
  final int progress;
  final String message;
}

abstract interface class LocalModelPort {
  Future<bool> isInstalled();
  Stream<LocalModelStatus> install();
  Future<void> uninstall();
}

enum LayoutExportFormat { svg, pdf }

final class LayoutExportRequest {
  const LayoutExportRequest({
    required this.job,
    required this.layout,
    required this.format,
  });

  final CuttingJob job;
  final NestingLayout layout;
  final LayoutExportFormat format;
}

final class ExportedLayout {
  const ExportedLayout({
    required this.path,
    required this.format,
    required this.bytes,
  });

  final String path;
  final LayoutExportFormat format;
  final int bytes;
}

abstract interface class LayoutExporter {
  Future<ExportedLayout> export(LayoutExportRequest request);
}
