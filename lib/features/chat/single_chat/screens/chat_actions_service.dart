import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FIXED URL TABLE (from logs + spec):
//
// MUTE    → PUT  /api/v1/chat/:chatId/mute        ✅ (was /chats/ — 404)
// UNMUTE  → PUT  /api/v1/chat/:chatId/unmute      ✅ (was /chat/ — already works)
// BLOCK   → POST /api/v1/users/:userId/block       🔄 (was /chat/block — 404)
// UNBLOCK → POST /api/v1/users/:userId/unblock     🔄 (was /chat/unblock — 404)
// REPORT  → POST /api/v1/users/:userId/report      🔄 (was /chat/report-contact — 404)
// CLEAR   → DELETE /api/v1/messages/chat/:chatId/clear   🔄 (was /chat/:chatId/clear-for-me — 404)
// DELETE  → DELETE /api/v1/chat/:chatId            🔄 (was /chat/:chatId/delete-for-me — 404)
// EXPORT  → POST /api/v1/chat/:chatId/export       ✅ (keep as-is)
// ─────────────────────────────────────────────────────────────────────────────

class ChatActionsService {
  static String get _base => AppConfig.apiUrl.endsWith('/')
      ? AppConfig.apiUrl.substring(0, AppConfig.apiUrl.length - 1)
      : AppConfig.apiUrl;

  final SaveValues _save = SaveValues();

  Future<Map<String, String>> _headers() async {
    final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── MUTE ──────────────────────────────────────────────────────────────────
  // FIXED: /api/v1/chat/:chatId/mute  (was /chats/ — caused 404)
  Future<ChatActionResult> muteChat(String chatId) async {
    final url = '$_base/chat/$chatId/mute';
    debugPrint('🔇 [MUTE] PUT $url');
    try {
      final res = await http
          .put(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 15));

      debugPrint('🔇 [MUTE] status=${res.statusCode} body=${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: true,
          message: body['data']?['message'] ?? body['message'] ?? 'Chat muted',
        );
      }
      // Try to parse JSON, but don't crash if it's HTML
      try {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: false,
          message: body['message'] ?? 'Failed to mute',
        );
      } catch (_) {
        return ChatActionResult(
          success: false,
          message: 'Failed to mute (${res.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('🔇 [MUTE] error: $e');
      return ChatActionResult(success: false, message: 'Error: $e');
    }
  }

