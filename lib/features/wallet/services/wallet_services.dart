import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/wallet/model/generated_wallet_response_model.dart';
import '../../../utilities/constants/app_strings/api_strings.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../model/fund_wallet_generated_response_model.dart';
import '../model/wallet_balance_model.dart';
import '../model/wallet_details_model.dart';


class WalletServices {

  final baseUrl = ApiStrings.sufyanBranch;
  final SaveValues _saveValues = SaveValues();

  Future<GeneratedWalletResponseModel> generateWallet({required BuildContext context}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/generate-account"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      final body = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && body['success'] == true) {
        if (body['data'] != null) {
          final Map<String, dynamic> collectedData = jsonDecode(response.body)['data'];
          final savedData = GeneratedWalletResponseModel.fromMap(collectedData);
          return savedData;
        }
        return body['data']['message'] ?? "Failed";
      } else {
        throw Exception(body['message'] ?? body['data']?['message'] ?? "Failed");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<int> fundWallet({required BuildContext context, required String amount}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/fund"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          'amount': amount
        })
      );
      print(response.body);
      final body = json.decode(response.body);
      return response.statusCode;
    } catch (e) {
    }
    return -1;
  }

  Future<WalletDetailsModel> getAccountDetails({required BuildContext context}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/wallet/account"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      final body = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && body['success'] == true) {
        if (body['data'] != null) {
          final Map<String, dynamic> collectedData = jsonDecode(response.body)['data'];
          final savedData = WalletDetailsModel.fromMap(collectedData);
          return savedData;
        }
        return body['data']['message'] ?? "Failed";
      } else {
        throw Exception(body['message'] ?? body['data']?['message'] ?? "Failed");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<WalletBalanceModel> getWalletBalance({required BuildContext context}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/wallet/balance"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      final body = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {

        if (body['data'] != null) {
          final Map<String, dynamic> data = body['data'];

          return WalletBalanceModel.fromMap(data);
        }

        throw Exception("No data returned from server");
      } else {
        throw Exception(
          body['message'] ?? body['data']?['message'] ?? "Failed to fetch balance",
        );
      }
    } catch (e) {
      throw Exception("Error fetching wallet balance: $e");
    }
  }

  Future<int> inAppTransfer({required BuildContext context, required String amount, required String receiverPhone}) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/transfer"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "receiverPhone": receiverPhone,
          "amount": amount,
        })
      );
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