import 'dart:math' as math;

import '../../../core/domain/geometry.dart';
import '../../cutting_job/domain/models.dart';

final class CreateRemnant {
  const CreateRemnant({this.minimumAreaMm2 = 10000, this.minimumSideMm = 30});

  final double minimumAreaMm2;
  final double minimumSideMm;

  Remnant? call({
    required CuttingJob job,
    required NestingLayout layout,
    required String id,
    String location = 'Por ubicar',
  }) {
    if (layout.placements.isEmpty) return null;
    final maxX = layout.placements
        .map((placement) => placement.polygon.bounds.maxX)
        .reduce(math.max);
    final maxY = layout.placements
        .map((placement) => placement.polygon.bounds.maxY)
        .reduce(math.max);
    final rightWidth = math.max(0.0, job.material.widthMm - maxX);
    final topHeight = math.max(0.0, job.material.heightMm - maxY);
    final rightArea = rightWidth * job.material.heightMm;
    final topArea = topHeight * job.material.widthMm;
    final useRight = rightArea >= topArea;
    final width = useRight ? rightWidth : job.material.widthMm;
    final height = useRight ? job.material.heightMm : topHeight;
    if (width < minimumSideMm ||
        height < minimumSideMm ||
        width * height < minimumAreaMm2) {
      return null;
    }
    return Remnant(
      id: id,
      name:
          'Retal ${job.material.color} ${width.round()} x ${height.round()} mm',
      kind: job.material.kind,
      color: job.material.color,
      thicknessMm: job.material.thicknessMm,
      polygon: Polygon2D.rectangle(width: width, height: height),
      location: location,
    );
  }
}
