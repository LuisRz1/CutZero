import 'dart:collection';

import '../../../core/domain/geometry.dart';

enum MaterialKind { eva, syntheticLeather, felt, foam, acrylic, thinWood }

enum OptimizationObjective { materialEfficiency, reusableRemnant }

enum CuttingJobStage {
  draft,
  captured,
  reviewed,
  optimizing,
  optimized,
  exported,
}

final class DefectZone {
  DefectZone({required this.id, required this.name, required this.polygon});

  final String id;
  final String name;
  final Polygon2D polygon;
}

final class MaterialSheet {
  MaterialSheet({
    required this.id,
    required this.name,
    required this.kind,
    required this.widthMm,
    required this.heightMm,
    required this.costPerSquareMeter,
    this.color = 'Celeste',
    this.thicknessMm = 2,
    List<DefectZone> defects = const [],
  }) : defects = UnmodifiableListView(defects) {
    if (widthMm <= 0 || heightMm <= 0) {
      throw ArgumentError('Material dimensions must be positive.');
    }
    if (costPerSquareMeter < 0 || thicknessMm <= 0) {
      throw ArgumentError('Material cost and thickness are invalid.');
    }
  }

  final String id;
  final String name;
  final MaterialKind kind;
  final double widthMm;
  final double heightMm;
  final double costPerSquareMeter;
  final String color;
  final double thicknessMm;
  final List<DefectZone> defects;

  Polygon2D get polygon =>
      Polygon2D.rectangle(width: widthMm, height: heightMm);
  double get areaMm2 => widthMm * heightMm;
}

final class PartTemplate {
  PartTemplate({
    required this.id,
    required this.name,
    required this.polygon,
    required this.quantity,
    required List<int> allowedRotations,
    this.grainLocked = false,
  }) : allowedRotations = UnmodifiableListView(
         allowedRotations.toSet().toList(growable: false)..sort(),
       ) {
    if (quantity < 1 || quantity > 20) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'Must be between 1 and 20.',
      );
    }
    if (this.allowedRotations.isEmpty ||
        this.allowedRotations.any((rotation) => rotation % 90 != 0)) {
      throw ArgumentError('Rotations must be non-empty multiples of 90.');
    }
  }

  final String id;
  final String name;
  final Polygon2D polygon;
  final int quantity;
  final List<int> allowedRotations;
  final bool grainLocked;

  PartTemplate copyWith({
    Polygon2D? polygon,
    int? quantity,
    List<int>? allowedRotations,
    bool? grainLocked,
  }) => PartTemplate(
    id: id,
    name: name,
    polygon: polygon ?? this.polygon,
    quantity: quantity ?? this.quantity,
    allowedRotations: allowedRotations ?? this.allowedRotations,
    grainLocked: grainLocked ?? this.grainLocked,
  );
}

final class PartInstance {
  const PartInstance({
    required this.id,
    required this.templateId,
    required this.name,
    required this.polygon,
    required this.allowedRotations,
  });

  final String id;
  final String templateId;
  final String name;
  final Polygon2D polygon;
  final List<int> allowedRotations;
}

final class Placement {
  const Placement({
    required this.instanceId,
    required this.templateId,
    required this.name,
    required this.polygon,
    required this.rotationDegrees,
  });

  final String instanceId;
  final String templateId;
  final String name;
  final Polygon2D polygon;
  final int rotationDegrees;
}

final class LayoutMetrics {
  const LayoutMetrics({
    required this.partsAreaMm2,
    required this.sheetAreaMm2,
    required this.usedEnvelopeAreaMm2,
    required this.largestReusableRemnantMm2,
    required this.estimatedWasteCost,
  });

  final double partsAreaMm2;
  final double sheetAreaMm2;
  final double usedEnvelopeAreaMm2;
  final double largestReusableRemnantMm2;
  final double estimatedWasteCost;

  double get utilizationPercent => partsAreaMm2 / sheetAreaMm2 * 100;
  double get materialWasteMm2 => sheetAreaMm2 - partsAreaMm2;
  double get envelopeEfficiencyPercent =>
      partsAreaMm2 / usedEnvelopeAreaMm2 * 100;
}

final class NestingLayout {
  NestingLayout({
    required this.id,
    required this.objective,
    required List<Placement> placements,
    required this.metrics,
    required this.elapsed,
    required this.seed,
  }) : placements = UnmodifiableListView(placements);

  final String id;
  final OptimizationObjective objective;
  final List<Placement> placements;
  final LayoutMetrics metrics;
  final Duration elapsed;
  final int seed;
}

final class CuttingJob {
  CuttingJob({
    required this.id,
    required this.name,
    required this.material,
    required List<PartTemplate> parts,
    this.gapMm = 5,
    this.stage = CuttingJobStage.draft,
    this.instruction = '',
    List<NestingLayout> layouts = const [],
    DateTime? createdAt,
  }) : parts = UnmodifiableListView(parts),
       layouts = UnmodifiableListView(layouts),
       createdAt = createdAt ?? DateTime.now().toUtc() {
    final instanceCount = parts.fold<int>(
      0,
      (sum, part) => sum + part.quantity,
    );
    if (parts.isEmpty || parts.length > 8 || instanceCount > 20) {
      throw ArgumentError(
        'A job supports 1-8 templates and up to 20 instances.',
      );
    }
    if (gapMm < 0 || gapMm > 50) {
      throw ArgumentError.value(gapMm, 'gapMm', 'Must be between 0 and 50.');
    }
  }

  final String id;
  final String name;
  final MaterialSheet material;
  final List<PartTemplate> parts;
  final double gapMm;
  final CuttingJobStage stage;
  final String instruction;
  final List<NestingLayout> layouts;
  final DateTime createdAt;

  List<PartInstance> get instances => [
    for (final template in parts)
      for (var index = 0; index < template.quantity; index++)
        PartInstance(
          id: '${template.id}-${index + 1}',
          templateId: template.id,
          name: '${template.name} ${index + 1}',
          polygon: template.polygon,
          allowedRotations: template.allowedRotations,
        ),
  ];

  CuttingJob copyWith({
    String? name,
    MaterialSheet? material,
    List<PartTemplate>? parts,
    double? gapMm,
    CuttingJobStage? stage,
    String? instruction,
    List<NestingLayout>? layouts,
  }) => CuttingJob(
    id: id,
    name: name ?? this.name,
    material: material ?? this.material,
    parts: parts ?? this.parts,
    gapMm: gapMm ?? this.gapMm,
    stage: stage ?? this.stage,
    instruction: instruction ?? this.instruction,
    layouts: layouts ?? this.layouts,
    createdAt: createdAt,
  );
}

final class Remnant {
  Remnant({
    required this.id,
    required this.name,
    required this.kind,
    required this.color,
    required this.thicknessMm,
    required this.polygon,
    required this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  final String id;
  final String name;
  final MaterialKind kind;
  final String color;
  final double thicknessMm;
  final Polygon2D polygon;
  final String location;
  final DateTime createdAt;
}

enum ToolInvocationStatus { running, success, rejected, failed }

final class ToolInvocation {
  ToolInvocation({
    required this.id,
    required this.jobId,
    required this.toolName,
    required this.arguments,
    required this.status,
    this.summary = '',
    this.elapsed = Duration.zero,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  final String id;
  final String jobId;
  final String toolName;
  final Map<String, Object?> arguments;
  final ToolInvocationStatus status;
  final String summary;
  final Duration elapsed;
  final DateTime createdAt;
}
