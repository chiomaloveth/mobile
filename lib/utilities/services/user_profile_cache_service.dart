import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caches user profile data locally so Chat Info works fully offline.
class UserProfileCacheService {
  static const String _prefix = 'user_profile_cache_';

  static String _key(String userId) => '$_prefix$userId';

  /// Save profile data to local cache.
  static Future<void> save({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(userId), jsonEncode(data));
    } catch (e) {
      debugPrint('❌ UserProfileCacheService.save: $e');
    }
  }

  /// Load cached profile data. Returns null if nothing cached.
  static Future<Map<String, dynamic>?> load(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(userId));
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ UserProfileCacheService.load: $e');
      return null;
    }
  }

  /// Clear cached data for a user.
  static Future<void> clear(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(userId));
    } catch (e) {
      debugPrint('❌ UserProfileCacheService.clear: $e');
    }
  }
}
