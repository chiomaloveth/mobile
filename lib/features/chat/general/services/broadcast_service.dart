import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/model/broadcast_model.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class BroadcastService {
  // ── Auth helper ──────────────────────────────────────────────
  Future<Map<String, String>> _headers() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  String get _base => '${ApiStrings.baseUri}chat/broadcast';

  // ── 1. GET /api/v1/chat/broadcast — list all broadcasts ──────
  Future<List<BroadcastList>> getAllBroadcasts() async {
    final response = await http
        .get(Uri.parse(_base), headers: await _headers())
        .timeout(const Duration(seconds: 10));

    debugPrint('📡 getAllBroadcasts: ${response.statusCode}');
    debugPrint(
      '📡 getAllBroadcasts body: ${response.body.substring(0, response.body.length.clamp(0, 300))}',
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // API returns { "success": true, "count": N, "data": [...] }
      List rawList;
      if (decoded is Map && decoded.containsKey('data')) {
        rawList = (decoded['data'] as List?) ?? [];
      } else if (decoded is List) {
        // Flat array fallback (older API)
        rawList = decoded;
      } else {
        rawList = [];
      }
      return rawList
          .map(
            (e) => BroadcastList.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    throw Exception('Failed to fetch broadcasts: ${response.statusCode}');
  }

  // ── 1b. GET /api/v1/chat/broadcast/contacts — contacts for picker ─
  Future<List<Map<String, dynamic>>> getBroadcastContacts() async {
    final response = await http
        .get(Uri.parse('$_base/contacts'), headers: await _headers())
        .timeout(const Duration(seconds: 10));

    debugPrint('📡 getBroadcastContacts: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List rawList = (decoded is Map && decoded.containsKey('data'))
          ? (decoded['data'] as List? ?? [])
          : (decoded is List ? decoded : []);
      return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw Exception(
      'Failed to fetch broadcast contacts: ${response.statusCode}',
    );
  }

  // ── 2. GET /api/v1/chat/broadcast/:id — single broadcast ─────
  Future<BroadcastList> getBroadcast(String broadcastId) async {
    final response = await http
        .get(Uri.parse('$_base/$broadcastId'), headers: await _headers())
        .timeout(const Duration(seconds: 10));

    debugPrint('📡 getBroadcast($broadcastId): ${response.statusCode}');
    debugPrint('📡 body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // API may wrap in { data: {...} }
      final payload = (data is Map && data.containsKey('data'))
          ? data['data']
          : data;
      return BroadcastList.fromJson(payload as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch broadcast: ${response.statusCode}');
  }

  // ── 3. PUT /api/v1/chat/broadcast/:id — update broadcast ─────
  Future<BroadcastList> updateBroadcast(
    String broadcastId, {
    String? name,
    String? content,
    String? audience,
    String? broadcastStatus,
    String? scheduledAt,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (content != null) body['content'] = content;
    if (audience != null) body['audience'] = audience;
    if (broadcastStatus != null) body['broadcastStatus'] = broadcastStatus;
    if (scheduledAt != null) body['scheduledAt'] = scheduledAt;

    final response = await http
        .put(
          Uri.parse('$_base/$broadcastId'),
          headers: await _headers(),
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('📡 updateBroadcast: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final payload = (data is Map && data.containsKey('data'))
          ? data['data']
          : data;
      return BroadcastList.fromJson(payload as Map<String, dynamic>);
    }
    final err = _extractMessage(response.body);
    throw Exception(err);
  }

  // ── 4. POST /api/v1/chat/broadcast/:id/members — add recipients
  Future<void> addMembers(String broadcastId, List<String> userIds) async {
    // Ensure unique user IDs on client side
    final uniqueUserIds = userIds.toSet().toList();

    if (uniqueUserIds.isEmpty) {
      throw Exception('No valid user IDs provided');
    }

    final response = await http
        .post(
          Uri.parse('$_base/$broadcastId/members'),
          headers: await _headers(),
          body: json.encode({'userIds': uniqueUserIds}),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint(
      '📡 addMembers: ${response.statusCode} (${uniqueUserIds.length} users)',
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractMessage(response.body));
    }
  }

  // ── 5. DELETE /api/v1/chat/broadcast/:id/members/:userId ─────
  Future<void> removeMember(String broadcastId, String userId) async {
    final response = await http
        .delete(
          Uri.parse('$_base/$broadcastId/members/$userId'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('📡 removeMember: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractMessage(response.body));
    }
  }

  // ── 6. DELETE /api/v1/chat/broadcast/:id — delete broadcast ──
  Future<void> deleteBroadcast(String broadcastId) async {
    final response = await http
        .delete(Uri.parse('$_base/$broadcastId'), headers: await _headers())
        .timeout(const Duration(seconds: 10));

    debugPrint('📡 deleteBroadcast: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extractMessage(response.body));
    }
  }

  // ── Helper ───────────────────────────────────────────────────
  String _extractMessage(String body) {
    try {
      final decoded = json.decode(body);
      return decoded['message']?.toString() ?? 'Something went wrong';
    } catch (_) {
      return 'Something went wrong';
    }
  }
}
