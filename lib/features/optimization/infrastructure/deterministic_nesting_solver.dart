import 'dart:math' as math;

import '../../../core/domain/geometry.dart';
import '../../cutting_job/application/ports.dart';
import '../../cutting_job/domain/models.dart';
import 'clipper_geometry.dart';

final class NestingFailure implements Exception {
  const NestingFailure(this.message);

  final String message;

  @override
  String toString() => 'NestingFailure: $message';
}

final class DeterministicNestingSolver implements NestingSolver {
  const DeterministicNestingSolver(this.geometry);

  final ClipperGeometry geometry;

  @override
  Future<NestingLayout> solve({
    required CuttingJob job,
    required OptimizationObjective objective,
    int seed = 42,
  }) async {
    final stopwatch = Stopwatch()..start();
    final instances = [...job.instances]
      ..sort((a, b) {
        final rotationComparison = a.allowedRotations.length.compareTo(
          b.allowedRotations.length,
        );
        if (rotationComparison != 0) return rotationComparison;
        final areaComparison = b.polygon.area.compareTo(a.polygon.area);
        if (areaComparison != 0) return areaComparison;
        return a.id.compareTo(b.id);
      });
    final placements = <Placement>[];

    for (final instance in instances) {
      final candidate = _bestCandidate(
        job: job,
        instance: instance,
        placements: placements,
        objective: objective,
      );
      if (candidate == null) {
        throw NestingFailure(
          'No existe una posicion valida para ${instance.name}.',
        );
      }
      placements.add(candidate);
    }

    stopwatch.stop();
    return NestingLayout(
      id: '${job.id}-${objective.name}-$seed',
      objective: objective,
      placements: placements,
      metrics: _metrics(job, placements),
      elapsed: stopwatch.elapsed,
      seed: seed,
    );
  }

  Placement? _bestCandidate({
    required CuttingJob job,
    required PartInstance instance,
    required List<Placement> placements,
    required OptimizationObjective objective,
  }) {
    Placement? best;
    List<double>? bestScore;
    final positions = _candidatePositions(placements, job.gapMm);

    for (final rotation in instance.allowedRotations) {
      final rotated = instance.polygon.rotated(rotation.toDouble()).normalized;
      for (final position in positions) {
        final polygon = rotated.translated(position.x, position.y);
        final placement = Placement(
          instanceId: instance.id,
          templateId: instance.templateId,
          name: instance.name,
          polygon: polygon,
          rotationDegrees: rotation,
        );
        if (!_isValidCandidate(job, placement, placements)) continue;

        final score = _score(placement, placements, objective);
        if (bestScore == null || _compareScores(score, bestScore) < 0) {
          best = placement;
          bestScore = score;
        }
      }
    }
    return best;
  }

  List<Point2D> _candidatePositions(List<Placement> placements, double gapMm) {
    final xValues = <double>{0};
    final yValues = <double>{0};
    for (final placement in placements) {
      final bounds = placement.polygon.bounds;
      xValues.add(bounds.maxX + gapMm);
      yValues.add(bounds.maxY + gapMm);
    }
    final positions = <Point2D>[
      for (final y in yValues)
        for (final x in xValues) Point2D(x, y),
    ];
    positions.sort((a, b) {
      final yComparison = a.y.compareTo(b.y);
      return yComparison != 0 ? yComparison : a.x.compareTo(b.x);
    });
    return positions;
  }

  bool _isValidCandidate(
    CuttingJob job,
    Placement candidate,
    List<Placement> placements,
  ) {
    if (!job.material.polygon.bounds.contains(candidate.polygon.bounds)) {
      return false;
    }
    for (final defect in job.material.defects) {
      if (geometry.overlaps(candidate.polygon, defect.polygon)) return false;
    }
    for (final placed in placements) {
      if (geometry.overlaps(
        candidate.polygon,
        placed.polygon,
        gapMm: job.gapMm,
      )) {
        return false;
      }
    }
    return true;
  }

  List<double> _score(
    Placement candidate,
    List<Placement> placements,
    OptimizationObjective objective,
  ) {
    final all = [...placements, candidate];
    final maxX = all
        .map((placement) => placement.polygon.bounds.maxX)
        .reduce(math.max);
    final maxY = all
        .map((placement) => placement.polygon.bounds.maxY)
        .reduce(math.max);
    final bounds = candidate.polygon.bounds;
    return switch (objective) {
      OptimizationObjective.materialEfficiency => [
        maxY,
        maxX,
        bounds.minY,
        bounds.minX,
        candidate.rotationDegrees.toDouble(),
      ],
      OptimizationObjective.reusableRemnant => [
        maxX,
        maxY,
        bounds.minX,
        bounds.minY,
        candidate.rotationDegrees.toDouble(),
      ],
    };
  }

  int _compareScores(List<double> first, List<double> second) {
    for (var index = 0; index < first.length; index++) {
      final comparison = first[index].compareTo(second[index]);
      if (comparison != 0) return comparison;
    }
    return 0;
  }

  LayoutMetrics _metrics(CuttingJob job, List<Placement> placements) {
    final partsArea = placements.fold<double>(
      0,
      (sum, placement) => sum + placement.polygon.area,
    );
    final maxX = placements
        .map((placement) => placement.polygon.bounds.maxX)
        .reduce(math.max);
    final maxY = placements
        .map((placement) => placement.polygon.bounds.maxY)
        .reduce(math.max);
    final rightStrip =
        math.max(0, job.material.widthMm - maxX) * job.material.heightMm;
    final topStrip =
        math.max(0, job.material.heightMm - maxY) * job.material.widthMm;
    final wasteArea = job.material.areaMm2 - partsArea;
    return LayoutMetrics(
      partsAreaMm2: partsArea,
      sheetAreaMm2: job.material.areaMm2,
      usedEnvelopeAreaMm2: math.max(partsArea, maxX * maxY),
      largestReusableRemnantMm2: math.max(rightStrip, topStrip),
      estimatedWasteCost: wasteArea / 1000000 * job.material.costPerSquareMeter,
    );
  }
}
