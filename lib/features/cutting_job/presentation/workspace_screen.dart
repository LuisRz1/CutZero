import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_shell.dart';
import '../../../app/theme/app_theme.dart';
import '../application/ports.dart';
import '../domain/models.dart';
import 'cutting_job_controller.dart';
import 'widgets/layout_canvas.dart';

final class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cuttingWorkspaceProvider);
    final controller = ref.read(cuttingWorkspaceProvider.notifier);
    return Scaffold(
      appBar: const CutZeroAppBar(),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _JobHeader(state: state),
                        const SizedBox(height: 18),
                        _StageTrack(stage: state.job.stage),
                        _Notice(state: state, onClose: controller.clearNotice),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 860;
                            final capture = _CapturePanel(
                              state: state,
                              controller: controller,
                            );
                            final review = _ReviewPanel(
                              state: state,
                              controller: controller,
                            );
                            if (!wide) {
                              return Column(
                                children: [
                                  capture,
                                  const SizedBox(height: 16),
                                  review,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 6, child: capture),
                                const SizedBox(width: 16),
                                Expanded(flex: 5, child: review),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.025),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: state.selectedLayout == null
                              ? _ReadyToOptimize(
                                  key: const ValueKey('ready'),
                                  state: state,
                                  onOptimize: controller.optimize,
                                )
                              : _ResultsPanel(
                                  key: ValueKey(state.job.layouts.length),
                                  state: state,
                                  controller: controller,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _JobHeader extends StatelessWidget {
  const _JobHeader({required this.state});

  final CuttingWorkspaceState state;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.job.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
            Text(
              '${state.job.material.name}  |  ${state.job.instances.length} piezas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CutZeroColors.ink.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      _StatusLabel(stage: state.job.stage),
    ],
  );
}

final class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.stage});

  final CuttingJobStage stage;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: _stageColor(stage).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      _stageName(stage),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: _stageColor(stage),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

final class _StageTrack extends StatelessWidget {
  const _StageTrack({required this.stage});

  final CuttingJobStage stage;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final active = switch (stage) {
        CuttingJobStage.draft => 0,
        CuttingJobStage.captured => 0,
        CuttingJobStage.reviewed => 1,
        CuttingJobStage.optimizing => 2,
        CuttingJobStage.optimized => 2,
        CuttingJobStage.exported => 3,
      };
      final compact = constraints.maxWidth < 560;
      const labels = ['Captura', 'Revision', 'Optimizacion', 'Salida'];
      const icons = [
        Icons.document_scanner_outlined,
        Icons.fact_check_outlined,
        Icons.auto_graph_outlined,
        Icons.file_present_outlined,
      ];
      return Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            Expanded(
              child: Semantics(
                label: labels[index],
                selected: index == active,
                child: Tooltip(
                  message: labels[index],
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 44,
                    padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
                    decoration: BoxDecoration(
                      color: index <= active
                          ? CutZeroColors.sky.withValues(alpha: 0.12)
                          : CutZeroColors.surface,
                      border: Border.all(
                        color: index <= active
                            ? CutZeroColors.sky
                            : CutZeroColors.line,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          size: 18,
                          color: index <= active
                              ? CutZeroColors.skyDark
                              : CutZeroColors.ink.withValues(alpha: 0.5),
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              labels[index],
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (index < labels.length - 1) const SizedBox(width: 8),
          ],
        ],
      );
    },
  );
}

final class _Notice extends StatelessWidget {
  const _Notice({required this.state, required this.onClose});

