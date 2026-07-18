import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../agent/infrastructure/gemma_model_manager.dart';
import '../../inventory/application/create_remnant.dart';
import '../../optimization/application/run_optimization.dart';
import '../application/ports.dart';
import '../domain/models.dart';
import '../infrastructure/demo_fixture.dart';

enum WorkspaceTask { none, capture, optimize, export, agent, model }

const _keepValue = Object();

final class CuttingWorkspaceState {
  const CuttingWorkspaceState({
    required this.job,
    this.capturePath = 'assets/fixtures/eva_bag_manual.png',
    this.captureBytes,
    this.vectorization,
    this.selectedLayoutIndex = 0,
    this.task = WorkspaceTask.none,
    this.message = '',
    this.error,
    this.agentEvents = const [],
    this.remnantSaved = false,
    this.lastExport,
    this.modelStatus = const GemmaModelStatus(
      state: GemmaModelState.notInstalled,
    ),
  });

  final CuttingJob job;
  final String capturePath;
  final Uint8List? captureBytes;
  final VectorizationResult? vectorization;
  final int selectedLayoutIndex;
  final WorkspaceTask task;
  final String message;
  final String? error;
  final List<AgentEvent> agentEvents;
  final bool remnantSaved;
  final ExportedLayout? lastExport;
  final GemmaModelStatus modelStatus;

  bool get isBusy => task != WorkspaceTask.none;
  bool get canReview =>
      vectorization != null && job.stage == CuttingJobStage.captured && !isBusy;
  bool get canOptimize => job.stage == CuttingJobStage.reviewed && !isBusy;
  NestingLayout? get selectedLayout => job.layouts.isEmpty
      ? null
      : job.layouts[selectedLayoutIndex.clamp(0, job.layouts.length - 1)];

  CuttingWorkspaceState copyWith({
    CuttingJob? job,
    String? capturePath,
    Object? captureBytes = _keepValue,
    Object? vectorization = _keepValue,
    int? selectedLayoutIndex,
    WorkspaceTask? task,
    String? message,
    Object? error = _keepValue,
    List<AgentEvent>? agentEvents,
    bool? remnantSaved,
    Object? lastExport = _keepValue,
    GemmaModelStatus? modelStatus,
  }) => CuttingWorkspaceState(
    job: job ?? this.job,
    capturePath: capturePath ?? this.capturePath,
    captureBytes: identical(captureBytes, _keepValue)
        ? this.captureBytes
        : captureBytes as Uint8List?,
    vectorization: identical(vectorization, _keepValue)
        ? this.vectorization
        : vectorization as VectorizationResult?,
    selectedLayoutIndex: selectedLayoutIndex ?? this.selectedLayoutIndex,
    task: task ?? this.task,
    message: message ?? this.message,
    error: identical(error, _keepValue) ? this.error : error as String?,
    agentEvents: agentEvents ?? this.agentEvents,
    remnantSaved: remnantSaved ?? this.remnantSaved,
    lastExport: identical(lastExport, _keepValue)
        ? this.lastExport
        : lastExport as ExportedLayout?,
    modelStatus: modelStatus ?? this.modelStatus,
  );
}

final cuttingWorkspaceProvider =
    NotifierProvider<CuttingWorkspaceController, CuttingWorkspaceState>(
      CuttingWorkspaceController.new,
    );

final class CuttingWorkspaceController extends Notifier<CuttingWorkspaceState> {
  final Uuid _uuid = const Uuid();

  @override
  CuttingWorkspaceState build() {
    final initial = CuttingWorkspaceState(job: DemoFixture.createJob());
    Future<void>.microtask(_restoreOrSeed);
    return initial;
  }

