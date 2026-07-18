import '../../../core/domain/geometry.dart';
import '../domain/models.dart';

final class DemoFixture {
  const DemoFixture._();

  static CuttingJob createJob() => CuttingJob(
    id: 'demo-eva-bags',
    name: 'Pedido bolsos Aurora',
    instruction:
        'Necesito dos bolsos. Respeta la veta, deja 8 milimetros y evita el defecto.',
    stage: CuttingJobStage.captured,
    gapMm: 8,
    material: MaterialSheet(
      id: 'sheet-eva-sky',
      name: 'EVA celeste 1100 x 700 mm',
      kind: MaterialKind.eva,
      widthMm: 1100,
      heightMm: 700,
      costPerSquareMeter: 42,
      color: 'Celeste',
      thicknessMm: 2,
      defects: [
        DefectZone(
          id: 'defect-1',
          name: 'Zona marcada',
          polygon: _ellipse(centerX: 1030, centerY: 625, rx: 48, ry: 38),
        ),
      ],
    ),
    parts: [
      PartTemplate(
        id: 'body',
        name: 'Cuerpo',
        polygon: _roundedRect(width: 310, height: 175, radius: 22),
        quantity: 4,
        allowedRotations: const [0, 180],
        grainLocked: true,
      ),
      PartTemplate(
        id: 'strap',
        name: 'Asa',
        polygon: _roundedRect(width: 42, height: 265, radius: 10),
        quantity: 4,
        allowedRotations: const [0],
        grainLocked: true,
      ),
      PartTemplate(
        id: 'pocket',
        name: 'Bolsillo',
        polygon: Polygon2D([
          const Point2D(0, 0),
          const Point2D(170, 0),
          const Point2D(170, 90),
          const Point2D(150, 125),
          const Point2D(115, 145),
          const Point2D(55, 145),
          const Point2D(20, 125),
          const Point2D(0, 90),
        ]),
        quantity: 2,
        allowedRotations: const [0, 180],
      ),
    ],
  );

  static Polygon2D _roundedRect({
    required double width,
    required double height,
    required double radius,
  }) => Polygon2D([
    Point2D(radius, 0),
    Point2D(width - radius, 0),
    Point2D(width, radius),
    Point2D(width, height - radius),
    Point2D(width - radius, height),
    Point2D(radius, height),
    Point2D(0, height - radius),
    Point2D(0, radius),
  ]);

  static Polygon2D _ellipse({
    required double centerX,
    required double centerY,
    required double rx,
    required double ry,
  }) {
    const points = 20;
    const radiansPerPoint = 0.3141592653589793;
    return Polygon2D([
      for (var index = 0; index < points; index++)
        Point2D(
          centerX + rx * _cos(index * radiansPerPoint),
          centerY + ry * _sin(index * radiansPerPoint),
        ),
    ]);
  }

  static double _sin(double value) {
    // Bhaskara approximation is sufficient for the deterministic fixture.
    const pi = 3.141592653589793;
    var x = value % (2 * pi);
    if (x > pi) x -= 2 * pi;
    final sign = x < 0 ? -1.0 : 1.0;
    x = x.abs();
    return sign * 16 * x * (pi - x) / (5 * pi * pi - 4 * x * (pi - x));
  }

  static double _cos(double value) => _sin(value + 1.5707963267948966);
}
