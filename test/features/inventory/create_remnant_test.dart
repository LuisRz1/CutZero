import 'package:cutzero/features/cutting_job/application/demo_fixture.dart';
import 'package:cutzero/features/inventory/application/create_remnant.dart';
import 'package:cutzero/features/optimization/application/run_optimization.dart';
import 'package:cutzero/features/optimization/infrastructure/clipper_geometry.dart';
import 'package:cutzero/features/optimization/infrastructure/deterministic_nesting_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates the largest reusable strip from a layout', () async {
    final job = DemoFixture.createJob();
    const geometry = ClipperGeometry();
    const optimization = RunOptimization(
      solver: DeterministicNestingSolver(geometry),
      validator: ClipperLayoutValidator(geometry),
    );
    final layout = (await optimization(job)).reusableRemnant;

    final remnant = const CreateRemnant()(
      job: job,
      layout: layout,
      id: 'remnant-1',
      location: 'R-02',
    );

    expect(remnant, isNotNull);
    expect(remnant!.polygon.area, greaterThanOrEqualTo(10000));
    expect(
      remnant.polygon.bounds.width,
      lessThanOrEqualTo(job.material.widthMm),
    );
    expect(
      remnant.polygon.bounds.height,
      lessThanOrEqualTo(job.material.heightMm),
    );
    expect(remnant.location, 'R-02');
  });
}
