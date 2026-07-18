import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';

import '../../cutting_job/application/ports.dart';

final class GemmaModelManager implements LocalModelPort {
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

  @override
  Future<bool> isInstalled() async {
    await initialize();
    return FlutterGemma.isModelInstalled(modelId);
  }

  @override
  Stream<LocalModelStatus> install() async* {
    await initialize();
    if (await FlutterGemma.isModelInstalled(modelId)) {
      yield const LocalModelStatus(
        state: LocalModelState.ready,
        progress: 100,
        message: 'Gemma 4 ya esta instalado.',
      );
      return;
    }
    final statuses = StreamController<LocalModelStatus>();
    statuses.add(
      const LocalModelStatus(
        state: LocalModelState.downloading,
        message: 'Descargando Gemma 4 E2B.',
      ),
    );
    unawaited(_installInto(statuses));
    yield* statuses.stream;
  }

  Future<void> _installInto(StreamController<LocalModelStatus> statuses) async {
    try {
      await FlutterGemma.installModel(
            modelType: ModelType.gemma4,
            fileType: ModelFileType.task,
          )
          .fromNetwork(modelUrl, token: huggingFaceToken, foreground: true)
          .withProgress(
            (value) => statuses.add(
              LocalModelStatus(
                state: LocalModelState.downloading,
                progress: value,
                message: 'Descargando Gemma 4 E2B.',
              ),
            ),
          )
          .install();
      statuses.add(
        const LocalModelStatus(
          state: LocalModelState.ready,
          progress: 100,
          message: 'Gemma 4 esta listo para trabajar sin conexion.',
        ),
      );
    } catch (error) {
      statuses.add(
        LocalModelStatus(
          state: LocalModelState.failed,
          message: 'No se pudo instalar Gemma 4: $error',
        ),
      );
    } finally {
      await statuses.close();
    }
  }

  @override
  Future<void> uninstall() async {
    await initialize();
    if (await FlutterGemma.isModelInstalled(modelId)) {
      await FlutterGemma.uninstallModel(modelId);
      await FlutterGemma.clearActiveInferenceIdentity();
    }
  }
}