  final CuttingWorkspaceState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final text = state.error ?? state.message;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: text.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Material(
                color:
                    (state.error == null
                            ? CutZeroColors.mint
                            : CutZeroColors.coral)
                        .withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
                  child: Row(
                    children: [
                      Icon(
                        state.error == null
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        size: 20,
                        color: state.error == null
                            ? CutZeroColors.mint
                            : CutZeroColors.coral,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(text)),
                      IconButton(
                        onPressed: onClose,
                        tooltip: 'Cerrar aviso',
                        icon: const Icon(Icons.close, size: 19),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

final class _CapturePanel extends StatelessWidget {
  const _CapturePanel({required this.state, required this.controller});

  final CuttingWorkspaceState state;
  final CuttingWorkspaceController controller;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.document_scanner_outlined,
            title: 'Captura de moldes',
            trailing: state.task == WorkspaceTask.capture
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ColoredBox(
                color: const Color(0xFFDDECEF),
                child: state.captureBytes == null
                    ? Image.asset(state.capturePath, fit: BoxFit.cover)
                    : Image.memory(state.captureBytes!, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Tooltip(
                message: 'Tomar foto',
                child: IconButton.outlined(
                  key: const Key('cameraButton'),
                  tooltip: 'Tomar foto',
                  onPressed: state.isBusy
                      ? null
                      : () => unawaited(
                          controller.capture(ImageCaptureSource.camera),
                        ),
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Elegir imagen',
                child: IconButton.outlined(
                  key: const Key('galleryButton'),
                  tooltip: 'Elegir imagen',
                  onPressed: state.isBusy
                      ? null
                      : () => unawaited(
                          controller.capture(ImageCaptureSource.gallery),
                        ),
                  icon: const Icon(Icons.photo_library_outlined),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('analyzeFixtureButton'),
                  onPressed: state.isBusy
                      ? null
                      : () => unawaited(controller.analyzeFixture()),
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Analizar captura'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

final class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({required this.state, required this.controller});

  final CuttingWorkspaceState state;
  final CuttingWorkspaceController controller;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.straighten,
            title: 'Revision tecnica',
            trailing: state.vectorization == null
                ? const Text('Pendiente')
                : Text('${(state.vectorization!.confidence * 100).round()}%'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.space_bar, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Separacion entre piezas')),
              Text('${state.job.gapMm.round()} mm'),
            ],
          ),
          Slider(
            value: state.job.gapMm,
            min: 0,
            max: 20,
            divisions: 20,
            label: '${state.job.gapMm.round()} mm',
            onChanged: state.isBusy
                ? null
                : (value) => unawaited(controller.updateGap(value)),
          ),
          const Divider(height: 24),
          for (final part in state.job.parts)
            _PartQuantityRow(
              part: part,
              total: state.job.instances.length,
              enabled: !state.isBusy,
              onChange: (delta) =>
                  unawaited(controller.changePartQuantity(part.id, delta)),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('confirmReviewButton'),
            onPressed: state.canReview
                ? () => unawaited(controller.confirmReview())
                : null,
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(
              state.job.stage.index >= CuttingJobStage.reviewed.index
                  ? 'Revision confirmada'
                  : 'Confirmar revision',
            ),
          ),
        ],
      ),
    ),
  );
}

final class _PartQuantityRow extends StatelessWidget {
  const _PartQuantityRow({
    required this.part,
    required this.total,
    required this.enabled,
    required this.onChange,
  });

  final PartTemplate part;
  final int total;
  final bool enabled;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(
          part.grainLocked ? Icons.lock_outline : Icons.rotate_90_degrees_ccw,
          size: 18,
          color: part.grainLocked ? CutZeroColors.amber : CutZeroColors.skyDark,
        ),
        const SizedBox(width: 9),
        Expanded(child: Text(part.name, overflow: TextOverflow.ellipsis)),
        IconButton(
          onPressed: enabled && part.quantity > 1 ? () => onChange(-1) : null,
          tooltip: 'Reducir ${part.name}',
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 30,
          child: Text(
            '${part.quantity}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: enabled && total < 20 ? () => onChange(1) : null,
          tooltip: 'Aumentar ${part.name}',
          icon: const Icon(Icons.add),
        ),
      ],
    ),
  );
}

final class _ReadyToOptimize extends StatelessWidget {
  const _ReadyToOptimize({
    required this.state,
    required this.onOptimize,
    super.key,
  });

  final CuttingWorkspaceState state;
  final Future<void> Function() onOptimize;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CutZeroColors.sky.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.auto_graph, color: CutZeroColors.skyDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimizacion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  state.canOptimize
                      ? 'Geometria validada para ${state.job.instances.length} piezas.'
                      : 'La captura debe quedar revisada antes del calculo.',
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            key: const Key('optimizeButton'),
            onPressed: state.canOptimize ? () => unawaited(onOptimize()) : null,
            icon: state.task == WorkspaceTask.optimize
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.play_arrow),
            label: const Text('Optimizar'),
          ),
        ],
      ),
    ),
  );
}

