import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';

enum GemmaModelState { notInstalled, downloading, ready, failed }

final class GemmaModelStatus {
  const GemmaModelStatus({
    required this.state,
    this.progress = 0,
    this.message = '',
  });

  final GemmaModelState state;
  final int progress;
  final String message;
}

final class GemmaModelManager {
  GemmaModelManager({this.huggingFaceToken});

  static const modelId = 'gemma-4-E2B-it.litertlm';
  static const modelUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';
  static const approximateSizeGb = 2.4;

  final String? huggingFaceToken;
  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= FlutterGemma.initialize(
    huggingFaceToken: huggingFaceToken,
    inferenceEngines: const [LiteRtLmEngine()],
  );

  Future<bool> isInstalled() async {
    await initialize();
    return FlutterGemma.isModelInstalled(modelId);
  }

  Stream<GemmaModelStatus> install() async* {
    await initialize();
    if (await FlutterGemma.isModelInstalled(modelId)) {
      yield const GemmaModelStatus(
        state: GemmaModelState.ready,
        progress: 100,
        message: 'Gemma 4 ya esta instalado.',
      );
      return;
    }
    final statuses = StreamController<GemmaModelStatus>();
    statuses.add(
      const GemmaModelStatus(
        state: GemmaModelState.downloading,
        message: 'Descargando Gemma 4 E2B.',
      ),
    );
    unawaited(_installInto(statuses));
    yield* statuses.stream;
  }

  Future<void> _installInto(StreamController<GemmaModelStatus> statuses) async {
    try {
      await FlutterGemma.installModel(
            modelType: ModelType.gemma4,
            fileType: ModelFileType.task,
          )
          .fromNetwork(modelUrl, token: huggingFaceToken, foreground: true)
          .withProgress(
            (value) => statuses.add(
              GemmaModelStatus(
                state: GemmaModelState.downloading,
                progress: value,
                message: 'Descargando Gemma 4 E2B.',
              ),
            ),
          )
          .install();
      statuses.add(
        const GemmaModelStatus(
          state: GemmaModelState.ready,
          progress: 100,
          message: 'Gemma 4 esta listo para trabajar sin conexion.',
        ),
      );
    } catch (error) {
      statuses.add(
        GemmaModelStatus(
          state: GemmaModelState.failed,
          message: 'No se pudo instalar Gemma 4: $error',
        ),
      );
    } finally {
      await statuses.close();
    }
  }

  Future<void> uninstall() async {
    await initialize();
    if (await FlutterGemma.isModelInstalled(modelId)) {
      await FlutterGemma.uninstallModel(modelId);
      await FlutterGemma.clearActiveInferenceIdentity();
    }
  }
}
