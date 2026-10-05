import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/wallet/features/transfer/model/bank_list_model.dart';
import 'package:qik_talk/features/wallet/features/transfer/model/local_account_number_response_model.dart';

import '../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../../../../utilities/services/app_pref_helper.dart';
import '../model/external_bank_transfer_response_model.dart';
import '../model/user_account_profile_response_model.dart';

class TransferServices {
  final baseUrl = ApiStrings.sufyanBranch;
  final SaveValues _saveValues = SaveValues();

  Future<int> inAppTransfer({
    required BuildContext context,
    required String amount,
    required String accountNumber,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/transfer"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"accountNumber": accountNumber, "amount": amount}),
      );
      print(response.body);
      final body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {}
    return -1;
  }

  Future<ProfileResponseModel?> userDetailsByAccountNumber({
    required BuildContext context,
    required String accountNumber,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/wallet/account/$accountNumber"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProfileResponseModel.fromMap(body);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  Future<List<BankListModel>> getBankList({
    required BuildContext context,
  }) async {
    List<BankListModel> bankListData = [];
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/wallet/bank-list"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> rawData = jsonDecode(response.body)['data'];

        for (var data in rawData) {
          bankListData.add(BankListModel.fromMap(data as Map<String, dynamic>));
        }
        return bankListData;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error loading transactions")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }
    return bankListData;
  }

  Future<LocalAccountNumberResponseModel?> verifyLocalAccountNumber({
    required BuildContext context,
    required String bankCode,
    required String accNo,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/verify-acc"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"bankCode": bankCode, "accNo": accNo}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> rawData = jsonDecode(response.body)['data'];
        final settledData = LocalAccountNumberResponseModel.fromMap(rawData);
        return settledData;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> transferToLocalBank({
    required BuildContext context,
    required String accountNumber,
    required String bankCode,
    required String amount,
    required String narration,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/transfer/external"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "accountNumber": accountNumber,
          "bankCode": bankCode,
          "amount": amount,
          "narration": narration
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = jsonDecode(response.body)['data'];

        return {
          'statusCode': response.statusCode,
          'data': rawData,
        };
      } else {
        return {
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint("Transfer Error: $e");
    }
    return {'statusCode': -1};
  }
}
