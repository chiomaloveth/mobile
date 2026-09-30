import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';

import '../../../../../utilities/services/app_pref_helper.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../model/chat_count_model.dart';

class ChatCountApiServices {

  Future<CountResponse> fetchUnreadChatCount() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    final uri = Uri.parse(ApiStrings.getUnreadChatCount);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return CountResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load unread Chat count: ${response.statusCode}');
    }
  }
}
