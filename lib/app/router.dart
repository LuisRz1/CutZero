import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/agent/presentation/agent_screen.dart';
import '../features/cutting_job/presentation/workspace_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/workspace',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/workspace',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: WorkspaceScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: InventoryScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/agent',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AgentScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('No se encontro la vista solicitada.')),
  ),
);
