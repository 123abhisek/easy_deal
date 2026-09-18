import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  ImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageAsBase64({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      final mimeType = file.name.endsWith('.png') ? 'image/png' : 'image/jpeg';
      return 'data:$mimeType;base64,$base64Str';
    } catch (_) {
      return null;
    }
  }

  static Future<List<String>> pickMultiImagesAsBase64({int maxImages = 5}) async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
        limit: maxImages,
      );
      final List<String> base64List = [];
      for (final file in files) {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);
        final mimeType = file.name.endsWith('.png') ? 'image/png' : 'image/jpeg';
        base64List.add('data:$mimeType;base64,$base64Str');
      }
      return base64List;
    } catch (_) {
      return [];
    }
  }
}
