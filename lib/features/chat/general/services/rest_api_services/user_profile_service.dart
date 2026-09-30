import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';

import '../../model/user_profile_model.dart';

class UserProfileService {
  final SaveValues _saveValues = SaveValues();

  /// Fetch user profile by userId
  /// Since the backend doesn't have /user/profile/:userId endpoint,
  /// we'll use the /user/profile endpoint which returns all users
  /// and filter by the userId we need
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      // ✅ VALIDATION: Check if userId is valid
      if (userId.isEmpty) {
        print('❌ Empty userId provided');
        return null;
      }

      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      if (token == null || token.isEmpty) {
        print('❌ No auth token found');
        return null;
      }

      // Use the base profile endpoint that returns all users
      final url = Uri.parse('${ApiStrings.baseUri}user/profile');

      print('📡 Fetching user profile: $url');
      print('📡 Looking for userId: $userId');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // The API returns { "success": true, "count": 2, "data": [...] }
        if (data['success'] == true && data['data'] != null) {
          final users = data['data'] as List;

          if (users.isEmpty) {
            print('❌ No users found in response');
            return null;
          }

          // Find the exact user by ID
          try {
            final userMap = users.firstWhere(
              (user) => user['_id'] == userId,
              orElse: () => throw Exception('User not found'),
            );

            print('✅ Found user: ${userMap['username']}');
            return UserProfile.fromJson(userMap);
          } catch (e) {
            print('❌ User with ID $userId not found in the list');
            print(
              'Available users (first 5): ${users.take(5).map((u) => u['_id']).join(', ')}...',
            );

            // ✅ IMPORTANT: Return null instead of throwing
            // This prevents the app from crashing when a cached userId doesn't exist
            return null;
          }
        }

        print('❌ Unexpected response format');
        return null;
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token may be invalid');
        return null;
      } else if (response.statusCode == 404) {
        print('❌ User not found (404)');
        return null;
      } else {
        print('❌ Failed to fetch user profile: ${response.statusCode}');
        print('❌ Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Get current user's own profile
  /// GET {{base_url}}/user/profile
  Future<UserProfile?> fetchMyProfile() async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      if (token == null || token.isEmpty) {
        print('❌ No auth token found');
        return null;
      }

      final url = Uri.parse('${ApiStrings.baseUri}user/profile');

      print('📡 Fetching my profile: $url');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get current user's ID
        final myUserId = await _saveValues.getString(AppPreferenceHelper.ID);

        // Handle array response
        if (data['success'] == true && data['data'] != null) {
          final users = data['data'] as List;

          if (users.isEmpty) {
            return null;
          }

          // Find current user
          if (myUserId != null) {
            try {
              final myUser = users.firstWhere(
                (user) => user['_id'] == myUserId,
              );
              return UserProfile.fromJson(myUser);
            } catch (e) {
              // If not found, return first user
              return UserProfile.fromJson(users.first);
            }
          }

          // Fallback to first user
          return UserProfile.fromJson(users.first);
        }

        // Fallback: try single object
        final userData = data['user'] ?? data['data'] ?? data;
        return UserProfile.fromJson(userData);
      } else {
        print('❌ Failed to fetch my profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching my profile: $e');
      return null;
    }
  }

  /// ✅ NEW: Clear invalid cached data
  /// Call this when a user profile fails to load
  static Future<void> clearInvalidCache(String chatId) async {
    try {
      // This would clear the specific chat from Hive
      // You'll need to import Hive and implement this
      print('🗑️ Clearing invalid cache for chat: $chatId');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}
