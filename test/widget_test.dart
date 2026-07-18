import 'package:cutzero/app/providers.dart';
import 'package:cutzero/app/theme/app_theme.dart';
import 'package:cutzero/core/infrastructure/database/app_database.dart';
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
        overrides: [appDatabaseProvider.overrideWithValue(database)],
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
  });
}
