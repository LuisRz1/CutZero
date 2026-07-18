import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/domain/geometry.dart';
import '../../cutting_job/application/ports.dart';
import '../../cutting_job/domain/models.dart';

typedef ExportDirectoryProvider = Future<Directory> Function();
typedef PdfFontDataProvider = Future<ByteData> Function();

final class FileLayoutExporter implements LayoutExporter {
  FileLayoutExporter({
    ExportDirectoryProvider? directoryProvider,
    PdfFontDataProvider? fontDataProvider,
  }) : _directoryProvider =
           directoryProvider ?? getApplicationDocumentsDirectory,
       _fontDataProvider =
           fontDataProvider ??
           (() => rootBundle.load('assets/fonts/NotoSans-Variable.ttf'));

  final ExportDirectoryProvider _directoryProvider;
  final PdfFontDataProvider _fontDataProvider;
  Future<pw.Font>? _font;

  @override
  Future<ExportedLayout> export(LayoutExportRequest request) async {
    if (request.layout.placements.length != request.job.instances.length) {
      throw StateError(
        'El layout debe contener todas las piezas antes de exportar.',
      );
    }
    final directory = await _directoryProvider();
    final exportDirectory = Directory(path.join(directory.path, 'CutZero'));
    await exportDirectory.create(recursive: true);
    final baseName = _safeFileName(
      '${request.job.name}-${request.layout.objective.name}',
    );

    return switch (request.format) {
      LayoutExportFormat.svg => _writeSvg(
        request,
        path.join(exportDirectory.path, '$baseName.svg'),
      ),
      LayoutExportFormat.pdf => _writePdf(
        request,
        path.join(exportDirectory.path, '$baseName.pdf'),
      ),
    };
  }

  Future<ExportedLayout> _writeSvg(
    LayoutExportRequest request,
    String outputPath,
  ) async {
    final bytes = utf8.encode(_buildSvg(request.job, request.layout));
    await File(outputPath).writeAsBytes(bytes, flush: true);
    return ExportedLayout(
      path: outputPath,
      format: LayoutExportFormat.svg,
      bytes: bytes.length,
    );
  }

  Future<ExportedLayout> _writePdf(
    LayoutExportRequest request,
    String outputPath,
  ) async {
    final job = request.job;
    final layout = request.layout;
    final font = await _loadFont();
    final document = pw.Document(
      title: 'CutZero - ${job.name}',
      author: 'CutZero',
    );
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              job.name,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${job.material.name} | ${job.instances.length} piezas | '
              '${layout.metrics.utilizationPercent.toStringAsFixed(1)}% de uso',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 12),
            pw.Expanded(
              child: pw.SvgImage(
                svg: _buildSvg(
                  job,
                  layout,
                  includeMetadata: false,
                  includeLabels: false,
                ),
                fit: pw.BoxFit.contain,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Separacion: ${job.gapMm.toStringAsFixed(0)} mm | '
              'Costo estimado de desperdicio: '
              '${layout.metrics.estimatedWasteCost.toStringAsFixed(2)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ),
    );
    final bytes = await document.save();
    await File(outputPath).writeAsBytes(bytes, flush: true);
    return ExportedLayout(
      path: outputPath,
      format: LayoutExportFormat.pdf,
      bytes: bytes.length,
    );
  }

  Future<pw.Font> _loadFont() =>
      _font ??= _fontDataProvider().then(pw.Font.ttf);

  String _buildSvg(
    CuttingJob job,
    NestingLayout layout, {
    bool includeMetadata = true,
    bool includeLabels = true,
  }) {
    final width = job.material.widthMm;
    final height = job.material.heightMm;
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" width="${width}mm" '
        'height="${height}mm" viewBox="0 0 $width $height">',
      )
      ..writeln('<rect width="$width" height="$height" fill="#EAF8FC"/>')
      ..writeln(
        '<rect x="1" y="1" width="${width - 2}" height="${height - 2}" '
        'fill="none" stroke="#167EA3" stroke-width="2"/>',
      );
    if (includeMetadata) {
      buffer.writeln(
        '<metadata>${const HtmlEscape().convert(jsonEncode({'jobId': job.id, 'layoutId': layout.id, 'objective': layout.objective.name, 'gapMm': job.gapMm}))}</metadata>',
      );
    }
    for (final defect in job.material.defects) {
      buffer.writeln(
        '<polygon points="${_points(defect.polygon)}" '
        'fill="#F5A4A4" fill-opacity="0.65" stroke="#C94141" '
        'stroke-width="2"/>',
      );
    }
    for (var index = 0; index < layout.placements.length; index++) {
      final placement = layout.placements[index];
      final bounds = placement.polygon.bounds;
      final fill = index.isEven ? '#67C7E5' : '#7BD3B1';
      buffer.writeln(
        '<polygon id="${const HtmlEscape().convert(placement.instanceId)}" '
        'points="${_points(placement.polygon)}" fill="$fill" '
        'stroke="#114B63" stroke-width="2"/>',
      );
      if (includeLabels) {
        buffer.writeln(
          '<text x="${bounds.minX + 8}" y="${bounds.minY + 18}" '
          'font-family="Arial, sans-serif" font-size="12" fill="#0B3445">'
          '${const HtmlEscape().convert(placement.name)}</text>',
        );
      }
    }
    buffer.writeln('</svg>');
    return buffer.toString();
  }

  String _points(Polygon2D polygon) => polygon.points
      .map(
        (point) =>
            '${point.x.toStringAsFixed(3)},${point.y.toStringAsFixed(3)}',
      )
      .join(' ');

  String _safeFileName(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized.isEmpty ? 'cutzero-layout' : normalized;
  }
}
