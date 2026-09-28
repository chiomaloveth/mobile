import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/status/model/my_status_model.dart';
import 'package:qik_talk/utilities/constants/app_config.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';

class StatusService {
  static String get _base => AppConfig.apiUrl.endsWith('/')
      ? AppConfig.apiUrl.substring(0, AppConfig.apiUrl.length - 1)
      : AppConfig.apiUrl;

  // ---------------------------------------------------------------------------
  // FETCH
  // ---------------------------------------------------------------------------

  static Future<List<MyStatusModel>> fetchStatuses(String token) async {
    final res = await http.get(
      Uri.parse('${_base}/social/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('fetchStatuses statusCode: ' + res.statusCode.toString());
    final snippet = res.body.length > 400
        ? res.body.substring(0, 400)
        : res.body;
    debugPrint('fetchStatuses body: ' + snippet);

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);

      List<dynamic> rawList;

      if (decoded is List) {
        // Raw list — old shape or already flat
        rawList = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        // Wrapped: { success: true, data: [...] }
        rawList = decoded['data'] as List;
      } else if (decoded is Map && decoded['data'] is Map) {
        // Wrapped single object: { success: true, data: {...} }
        rawList = [decoded['data']];
      } else {
        rawList = [];
      }

      if (rawList.isEmpty) return [];

      final firstItem = rawList.first as Map<String, dynamic>;
      final isGrouped = firstItem.containsKey('updates');

      if (isGrouped) {
        return rawList
            .map((e) => MyStatusModel.fromJson(e))
            .where((s) => s.updates.isNotEmpty)
            .toList();
      } else {
        return MyStatusModel.fromFlatList(rawList);
      }
    } else {
      throw Exception('Failed to load statuses: ' + res.statusCode.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // VIEW TRACKING
  // ---------------------------------------------------------------------------

  static Future<void> markAsViewed(String token, String statusId) async {
    try {
      final url = _base + '/social/status/' + statusId + '/view';
      debugPrint('markAsViewed -> ' + url);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('markAsViewed status: ' + response.statusCode.toString());
      debugPrint('markAsViewed body: ' + response.body);
    } catch (e) {
      debugPrint('markAsViewed failed: ' + e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // REPLIES
  // ---------------------------------------------------------------------------

  static Future<String?> replyToStatus({
    required String token,
    required String chatId,
    required String replyText,
    required String statusId,
    required String statusOwnerName,
    required String statusMediaType,
    required String statusMedia,
    required String statusCaption,
  }) async {
    try {
      final safeCaption = statusCaption.replaceAll('|', '[pipe]');
      final safeReply = replyText.replaceAll('|', '[pipe]');
      final safeMedia = statusMedia.replaceAll('|', '[pipe]');

      final encodedContent =
          '__STATUS_REPLY__:' +
          statusId +
          ':' +
          statusMediaType +
          ':' +
          safeMedia +
          ':' +
          safeCaption +
          '|' +
          safeReply;

      debugPrint('replyToStatus encoded: ' + encodedContent);

      final response = await http.post(
        Uri.parse(ApiStrings.sendMessageToApi),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'chatId': chatId, 'content': encodedContent}),
      );

      debugPrint('replyToStatus status: ' + response.statusCode.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['_id'] ?? data['message']?['_id'];
      }
      return null;
    } catch (e) {
      debugPrint('replyToStatus error: ' + e.toString());
      return null;
    }
  }

  static Future<String?> ensureChat({
    required String token,
    required String otherUserId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiStrings.accessNewChat),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': otherUserId}),
      );

      debugPrint('ensureChat status: ' + response.statusCode.toString());
      debugPrint('ensureChat body: ' + response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['_id'] ?? data['chat']?['_id'] ?? data['data']?['_id'];
      }
      return null;
    } catch (e) {
      debugPrint('ensureChat error: ' + e.toString());
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // RESHARE
  // ---------------------------------------------------------------------------

  static Future<bool> reshareStatus({
    required String token,
    required String originalStatusId,
  }) async {
    try {
      final url = _base + '/social/status/' + originalStatusId + '/reshare';
      debugPrint('reshareStatus -> ' + url);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('reshareStatus status: ' + response.statusCode.toString());
      debugPrint('reshareStatus body: ' + response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('reshareStatus exception: ' + e.toString());
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE STATUS
  // ---------------------------------------------------------------------------

  static Future<bool> deleteStatus({
    required String token,
    required String statusId,
  }) async {
    try {
      final url = _base + '/social/status/' + statusId;
      debugPrint('deleteStatus -> DELETE ' + url);

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('deleteStatus status: ' + response.statusCode.toString());
      debugPrint('deleteStatus body: ' + response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('deleteStatus exception: ' + e.toString());
      return false;
    }
  }
}
