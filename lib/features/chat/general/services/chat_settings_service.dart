import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/presigned_upload_service.dart';

class SettingsResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const SettingsResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class ChatSettingsService {
  final SaveValues _save = SaveValues();

  Future<Map<String, String>> _headers() async {
    final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  String _error(String body) {
    try {
      return (jsonDecode(body))['message'] as String? ?? 'Something went wrong';
    } catch (_) {
      return 'Something went wrong';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // RENAME
  //
  // Group:     PUT /chat/group/rename          body: { chatId, chatName }
  // Community: PUT /chat/community/:id         body: { chatName, name }
  //
  // ✅ FIX: community was using PATCH /chat/:id which returns 404.
  //         The correct method + path is PUT /chat/community/:id.
  // ─────────────────────────────────────────────────────────────────────────────
  Future<SettingsResult> renameChatOrCommunity({
    required String chatId,
    required String newName,
    bool isCommunity = false,
  }) async {
    try {
      final headers = await _headers();
      final http.Response response;

      if (isCommunity) {
        // ✅ PUT /chat/community/:id   body: { chatName, name }
        response = await http
            .put(
              Uri.parse('${ApiStrings.baseUri}chat/community/$chatId'),
              headers: headers,
              body: jsonEncode({'chatName': newName, 'name': newName}),
            )
            .timeout(const Duration(seconds: 15));
      } else {
        // PUT /chat/group/rename   body: { chatId, chatName }
        response = await http
            .put(
              Uri.parse('${ApiStrings.baseUri}chat/group/rename'),
              headers: headers,
              body: jsonEncode({'chatId': chatId, 'chatName': newName}),
            )
            .timeout(const Duration(seconds: 15));
      }

      print(
        '✏️ rename $chatId isCommunity=$isCommunity: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SettingsResult(
          success: true,
          message: 'Renamed successfully',
          data: data,
        );
      }
      return SettingsResult(success: false, message: _error(response.body));
    } catch (e) {
      print('❌ renameChatOrCommunity: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UPDATE DESCRIPTION
  //
  // Group:     PUT  /chat/group/:groupId/description   body: { description }
  // Community: PUT  /chat/community/:id                body: { description }
  //
  // ✅ FIX: community was using PATCH /chat/:id which returns 404.
  //         The correct method + path is PUT /chat/community/:id.
  // ─────────────────────────────────────────────────────────────────────────────
  Future<SettingsResult> updateDescription({
    required String chatId,
    required String description,
    bool isCommunity = false,
  }) async {
    try {
      final headers = await _headers();

      final uri = isCommunity
          ? Uri.parse('${ApiStrings.baseUri}chat/community/$chatId')
          : Uri.parse('${ApiStrings.baseUri}chat/group/$chatId/description');

      // ✅ FIX: both group and community now use PUT
      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode({'description': description}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '✏️ updateDescription $chatId isCommunity=$isCommunity: ${response.statusCode}',
      );
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200 ? 'Updated' : _error(response.body),
      );
    } catch (e) {
      print('❌ updateDescription: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UPDATE IMAGE
  //
  // Group:     PUT /chat/group/rename  does NOT handle images.
  //            Use PUT /chat/community/:id (multipart) for communities.
  //            Use PUT /chat/group/:id  (multipart) for groups — same base path.
  //
  // Both group and community image uploads use multipart PUT to their
  // respective update endpoints:
  //   Group:     PUT /chat/group/:chatId        (multipart, field: chatImage)
  //   Community: PUT /chat/community/:chatId    (multipart, field: chatImage)
  //
  // ✅ FIX: was using PATCH /chat/:id for both which returns 404.
  // ─────────────────────────────────────────────────────────────────────────────
  Future<SettingsResult> updateChatImage({
    required String chatId,
    required File imageFile,
    bool isCommunity = false,
  }) async {
    try {
      final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final parts = mimeType.split('/');

      // ✅ Route to the correct endpoint
      final uri = isCommunity
          ? Uri.parse('${ApiStrings.baseUri}chat/community/$chatId')
          : Uri.parse('${ApiStrings.baseUri}chat/group/$chatId');

      print('🖼 updateChatImage URL: $uri | file: ${imageFile.path}');

      // Step 1 — Upload to MinIO via presigned URL
      final publicUrl = await PresignedUploadService.uploadFile(
        file: imageFile,
        mimeType: mimeType,
      );
      if (publicUrl == null) {
        return const SettingsResult(
          success: false,
          message: 'Failed to upload image',
        );
      }

      // Step 2 — Send the URL to backend as JSON
      final headers = await _headers();
      final response = await http
          .put(uri, headers: headers, body: jsonEncode({'imageUrl': publicUrl}))
          .timeout(const Duration(seconds: 30));

      print(
        '🖼 updateChatImage $chatId isCommunity=$isCommunity: ${response.statusCode}',
      );
      print('🖼 updateChatImage response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SettingsResult(
          success: true,
          message: 'Image updated',
          data: data,
        );
      }
      return SettingsResult(success: false, message: _error(response.body));
    } catch (e) {
      print('❌ updateChatImage: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GROUP SETTINGS (groups only)
  // PATCH /chat/:chatId/settings
  // ─────────────────────────────────────────────────────────────────────────────
  Future<SettingsResult> setOnlyAdminsCanMessage({
    required String chatId,
    required bool value,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .patch(
            Uri.parse('${ApiStrings.baseUri}chat/$chatId/settings'),
            headers: headers,
            body: jsonEncode({'onlyAdminsCanMessage': value}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '⚙️ setOnlyAdminsCanMessage $chatId=$value: ${response.statusCode}',
      );
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200 ? 'Updated' : _error(response.body),
      );
    } catch (e) {
      print('❌ setOnlyAdminsCanMessage: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  Future<SettingsResult> setOnlyAdminsCanEditInfo({
    required String chatId,
    required bool value,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .patch(
            Uri.parse('${ApiStrings.baseUri}chat/$chatId/settings'),
            headers: headers,
            body: jsonEncode({'onlyAdminsCanEditInfo': value}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '⚙️ setOnlyAdminsCanEditInfo $chatId=$value: ${response.statusCode}',
      );
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200 ? 'Updated' : _error(response.body),
      );
    } catch (e) {
      print('❌ setOnlyAdminsCanEditInfo: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  Future<SettingsResult> setDisappearingMessages({
    required String chatId,
    required bool enabled,
    required int durationSeconds,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .patch(
            Uri.parse('${ApiStrings.baseUri}chat/$chatId/settings'),
            headers: headers,
            body: jsonEncode({
              'disappearingMessages': {
                'enabled': enabled,
                'duration': durationSeconds,
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '⚙️ setDisappearingMessages $chatId enabled=$enabled: ${response.statusCode}',
      );
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200 ? 'Updated' : _error(response.body),
      );
    } catch (e) {
      print('❌ setDisappearingMessages: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MEMBER MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────────

  Future<SettingsResult> addMembersToCommunity({
    required String communityId,
    required List<String> userIds,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .post(
            Uri.parse(
              '${ApiStrings.baseUri}chat/community/$communityId/members',
            ),
            headers: headers,
            body: jsonEncode({'userIds': userIds}),
          )
          .timeout(const Duration(seconds: 15));

      print('👥 addMembersToCommunity $communityId: ${response.statusCode}');
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200
            ? 'Members added'
            : _error(response.body),
      );
    } catch (e) {
      print('❌ addMembersToCommunity: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  Future<SettingsResult> addMemberToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/group/add'),
            headers: headers,
            body: jsonEncode({'chatId': groupId, 'userId': userId}),
          )
          .timeout(const Duration(seconds: 15));

      print('👥 addMemberToGroup $groupId/$userId: ${response.statusCode}');
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200 ? 'Added' : _error(response.body),
      );
    } catch (e) {
      print('❌ addMemberToGroup: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  Future<SettingsResult> removeMemberFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/group/remove'),
            headers: headers,
            body: jsonEncode({'chatId': groupId, 'userId': userId}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '👥 removeMemberFromGroup $groupId/$userId: ${response.statusCode}',
      );
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200 ? 'Removed' : _error(response.body),
      );
    } catch (e) {
      print('❌ removeMemberFromGroup: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }

  Future<SettingsResult> setGroupAdmin({
    required String groupId,
    required String userId,
    required bool makeAdmin,
  }) async {
    try {
      final headers = await _headers();
      final endpoint = makeAdmin ? 'promote' : 'demote';
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/group/$endpoint'),
            headers: headers,
            body: jsonEncode({'chatId': groupId, 'userId': userId}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '👑 setGroupAdmin $groupId/$userId makeAdmin=$makeAdmin: ${response.statusCode}',
      );
      return SettingsResult(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200
            ? (makeAdmin ? 'Promoted to admin' : 'Removed as admin')
            : _error(response.body),
      );
    } catch (e) {
      print('❌ setGroupAdmin: $e');
      return SettingsResult(success: false, message: e.toString());
    }
  }
}