final class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.state,
    required this.controller,
    super.key,
  });

  final CuttingWorkspaceState state;
  final CuttingWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final layout = state.selectedLayout!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle(
              icon: Icons.grid_view,
              title: 'Plan de corte',
              trailing: Text('${layout.placements.length} piezas'),
            ),
            const SizedBox(height: 14),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.percent),
                  label: Text('Aprovechamiento'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('Retal reutilizable'),
                ),
              ],
              selected: {state.selectedLayoutIndex},
              onSelectionChanged: state.isBusy
                  ? null
                  : (selection) => controller.selectLayout(selection.first),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: LayoutCanvas(
                key: ValueKey(layout.id),
                job: state.job,
                layout: layout,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Metric(
                  label: 'Material usado',
                  value:
                      '${layout.metrics.utilizationPercent.toStringAsFixed(1)}%',
                  icon: Icons.percent,
                  color: CutZeroColors.skyDark,
                ),
                _Metric(
                  label: 'Retal mayor',
                  value:
                      '${(layout.metrics.largestReusableRemnantMm2 / 1000000).toStringAsFixed(2)} m2',
                  icon: Icons.inventory_2_outlined,
                  color: CutZeroColors.mint,
                ),
                _Metric(
                  label: 'Costo desperdicio',
                  value: layout.metrics.estimatedWasteCost.toStringAsFixed(2),
                  icon: Icons.payments_outlined,
                  color: CutZeroColors.coral,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: state.isBusy || state.remnantSaved
                      ? null
                      : () => unawaited(controller.saveRemnant()),
                  icon: Icon(
                    state.remnantSaved ? Icons.check : Icons.add_box_outlined,
                  ),
                  label: Text(
                    state.remnantSaved ? 'Retal guardado' : 'Guardar retal',
                  ),
                ),
                Tooltip(
                  message: 'Exportar SVG',
                  child: IconButton.outlined(
                    key: const Key('exportSvgButton'),
                    tooltip: 'Exportar SVG',
                    onPressed: state.isBusy
                        ? null
                        : () => unawaited(
                            controller.export(LayoutExportFormat.svg),
                          ),
                    icon: const Icon(Icons.code),
                  ),
                ),
                Tooltip(
                  message: 'Exportar PDF',
                  child: IconButton.filled(
                    key: const Key('exportPdfButton'),
                    tooltip: 'Exportar PDF',
                    onPressed: state.isBusy
                        ? null
                        : () => unawaited(
                            controller.export(LayoutExportFormat.pdf),
                          ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                ),
                Tooltip(
                  message: 'Compartir archivo',
                  child: IconButton.outlined(
                    tooltip: 'Compartir archivo',
                    onPressed: state.isBusy || state.lastExport == null
                        ? null
                        : () => unawaited(controller.shareLastExport()),
                    icon: const Icon(Icons.share_outlined),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 176),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    ),
  );
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: CutZeroColors.skyDark, size: 22),
      const SizedBox(width: 9),
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      ?trailing,
    ],
  );
}

String _stageName(CuttingJobStage stage) => switch (stage) {
  CuttingJobStage.draft => 'Borrador',
  CuttingJobStage.captured => 'Capturado',
  CuttingJobStage.reviewed => 'Revisado',
  CuttingJobStage.optimizing => 'Calculando',
  CuttingJobStage.optimized => 'Optimizado',
  CuttingJobStage.exported => 'Exportado',
};

Color _stageColor(CuttingJobStage stage) => switch (stage) {
  CuttingJobStage.draft => CutZeroColors.ink,
  CuttingJobStage.captured => CutZeroColors.skyDark,
  CuttingJobStage.reviewed => CutZeroColors.mint,
  CuttingJobStage.optimizing => CutZeroColors.amber,
  CuttingJobStage.optimized => CutZeroColors.mint,
  CuttingJobStage.exported => CutZeroColors.skyDark,
};
