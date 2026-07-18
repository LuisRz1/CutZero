import 'package:cutzero/core/domain/geometry.dart';
import 'package:cutzero/core/infrastructure/database/app_database.dart';
import 'package:cutzero/features/agent/application/agent_coordinator.dart';
import 'package:cutzero/features/agent/domain/agent_models.dart';
import 'package:cutzero/features/agent/infrastructure/cutzero_tools.dart';
import 'package:cutzero/features/agent/infrastructure/fixture_agent_gateway.dart';
import 'package:cutzero/features/agent/infrastructure/fixture_vision_adapter.dart';
import 'package:cutzero/features/cutting_job/application/ports.dart';
import 'package:cutzero/features/cutting_job/domain/models.dart';
import 'package:cutzero/features/cutting_job/infrastructure/demo_fixture.dart';
import 'package:cutzero/features/cutting_job/infrastructure/persistence/cutting_job_mapper.dart';
import 'package:cutzero/features/cutting_job/infrastructure/persistence/drift_repositories.dart';
import 'package:cutzero/features/optimization/application/run_optimization.dart';
import 'package:cutzero/features/optimization/infrastructure/clipper_geometry.dart';
import 'package:cutzero/features/optimization/infrastructure/deterministic_nesting_solver.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftToolInvocationRepository invocationRepository;
  late DriftRemnantRepository remnantRepository;
  const mapper = CuttingJobMapper();

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    invocationRepository = DriftToolInvocationRepository(database, mapper);
    remnantRepository = DriftRemnantRepository(database, mapper);
  });

  tearDown(() => database.close());

  test('runs the complete safe tool chain and persists its trace', () async {
    final job = DemoFixture.createJob();
    await remnantRepository.save(
      Remnant(
        id: 'eva-compatible',
        name: 'Retal EVA celeste',
        kind: MaterialKind.eva,
        color: 'Celeste',
        thicknessMm: 2,
        polygon: Polygon2D.rectangle(width: 300, height: 200),
        location: 'R-01',
      ),
    );
    const geometry = ClipperGeometry();
    const optimization = RunOptimization(
      solver: DeterministicNestingSolver(geometry),
      validator: ClipperLayoutValidator(geometry),
    );
    final coordinator = AgentCoordinator(
      gateway: const FixtureAgentGateway(),
      registry: AgentToolRegistry([
        SearchRemnantsTool(remnantRepository),
        const VectorizeCaptureTool(FixtureVisionAdapter()),
        const ValidateGeometryTool(),
        const RunNestingTool(optimization),
        const CalculateCostTool(),
      ]),
      invocations: invocationRepository,
    );

    final events = await coordinator
        .run(AgentRequest(instruction: job.instruction, job: job))
        .toList();
    final trace = await invocationRepository.watchForJob(job.id).first;

    expect(events.last.type, AgentEventType.completed);
    expect(trace.map((invocation) => invocation.toolName), [
      'search_remnants',
      'vectorize_capture',
      'validate_geometry',
      'run_nesting',
      'calculate_cost',
    ]);
    expect(
      trace.every(
        (invocation) => invocation.status == ToolInvocationStatus.success,
      ),
      isTrue,
    );
    expect(
      events.where((event) => event.type == AgentEventType.toolCompleted),
      hasLength(5),
    );
  });

  test('rejects a model call outside the whitelist and records it', () async {
    final job = DemoFixture.createJob();
    final coordinator = AgentCoordinator(
      gateway: const _SingleCallGateway(AgentToolCall(name: 'delete_all_jobs')),
      registry: AgentToolRegistry(const []),
      invocations: invocationRepository,
    );

    final events = await coordinator
        .run(AgentRequest(instruction: job.instruction, job: job))
        .toList();
    final trace = await invocationRepository.watchForJob(job.id).first;

    expect(events.last.type, AgentEventType.failed);
    expect(trace, hasLength(1));
    expect(trace.single.status, ToolInvocationStatus.rejected);
    expect(trace.single.summary, contains('no permitida'));
  });

  test('rejects unexpected arguments before a handler runs', () async {
    final job = DemoFixture.createJob();
    final coordinator = AgentCoordinator(
      gateway: const _SingleCallGateway(
        AgentToolCall(
          name: 'validate_geometry',
          arguments: {'shellCommand': 'ignored'},
        ),
      ),
      registry: AgentToolRegistry(const [ValidateGeometryTool()]),
      invocations: invocationRepository,
    );

    final events = await coordinator
        .run(AgentRequest(instruction: job.instruction, job: job))
        .toList();
    final trace = await invocationRepository.watchForJob(job.id).first;

    expect(events.last.type, AgentEventType.failed);
    expect(trace.single.status, ToolInvocationStatus.rejected);
    expect(trace.single.summary, contains('Argumento no permitido'));
  });
}

final class _SingleCallGateway implements AgentModelGateway {
  const _SingleCallGateway(this.call);

  final AgentToolCall call;

  @override
  Future<AgentModelSession> open({
    required AgentRequest request,
    required List<AgentToolDefinition> tools,
  }) async => _SingleCallSession(call);
}

final class _SingleCallSession implements AgentModelSession {
  const _SingleCallSession(this.call);

  final AgentToolCall call;

  @override
  Future<AgentModelTurn> start() async => AgentModelTurn(calls: [call]);

  @override
  Future<AgentModelTurn> respondToTools(List<AgentToolResult> results) async =>
      const AgentModelTurn(isComplete: true);

  @override
  Future<void> close() async {}
}
