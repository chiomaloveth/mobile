/*import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';

class StatusUploadService {
  static Future<bool> uploadMediaStatus({
    required String token,
    required File file,
    required bool isVideo,
    required String caption,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final mimeType =
          lookupMimeType(file.path) ?? (isVideo ? 'video/mp4' : 'image/jpeg');

      debugPrint("Uploading file: ${file.path}");
      debugPrint("Mime: $mimeType");
      debugPrint("Size: ${await file.length()} bytes");

      final dio = Dio();

      final formData = FormData.fromMap({
        'mediaType': isVideo ? 'video' : 'image',
        'caption': caption,
        'media': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await dio.post(
        ApiStrings.uploadStatus,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            // ✅ Do NOT set Content-Type manually — Dio adds boundary automatically
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total);
            debugPrint("Progress: ${(sent / total * 100).toStringAsFixed(1)}%");
          }
        },
      );

      debugPrint("Upload response: ${response.statusCode} - ${response.data}");
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint("Dio upload error: ${e.type}");
      debugPrint("Dio response: ${e.response?.statusCode}");
      debugPrint("Dio body: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("Upload error: $e");
      rethrow;
    }
  }
}*/
