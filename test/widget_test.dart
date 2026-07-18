import 'package:cutzero/app/providers.dart';
import 'package:cutzero/app/theme/app_theme.dart';
import 'package:cutzero/app/cutzero_app.dart';
import 'package:cutzero/core/infrastructure/database/app_database.dart';
import 'package:cutzero/features/cutting_job/application/ports.dart';
import 'package:cutzero/features/cutting_job/presentation/cutting_job_controller.dart';
import 'package:cutzero/features/cutting_job/presentation/workspace_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('completes capture review and optimization from the interface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(820, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          localModelProvider.overrideWithValue(const _UnavailableLocalModel()),
        ],
        child: MaterialApp(
          theme: CutZeroTheme.light,
          home: const WorkspaceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CutZero'), findsOneWidget);
    expect(find.text('Pedido bolsos Aurora'), findsOneWidget);

    final analyze = find.byKey(const Key('analyzeFixtureButton'));
    await tester.ensureVisible(analyze);
    await tester.tap(analyze);
    await tester.pumpAndSettle();
    expect(find.text('94%'), findsOneWidget);

    final confirm = find.byKey(const Key('confirmReviewButton'));
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.text('Revisado'), findsOneWidget);

    final optimize = find.byKey(const Key('optimizeButton'));
    await tester.ensureVisible(optimize);
    await tester.tap(optimize);
    await tester.pumpAndSettle();

    expect(find.text('Plan de corte'), findsOneWidget);
    expect(find.text('Material usado'), findsOneWidget);
    expect(find.byKey(const Key('exportPdfButton')), findsOneWidget);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('keeps the workspace stable on a compact phone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          localModelProvider.overrideWithValue(const _UnavailableLocalModel()),
        ],
        child: MaterialApp(
          theme: CutZeroTheme.light,
          home: const WorkspaceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Pedido bolsos Aurora'), findsOneWidget);
    expect(find.byKey(const Key('cameraButton')), findsOneWidget);
  });

  testWidgets('navigates between workspace inventory and local agent', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          localModelProvider.overrideWithValue(const _UnavailableLocalModel()),
        ],
        child: const CutZeroApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CutZeroApp)),
    );
    final controller = container.read(cuttingWorkspaceProvider.notifier);
    await controller.analyzeFixture();
    await controller.confirmReview();
    await controller.optimize();
    await controller.saveRemnant();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inventario'));
    await tester.pumpAndSettle();
    expect(find.text('Inventario de retales'), findsOneWidget);
    expect(find.textContaining('Retal Celeste'), findsOneWidget);

    await tester.tap(find.text('Agente'));
    await tester.pumpAndSettle();
    expect(find.text('Agente local'), findsOneWidget);
    expect(find.byKey(const Key('runAgentButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('runAgentButton')));
    await tester.pumpAndSettle();
    expect(find.text('search_remnants'), findsWidgets);
    expect(find.text('calculate_cost'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

final class _UnavailableLocalModel implements LocalModelPort {
  const _UnavailableLocalModel();

  @override
  Future<bool> isInstalled() async => false;

  @override
  Stream<LocalModelStatus> install() => const Stream.empty();

  @override
  Future<void> uninstall() async {}
}
