import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_cropper/image_cropper.dart';

/// Centralized image editing service for QikTalk.
/// Provides cropping and future editing capabilities.
class ImageEditingService {
  /// Crop a single image file.
  ///
  /// Returns the cropped [File], or the original [imageFile] if the user
  /// cancels the crop, or `null` if an error occurs.
  static Future<File?> cropImage(File imageFile, BuildContext context) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: HexColor("#1A7F4B"),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: HexColor("#1A7F4B"),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Edit Image',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }

      // User cancelled — return the original file unchanged
      return imageFile;
    } catch (e) {
      debugPrint('❌ Error cropping image: $e');
      return null;
    }
  }

  /// Crop multiple images sequentially.
  ///
  /// Opens the crop UI for each image in [imageFiles]. If the user cancels
  /// on a particular image, the original file is kept. Returns the full list
  /// with any cropped replacements applied.
  static Future<List<File>> cropImages(
    List<File> imageFiles,
    BuildContext context,
  ) async {
    final List<File> results = [];

    for (final file in imageFiles) {
      // Check mounted state between each crop operation
      if (!context.mounted) break;

      final cropped = await cropImage(file, context);
      results.add(cropped ?? file);
    }

    return results;
  }
}
