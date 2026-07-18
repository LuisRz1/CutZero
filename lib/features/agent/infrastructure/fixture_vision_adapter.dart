import '../../cutting_job/application/ports.dart';
import '../../cutting_job/application/demo_fixture.dart';

final class FixtureVisionAdapter implements VisionPort {
  const FixtureVisionAdapter();

  @override
  Future<VectorizationResult> vectorize(VectorizationRequest request) async {
    if (request.imagePath.trim().isEmpty || request.referenceLengthMm <= 0) {
      throw ArgumentError(
        'La captura y la referencia de escala son obligatorias.',
      );
    }
    final fixture = DemoFixture.createJob();
    return VectorizationResult(
      contours: fixture.parts
          .map((part) => part.polygon)
          .toList(growable: false),
      confidence: 0.94,
      requiresReview: true,
    );
  }
}
