import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class PinnedMessageSender {
  final String id;
  final String username;
  final String profilePicture;

  const PinnedMessageSender({
    required this.id,
    required this.username,
    required this.profilePicture,
  });

  factory PinnedMessageSender.fromJson(Map<String, dynamic> json) =>
      PinnedMessageSender(
        id: json['_id'] as String? ?? '',
        username: json['username'] as String? ?? 'User',
        profilePicture: json['profilePicture'] as String? ?? '',
      );
}

class PinnedMessage {
  final String id;
  final String content;
  final String contentType;
  final PinnedMessageSender sender;
  final DateTime sentAt;
  final List<Map<String, dynamic>> attachments;

  const PinnedMessage({
    required this.id,
    required this.content,
    required this.contentType,
    required this.sender,
    required this.sentAt,
    required this.attachments,
  });

  factory PinnedMessage.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['sender'];
    return PinnedMessage(
      id: json['_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      contentType: json['contentType'] as String? ?? 'text',
      sender: senderRaw is Map<String, dynamic>
          ? PinnedMessageSender.fromJson(senderRaw)
          : PinnedMessageSender(id: '', username: 'User', profilePicture: ''),
      sentAt:
          DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
      attachments:
          (json['attachments'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          [],
    );
  }

  String get previewText {
    if (content.isNotEmpty) return content.replaceAll('"', '');
    if (contentType == 'image') return '📷 Photo';
    if (contentType == 'video') return '🎥 Video';
    if (contentType == 'audio') return '🎵 Audio';
    if (contentType == 'document') return '📄 Document';
    return 'Message';
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class PinnedMessageService {
  final SaveValues _save = SaveValues();

  Future<Map<String, String>> _headers() async {
    final token = await _save.getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  String _extractError(String body) {
    try {
      return (jsonDecode(body) as Map<String, dynamic>)['message'] as String? ??
          'Something went wrong';
    } catch (_) {
      return 'Something went wrong';
    }
  }

  // GET /chat/:chatId/pinned
  Future<List<PinnedMessage>> getPinnedMessages(String chatId) async {
    try {
      final headers = await _headers();
      final response = await http
          .get(
            Uri.parse('${ApiStrings.baseUri}chat/$chatId/pinned'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((m) => PinnedMessage.fromJson(m))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ getPinnedMessages: $e');
      return [];
    }
  }

  // PUT /chat/:chatId/pin   body: { messageId }
  Future<bool> pinMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/$chatId/pin'),
            headers: headers,
            body: jsonEncode({'messageId': messageId}),
          )
          .timeout(const Duration(seconds: 15));

      print('📌 pinMessage $chatId/$messageId: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ pinMessage: $e');
      return false;
    }
  }

  // PUT /chat/:chatId/unpin   body: { messageId }
  Future<bool> unpinMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/$chatId/unpin'),
            headers: headers,
            body: jsonEncode({'messageId': messageId}),
          )
          .timeout(const Duration(seconds: 15));

      print('📌 unpinMessage $chatId/$messageId: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ unpinMessage: $e');
      return false;
    }
  }
}
