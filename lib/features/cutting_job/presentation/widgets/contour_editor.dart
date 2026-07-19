import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/domain/geometry.dart';

final class ContourEditor extends StatefulWidget {
  const ContourEditor({
    required this.names,
    required this.contours,
    required this.selectedIndex,
    required this.enabled,
    required this.onSelected,
    required this.onVertexChanged,
    required this.onReset,
    super.key,
  });

  final List<String> names;
  final List<Polygon2D> contours;
  final int selectedIndex;
  final bool enabled;
  final ValueChanged<int> onSelected;
  final void Function(int vertexIndex, Point2D point) onVertexChanged;
  final VoidCallback onReset;

  @override
  State<ContourEditor> createState() => _ContourEditorState();
}

final class _ContourEditorState extends State<ContourEditor> {
  int? _activeVertex;
  _ContourTransform? _dragTransform;

  Polygon2D get _polygon => widget.contours[widget.selectedIndex];

  @override
  Widget build(BuildContext context) {
    if (widget.contours.isEmpty ||
        widget.names.length != widget.contours.length) {
      return const SizedBox.shrink();
    }
    final bounds = _polygon.bounds;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CutZeroColors.ink.withValues(alpha: 0.025),
        border: Border.all(color: CutZeroColors.ink.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      key: const Key('contourSelector'),
                      isExpanded: true,
                      value: widget.selectedIndex,
                      items: [
                        for (
                          var index = 0;
                          index < widget.names.length;
                          index++
                        )
                          DropdownMenuItem(
                            value: index,
                            child: Text(
                              widget.names[index],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: widget.enabled
                          ? (index) {
                              if (index != null) widget.onSelected(index);
                            }
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: const Key('resetContourButton'),
                  tooltip: 'Restaurar contorno',
                  onPressed: widget.enabled ? widget.onReset : null,
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              label:
                  'Editor de contorno de ${widget.names[widget.selectedIndex]}',
              child: SizedBox(
                height: 226,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final transform =
                        _dragTransform ??
                        _ContourTransform.fromPolygon(_polygon, size);
                    return GestureDetector(
                      key: const Key('contourEditorCanvas'),
                      behavior: HitTestBehavior.opaque,
                      onPanStart: widget.enabled
                          ? (details) =>
                                _startDrag(details.localPosition, transform)
                          : null,
                      onPanUpdate: widget.enabled
                          ? (details) => _updateDrag(details.localPosition)
                          : null,
                      onPanEnd: widget.enabled ? (_) => _endDrag() : null,
                      onPanCancel: widget.enabled ? _endDrag : null,
                      child: CustomPaint(
                        painter: _ContourPainter(
                          polygon: _polygon,
                          transform: transform,
                          activeVertex: _activeVertex,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${bounds.width.round()} x ${bounds.height.round()} mm',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _startDrag(Offset position, _ContourTransform transform) {
    var closestDistance = double.infinity;
    int? closest;
    for (var index = 0; index < _polygon.points.length; index++) {
      final distance =
          (transform.toCanvas(_polygon.points[index]) - position).distance;
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = index;
      }
    }
    if (closestDistance > 30) return;
    setState(() {
      _activeVertex = closest;
      _dragTransform = transform;
    });
  }

  void _updateDrag(Offset position) {
    final vertex = _activeVertex;
    final transform = _dragTransform;
    if (vertex == null || transform == null) return;
    widget.onVertexChanged(vertex, transform.toMetric(position));
  }

  void _endDrag() {
    if (_activeVertex == null) return;
    setState(() {
      _activeVertex = null;
      _dragTransform = null;
    });
  }
}

final class _ContourTransform {
  const _ContourTransform({
    required this.bounds,
    required this.scale,
    required this.offset,
  });

  final Bounds2D bounds;
  final double scale;
  final Offset offset;

  factory _ContourTransform.fromPolygon(Polygon2D polygon, Size size) {
    const padding = 28.0;
    final bounds = polygon.bounds;
    final availableWidth = math.max(1, size.width - padding * 2);
    final availableHeight = math.max(1, size.height - padding * 2);
    final scale = math.min(
      availableWidth / math.max(bounds.width, 1),
      availableHeight / math.max(bounds.height, 1),
    );
    final drawnWidth = bounds.width * scale;
    final drawnHeight = bounds.height * scale;
    return _ContourTransform(
      bounds: bounds,
      scale: scale,
      offset: Offset(
        (size.width - drawnWidth) / 2,
        (size.height - drawnHeight) / 2,
      ),
    );
  }

  Offset toCanvas(Point2D point) => Offset(
    offset.dx + (point.x - bounds.minX) * scale,
    offset.dy + (point.y - bounds.minY) * scale,
  );

  Point2D toMetric(Offset point) => Point2D(
    bounds.minX + (point.dx - offset.dx) / scale,
    bounds.minY + (point.dy - offset.dy) / scale,
  );
}

final class _ContourPainter extends CustomPainter {
  const _ContourPainter({
    required this.polygon,
    required this.transform,
    required this.activeVertex,
  });

  final Polygon2D polygon;
  final _ContourTransform transform;
  final int? activeVertex;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = CutZeroColors.ink.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    const spacing = 28.0;
    for (var x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path();
    for (var index = 0; index < polygon.points.length; index++) {
      final point = transform.toCanvas(polygon.points[index]);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = CutZeroColors.sky.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = polygon.isSimple
            ? CutZeroColors.skyDark
            : ThemeData.light().colorScheme.error
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    for (var index = 0; index < polygon.points.length; index++) {
      final point = transform.toCanvas(polygon.points[index]);
      canvas.drawCircle(
        point,
        index == activeVertex ? 8 : 6,
        Paint()
          ..color = index == activeVertex
              ? CutZeroColors.amber
              : CutZeroColors.surface,
      );
      canvas.drawCircle(
        point,
        index == activeVertex ? 8 : 6,
        Paint()
          ..color = CutZeroColors.skyDark
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_ContourPainter oldDelegate) =>
      oldDelegate.polygon != polygon ||
      oldDelegate.transform != transform ||
      oldDelegate.activeVertex != activeVertex;
}
