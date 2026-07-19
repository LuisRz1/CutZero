import 'dart:math' as math;

final class Point2D {
  const Point2D(this.x, this.y);

  final double x;
  final double y;

  Point2D translated(double dx, double dy) => Point2D(x + dx, y + dy);

  Map<String, double> toJson() => {'x': x, 'y': y};

  factory Point2D.fromJson(Map<String, Object?> json) =>
      Point2D((json['x']! as num).toDouble(), (json['y']! as num).toDouble());

  @override
  bool operator ==(Object other) =>
      other is Point2D && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

final class Bounds2D {
  const Bounds2D({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
  double get area => width * height;

  bool contains(Bounds2D other, {double tolerance = 0.001}) =>
      other.minX >= minX - tolerance &&
      other.minY >= minY - tolerance &&
      other.maxX <= maxX + tolerance &&
      other.maxY <= maxY + tolerance;
}

final class Polygon2D {
  Polygon2D(Iterable<Point2D> points)
    : points = List<Point2D>.unmodifiable(points) {
    if (this.points.length < 3) {
      throw ArgumentError.value(points, 'points', 'A polygon needs 3 points.');
    }
    if (area <= 0.0001) {
      throw ArgumentError.value(
        points,
        'points',
        'Polygon area must be positive.',
      );
    }
  }

  final List<Point2D> points;

  factory Polygon2D.rectangle({required double width, required double height}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Rectangle dimensions must be positive.');
    }
    return Polygon2D([
      const Point2D(0, 0),
      Point2D(width, 0),
      Point2D(width, height),
      Point2D(0, height),
    ]);
  }

  double get signedArea {
    var sum = 0.0;
    for (var index = 0; index < points.length; index++) {
      final current = points[index];
      final next = points[(index + 1) % points.length];
      sum += current.x * next.y - next.x * current.y;
    }
    return sum / 2;
  }

  double get area => signedArea.abs();

  bool get isSimple {
    for (var index = 0; index < points.length; index++) {
      if (points[index] == points[(index + 1) % points.length]) return false;
      for (var other = index + 1; other < points.length; other++) {
        final adjacent =
            other == index + 1 || (index == 0 && other == points.length - 1);
        if (adjacent) continue;
        if (_segmentsIntersect(
          points[index],
          points[(index + 1) % points.length],
          points[other],
          points[(other + 1) % points.length],
        )) {
          return false;
        }
      }
    }
    return true;
  }

  Bounds2D get bounds {
    var minX = points.first.x;
    var minY = points.first.y;
    var maxX = points.first.x;
    var maxY = points.first.y;
    for (final point in points.skip(1)) {
      minX = math.min(minX, point.x);
      minY = math.min(minY, point.y);
      maxX = math.max(maxX, point.x);
      maxY = math.max(maxY, point.y);
    }
    return Bounds2D(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }

  Polygon2D translated(double dx, double dy) =>
      Polygon2D(points.map((point) => point.translated(dx, dy)));

  Polygon2D rotated(double degrees) {
    final normalizedDegrees = ((degrees % 360) + 360) % 360;
    final radians = normalizedDegrees * math.pi / 180;
    final cosine = math.cos(radians);
    final sine = math.sin(radians);
    double clean(double value) => value.abs() < 0.0000001 ? 0 : value;

    return Polygon2D(
      points.map(
        (point) => Point2D(
          clean(point.x * cosine - point.y * sine),
          clean(point.x * sine + point.y * cosine),
        ),
      ),
    );
  }

  Polygon2D get normalized {
    final polygonBounds = bounds;
    return translated(-polygonBounds.minX, -polygonBounds.minY);
  }

  List<Map<String, double>> toJson() =>
      points.map((point) => point.toJson()).toList(growable: false);

  factory Polygon2D.fromJson(List<Object?> json) => Polygon2D(
    json.map((point) => Point2D.fromJson(point! as Map<String, Object?>)),
  );
}

bool _segmentsIntersect(Point2D a, Point2D b, Point2D c, Point2D d) {
  double cross(Point2D p, Point2D q, Point2D r) =>
      (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x);

  bool onSegment(Point2D p, Point2D q, Point2D r) =>
      q.x >= math.min(p.x, r.x) - 0.000001 &&
      q.x <= math.max(p.x, r.x) + 0.000001 &&
      q.y >= math.min(p.y, r.y) - 0.000001 &&
      q.y <= math.max(p.y, r.y) + 0.000001;

  final abC = cross(a, b, c);
  final abD = cross(a, b, d);
  final cdA = cross(c, d, a);
  final cdB = cross(c, d, b);
  if (((abC > 0 && abD < 0) || (abC < 0 && abD > 0)) &&
      ((cdA > 0 && cdB < 0) || (cdA < 0 && cdB > 0))) {
    return true;
  }
  if (abC.abs() <= 0.000001 && onSegment(a, c, b)) return true;
  if (abD.abs() <= 0.000001 && onSegment(a, d, b)) return true;
  if (cdA.abs() <= 0.000001 && onSegment(c, a, d)) return true;
  if (cdB.abs() <= 0.000001 && onSegment(c, b, d)) return true;
  return false;
}
