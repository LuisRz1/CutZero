import '../../cutting_job/application/ports.dart';
import '../../optimization/application/run_optimization.dart';
import '../application/agent_coordinator.dart';
import '../domain/agent_models.dart';

final class SearchRemnantsTool implements AgentToolHandler {
  const SearchRemnantsTool(this.repository);

  final RemnantRepository repository;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
    name: 'search_remnants',
    description:
        'Busca retales locales compatibles antes de usar una lamina nueva.',
    optionalArguments: {'minAreaMm2': AgentArgumentKind.number},
  );

  @override
  Future<AgentToolResult> execute(
    AgentRunContext context,
    Map<String, Object?> arguments,
  ) async {
    final smallestPart = context.job.parts
        .map((part) => part.polygon.area)
        .reduce((first, second) => first < second ? first : second);
    final minimumArea =
        (arguments['minAreaMm2'] as num?)?.toDouble() ?? smallestPart;
    if (minimumArea <= 0) {
      throw const AgentToolRejected('El area minima debe ser positiva.');
    }
    final material = context.job.material;
    final remnants = await repository.findCompatible(
      kind: material.kind,
      color: material.color,
      minAreaMm2: minimumArea,
    );
    return AgentToolResult(
      toolName: definition.name,
      summary: remnants.isEmpty
          ? 'No hay retales compatibles; se evaluara la lamina actual.'
          : 'Se encontraron ${remnants.length} retales compatibles.',
      payload: {
        'count': remnants.length,
        'remnants': [
          for (final remnant in remnants)
            {
              'id': remnant.id,
              'name': remnant.name,
              'areaMm2': remnant.polygon.area,
              'location': remnant.location,
            },
        ],
      },
    );
  }
}

final class VectorizeCaptureTool implements AgentToolHandler {
  const VectorizeCaptureTool(this.vision);

  final VisionPort vision;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
    name: 'vectorize_capture',
    description: 'Convierte una captura calibrada en contornos medibles.',
    requiredArguments: {
      'imagePath': AgentArgumentKind.string,
      'referenceLengthMm': AgentArgumentKind.number,
    },
  );

  @override
  Future<AgentToolResult> execute(
    AgentRunContext context,
    Map<String, Object?> arguments,
  ) async {
    final result = await vision.vectorize(
      VectorizationRequest(
        imagePath: arguments['imagePath']! as String,
        referenceLengthMm: (arguments['referenceLengthMm']! as num).toDouble(),
      ),
    );
    context.vectorization = result;
    return AgentToolResult(
      toolName: definition.name,
      summary:
          '${result.contours.length} contornos detectados con ${(result.confidence * 100).round()}% de confianza.',
      payload: {
        'contourCount': result.contours.length,
        'confidence': result.confidence,
        'requiresReview': result.requiresReview,
      },
    );
  }
}

final class ValidateGeometryTool implements AgentToolHandler {
  const ValidateGeometryTool();

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
    name: 'validate_geometry',
    description: 'Valida dimensiones, areas y limites antes de optimizar.',
  );

  @override
  Future<AgentToolResult> execute(
    AgentRunContext context,
    Map<String, Object?> arguments,
  ) async {
    final errors = <String>[];
    for (final part in context.job.parts) {
      if (part.polygon.area <= 0.001) {
        errors.add('${part.name} no tiene un area valida.');
      }
      final bounds = part.polygon.bounds;
      if (bounds.width > context.job.material.widthMm ||
          bounds.height > context.job.material.heightMm) {
        errors.add('${part.name} supera las dimensiones del material.');
      }
    }
    if (context.vectorization != null &&
        context.vectorization!.contours.length != context.job.parts.length) {
      errors.add('La cantidad de contornos no coincide con los moldes.');
    }
    if (errors.isNotEmpty) {
      throw StateError(errors.join(' '));
    }
    return AgentToolResult(
      toolName: definition.name,
      summary:
          'Geometria validada para ${context.job.instances.length} piezas.',
      payload: {'valid': true, 'pieceCount': context.job.instances.length},
    );
  }
}

final class RunNestingTool implements AgentToolHandler {
  const RunNestingTool(this.runOptimization);

  final RunOptimization runOptimization;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
    name: 'run_nesting',
    description:
        'Calcula y valida alternativas de aprovechamiento y retal reutilizable.',
  );

  @override
  Future<AgentToolResult> execute(
    AgentRunContext context,
    Map<String, Object?> arguments,
  ) async {
    final result = await runOptimization(context.job);
    context.optimization = result;
    return AgentToolResult(
      toolName: definition.name,
      summary:
          'Se generaron y validaron ${result.layouts.length} alternativas.',
      payload: {
        'layouts': [
          for (final layout in result.layouts)
            {
              'id': layout.id,
              'objective': layout.objective.name,
              'utilizationPercent': layout.metrics.utilizationPercent,
              'reusableRemnantMm2': layout.metrics.largestReusableRemnantMm2,
            },
        ],
      },
    );
  }
}

final class CalculateCostTool implements AgentToolHandler {
  const CalculateCostTool();

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
    name: 'calculate_cost',
    description:
        'Compara el desperdicio y su costo estimado para cada alternativa.',
  );

  @override
  Future<AgentToolResult> execute(
    AgentRunContext context,
    Map<String, Object?> arguments,
  ) async {
    final optimization = context.optimization;
    if (optimization == null) {
      throw StateError('Primero debe ejecutarse run_nesting.');
    }
    final layouts = [...optimization.layouts]
      ..sort(
        (first, second) => first.metrics.estimatedWasteCost.compareTo(
          second.metrics.estimatedWasteCost,
        ),
      );
    final best = layouts.first;
    return AgentToolResult(
      toolName: definition.name,
      summary:
          'La alternativa recomendada estima ${best.metrics.estimatedWasteCost.toStringAsFixed(2)} de costo en desperdicio.',
      payload: {
        'recommendedLayoutId': best.id,
        'estimatedWasteCost': best.metrics.estimatedWasteCost,
        'materialCostPerSquareMeter': context.job.material.costPerSquareMeter,
      },
    );
  }
}
