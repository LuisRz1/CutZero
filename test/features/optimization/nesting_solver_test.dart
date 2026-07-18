import 'package:cutzero/core/domain/geometry.dart';
import 'package:cutzero/features/cutting_job/domain/models.dart';
import 'package:cutzero/features/cutting_job/application/demo_fixture.dart';
import 'package:cutzero/features/optimization/application/run_optimization.dart';
import 'package:cutzero/features/optimization/infrastructure/clipper_geometry.dart';
import 'package:cutzero/features/optimization/infrastructure/deterministic_nesting_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const geometry = ClipperGeometry();
  const validator = ClipperLayoutValidator(geometry);
  const solver = DeterministicNestingSolver(geometry);

  test('produces deterministic valid layouts for both objectives', () async {
    final job = DemoFixture.createJob();
    const useCase = RunOptimization(solver: solver, validator: validator);

    final first = await useCase(job);
    final second = await useCase(job);

    expect(first.materialEfficient.placements, hasLength(job.instances.length));
    expect(first.reusableRemnant.placements, hasLength(job.instances.length));
    expect(validator.validate(job, first.materialEfficient).isValid, isTrue);
    expect(validator.validate(job, first.reusableRemnant).isValid, isTrue);
    expect(
      _signature(first.materialEfficient),
      _signature(second.materialEfficient),
    );
    expect(first.materialEfficient.metrics.utilizationPercent, greaterThan(35));
    expect(
      first.reusableRemnant.metrics.largestReusableRemnantMm2,
      greaterThan(0),
    );
  });

  test('fails when the requested pieces cannot fit', () async {
    final impossible = CuttingJob(
      id: 'impossible',
      name: 'Pedido imposible',
      material: MaterialSheet(
        id: 'small-sheet',
        name: 'Lamina pequena',
        kind: MaterialKind.eva,
        widthMm: 100,
        heightMm: 100,
        costPerSquareMeter: 20,
      ),
      parts: [
        PartTemplate(
          id: 'large',
          name: 'Pieza grande',
          polygon: Polygon2D.rectangle(width: 90, height: 90),
          quantity: 2,
          allowedRotations: const [0],
        ),
      ],
    );

    expect(
      () => solver.solve(
        job: impossible,
        objective: OptimizationObjective.materialEfficiency,
      ),
      throwsA(isA<NestingFailure>()),
    );
  });

  test('validator rejects overlap and missing pieces', () {
    final job = DemoFixture.createJob();
    final polygon = job.parts.first.polygon;
    final invalid = NestingLayout(
      id: 'invalid',
      objective: OptimizationObjective.materialEfficiency,
      placements: [
        Placement(
          instanceId: job.instances.first.id,
          templateId: job.instances.first.templateId,
          name: job.instances.first.name,
          polygon: polygon,
          rotationDegrees: 0,
        ),
        Placement(
          instanceId: job.instances[1].id,
          templateId: job.instances[1].templateId,
          name: job.instances[1].name,
          polygon: polygon,
          rotationDegrees: 0,
        ),
      ],
      metrics: const LayoutMetrics(
        partsAreaMm2: 1,
        sheetAreaMm2: 2,
        usedEnvelopeAreaMm2: 1,
        largestReusableRemnantMm2: 1,
        estimatedWasteCost: 0,
      ),
      elapsed: Duration.zero,
      seed: 42,
    );

    final result = validator.validate(job, invalid);

    expect(result.isValid, isFalse);
    expect(result.errors, isNotEmpty);
  });
}

String _signature(NestingLayout layout) => layout.placements
    .map(
      (placement) =>
          '${placement.instanceId}:${placement.polygon.bounds.minX.toStringAsFixed(2)}:'
          '${placement.polygon.bounds.minY.toStringAsFixed(2)}:${placement.rotationDegrees}',
    )
    .join('|');
