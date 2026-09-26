import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';

import '../../../../../../utilities/database/save_values.dart';
import '../../../../../../utilities/services/app_pref_helper.dart';

class AddProfileServices {
  final baseUrl = ApiStrings.baseUri;
  final SaveValues _saveValues = SaveValues();

  Future<void> updateProfile({required BuildContext context, required Map<String, dynamic> data}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      await http.put(
        Uri.parse("${baseUrl}user/profile/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode(data),
      );
      // print(response.body);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server Error")));
    }
  }

  Future<void> updateUserName({required BuildContext context, required String userName}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.put(
        Uri.parse("${baseUrl}user/change-username"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "username": userName
        }),
      );
      print("RESPONSE FROM REQUEST: ${response.body}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server Error")));
    }
  }
}