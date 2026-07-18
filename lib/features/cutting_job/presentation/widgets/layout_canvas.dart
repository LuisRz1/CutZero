import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/domain/geometry.dart';
import '../../domain/models.dart';

final class LayoutCanvas extends StatelessWidget {
  const LayoutCanvas({required this.job, required this.layout, super.key});

  final CuttingJob job;
  final NestingLayout layout;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: job.material.widthMm / job.material.heightMm,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CutZeroColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          boundaryMargin: const EdgeInsets.all(80),
          child: CustomPaint(
            key: ValueKey(layout.id),
            painter: _LayoutPainter(
              job: job,
              layout: layout,
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ),
  );
}

final class _LayoutPainter extends CustomPainter {
  const _LayoutPainter({
    required this.job,
    required this.layout,
    required this.fontFamily,
  });

  final CuttingJob job;
  final NestingLayout layout;
  final String? fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 14.0;
    final availableWidth = math.max(1, size.width - padding * 2);
    final availableHeight = math.max(1, size.height - padding * 2);
    final scale = math.min(
      availableWidth / job.material.widthMm,
      availableHeight / job.material.heightMm,
    );
    final width = job.material.widthMm * scale;
    final height = job.material.heightMm * scale;
    final origin = Offset((size.width - width) / 2, (size.height - height) / 2);

    canvas.drawRect(
      origin & Size(width, height),
      Paint()..color = const Color(0xFFEAF8FC),
    );
    canvas.drawRect(
      origin & Size(width, height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = CutZeroColors.skyDark,
    );

    for (final defect in job.material.defects) {
      canvas.drawPath(
        _path(defect.polygon, origin, scale),
        Paint()..color = CutZeroColors.coral.withValues(alpha: 0.55),
      );
    }
    for (var index = 0; index < layout.placements.length; index++) {
      final placement = layout.placements[index];
      final path = _path(placement.polygon, origin, scale);
      canvas
        ..drawPath(
          path,
          Paint()
            ..color = index.isEven
                ? CutZeroColors.sky.withValues(alpha: 0.82)
                : CutZeroColors.mint.withValues(alpha: 0.8),
        )
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.25
            ..color = CutZeroColors.ink,
        );
      final bounds = placement.polygon.bounds;
      final label = TextPainter(
        text: TextSpan(
          text: placement.name,
          style: TextStyle(
            color: CutZeroColors.ink,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontFamily: fontFamily,
          ),
        ),
        maxLines: 1,
        ellipsis: '...',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: math.max(20, bounds.width * scale - 8));
      label.paint(
        canvas,
        origin + Offset(bounds.minX * scale + 4, bounds.minY * scale + 4),
      );
    }
  }

  Path _path(Polygon2D polygon, Offset origin, double scale) {
    final path = Path();
    for (var index = 0; index < polygon.points.length; index++) {
      final point = polygon.points[index];
      final offset = origin + Offset(point.x * scale, point.y * scale);
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _LayoutPainter oldDelegate) =>
      oldDelegate.layout.id != layout.id ||
      oldDelegate.job != job ||
      oldDelegate.fontFamily != fontFamily;
}
