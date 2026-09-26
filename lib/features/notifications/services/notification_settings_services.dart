import 'dart:convert';
import '../../../utilities/constants/app_strings/api_strings.dart';
import '../../../utilities/database/save_values.dart';
import 'package:http/http.dart' as http;
import '../../../utilities/services/app_pref_helper.dart';

/// Key used to cache notification settings locally via SharedPreferences.
const String _kNotifSettingsCache = 'notification_settings_cache';

class NotificationSettingsServices {
  final baseUrl = ApiStrings.baseUri;
  final SaveValues _saveValues = SaveValues();

  // ── Local cache helpers ──────────────────────────────────────────────────

  /// Persist the latest notification settings map to SharedPreferences so the
  /// UI can render instantly on next launch without waiting for the network.
  Future<void> cacheSettings(Map<String, dynamic> data) async {
    await _saveValues.saveString(_kNotifSettingsCache, json.encode(data));
  }

  /// Return the last-known notification settings from the local cache, or
  /// `null` if nothing has been cached yet.
  Future<Map<String, dynamic>?> getCachedSettings() async {
    final raw = await _saveValues.getString(_kNotifSettingsCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Network calls ────────────────────────────────────────────────────────

  /// Fetch notification settings from the backend.
  /// Returns the `data` map on success, throws on failure.
  Future<Map<String, dynamic>> fetchNotificationSettings() async {
    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

    final response = await http.get(
      Uri.parse(ApiStrings.getNotificationSettings),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = json.decode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['success'] == true) {
      final data = (body['data'] as Map<String, dynamic>?) ?? {};
      await cacheSettings(data);
      return data;
    } else {
      throw Exception(
          body['message'] ?? body['data']?['message'] ?? 'Failed to fetch notification settings');
    }
  }

  /// Update notification settings on the backend.
  /// Accepts a flat map matching the Postman spec:
  ///   { "messages": true, "sound": true, "vibrate": true, "calls": true, "groups": false }
  /// Also persists the new values to the local cache.
  Future<String> updateNotificationSettings({
    required Map<String, dynamic> data,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.put(
        Uri.parse(ApiStrings.updateNotificationSettings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      final body = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        // Cache the returned data (or the sent data as fallback)
        final returned = (body['data'] as Map<String, dynamic>?) ?? data;
        await cacheSettings(returned);
        return body['message'] ?? 'Notification settings updated successfully';
      } else {
        throw Exception(
            body['message'] ?? body['data']?['message'] ?? 'Failed to update notification settings');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
