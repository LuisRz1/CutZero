import 'dart:io';
import 'dart:typed_data';

import 'package:cutzero/app/providers.dart';
import 'package:cutzero/core/infrastructure/database/app_database.dart';
import 'package:cutzero/features/cutting_job/application/ports.dart';
import 'package:cutzero/features/cutting_job/domain/models.dart';
import 'package:cutzero/features/cutting_job/presentation/cutting_job_controller.dart';
import 'package:cutzero/features/export/infrastructure/file_layout_exporter.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late Directory exportDirectory;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    exportDirectory = await Directory.systemTemp.createTemp('cutzero-flow-');
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        imageAcquisitionProvider.overrideWithValue(
          const _TestImageAcquisition(),
        ),
        layoutExporterProvider.overrideWithValue(
          FileLayoutExporter(
            directoryProvider: () async => exportDirectory,
            fontDataProvider: _loadFont,
          ),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
    await exportDirectory.delete(recursive: true);
  });

  test('coordinates the complete local-first workflow', () async {
    final controller = container.read(cuttingWorkspaceProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.capture(ImageCaptureSource.gallery);
    expect(container.read(cuttingWorkspaceProvider).vectorization, isNotNull);
    expect(
      container.read(cuttingWorkspaceProvider).capturePath,
      'captured-test.png',
    );
    expect(
      container.read(cuttingWorkspaceProvider).job.stage,
      CuttingJobStage.captured,
    );

    await controller.confirmReview();
    expect(
      container.read(cuttingWorkspaceProvider).job.stage,
      CuttingJobStage.reviewed,
    );

    await controller.optimize();
    final optimized = container.read(cuttingWorkspaceProvider);
    expect(optimized.job.stage, CuttingJobStage.optimized);
    expect(optimized.job.layouts, hasLength(2));
    expect(
      optimized.job.layouts.every(
        (layout) => layout.placements.length == optimized.job.instances.length,
      ),
      isTrue,
    );

    await controller.export(LayoutExportFormat.svg);
    final svg = container.read(cuttingWorkspaceProvider).lastExport;
    expect(svg?.format, LayoutExportFormat.svg);
    expect(await File(svg!.path).exists(), isTrue);

    await controller.export(LayoutExportFormat.pdf);
    final pdf = container.read(cuttingWorkspaceProvider).lastExport;
    expect(pdf?.format, LayoutExportFormat.pdf);
    expect(await File(pdf!.path).exists(), isTrue);
    expect(
      container.read(cuttingWorkspaceProvider).job.stage,
      CuttingJobStage.exported,
    );

    await controller.saveRemnant();
    expect(container.read(cuttingWorkspaceProvider).remnantSaved, isTrue);
    final remnants = await container
        .read(remnantRepositoryProvider)
        .watchAll()
        .first;
    expect(remnants, hasLength(1));

    await controller.runAgent(useGemma: false);
    final completed = container.read(cuttingWorkspaceProvider);
    expect(completed.task, WorkspaceTask.none);
    expect(completed.error, isNull);
    expect(completed.agentEvents.last.type, AgentEventType.completed);
    expect(completed.job.layouts, hasLength(2));

    final trace = await container
        .read(toolInvocationRepositoryProvider)
        .watchForJob(completed.job.id)
        .first;
    expect(trace, hasLength(5));
    expect(
      trace.every((item) => item.status == ToolInvocationStatus.success),
      isTrue,
    );
  });

  test('editing a reviewed job invalidates stale layouts safely', () async {
    final controller = container.read(cuttingWorkspaceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.analyzeFixture();
    await controller.confirmReview();
    await controller.optimize();

    await controller.updateGap(12);
    final edited = container.read(cuttingWorkspaceProvider);

    expect(edited.job.gapMm, 12);
    expect(edited.job.stage, CuttingJobStage.captured);
    expect(edited.job.layouts, isEmpty);
    expect(edited.lastExport, isNull);
  });
}

final class _TestImageAcquisition implements ImageAcquisitionPort {
  const _TestImageAcquisition();

  @override
  Future<CapturedImage?> pick(ImageCaptureSource source) async => CapturedImage(
    path: 'captured-test.png',
    bytes: Uint8List.fromList(const [1, 2, 3]),
  );
}

Future<ByteData> _loadFont() async => ByteData.sublistView(
  await File('assets/fonts/NotoSans-Variable.ttf').readAsBytes(),
);
