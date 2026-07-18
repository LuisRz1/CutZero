import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';

final class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const destinations = [
    NavigationDestination(
      icon: Icon(Icons.space_dashboard_outlined),
      selectedIcon: Icon(Icons.space_dashboard),
      label: 'Trabajo',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Inventario',
    ),
    NavigationDestination(
      icon: Icon(Icons.memory_outlined),
      selectedIcon: Icon(Icons.memory),
      label: 'Agente',
    ),
  ];

  void _navigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      if (!wide) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _navigate,
            destinations: destinations,
          ),
        );
      }
      return Scaffold(
        body: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: CutZeroColors.surface,
                border: Border(right: BorderSide(color: CutZeroColors.line)),
              ),
              child: NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _navigate,
                labelType: NavigationRailLabelType.all,
                leading: const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 20),
                  child: _BrandMark(compact: true),
                ),
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: Text(destination.label),
                    ),
                ],
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    },
  );
}

final class CutZeroAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CutZeroAppBar({this.actions = const [], super.key});

  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 68,
    titleSpacing: 20,
    title: const _BrandMark(),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1),
    ),
  );
}

final class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'CutZero',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: CutZeroColors.skyDark,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.content_cut, color: Colors.white, size: 20),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          Text(
            'CutZero',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: CutZeroColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    ),
  );
}
