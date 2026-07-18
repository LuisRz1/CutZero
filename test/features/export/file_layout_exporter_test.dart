import 'dart:io';
import 'dart:typed_data';

import 'package:cutzero/features/cutting_job/application/ports.dart';
import 'package:cutzero/features/cutting_job/application/demo_fixture.dart';
import 'package:cutzero/features/export/infrastructure/file_layout_exporter.dart';
import 'package:cutzero/features/optimization/application/run_optimization.dart';
import 'package:cutzero/features/optimization/infrastructure/clipper_geometry.dart';
import 'package:cutzero/features/optimization/infrastructure/deterministic_nesting_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory output;

  setUp(() async {
    output = await Directory.systemTemp.createTemp('cutzero-export-test-');
  });

  tearDown(() => output.delete(recursive: true));

  test('exports valid SVG and PDF files', () async {
    final job = DemoFixture.createJob();
    const geometry = ClipperGeometry();
    const optimization = RunOptimization(
      solver: DeterministicNestingSolver(geometry),
      validator: ClipperLayoutValidator(geometry),
    );
    final layout = (await optimization(job)).materialEfficient;
    final exporter = FileLayoutExporter(
      directoryProvider: () async => output,
      fontDataProvider: _loadFont,
    );

    final svg = await exporter.export(
      LayoutExportRequest(
        job: job,
        layout: layout,
        format: LayoutExportFormat.svg,
      ),
    );
    final pdf = await exporter.export(
      LayoutExportRequest(
        job: job,
        layout: layout,
        format: LayoutExportFormat.pdf,
      ),
    );

    expect(File(svg.path).readAsStringSync(), contains('<polygon'));
    expect(File(svg.path).readAsStringSync(), contains(job.id));
    expect(File(pdf.path).readAsBytesSync().take(4), [0x25, 0x50, 0x44, 0x46]);
    expect(pdf.bytes, greaterThan(1000));
  });
}

Future<ByteData> _loadFont() async => ByteData.sublistView(
  await File('assets/fonts/NotoSans-Variable.ttf').readAsBytes(),
);
