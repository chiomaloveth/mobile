import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/model/friend_request_model.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class MessageRequestService {
  // ── Fetch all pending message requests ───────────────────────
  static Future<List<FriendRequest>> fetchRequests() async {
    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );
      final response = await http
          .get(
            Uri.parse('${ApiStrings.baseUri}message/chat/requests'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // New shape: { "success": true, "data": [...] }
        final List rawList = body['data'] ?? (body is List ? body : []);

        final List<FriendRequest> requests = [];
        for (final item in rawList) {
          final map = item as Map<String, dynamic>;
          final meta = map['meta'] as Map<String, dynamic>? ?? {};
          // Skip anything that isn't still pending
          if (meta['requestStatus'] != 'pending') continue;
          final req = FriendRequest.fromJson(map);
          if (req.id.isNotEmpty && req.userId.isNotEmpty) {
            requests.add(req);
          }
        }
        return requests;
      }
      debugPrint(
        'fetchRequests error: ${response.statusCode} ${response.body}',
      );
      return [];
    } catch (e) {
      debugPrint('fetchRequests exception: $e');
      return [];
    }
  }

  // ── Accept a message request ──────────────────────────────────
  // addContact = true  → backend adds to contacts + enables calls
  // addContact = false → opens chat without adding to contacts
  static Future<bool> acceptRequest({
    required String messageId,
    required String chatId,
    bool addContact = false,
  }) async {
    // The chatId and messageId are the same value with the new backend shape
    // Try the most likely correct endpoint patterns
    const possiblePaths = [
      'message/chat/requests', // PATCH with body
      'chat/requests', // alternative prefix
      'message/request', // another common pattern
    ];

    final url = '${ApiStrings.baseUri}message/requests/respond';
    final bodyMap = {'chatId': chatId, 'action': 'accept'};

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 ACCEPT REQUEST');
    debugPrint('   chatId    : $chatId');
    debugPrint('   messageId : $messageId');
    debugPrint('   addContact: $addContact');
    debugPrint('   URL (POST): $url');
    debugPrint('   body      : ${jsonEncode(bodyMap)}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      // ── Try PATCH first (common for status updates) ──────────
      debugPrint('🔄 Trying POST $url ...');
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(bodyMap),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint('   POST → ${response.statusCode}: ${response.body}');

      final success = response.statusCode == 200 || response.statusCode == 201;
      debugPrint(success ? '✅ Accept succeeded' : '❌ Accept failed');
      return success;
    } catch (e) {
      debugPrint('❌ acceptRequest exception: $e');
      return false;
    }
  }

  // ── Reject / decline a message request ───────────────────────
  static Future<bool> rejectRequest({required String messageId}) async {
    final url = '${ApiStrings.baseUri}message/requests/respond';
    final bodyMap = {'chatId': messageId, 'action': 'reject'};

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 REJECT REQUEST');
    debugPrint('   messageId/chatId: $messageId');
    debugPrint('   URL (POST): $url');
    debugPrint('   body      : ${jsonEncode(bodyMap)}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final token = await SaveValues().getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      // ── Try PATCH first ───────────────────────────────────────
      debugPrint('🔄 Trying POST $url ...');
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(bodyMap),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint('   POST → ${response.statusCode}: ${response.body}');

      final success =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      debugPrint(success ? '✅ Reject succeeded' : '❌ Reject failed');
      return success;
    } catch (e) {
      debugPrint('❌ rejectRequest exception: $e');
      return false;
    }
  }
}
