import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_config.dart';

import '../../../../../utilities/services/app_pref_helper.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../model/user_online_model.dart';

Future<UserOnlineData?> fetchUserStatus(String userId) async {
  if (userId.isEmpty) {
    print("❌ Empty userId provided - skipping status fetch");
    return null;
  }

  SaveValues mySaveValues = SaveValues();
  final token = await mySaveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

  try {
    print("📡 Fetching status for userId: $userId");
    final response = await http
        .get(
          Uri.parse("${AppConfig.apiUrl}user/$userId/active-status"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        )
        .timeout(const Duration(seconds: 10));

    print("📡 API status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final userData = jsonData['data'];

      print(
        "📡 isOnline: ${userData['isOnline']}, lastActive: ${userData['lastActive']}",
      );

      return UserOnlineData(
        id: userData['_id']?.toString() ?? userId,
        isOnline: userData['isOnline'] ?? false,
        lastActive: userData['lastActive'] != null
            ? DateTime.parse(userData['lastActive'].toString())
            : null,
      );
    } else {
      print("❌ Failed to load user status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("❌ Error fetching user status: $e");
    return null;
  }
}
