import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/infrastructure/database/app_database.dart';
import '../features/agent/application/agent_coordinator.dart';
import '../features/agent/infrastructure/cutzero_tools.dart';
import '../features/agent/infrastructure/fixture_agent_gateway.dart';
import '../features/agent/infrastructure/fixture_vision_adapter.dart';
import '../features/agent/infrastructure/gemma_agent_gateway.dart';
import '../features/agent/infrastructure/gemma_model_manager.dart';
import '../features/cutting_job/application/ports.dart';
import '../features/cutting_job/domain/models.dart';
import '../features/cutting_job/infrastructure/persistence/cutting_job_mapper.dart';
import '../features/cutting_job/infrastructure/persistence/drift_repositories.dart';
import '../features/cutting_job/infrastructure/image_picker_adapter.dart';
import '../features/export/infrastructure/file_layout_exporter.dart';
import '../features/inventory/application/create_remnant.dart';
import '../features/optimization/application/run_optimization.dart';
import '../features/optimization/infrastructure/clipper_geometry.dart';
import '../features/optimization/infrastructure/deterministic_nesting_solver.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final cuttingJobMapperProvider = Provider<CuttingJobMapper>(
  (ref) => const CuttingJobMapper(),
);

final cuttingJobRepositoryProvider = Provider<CuttingJobRepository>(
  (ref) => DriftCuttingJobRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(cuttingJobMapperProvider),
  ),
);

final remnantRepositoryProvider = Provider<RemnantRepository>(
  (ref) => DriftRemnantRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(cuttingJobMapperProvider),
  ),
);

final toolInvocationRepositoryProvider = Provider<ToolInvocationRepository>(
  (ref) => DriftToolInvocationRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(cuttingJobMapperProvider),
  ),
);

final remnantsProvider = StreamProvider<List<Remnant>>(
  (ref) => ref.watch(remnantRepositoryProvider).watchAll(),
);

final toolInvocationsProvider =
    StreamProvider.family<List<ToolInvocation>, String>(
      (ref, jobId) =>
          ref.watch(toolInvocationRepositoryProvider).watchForJob(jobId),
    );

final visionProvider = Provider<VisionPort>(
  (ref) => const FixtureVisionAdapter(),
);

final imageAcquisitionProvider = Provider<ImageAcquisitionPort>(
  (ref) => ImagePickerAdapter(),
);

final runOptimizationProvider = Provider<RunOptimization>((ref) {
  const geometry = ClipperGeometry();
  return RunOptimization(
    solver: const DeterministicNestingSolver(geometry),
    validator: const ClipperLayoutValidator(geometry),
  );
});

final layoutExporterProvider = Provider<LayoutExporter>(
  (ref) => FileLayoutExporter(),
);

final createRemnantProvider = Provider<CreateRemnant>(
  (ref) => const CreateRemnant(),
);

final gemmaModelManagerProvider = Provider<GemmaModelManager>(
  (ref) => GemmaModelManager(
    huggingFaceToken: const String.fromEnvironment('HF_TOKEN').trim().isEmpty
        ? null
        : const String.fromEnvironment('HF_TOKEN'),
  ),
);

final localModelProvider = Provider<LocalModelPort>(
  (ref) => ref.watch(gemmaModelManagerProvider),
);

final agentToolRegistryProvider = Provider<AgentToolRegistry>(
  (ref) => AgentToolRegistry([
    SearchRemnantsTool(ref.watch(remnantRepositoryProvider)),
    VectorizeCaptureTool(ref.watch(visionProvider)),
    const ValidateGeometryTool(),
    RunNestingTool(ref.watch(runOptimizationProvider)),
    const CalculateCostTool(),
  ]),
);

final fixtureAgentProvider = Provider<AgentPort>(
  (ref) => AgentCoordinator(
    gateway: const FixtureAgentGateway(),
    registry: ref.watch(agentToolRegistryProvider),
    invocations: ref.watch(toolInvocationRepositoryProvider),
  ),
);

final gemmaAgentProvider = Provider<AgentPort>(
  (ref) => AgentCoordinator(
    gateway: GemmaAgentGateway(ref.watch(gemmaModelManagerProvider)),
    registry: ref.watch(agentToolRegistryProvider),
    invocations: ref.watch(toolInvocationRepositoryProvider),
  ),
);
