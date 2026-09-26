import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../../../../../utilities/services/app_pref_helper.dart';
import '../../../../../../utilities/database/save_values.dart';
import '../../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../../utilities/services/presigned_upload_service.dart';
import '../state/add_profile_info_state.dart';

final addProfileInfoProvider =
    StateNotifierProvider<AddProfileInfoNotifier, AddProfileInfoState>(
  (ref) => AddProfileInfoNotifier(),
);

class AddProfileInfoNotifier extends StateNotifier<AddProfileInfoState> {
  AddProfileInfoNotifier() : super(const AddProfileInfoState());

  final SaveValues _saveValues = SaveValues();

  void updateUsername(String value) {
    state = state.copyWith(
      username: value,
      isButtonEnabled: value.trim().isNotEmpty,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (!status.isGranted && !storageStatus.isGranted) {
      print("Permission not granted!");
      return;
    }

    try {
      final picked = await ImagePicker()
          .pickImage(source: source, imageQuality: 100);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            lockAspectRatio: false,
            initAspectRatio: CropAspectRatioPreset.original,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (cropped != null) {
        state = state.copyWith(image: File(cropped.path));
      }
    } catch (e) {
      print("❌ Error picking image: $e");
    }
  }

  Future<void> uploadUserProfile(
    Function(String) showMessage,
    Function navigate,
  ) async {
    if (state.username.isEmpty) {
      showMessage('Please enter a username.');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final token =
          await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      // ── Step 1: Upload image to MinIO if selected ──────────────────
      String? profilePictureUrl;
      if (state.image != null) {
        final ext = state.image!.path.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

        profilePictureUrl = await PresignedUploadService.uploadFile(
          file: state.image!,
          mimeType: mimeType,
          onProgress: (_) {},
        );

        if (profilePictureUrl == null) {
          showMessage('Image upload failed. Please try again.');
          state = state.copyWith(isLoading: false);
          return;
        }
      }

      // ── Step 2: Send JSON to profile update endpoint ───────────────
      final Map<String, dynamic> body = {
        'username': state.username,
        'fullName': state.username,
      };

      if (profilePictureUrl != null) {
        body['profilePicture'] = profilePictureUrl;
      }

      print('PUT: ${ApiStrings.uploadPhotoUsername}');
      final response = await http.put(
        Uri.parse(ApiStrings.uploadPhotoUsername),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final jsonResponse = jsonDecode(response.body);
      print(response.statusCode);
      print('Response Body: ${response.body}');

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final msg =
            jsonResponse['message'] ?? 'Profile updated successfully';
        showMessage(msg);
        navigate();
      } else {
        final msg =
            jsonResponse['message'] ?? 'Unknown error occurred';
        showMessage(msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      showMessage('Network error occurred. Please try again.');
      print('❌ Error uploading profile: $e');
    }
  }
}