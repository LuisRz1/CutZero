import '../../cutting_job/application/ports.dart';
import '../../cutting_job/domain/models.dart';

final class OptimizationResult {
  const OptimizationResult({
    required this.materialEfficient,
    required this.reusableRemnant,
  });

  final NestingLayout materialEfficient;
  final NestingLayout reusableRemnant;

  List<NestingLayout> get layouts => [materialEfficient, reusableRemnant];
}

final class RunOptimization {
  const RunOptimization({required this.solver, required this.validator});

  final NestingSolver solver;
  final LayoutValidator validator;

  Future<OptimizationResult> call(CuttingJob job) async {
    final results = await Future.wait([
      solver.solve(
        job: job,
        objective: OptimizationObjective.materialEfficiency,
      ),
      solver.solve(job: job, objective: OptimizationObjective.reusableRemnant),
    ]);
    for (final layout in results) {
      final validation = validator.validate(job, layout);
      if (!validation.isValid) {
        throw StateError(
          'El solver produjo un layout invalido: ${validation.errors.join(' | ')}',
        );
      }
    }
    return OptimizationResult(
      materialEfficient: results[0],
      reusableRemnant: results[1],
    );
  }
}
