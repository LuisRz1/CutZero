import 'package:cutzero/app/cutzero_app.dart';
import 'package:cutzero/features/cutting_job/application/ports.dart';
import 'package:cutzero/features/cutting_job/domain/models.dart';
import 'package:cutzero/features/cutting_job/presentation/cutting_job_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'runs real vision persistence optimization and export on Android',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CutZeroApp()));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CutZeroApp)),
      );
      final controller = container.read(cuttingWorkspaceProvider.notifier);

      await controller.analyzeFixture();
      await tester.pumpAndSettle();
      final captured = container.read(cuttingWorkspaceProvider);
      expect(captured.error, isNull);
      expect(captured.job.stage, CuttingJobStage.captured);
      expect(captured.vectorization?.contours, hasLength(3));
      expect(captured.vectorization?.templateIds, ['body', 'strap', 'pocket']);
      expect(
        captured.vectorization!.contours.every(
          (polygon) => polygon.area > 0 && polygon.isSimple,
        ),
        isTrue,
      );

      await controller.confirmReview();
      await controller.optimize();
      final optimized = container.read(cuttingWorkspaceProvider);
      expect(optimized.error, isNull);
      expect(optimized.job.stage, CuttingJobStage.optimized);
      expect(optimized.job.layouts, hasLength(2));

      await controller.export(LayoutExportFormat.svg);
      final exported = container.read(cuttingWorkspaceProvider);
      expect(exported.error, isNull);
      expect(exported.lastExport?.bytes, greaterThan(0));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
