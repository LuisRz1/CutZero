import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_shell.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../cutting_job/application/ports.dart';
import '../../cutting_job/presentation/cutting_job_controller.dart';
import '../infrastructure/gemma_model_manager.dart';

final class AgentScreen extends ConsumerStatefulWidget {
  const AgentScreen({super.key});

  @override
  ConsumerState<AgentScreen> createState() => _AgentScreenState();
}

final class _AgentScreenState extends ConsumerState<AgentScreen> {
  var _useGemma = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(cuttingWorkspaceProvider.notifier).checkModel());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cuttingWorkspaceProvider);
    final controller = ref.read(cuttingWorkspaceProvider.notifier);
    final invocations = ref.watch(toolInvocationsProvider(state.job.id));
    return Scaffold(
      appBar: const CutZeroAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Agente local',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    state.job.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _ModelPanel(
                    state: state,
                    onInstall: controller.installModel,
                    onUninstall: controller.uninstallModel,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.account_tree_outlined,
                                color: CutZeroColors.skyDark,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Ejecucion',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                invocations.when(
                                  data: (items) => '${items.length} registros',
                                  loading: () => 'Consultando',
                                  error: (error, stack) => 'Sin registro',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                icon: Icon(Icons.science_outlined),
                                label: Text('Demostracion'),
                              ),
                              ButtonSegment(
                                value: true,
                                icon: Icon(Icons.memory),
                                label: Text('Gemma 4 local'),
                              ),
                            ],
                            selected: {_useGemma},
                            onSelectionChanged: state.isBusy
                                ? null
                                : (values) =>
                                      setState(() => _useGemma = values.first),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: CutZeroColors.canvas,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: CutZeroColors.line),
                            ),
                            child: Text(state.job.instruction),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            key: const Key('runAgentButton'),
                            onPressed:
                                state.isBusy ||
                                    (_useGemma &&
                                        state.modelStatus.state !=
                                            GemmaModelState.ready)
                                ? null
                                : () => unawaited(
                                    controller.runAgent(useGemma: _useGemma),
                                  ),
                            icon: state.task == WorkspaceTask.agent
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.play_arrow),
                            label: Text(
                              state.task == WorkspaceTask.agent
                                  ? 'Ejecutando flujo'
                                  : 'Ejecutar agente',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TracePanel(events: state.agentEvents),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _ModelPanel extends StatelessWidget {
  const _ModelPanel({
    required this.state,
    required this.onInstall,
    required this.onUninstall,
  });

  final CuttingWorkspaceState state;
  final Future<void> Function() onInstall;
  final Future<void> Function() onUninstall;

  @override
  Widget build(BuildContext context) {
    final status = state.modelStatus;
    final ready = status.state == GemmaModelState.ready;
    final downloading = status.state == GemmaModelState.downloading;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (ready ? CutZeroColors.mint : CutZeroColors.sky)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.memory,
                    color: ready ? CutZeroColors.mint : CutZeroColors.skyDark,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gemma 4 E2B',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        status.message.isEmpty
                            ? 'Modelo multimodal local | 2.4 GB'
                            : status.message,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (ready)
                  IconButton.outlined(
                    onPressed: state.isBusy
                        ? null
                        : () => unawaited(onUninstall()),
                    tooltip: 'Eliminar modelo',
                    icon: const Icon(Icons.delete_outline),
                  )
                else
                  FilledButton.icon(
                    onPressed: state.isBusy
                        ? null
                        : () => unawaited(onInstall()),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Instalar'),
                  ),
              ],
            ),
            if (downloading) ...[
              const SizedBox(height: 14),
              LinearProgressIndicator(value: status.progress / 100),
              const SizedBox(height: 6),
              Text(
                '${status.progress}%',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _TracePanel extends StatelessWidget {
  const _TracePanel({required this.events});

  final List<AgentEvent> events;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: CutZeroColors.skyDark,
              ),
              const SizedBox(width: 9),
              Text(
                'Trazabilidad',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: events.isEmpty
                ? const Padding(
                    key: ValueKey('empty-trace'),
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Center(
                      child: Text('Aun no hay una ejecucion activa.'),
                    ),
                  )
                : Column(
                    key: ValueKey('trace-${events.length}'),
                    children: [
                      for (var index = 0; index < events.length; index++)
                        _TraceEntry(
                          event: events[index],
                          last: index == events.length - 1,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

final class _TraceEntry extends StatelessWidget {
  const _TraceEntry({required this.event, required this.last});

  final AgentEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (event.type) {
      AgentEventType.message => (
        Icons.chat_bubble_outline,
        CutZeroColors.skyDark,
      ),
      AgentEventType.toolStarted => (
        Icons.play_circle_outline,
        CutZeroColors.amber,
      ),
      AgentEventType.toolCompleted => (
        Icons.check_circle_outline,
        CutZeroColors.mint,
      ),
      AgentEventType.completed => (Icons.task_alt, CutZeroColors.mint),
      AgentEventType.failed => (Icons.error_outline, CutZeroColors.coral),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Icon(icon, color: color, size: 21),
              if (!last)
                Container(
                  width: 1,
                  height: 38,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: CutZeroColors.line,
                ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.tool != null)
                  Text(
                    event.tool!,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                Text(event.message),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
