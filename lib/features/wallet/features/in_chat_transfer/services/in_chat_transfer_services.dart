import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../../../../utilities/services/app_pref_helper.dart';

class InChatTransferServices {

  final baseUrl = ApiStrings.sufyanBranch;
  final SaveValues _saveValues = SaveValues();

  Future<int> inChatTransfer({required BuildContext context, required String amount, required String accountNumber}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/wallet/transfer"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({
            "userID": accountNumber,
            "amount": amount,
          })
      );
      print(response.body);
      print("Account Number: $accountNumber");
      print("Amount: $amount");
      final body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {

    }
    return -1;
  }

}