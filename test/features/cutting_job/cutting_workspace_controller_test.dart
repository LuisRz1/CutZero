import 'package:cutzero/app/providers.dart';
import 'package:cutzero/core/infrastructure/database/app_database.dart';
import 'package:cutzero/features/cutting_job/application/ports.dart';
import 'package:cutzero/features/cutting_job/domain/models.dart';
import 'package:cutzero/features/cutting_job/presentation/cutting_job_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('coordinates the complete local-first workflow', () async {
    final controller = container.read(cuttingWorkspaceProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await controller.analyzeFixture();
    expect(container.read(cuttingWorkspaceProvider).vectorization, isNotNull);
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
