import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidthPx.toDouble(),
        maxHeight: AppConstants.maxImageHeightPx.toDouble(),
        imageQuality: AppConstants.imageCompressionQuality,
      );
      if (image == null) return null;
      return await _compressAndEncode(image);
    } catch (e) {
      return null;
    }
  }

  Future<String?> pickFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidthPx.toDouble(),
        maxHeight: AppConstants.maxImageHeightPx.toDouble(),
        imageQuality: AppConstants.imageCompressionQuality,
      );
      if (image == null) return null;
      return await _compressAndEncode(image);
    } catch (e) {
      return null;
    }
  }

  Future<String?> compressAndEncode(XFile imageFile) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 400,
        minHeight: 400,
        quality: AppConstants.imageCompressionQuality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) return null;

      if (compressedBytes.length > AppConstants.maxImageSizeBytes) {
        throw Exception('حجم الصورة كبير جدًا');
      }

      return base64Encode(compressedBytes);
    } catch (e) {
      throw Exception('فشل في ضغط الصورة');
    }
  }

  Future<String?> _compressAndEncode(XFile imageFile) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 400,
        minHeight: 400,
        quality: AppConstants.imageCompressionQuality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) return null;

      if (compressedBytes.length > AppConstants.maxImageSizeBytes) {
        throw Exception('حجم الصورة كبير جدًا');
      }

      return base64Encode(compressedBytes);
    } catch (e) {
      throw Exception('فشل في معالجة الصورة');
    }
  }

  Uint8List? decodeBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  bool isSizeValid(String base64String) {
    final bytes = base64Decode(base64String);
    return bytes.length <= AppConstants.maxImageSizeBytes;
  }

  int getSizeInMB(String base64String) {
    final bytes = base64Decode(base64String);
    return (bytes.length / (1024 * 1024)).ceil();
  }
}

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});