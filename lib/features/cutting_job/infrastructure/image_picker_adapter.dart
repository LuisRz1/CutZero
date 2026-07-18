import 'package:image_picker/image_picker.dart';

import '../application/ports.dart';

final class ImagePickerAdapter implements ImageAcquisitionPort {
  ImagePickerAdapter({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<CapturedImage?> pick(ImageCaptureSource source) async {
    final image = await _picker.pickImage(
      source: switch (source) {
        ImageCaptureSource.camera => ImageSource.camera,
        ImageCaptureSource.gallery => ImageSource.gallery,
      },
      imageQuality: 92,
      maxWidth: 2200,
    );
    if (image == null) return null;
    return CapturedImage(path: image.path, bytes: await image.readAsBytes());
  }
}
