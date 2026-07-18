import '../../cutting_job/application/ports.dart';
import '../domain/agent_models.dart';

final class FixtureAgentGateway implements AgentModelGateway {
  const FixtureAgentGateway();

  @override
  Future<AgentModelSession> open({
    required AgentRequest request,
    required List<AgentToolDefinition> tools,
  }) async => _FixtureAgentSession(request);
}

final class _FixtureAgentSession implements AgentModelSession {
  _FixtureAgentSession(this.request);

  final AgentRequest request;
  var _index = 0;

  late final List<AgentToolCall> _calls = [
    const AgentToolCall(
      name: 'search_remnants',
      arguments: {'minAreaMm2': 12000},
    ),
    const AgentToolCall(
      name: 'vectorize_capture',
      arguments: {
        'imagePath': 'assets/fixtures/eva_bag_manual.png',
        'referenceLengthMm': 100,
      },
    ),
    const AgentToolCall(name: 'validate_geometry'),
    const AgentToolCall(name: 'run_nesting'),
    const AgentToolCall(name: 'calculate_cost'),
  ];

  @override
  Future<AgentModelTurn> start() async => AgentModelTurn(
    message: 'Analizare el material, los moldes y el inventario local.',
    calls: [_calls.first],
  );

  @override
  Future<AgentModelTurn> respondToTools(List<AgentToolResult> results) async {
    _index++;
    if (_index >= _calls.length) {
      return const AgentModelTurn(
        message: 'Prepare dos alternativas de corte validas para comparar.',
        isComplete: true,
      );
    }
    return AgentModelTurn(calls: [_calls[_index]]);
  }

  @override
  Future<void> close() async {}
}
