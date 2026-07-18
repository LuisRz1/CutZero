import 'package:flutter_gemma/flutter_gemma.dart';

import '../../cutting_job/application/ports.dart';
import '../domain/agent_models.dart';
import 'gemma_model_manager.dart';

final class GemmaAgentGateway implements AgentModelGateway {
  const GemmaAgentGateway(this.modelManager);

  final GemmaModelManager modelManager;

  @override
  Future<AgentModelSession> open({
    required AgentRequest request,
    required List<AgentToolDefinition> tools,
  }) async {
    await modelManager.initialize();
    if (!await modelManager.isInstalled()) {
      throw StateError('Gemma 4 no esta instalado en este dispositivo.');
    }
    final model = await FlutterGemma.getActiveModel(
      maxTokens: 4096,
      preferredBackend: PreferredBackend.cpu,
      supportImage: true,
      maxNumImages: 1,
      maxConcurrentSessions: 1,
    );
    final chat = await model.createChat(
      temperature: 0.2,
      topK: 8,
      topP: 0.9,
      maxOutputTokens: 384,
      supportsFunctionCalls: true,
      modelType: ModelType.gemma4,
      tools: tools.map(_toGemmaTool).toList(growable: false),
      systemInstruction:
          'Eres el agente local de CutZero. Usa solo las herramientas declaradas, '
          'en orden seguro, y responde en espanol claro. Nunca inventes medidas, '
          'costos ni resultados del optimizador.',
    );
    return _GemmaAgentSession(request: request, model: model, chat: chat);
  }

  Tool _toGemmaTool(AgentToolDefinition definition) {
    final properties = <String, Object?>{};
    for (final entry in {
      ...definition.requiredArguments,
      ...definition.optionalArguments,
    }.entries) {
      properties[entry.key] = {
        'type': switch (entry.value) {
          AgentArgumentKind.string => 'string',
          AgentArgumentKind.number => 'number',
          AgentArgumentKind.boolean => 'boolean',
        },
      };
    }
    return Tool(
      name: definition.name,
      description: definition.description,
      parameters: {
        'type': 'object',
        'properties': properties,
        'required': definition.requiredArguments.keys.toList(growable: false),
      },
    );
  }
}

final class _GemmaAgentSession implements AgentModelSession {
  _GemmaAgentSession({
    required this.request,
    required this.model,
    required this.chat,
  });

  final AgentRequest request;
  final InferenceModel model;
  final InferenceChat chat;

  @override
  Future<AgentModelTurn> start() async {
    await chat.addQuery(Message.text(text: _promptFor(request), isUser: true));
    return _generateTurn();
  }

  @override
  Future<AgentModelTurn> respondToTools(List<AgentToolResult> results) async {
    for (final result in results) {
      await chat.addQuery(
        Message.toolResponse(
          toolName: result.toolName,
          response: {'summary': result.summary, 'payload': result.payload},
        ),
      );
    }
    return _generateTurn();
  }

  Future<AgentModelTurn> _generateTurn() async {
    final response = await chat.generateChatResponse();
    return switch (response) {
      TextResponse(:final token) => AgentModelTurn(
        message: token,
        isComplete: true,
      ),
      FunctionCallResponse(:final name, :final args) => AgentModelTurn(
        calls: [
          AgentToolCall(name: name, arguments: Map<String, Object?>.from(args)),
        ],
      ),
      ParallelFunctionCallResponse(:final calls) => AgentModelTurn(
        calls: [
          for (final call in calls)
            AgentToolCall(
              name: call.name,
              arguments: Map<String, Object?>.from(call.args),
            ),
        ],
      ),
      ThinkingResponse(:final content) => AgentModelTurn(message: content),
    };
  }

  String _promptFor(AgentRequest request) =>
      '${request.instruction}\nTrabajo: ${request.job.name}. '
      'Material: ${request.job.material.name}. '
      'Piezas: ${request.job.instances.length}. '
      'Separacion: ${request.job.gapMm} mm. '
      'Busca retales, valida la captura, ejecuta el nesting y calcula el costo.';

  @override
  Future<void> close() => model.close();
}