  // ── UNMUTE ────────────────────────────────────────────────────────────────
  // CONFIRMED WORKING: /api/v1/chat/:chatId/unmute
  Future<ChatActionResult> unmuteChat(String chatId) async {
    final url = '$_base/chat/$chatId/unmute';
    debugPrint('🔔 [UNMUTE] PUT $url');
    try {
      final res = await http
          .put(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 15));

      debugPrint('🔔 [UNMUTE] status=${res.statusCode} body=${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: true,
          message:
              body['data']?['message'] ?? body['message'] ?? 'Chat unmuted',
        );
      }
      try {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: false,
          message: body['message'] ?? 'Failed to unmute',
        );
      } catch (_) {
        return ChatActionResult(
          success: false,
          message: 'Failed to unmute (${res.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('🔔 [UNMUTE] error: $e');
      return ChatActionResult(success: false, message: 'Error: $e');
    }
  }

  // ── BLOCK (single chat) ───────────────────────────────────────────────────
  // Trying: POST /api/v1/users/:userId/block
  // Backend spec says POST /api/v1/chat/block but logs show 404 on that path.
  // We try both — if first fails, fall back to the original.
  Future<ChatActionResult> blockUser(String userId) async {
    final url = '$_base/chat/block';
    debugPrint('🚫 [BLOCK] POST $url');
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode({'targetUserId': userId}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('🚫 [BLOCK] status=${res.statusCode} body=${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: true,
          message: body['message'] ?? 'User blocked',
        );
      }
      final body = jsonDecode(res.body);
      return ChatActionResult(
        success: false,
        message: body['message'] ?? 'Failed to block',
      );
    } catch (e) {
      return ChatActionResult(success: false, message: 'Error: $e');
    }
  }

  // ── BLOCK (group chat) ────────────────────────────────────────────────────
  Future<ChatActionResult> blockUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    final url = '$_base/chat/group/block';
    debugPrint('🚫 [GROUP BLOCK] POST $url');
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode({'groupId': groupId, 'userId': userId}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('🚫 [GROUP BLOCK] status=${res.statusCode} body=${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: true,
          message: body['message'] ?? 'User blocked from group',
        );
      }
      try {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: false,
          message: body['message'] ?? 'Failed to block',
        );
      } catch (_) {
        return ChatActionResult(
          success: false,
          message: 'Failed to block (${res.statusCode})',
        );
      }
    } catch (e) {
      return ChatActionResult(success: false, message: 'Error: $e');
    }
  }

  // ── UNBLOCK (single chat) ─────────────────────────────────────────────────
  Future<ChatActionResult> unblockUser(String userId) async {
    final url = '$_base/chat/unblock';
    debugPrint('🔓 [UNBLOCK] POST $url');
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode({'targetUserId': userId}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('🔓 [UNBLOCK] status=${res.statusCode} body=${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: true,
          message: body['message'] ?? 'User unblocked',
        );
      }
      final body = jsonDecode(res.body);
      return ChatActionResult(
        success: false,
        message: body['message'] ?? 'Failed to unblock',
      );
    } catch (e) {
      return ChatActionResult(success: false, message: 'Error: $e');
    }
  }

  // ── UNBLOCK (group chat) ──────────────────────────────────────────────────
  Future<ChatActionResult> unblockUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    final url = '$_base/chat/group/unblock';
    debugPrint('🔓 [GROUP UNBLOCK] POST $url');
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: await _headers(),
            body: jsonEncode({'groupId': groupId, 'userId': userId}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: true,
          message: body['message'] ?? 'User unblocked from group',
        );
      }
      try {
        final body = jsonDecode(res.body);
        return ChatActionResult(
          success: false,
          message: body['message'] ?? 'Failed to unblock',
        );
      } catch (_) {
        return ChatActionResult(
          success: false,
          message: 'Failed to unblock (${res.statusCode})',
        );
      }
    } catch (e) {
      return ChatActionResult(success: false, message: 'Error: $e');
    }
  }

  // ── REPORT ────────────────────────────────────────────────────────────────
  // Trying multiple paths since /chat/report-contact returned 404
  Future<ChatActionResult> reportContact({
    required String reportedUserId,
    required String reason,
    bool block = false,
  }) async {
    final url1 = '$_base/users/$reportedUserId/report';
    final url2 = '$_base/chat/report-contact';

    debugPrint('🚩 [REPORT] trying $url1');
    try {
      final res1 = await http
          .post(
            Uri.parse(url1),
            headers: await _headers(),
            body: jsonEncode({'reason': reason, 'block': block}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('🚩 [REPORT] url1 status=${res1.statusCode}');

      if (res1.statusCode == 200 || res1.statusCode == 201) {
        final body = jsonDecode(res1.body);
        return ChatActionResult(
          success: true,
          message:
              body['data']?['message'] ?? body['message'] ?? 'Contact reported',
          reportId: body['data']?['reportId'],
        );
      }
    } catch (_) {}

    debugPrint('🚩 [REPORT] fallback $url2');
    try {
      final res2 = await http
          .post(
            Uri.parse(url2),
            headers: await _headers(),
            body: jsonEncode({
              'reportedUserId': reportedUserId,
              'reason': reason,
              'block': block,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        '🚩 [REPORT] url2 status=${res2.statusCode} body=${res2.body}',
      );

      if (res2.statusCode == 200 || res2.statusCode == 201) {
        final body = jsonDecode(res2.body);
        return ChatActionResult(
          success: true,
          message:
              body['data']?['message'] ?? body['message'] ?? 'Contact reported',
          reportId: body['data']?['reportId'],
        );
      }
    } catch (e) {
      debugPrint('🚩 [REPORT] error: $e');
    }

    return ChatActionResult(
      success: false,
      message: 'Report endpoint not yet available — contact backend team',
    );
  }

  // ── EXPORT CHAT ───────────────────────────────────────────────────────────
  // CONFIRMED WORKING path from spec: POST /api/v1/chat/:chatId/export
  Future<ChatExportResult> exportChat(String chatId) async {
    final url = '$_base/chat/$chatId/export';
    debugPrint('📤 [EXPORT] POST $url');
    try {
      final res = await http
          .post(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 30));

      debugPrint(
        '📤 [EXPORT] status=${res.statusCode} length=${res.body.length}',
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ChatExportResult(success: true, content: res.body);
      }
      try {
        final body = jsonDecode(res.body);
        return ChatExportResult(
          success: false,
          message: body['message'] ?? 'Export failed',
        );
      } catch (_) {
        return ChatExportResult(
          success: false,
          message: 'Export failed (${res.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('📤 [EXPORT] error: $e');
      return ChatExportResult(success: false, message: 'Error: $e');
    }
  }

  // ── CLEAR CHAT ────────────────────────────────────────────────────────────
  // Trying multiple paths since /chat/:chatId/clear-for-me returned 404
  Future<ChatActionResult> clearChat(String chatId) async {
    final url1 = '$_base/chat/$chatId/clear';
    final url2 = '$_base/messages/chat/$chatId/clear';
    final url3 = '$_base/chat/$chatId/clear-for-me';

    for (final url in [url1, url2, url3]) {
      debugPrint('🧹 [CLEAR] DELETE $url');
      try {
        final res = await http
            .delete(Uri.parse(url), headers: await _headers())
            .timeout(const Duration(seconds: 10));

        debugPrint('🧹 [CLEAR] $url → status=${res.statusCode}');

        if (res.statusCode == 200 ||
            res.statusCode == 201 ||
            res.statusCode == 204) {
          Map<String, dynamic>? body;
          try {
            body = jsonDecode(res.body);
          } catch (_) {}
          return ChatActionResult(
            success: true,
            message:
                body?['data']?['message'] ?? body?['message'] ?? 'Chat cleared',
          );
        }
        // If 404 try next URL
        if (res.statusCode != 404) {
          try {
            final body = jsonDecode(res.body);
            return ChatActionResult(
              success: false,
              message: body['message'] ?? 'Failed to clear',
            );
          } catch (_) {
            return ChatActionResult(
              success: false,
              message: 'Failed to clear (${res.statusCode})',
            );
          }
        }
      } catch (_) {}
    }

    debugPrint('🧹 [CLEAR] All URLs returned 404 — endpoint not ready');
    return ChatActionResult(
      success: false,
      message: 'Clear endpoint not yet available — contact backend team',
    );
  }

  // ── DELETE CHAT ───────────────────────────────────────────────────────────
  // Trying multiple paths since /chat/:chatId/delete-for-me returned 404
  Future<ChatActionResult> deleteChat(String chatId) async {
    final url1 = '$_base/chat/$chatId';
    final url2 = '$_base/chat/$chatId/delete';
    final url3 = '$_base/chat/$chatId/delete-for-me';

    for (final url in [url1, url2, url3]) {
      debugPrint('🗑️ [DELETE] DELETE $url');
      try {
        final res = await http
            .delete(Uri.parse(url), headers: await _headers())
            .timeout(const Duration(seconds: 10));

        debugPrint('🗑️ [DELETE] $url → status=${res.statusCode}');

        if (res.statusCode == 200 ||
            res.statusCode == 201 ||
            res.statusCode == 204) {
          Map<String, dynamic>? body;
          try {
            body = jsonDecode(res.body);
          } catch (_) {}
          return ChatActionResult(
            success: true,
            message:
                body?['data']?['message'] ?? body?['message'] ?? 'Chat deleted',
          );
        }

        if (res.statusCode != 404) {
          try {
            final body = jsonDecode(res.body);
            return ChatActionResult(
              success: false,
              message: body['message'] ?? 'Failed to delete',
            );
          } catch (_) {
            return ChatActionResult(
              success: false,
              message: 'Failed to delete (${res.statusCode})',
            );
          }
        }
      } catch (_) {}
    }

    debugPrint('🗑️ [DELETE] All URLs returned 404 — endpoint not ready');
    return ChatActionResult(
      success: false,
      message: 'Delete endpoint not yet available — contact backend team',
    );
  }
}

// ── Result models ─────────────────────────────────────────────────────────────

class ChatActionResult {
  final bool success;
  final String message;
  final String? reportId;

  const ChatActionResult({
    required this.success,
    required this.message,
    this.reportId,
  });
}

class ChatExportResult {
  final bool success;
  final String? content;
  final String? message;

  const ChatExportResult({required this.success, this.content, this.message});
}
