import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../cutting_job/application/ports.dart';
import '../../cutting_job/domain/models.dart';
import '../../optimization/application/run_optimization.dart';
import '../domain/agent_models.dart';

final class AgentRunContext {
  AgentRunContext(this.job);

  final CuttingJob job;
  VectorizationResult? vectorization;
  OptimizationResult? optimization;
}

abstract interface class AgentToolHandler {
  AgentToolDefinition get definition;

  Future<AgentToolResult> execute(
    AgentRunContext context,
    Map<String, Object?> arguments,
  );
}

final class AgentToolRejected implements Exception {
  const AgentToolRejected(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AgentToolRegistry {
  AgentToolRegistry(Iterable<AgentToolHandler> handlers)
    : _handlers = {
        for (final handler in handlers) handler.definition.name: handler,
      } {
    if (_handlers.length != handlers.length) {
      throw ArgumentError('Los nombres de herramientas deben ser unicos.');
    }
  }

  final Map<String, AgentToolHandler> _handlers;

  List<AgentToolDefinition> get definitions => _handlers.values
      .map((handler) => handler.definition)
      .toList(growable: false);

  Future<AgentToolResult> execute(
    AgentToolCall call,
    AgentRunContext context,
  ) async {
    final handler = _handlers[call.name];
    if (handler == null) {
      throw AgentToolRejected('Herramienta no permitida: ${call.name}.');
    }
    _validateArguments(handler.definition, call.arguments);
    return handler.execute(context, call.arguments);
  }

  void _validateArguments(
    AgentToolDefinition definition,
    Map<String, Object?> arguments,
  ) {
    final allowed = {
      ...definition.requiredArguments,
      ...definition.optionalArguments,
    };
    for (final key in arguments.keys) {
      if (!allowed.containsKey(key)) {
        throw AgentToolRejected(
          'Argumento no permitido para ${definition.name}: $key.',
        );
      }
    }
    for (final entry in definition.requiredArguments.entries) {
      if (!arguments.containsKey(entry.key)) {
        throw AgentToolRejected(
          'Falta el argumento requerido ${entry.key} para ${definition.name}.',
        );
      }
    }
    for (final entry in arguments.entries) {
      final expected = allowed[entry.key];
      final value = entry.value;
      final valid = switch (expected) {
        AgentArgumentKind.string => value is String,
        AgentArgumentKind.number => value is num,
        AgentArgumentKind.boolean => value is bool,
        null => false,
      };
      if (!valid) {
        throw AgentToolRejected(
          'El argumento ${entry.key} de ${definition.name} tiene un tipo invalido.',
        );
      }
    }
  }
}

final class AgentCoordinator implements AgentPort {
  AgentCoordinator({
    required this.gateway,
    required this.registry,
    required this.invocations,
    Uuid? uuid,
    this.maxTurns = 10,
  }) : _uuid = uuid ?? const Uuid();

  final AgentModelGateway gateway;
  final AgentToolRegistry registry;
  final ToolInvocationRepository invocations;
  final Uuid _uuid;
  final int maxTurns;

  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    final context = AgentRunContext(request.job);
    AgentModelSession? session;
    try {
      session = await gateway.open(
        request: request,
        tools: registry.definitions,
      );
      var turn = await session.start();
      for (var turnIndex = 0; turnIndex < maxTurns; turnIndex++) {
        if (turn.message.trim().isNotEmpty) {
          yield AgentEvent(
            type: AgentEventType.message,
            message: turn.message.trim(),
          );
        }
        if (turn.calls.isEmpty) {
          if (!turn.isComplete) {
            throw StateError(
              'El agente no finalizo ni solicito una herramienta.',
            );
          }
          yield const AgentEvent(
            type: AgentEventType.completed,
            message: 'Analisis completado y verificado.',
          );
          return;
        }

        final results = <AgentToolResult>[];
        for (final call in turn.calls) {
          final invocationId = _uuid.v4();
          final createdAt = DateTime.now().toUtc();
          final stopwatch = Stopwatch()..start();
          yield AgentEvent(
            type: AgentEventType.toolStarted,
            message: 'Ejecutando ${call.name}.',
            tool: call.name,
            payload: call.arguments,
          );
          await invocations.append(
            ToolInvocation(
              id: invocationId,
              jobId: request.job.id,
              toolName: call.name,
              arguments: call.arguments,
              status: ToolInvocationStatus.running,
              createdAt: createdAt,
            ),
          );
          try {
            final result = await registry.execute(call, context);
            stopwatch.stop();
            await invocations.append(
              ToolInvocation(
                id: invocationId,
                jobId: request.job.id,
                toolName: call.name,
                arguments: call.arguments,
                status: ToolInvocationStatus.success,
                summary: result.summary,
                elapsed: stopwatch.elapsed,
                createdAt: createdAt,
              ),
            );
            results.add(result);
            yield AgentEvent(
              type: AgentEventType.toolCompleted,
              message: result.summary,
              tool: call.name,
              payload: result.payload,
            );
          } on AgentToolRejected catch (error) {
            stopwatch.stop();
            await invocations.append(
              ToolInvocation(
                id: invocationId,
                jobId: request.job.id,
                toolName: call.name,
                arguments: call.arguments,
                status: ToolInvocationStatus.rejected,
                summary: error.message,
                elapsed: stopwatch.elapsed,
                createdAt: createdAt,
              ),
            );
            rethrow;
          } catch (error) {
            stopwatch.stop();
            await invocations.append(
              ToolInvocation(
                id: invocationId,
                jobId: request.job.id,
                toolName: call.name,
                arguments: call.arguments,
                status: ToolInvocationStatus.failed,
                summary: error.toString(),
                elapsed: stopwatch.elapsed,
                createdAt: createdAt,
              ),
            );
            rethrow;
          }
        }
        turn = await session.respondToTools(results);
      }
      throw StateError(
        'El agente excedio el limite seguro de $maxTurns turnos.',
      );
    } catch (error) {
      yield AgentEvent(
        type: AgentEventType.failed,
        message: 'No se pudo completar el analisis: $error',
      );
    } finally {
      await session?.close();
    }
  }
}
