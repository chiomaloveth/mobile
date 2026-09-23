import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'dart:convert';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

/// Handles the 3-step presigned URL upload flow:
/// 1. Request upload URL from backend
/// 2. PUT file directly to MinIO
/// 3. Return publicUrl for use in message API call
class PresignedUploadService {
  static const _baseUrl = AppConfig.apiUrl;

  /// Uploads [file] directly to MinIO via presigned URL.
  /// Returns the [publicUrl] on success, null on failure.
  /// [onProgress] reports 0.0–1.0 upload progress.
  ///
  /// Retries up to [maxRetries] times on network error.
  static Future<String?> uploadFile({
    required File file,
    required String mimeType,
    void Function(double progress)? onProgress,
    int maxRetries = 2,
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      final result = await _attemptUpload(
        file: file,
        mimeType: mimeType,
        onProgress: onProgress,
      );
      if (result != null) return result;
      if (attempt < maxRetries) {
        // Brief back-off before retry
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    return null;
  }

  static Future<String?> _attemptUpload({
    required File file,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      // ── Step 1: Get presigned URL from backend ──────────────────────────
      final genRes = await http
          .post(
            Uri.parse('${_baseUrl}media/generate-upload-url'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'fileName': file.path.split('/').last,
              'mimeType': mimeType,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (genRes.statusCode != 200 && genRes.statusCode != 201) {
        print(
          '❌ Failed to get presigned URL: ${genRes.statusCode} ${genRes.body}',
        );
        return null;
      }

      final genData = jsonDecode(genRes.body) as Map<String, dynamic>;
      final data = genData['data'] as Map<String, dynamic>?;
      final uploadUrl = data?['uploadUrl'] as String?;
      final publicUrl = data?['publicUrl'] as String?;

      if (uploadUrl == null || publicUrl == null) {
        print('❌ Missing uploadUrl or publicUrl in response');
        return null;
      }

      print('✅ Got presigned URL, uploading to MinIO...');

      // ── Step 2: PUT file directly to MinIO using a stream ──────────────
      // Streaming avoids loading the entire file into memory at once,
      // which is critical for large videos.
      final fileLength = await file.length();

      final dio = Dio();
      final response = await dio.put(
        uploadUrl,
        data: file.openRead(),
        options: Options(
          headers: {'Content-Type': mimeType, 'Content-Length': fileLength},
          receiveTimeout: const Duration(minutes: 15),
          sendTimeout: const Duration(minutes: 15),
          contentType: mimeType,
        ),
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        print('✅ File uploaded to MinIO: $publicUrl');
        return publicUrl;
      } else {
        print('❌ MinIO upload failed: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('❌ Dio upload error: ${e.type} — ${e.message}');
      return null;
    } catch (e) {
      print('❌ PresignedUploadService error: $e');
      return null;
    }
  }
}
