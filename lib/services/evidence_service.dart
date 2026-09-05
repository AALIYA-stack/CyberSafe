import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class EvidenceService {
  EvidenceService._();

  static final EvidenceService instance =
  EvidenceService._();

  final ImagePicker _imagePicker =
  ImagePicker();

  // ==========================================================
  // CAMERA
  // ==========================================================

  Future<String?> pickFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      return image?.path;
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // GALLERY
  // ==========================================================

  Future<String?> pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      return image?.path;
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // MULTIPLE GALLERY IMAGES
  // ==========================================================

  Future<List<String>> pickMultipleImages() async {
    try {
      final images =
      await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      return images
          .map((image) => image.path)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ==========================================================
  // FILE PICKER
  // ==========================================================

  Future<List<String>> pickFiles() async {
    try {
      final result =
      await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'txt',
        ],
      );

      if (result == null) {
        return [];
      }

      return result.files
          .where(
            (file) => file.path != null,
      )
          .map(
            (file) => file.path!,
      )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ==========================================================
  // FILE NAME
  // ==========================================================

  String fileName(String path) {
    return path.split(
      Platform.pathSeparator,
    ).last;
  }

  // ==========================================================
  // FILE TYPE
  // ==========================================================

  bool isImage(String path) {
    final lower = path.toLowerCase();

    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  bool isPdf(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }
}