  Future<void> _restoreOrSeed() async {
    try {
      final repository = ref.read(cuttingJobRepositoryProvider);
      final existing = await repository.findById(state.job.id);
      if (!ref.mounted) return;
      if (existing == null) {
        await repository.save(state.job);
      } else {
        state = state.copyWith(
          job: existing,
          selectedLayoutIndex: 0,
          remnantSaved: false,
        );
      }
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        error: 'No se pudo abrir el trabajo local: $error',
      );
    }
  }

  Future<void> analyzeFixture() async {
    await _vectorize(path: 'assets/fixtures/eva_bag_manual.png', bytes: null);
  }

  Future<void> capture(ImageCaptureSource source) async {
    if (state.isBusy) return;
    state = state.copyWith(
      task: WorkspaceTask.capture,
      message: '',
      error: null,
    );
    try {
      final image = await ref.read(imageAcquisitionProvider).pick(source);
      if (image == null || !ref.mounted) {
        if (ref.mounted) state = state.copyWith(task: WorkspaceTask.none);
        return;
      }
      await _vectorize(path: image.path, bytes: image.bytes);
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        task: WorkspaceTask.none,
        error: 'No se pudo procesar la captura: $error',
      );
    }
  }

  Future<void> _vectorize({
    required String path,
    required Uint8List? bytes,
  }) async {
    if (state.task == WorkspaceTask.none) {
      state = state.copyWith(
        task: WorkspaceTask.capture,
        message: '',
        error: null,
      );
    }
    try {
      final result = await ref
          .read(visionProvider)
          .vectorize(
            VectorizationRequest(imagePath: path, referenceLengthMm: 100),
          );
      if (!ref.mounted) return;
      final updatedJob = state.job.copyWith(
        stage: CuttingJobStage.captured,
        layouts: const [],
      );
      await ref.read(cuttingJobRepositoryProvider).save(updatedJob);
      if (!ref.mounted) return;
      state = state.copyWith(
        job: updatedJob,
        capturePath: path,
        captureBytes: bytes,
        vectorization: result,
        selectedLayoutIndex: 0,
        task: WorkspaceTask.none,
        message: 'Contornos detectados. Revisa las medidas antes de continuar.',
        error: null,
        remnantSaved: false,
        lastExport: null,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        task: WorkspaceTask.none,
        error: 'No se pudo vectorizar la captura: $error',
      );
    }
  }

  Future<void> confirmReview() async {
    if (!state.canReview) return;
    final updatedJob = state.job.copyWith(stage: CuttingJobStage.reviewed);
    await _saveJob(
      updatedJob,
      message: 'Geometria revisada y lista para optimizar.',
    );
  }

  Future<void> updateGap(double value) async {
    final updatedJob = state.job.copyWith(
      gapMm: value.roundToDouble(),
      stage: CuttingJobStage.captured,
      layouts: const [],
    );
    await _saveJob(updatedJob, clearResults: true);
  }

  Future<void> changePartQuantity(String templateId, int delta) async {
    final currentTotal = state.job.instances.length;
    final updatedParts = [
      for (final part in state.job.parts)
        if (part.id == templateId)
          part.copyWith(
            quantity: (part.quantity + delta).clamp(
              1,
              20 - currentTotal + part.quantity,
            ),
          )
        else
          part,
    ];
    final updatedJob = state.job.copyWith(
      parts: updatedParts,
      stage: CuttingJobStage.captured,
      layouts: const [],
    );
    await _saveJob(updatedJob, clearResults: true);
  }

  Future<void> optimize() async {
    if (!state.canOptimize) return;
    state = state.copyWith(
      job: state.job.copyWith(stage: CuttingJobStage.optimizing),
      task: WorkspaceTask.optimize,
      message: '',
      error: null,
    );
    try {
      final OptimizationResult result = await ref.read(runOptimizationProvider)(
        state.job.copyWith(stage: CuttingJobStage.reviewed),
      );
      if (!ref.mounted) return;
      final updatedJob = state.job.copyWith(
        stage: CuttingJobStage.optimized,
        layouts: result.layouts,
      );
      await ref.read(cuttingJobRepositoryProvider).save(updatedJob);
      if (!ref.mounted) return;
      state = state.copyWith(
        job: updatedJob,
        selectedLayoutIndex: 0,
        task: WorkspaceTask.none,
        message: 'Dos alternativas fueron calculadas y validadas.',
        error: null,
        remnantSaved: false,
        lastExport: null,
      );
    } catch (error) {
      if (!ref.mounted) return;
      final restored = state.job.copyWith(stage: CuttingJobStage.reviewed);
      state = state.copyWith(
        job: restored,
        task: WorkspaceTask.none,
        error: 'No se pudo completar la optimizacion: $error',
      );
    }
  }

  void selectLayout(int index) {
    if (index < 0 || index >= state.job.layouts.length) return;
    state = state.copyWith(selectedLayoutIndex: index);
  }

  Future<void> export(LayoutExportFormat format) async {
    final layout = state.selectedLayout;
    if (layout == null || state.isBusy) return;
    state = state.copyWith(
      task: WorkspaceTask.export,
      message: '',
      error: null,
    );
    try {
      final exported = await ref
          .read(layoutExporterProvider)
          .export(
            LayoutExportRequest(job: state.job, layout: layout, format: format),
          );
      if (!ref.mounted) return;
      final updatedJob = state.job.copyWith(stage: CuttingJobStage.exported);
      await ref.read(cuttingJobRepositoryProvider).save(updatedJob);
      if (!ref.mounted) return;
      state = state.copyWith(
        job: updatedJob,
        task: WorkspaceTask.none,
        lastExport: exported,
        message: 'Archivo guardado en ${exported.path}',
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        task: WorkspaceTask.none,
        error: 'No se pudo exportar el layout: $error',
      );
    }
  }

  Future<void> shareLastExport() async {
    final exported = state.lastExport;
    if (exported == null || state.isBusy) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(exported.path)],
          text: 'Layout de corte generado por CutZero',
          subject: state.job.name,
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(error: 'No se pudo compartir el archivo: $error');
    }
  }

  Future<void> saveRemnant() async {
    final layout = state.selectedLayout;
    if (layout == null || state.remnantSaved || state.isBusy) return;
    final CreateRemnant create = ref.read(createRemnantProvider);
    final remnant = create(
      job: state.job,
      layout: layout,
      id: _uuid.v4(),
      location: 'Estante principal',
    );
    if (remnant == null) {
      state = state.copyWith(
        error: 'No queda un retal reutilizable con el tamano minimo.',
      );
      return;
    }
    try {
      await ref.read(remnantRepositoryProvider).save(remnant);
      if (!ref.mounted) return;
      state = state.copyWith(
        remnantSaved: true,
        message: '${remnant.name} fue agregado al inventario.',
        error: null,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(error: 'No se pudo guardar el retal: $error');
    }
  }

  Future<void> runAgent({required bool useGemma}) async {
    if (state.isBusy) return;
    state = state.copyWith(
      task: WorkspaceTask.agent,
      message: '',
      error: null,
      agentEvents: const [],
    );
    final agent = ref.read(
      useGemma ? gemmaAgentProvider : fixtureAgentProvider,
    );
    try {
      await for (final event in agent.run(
        AgentRequest(instruction: state.job.instruction, job: state.job),
      )) {
        if (!ref.mounted) return;
        var updatedJob = state.job;
        if (event.type == AgentEventType.completed) {
          final layouts =
              (event.payload['layouts'] as List<Object?>? ?? const [])
                  .whereType<NestingLayout>()
                  .toList(growable: false);
          if (layouts.isNotEmpty) {
            updatedJob = updatedJob.copyWith(
              stage: CuttingJobStage.optimized,
              layouts: layouts,
            );
            await ref.read(cuttingJobRepositoryProvider).save(updatedJob);
          }
        }
        state = state.copyWith(
          job: updatedJob,
          selectedLayoutIndex: 0,
          agentEvents: [...state.agentEvents, event],
          error: event.type == AgentEventType.failed ? event.message : null,
        );
      }
      if (!ref.mounted) return;
      state = state.copyWith(
        task: WorkspaceTask.none,
        message: state.error == null
            ? 'El agente termino el flujo y registro cada herramienta.'
            : '',
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        task: WorkspaceTask.none,
        error: 'No se pudo ejecutar el agente: $error',
      );
    }
  }

  Future<void> checkModel() async {
    try {
      final installed = await ref.read(gemmaAvailabilityProvider)();
      if (!ref.mounted) return;
      state = state.copyWith(
        modelStatus: GemmaModelStatus(
          state: installed
              ? GemmaModelState.ready
              : GemmaModelState.notInstalled,
          progress: installed ? 100 : 0,
          message: installed
              ? 'Gemma 4 esta instalado.'
              : 'Gemma 4 aun no esta instalado.',
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        modelStatus: GemmaModelStatus(
          state: GemmaModelState.failed,
          message: 'No se pudo consultar el modelo: $error',
        ),
      );
    }
  }

  Future<void> installModel() async {
    if (state.isBusy) return;
    state = state.copyWith(task: WorkspaceTask.model, error: null);
    await for (final status in ref.read(gemmaModelManagerProvider).install()) {
      if (!ref.mounted) return;
      state = state.copyWith(modelStatus: status);
    }
    if (!ref.mounted) return;
    state = state.copyWith(task: WorkspaceTask.none);
  }

  Future<void> uninstallModel() async {
    if (state.isBusy) return;
    state = state.copyWith(task: WorkspaceTask.model, error: null);
    try {
      await ref.read(gemmaModelManagerProvider).uninstall();
      if (!ref.mounted) return;
      state = state.copyWith(
        task: WorkspaceTask.none,
        modelStatus: const GemmaModelStatus(
          state: GemmaModelState.notInstalled,
          message: 'Gemma 4 fue eliminado del dispositivo.',
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        task: WorkspaceTask.none,
        error: 'No se pudo eliminar el modelo: $error',
      );
    }
  }

  void clearNotice() {
    state = state.copyWith(message: '', error: null);
  }

  Future<void> _saveJob(
    CuttingJob job, {
    String message = '',
    bool clearResults = false,
  }) async {
    try {
      await ref.read(cuttingJobRepositoryProvider).save(job);
      if (!ref.mounted) return;
      state = state.copyWith(
        job: job,
        selectedLayoutIndex: clearResults ? 0 : state.selectedLayoutIndex,
        remnantSaved: clearResults ? false : state.remnantSaved,
        lastExport: clearResults ? null : state.lastExport,
        message: message,
        error: null,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(error: 'No se pudo guardar el trabajo: $error');
    }
  }
}
