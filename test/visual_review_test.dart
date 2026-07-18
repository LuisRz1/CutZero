import 'dart:io';
import 'dart:ui' as ui;

import 'package:cutzero/app/providers.dart';
import 'package:cutzero/app/theme/app_theme.dart';
import 'package:cutzero/core/infrastructure/database/app_database.dart';
import 'package:cutzero/features/cutting_job/application/ports.dart';
import 'package:cutzero/features/cutting_job/presentation/cutting_job_controller.dart';
import 'package:cutzero/features/cutting_job/presentation/workspace_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _updateVisuals = bool.fromEnvironment('UPDATE_VISUALS');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;

  setUpAll(() async {
    if (!_updateVisuals) return;
    final font = await File('C:/Windows/Fonts/segoeui.ttf').readAsBytes();
    await ui.loadFontFromList(font, fontFamily: 'CutZeroVisual');
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('renders the mobile capture workspace', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpWorkspace(tester, database);

    await expectLater(
      find.byType(WorkspaceScreen),
      matchesGoldenFile('goldens/workspace-mobile.png'),
    );
  }, skip: !_updateVisuals);

  testWidgets('renders an optimized desktop layout', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpWorkspace(tester, database);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkspaceScreen)),
    );
    final controller = container.read(cuttingWorkspaceProvider.notifier);
    await controller.analyzeFixture();
    await controller.confirmReview();
    await controller.optimize();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Plan de corte'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(WorkspaceScreen),
      matchesGoldenFile('goldens/workspace-optimized-desktop.png'),
    );
  }, skip: !_updateVisuals);
}

Future<void> _pumpWorkspace(WidgetTester tester, AppDatabase database) async {
  final theme = CutZeroTheme.light;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        localModelProvider.overrideWithValue(const _UnavailableLocalModel()),
      ],
      child: MaterialApp(
        theme: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'CutZeroVisual'),
        ),
        home: const WorkspaceScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/fixtures/eva_bag_manual.png'),
      tester.element(find.byType(WorkspaceScreen)),
    ),
  );
  await tester.pumpAndSettle();
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
