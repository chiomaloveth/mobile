import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class ChatPinService {
  /// PUT /api/v1/chat/pin/{chatId}/chat
  Future<bool> pinChat({required String chatId}) async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.put(
        Uri.parse('${ApiStrings.baseUri}chat/pin/$chatId/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('📌 pinChat [$chatId] → ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return body['success'] == true;
      }
      // 400 on pin = server says already pinned → treat as success
      // so local Hive state stays pinned correctly
      if (response.statusCode == 400) {
        debugPrint('📌 pinChat: already pinned on server, treating as success');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ pinChat error: $e');
      return false;
    }
  }

  /// PUT /api/v1/chat/unpin/{chatId}/chat
  Future<bool> unpinChat({required String chatId}) async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http.put(
        Uri.parse('${ApiStrings.baseUri}chat/unpin/$chatId/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('📌 unpinChat [$chatId] → ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return body['success'] == true;
      }
      // 400 on unpin = server says already not pinned → treat as success
      // because the desired end state (unpinned) is already achieved.
      if (response.statusCode == 400) {
        debugPrint(
          '📌 unpinChat: already unpinned on server, treating as success',
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ unpinChat error: $e');
      return false;
    }
  }
}
