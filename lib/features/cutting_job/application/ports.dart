import '../../../core/domain/geometry.dart';
import '../domain/models.dart';

abstract interface class NestingSolver {
  Future<NestingLayout> solve({
    required CuttingJob job,
    required OptimizationObjective objective,
    int seed = 42,
  });
}

abstract interface class LayoutValidator {
  LayoutValidation validate(CuttingJob job, NestingLayout layout);
}

final class LayoutValidation {
  const LayoutValidation({required this.isValid, this.errors = const []});

  final bool isValid;
  final List<String> errors;
}

abstract interface class CuttingJobRepository {
  Stream<List<CuttingJob>> watchAll();
  Future<CuttingJob?> findById(String id);
  Future<void> save(CuttingJob job);
}

abstract interface class RemnantRepository {
  Stream<List<Remnant>> watchAll();
  Future<List<Remnant>> findCompatible({
    required MaterialKind kind,
    required String color,
    required double minAreaMm2,
  });
  Future<void> save(Remnant remnant);
}

abstract interface class ToolInvocationRepository {
  Stream<List<ToolInvocation>> watchForJob(String jobId);
  Future<void> append(ToolInvocation invocation);
}

enum AgentEventType { message, toolStarted, toolCompleted, completed, failed }

final class AgentRequest {
  const AgentRequest({required this.instruction, required this.job});

  final String instruction;
  final CuttingJob job;
}

final class AgentEvent {
  const AgentEvent({
    required this.type,
    required this.message,
    this.tool,
    this.payload = const {},
  });

  final AgentEventType type;
  final String message;
  final String? tool;
  final Map<String, Object?> payload;
}

abstract interface class AgentPort {
  Stream<AgentEvent> run(AgentRequest request);
}

final class VectorizationRequest {
  const VectorizationRequest({
    required this.imagePath,
    required this.referenceLengthMm,
  });

  final String imagePath;
  final double referenceLengthMm;
}

final class VectorizationResult {
  const VectorizationResult({
    required this.contours,
    required this.confidence,
    required this.requiresReview,
  });

  final List<Polygon2D> contours;
  final double confidence;
  final bool requiresReview;
}

abstract interface class VisionPort {
  Future<VectorizationResult> vectorize(VectorizationRequest request);
}

enum LayoutExportFormat { svg, pdf }

final class LayoutExportRequest {
  const LayoutExportRequest({
    required this.job,
    required this.layout,
    required this.format,
  });

  final CuttingJob job;
  final NestingLayout layout;
  final LayoutExportFormat format;
}

final class ExportedLayout {
  const ExportedLayout({
    required this.path,
    required this.format,
    required this.bytes,
  });

  final String path;
  final LayoutExportFormat format;
  final int bytes;
}

abstract interface class LayoutExporter {
  Future<ExportedLayout> export(LayoutExportRequest request);
}
