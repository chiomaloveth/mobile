import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import '../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../../../../utilities/services/app_pref_helper.dart';
import '../../../../../utilities/services/presigned_upload_service.dart';
import '../../../model/generated_wallet_response_model.dart';

class WalletSetupServices {

  final baseUrl = ApiStrings.baseUriTwo;
  final SaveValues _saveValues = SaveValues();

  Future<GeneratedWalletResponseModel> generateWallet({required BuildContext context, required Map<String, dynamic> data}) async {
    try {
      // The backend expects the key to be exactly "bvn" (lowercase) based on Postman
      final String bvnValue = data['BVN'] ?? data['bvn'] ?? '';
      
      final Map<String, dynamic> modifiedData = {
        'bvn': bvnValue,
      };

      print("🛠️ [WalletSetupServices] Starting generateWallet...");
      print("🛠️ [WalletSetupServices] Request Data: ${json.encode(modifiedData)}");

      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final url = "$baseUrl/api/v1/wallet/generate-account";

      print("🛠️ [WalletSetupServices] POST to: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode(modifiedData)
      );

      print("🛠️ [WalletSetupServices] Status Code: ${response.statusCode}");
      print("🛠️ [WalletSetupServices] Response Body: ${response.body}");

      final body = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && body['success'] == true) {
        print("✅ [WalletSetupServices] Wallet generated successfully.");
        if (body['data'] != null) {
          final Map<String, dynamic> collectedData = body['data'];
          final savedData = GeneratedWalletResponseModel.fromMap(collectedData);
          return savedData;
        }
        throw Exception("Wallet generated successfully, but no data was returned.");
      } else {
        print("❌ [WalletSetupServices] Server returned an error.");
        
        // Handle backend errors where message might be an empty object `{}`
        String errorMessage = "Failed to generate wallet.";
        if (body['message'] != null && body['message'] is String && (body['message'] as String).isNotEmpty) {
          errorMessage = body['message'];
        } else if (body['data'] != null && body['data']['message'] != null) {
          errorMessage = body['data']['message'];
        } else if (body['title'] != null && body['title'] is String) {
          errorMessage = body['title']; // Fallback to "Server Error"
        }
        
        print("❌ [WalletSetupServices] Extracted Error: $errorMessage");
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("🔥 [WalletSetupServices] Exception caught: $e");
      if (e.toString().startsWith("Exception: ")) {
        rethrow;
      }
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<void> selfieImageUpload({
    required BuildContext context,
    required String image,
  }) async {
    try {
      // Step 1: Upload image to MinIO via presigned URL
      final file = File(image);
      final mimeType = lookupMimeType(image) ?? 'image/jpeg';

      print('📤 Uploading selfie to MinIO...');
      final publicUrl = await PresignedUploadService.uploadFile(
        file: file,
        mimeType: mimeType,
      );

      if (publicUrl == null || publicUrl.isEmpty) {
        throw Exception('Failed to upload selfie image');
      }

      print('✅ Selfie uploaded to MinIO: $publicUrl');

      // Step 2: Send the MinIO URL to the backend for facial verification
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/facial-verification"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "verificationImage": publicUrl,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        print("✅ Facial verification successful");
        print("Selfie verification response: ${response.body}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification successful")),
        );
      } else {
        print("❌ Facial verification failed");
        print(response.body);

        final errorMsg = responseBody['message'] ?? 'Verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $errorMsg")),
        );
        throw Exception(errorMsg);
      }
    } catch (e) {
      print("🔥 Exception: $e");
      if (e is Exception) rethrow;
      throw Exception("Something went wrong: $e");
    }
  }

}