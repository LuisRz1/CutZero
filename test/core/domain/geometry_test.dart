import 'package:cutzero/core/domain/geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Polygon2D', () {
    test('calculates area and bounds', () {
      final polygon = Polygon2D.rectangle(width: 100, height: 50);

      expect(polygon.area, 5000);
      expect(polygon.bounds.width, 100);
      expect(polygon.bounds.height, 50);
    });

    test('normalizes a rotated rectangle without changing area', () {
      final original = Polygon2D.rectangle(width: 120, height: 40);
      final rotated = original.rotated(90).normalized;

      expect(rotated.area, closeTo(original.area, 0.001));
      expect(rotated.bounds.width, closeTo(40, 0.001));
      expect(rotated.bounds.height, closeTo(120, 0.001));
      expect(rotated.bounds.minX, closeTo(0, 0.001));
      expect(rotated.bounds.minY, closeTo(0, 0.001));
    });

    test('rejects degenerate polygons', () {
      expect(
        () => Polygon2D([
          const Point2D(0, 0),
          const Point2D(1, 0),
          const Point2D(2, 0),
        ]),
        throwsArgumentError,
      );
    });
  });
}
