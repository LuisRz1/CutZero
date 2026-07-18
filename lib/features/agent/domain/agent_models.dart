import '../../cutting_job/application/ports.dart';

enum AgentArgumentKind { string, number, boolean }

final class AgentToolDefinition {
  const AgentToolDefinition({
    required this.name,
    required this.description,
    this.requiredArguments = const {},
    this.optionalArguments = const {},
  });

  final String name;
  final String description;
  final Map<String, AgentArgumentKind> requiredArguments;
  final Map<String, AgentArgumentKind> optionalArguments;
}

final class AgentToolCall {
  const AgentToolCall({required this.name, this.arguments = const {}});

  final String name;
  final Map<String, Object?> arguments;
}

final class AgentToolResult {
  const AgentToolResult({
    required this.toolName,
    required this.summary,
    this.payload = const {},
  });

  final String toolName;
  final String summary;
  final Map<String, Object?> payload;
}

final class AgentModelTurn {
  const AgentModelTurn({
    this.message = '',
    this.calls = const [],
    this.isComplete = false,
  });

  final String message;
  final List<AgentToolCall> calls;
  final bool isComplete;
}

abstract interface class AgentModelSession {
  Future<AgentModelTurn> start();
  Future<AgentModelTurn> respondToTools(List<AgentToolResult> results);
  Future<void> close();
}

abstract interface class AgentModelGateway {
  Future<AgentModelSession> open({
    required AgentRequest request,
    required List<AgentToolDefinition> tools,
  });
}
