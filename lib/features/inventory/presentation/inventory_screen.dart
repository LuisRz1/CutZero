import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_shell.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../cutting_job/domain/models.dart';

final class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remnants = ref.watch(remnantsProvider);
    return Scaffold(
      appBar: const CutZeroAppBar(),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inventario de retales',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              remnants.when(
                                data: (items) =>
                                    '${items.length} materiales reutilizables',
                                loading: () =>
                                    'Sincronizando almacenamiento local',
                                error: (error, stackTrace) =>
                                    'Inventario no disponible',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: () => ref.invalidate(remnantsProvider),
                        tooltip: 'Actualizar inventario',
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: remnants.when(
                        loading: () => const Center(
                          key: ValueKey('loading'),
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stackTrace) => _InventoryError(
                          key: const ValueKey('error'),
                          error: error,
                        ),
                        data: (items) => items.isEmpty
                            ? const _EmptyInventory(key: ValueKey('empty'))
                            : _RemnantList(
                                key: ValueKey('items-${items.length}'),
                                remnants: items,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _RemnantList extends StatelessWidget {
  const _RemnantList({required this.remnants, super.key});

  final List<Remnant> remnants;

  @override
  Widget build(BuildContext context) => ListView.separated(
    itemCount: remnants.length,
    separatorBuilder: (context, index) => const SizedBox(height: 10),
    itemBuilder: (context, index) => _RemnantTile(remnant: remnants[index]),
  );
}

final class _RemnantTile extends StatelessWidget {
  const _RemnantTile({required this.remnant});

  final Remnant remnant;

  @override
  Widget build(BuildContext context) {
    final bounds = remnant.polygon.bounds;
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 540;
          final icon = Container(
            width: compact ? 44 : 52,
            height: compact ? 44 : 52,
            decoration: BoxDecoration(
              color: CutZeroColors.mint.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: CutZeroColors.mint,
            ),
          );
          final area = Text(
            '${(remnant.polygon.area / 1000000).toStringAsFixed(2)} m2',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: CutZeroColors.skyDark),
          );
          final details = Wrap(
            spacing: 14,
            runSpacing: 7,
            children: [
              _Detail(
                icon: Icons.straighten,
                text: '${bounds.width.round()} x ${bounds.height.round()} mm',
              ),
              _Detail(
                icon: Icons.layers_outlined,
                text: '${remnant.thicknessMm.toStringAsFixed(1)} mm',
              ),
              _Detail(icon: Icons.palette_outlined, text: remnant.color),
              _Detail(icon: Icons.place_outlined, text: remnant.location),
            ],
          );
          return Padding(
            padding: const EdgeInsets.all(15),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          icon,
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              remnant.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          area,
                        ],
                      ),
                      const SizedBox(height: 12),
                      details,
                    ],
                  )
                : Row(
                    children: [
                      icon,
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              remnant.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 5),
                            details,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      area,
                    ],
                  ),
          );
        },
      ),
    );
  }
}

final class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: CutZeroColors.ink.withValues(alpha: 0.58)),
      const SizedBox(width: 5),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

final class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CutZeroColors.sky.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: CutZeroColors.skyDark,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Inventario vacio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Los retales guardados desde un plan de corte apareceran aqui.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

final class _InventoryError extends StatelessWidget {
  const _InventoryError({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'No se pudo abrir el inventario: $error',
      textAlign: TextAlign.center,
      style: const TextStyle(color: CutZeroColors.coral),
    ),
  );
}
