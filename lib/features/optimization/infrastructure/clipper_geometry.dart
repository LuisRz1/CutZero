import 'package:clipper2/clipper2.dart' as clipper;

import '../../../core/domain/geometry.dart';
import '../../cutting_job/application/ports.dart';
import '../../cutting_job/domain/models.dart';

final class ClipperGeometry {
  const ClipperGeometry();

  clipper.PathD toPath(Polygon2D polygon) => polygon.points
      .map((point) => clipper.PointD(point.x, point.y))
      .toList(growable: false);

  double intersectionArea(Polygon2D first, Polygon2D second) {
    final result = clipper.Clipper.intersectD(
      subject: [toPath(first)],
      clip: [toPath(second)],
      fillRule: clipper.FillRule.nonZero,
      precision: 3,
    );
    return result.area.abs();
  }

  Polygon2D inflate(Polygon2D polygon, double delta) {
    if (delta <= 0) return polygon;
    final result = clipper.Clipper.inflatePathsD(
      paths: [toPath(polygon)],
      delta: delta,
      joinType: clipper.JoinType.round,
      endType: clipper.EndType.polygon,
      precision: 3,
    );
    if (result.isEmpty) return polygon;
    final largest = result.reduce(
      (a, b) => a.area.abs() >= b.area.abs() ? a : b,
    );
    return Polygon2D(largest.map((point) => Point2D(point.x, point.y)));
  }

  bool overlaps(Polygon2D first, Polygon2D second, {double gapMm = 0}) {
    final halfGap = gapMm / 2;
    final firstWithGap = inflate(first, halfGap);
    final secondWithGap = inflate(second, halfGap);
    return intersectionArea(firstWithGap, secondWithGap) > 0.001;
  }
}

final class ClipperLayoutValidator implements LayoutValidator {
  const ClipperLayoutValidator(this.geometry);

  final ClipperGeometry geometry;

  @override
  LayoutValidation validate(CuttingJob job, NestingLayout layout) {
    final errors = <String>[];
    final sheetBounds = job.material.polygon.bounds;
    final instanceIds = job.instances.map((instance) => instance.id).toSet();
    final placementIds = layout.placements
        .map((placement) => placement.instanceId)
        .toSet();

    if (instanceIds.length != placementIds.length ||
        !instanceIds.containsAll(placementIds)) {
      errors.add('El layout no contiene exactamente todas las piezas.');
    }

    for (final placement in layout.placements) {
      if (!sheetBounds.contains(placement.polygon.bounds)) {
        errors.add('${placement.name} esta fuera del material.');
      }
      for (final defect in job.material.defects) {
        if (geometry.overlaps(placement.polygon, defect.polygon)) {
          errors.add('${placement.name} intersecta ${defect.name}.');
        }
      }
    }

    for (var first = 0; first < layout.placements.length; first++) {
      for (
        var second = first + 1;
        second < layout.placements.length;
        second++
      ) {
        final a = layout.placements[first];
        final b = layout.placements[second];
        if (geometry.overlaps(a.polygon, b.polygon, gapMm: job.gapMm)) {
          errors.add('${a.name} se superpone con ${b.name}.');
        }
      }
    }

    return LayoutValidation(isValid: errors.isEmpty, errors: errors);
  }
}
