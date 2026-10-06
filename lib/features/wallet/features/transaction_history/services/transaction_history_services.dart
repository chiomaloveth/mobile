import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/wallet/features/transaction_history/model/transaction_history_model.dart';
import '../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../../../../utilities/services/app_pref_helper.dart';

class TransactionHistoryServices {
  final baseUrl = ApiStrings.sufyanBranch;
  final SaveValues _saveValues = SaveValues();

  Future<List<TransactionHistoryModel>> getUserTransactions({required BuildContext context}) async {
    List<TransactionHistoryModel> transactions = [];
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/wallet/transactions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        final List<dynamic> rawData = decodedData['data'] ?? [];
        for (var data in rawData) {
          transactions.add(TransactionHistoryModel.fromMap(data as Map<String, dynamic>));
        }
        return transactions;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error loading transactions")));
        }
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }

    return [];
  }
}