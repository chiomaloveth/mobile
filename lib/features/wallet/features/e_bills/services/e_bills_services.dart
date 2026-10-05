import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../../../../utilities/services/app_pref_helper.dart';
import '../electricity/model/electricity_verification_model.dart';

class EBillsServices {
  final String baseUrl = ApiStrings.baseUriTwo;
  final SaveValues _saveValues = SaveValues();

  Future<int> buyAirtime({
    required BuildContext context,
    required String phoneNumber,
    required String service,
    required String amount,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/airtime"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "phone": phoneNumber,
          "service": service,
          "amount": amount,
        }),
      );
      print(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return -1;
    }
  }

  Future<int> buyDataBundle({
    required BuildContext context,
    required String phone,
    required String service_id,
    required String variation_id,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/data/buy"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "phone": phone,
          "service_id": service_id,
          "variation_id": variation_id,
        }),
      );
      print(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return -1;
    }
  }

  Future<int> verifyBettingHandler({
    required BuildContext context,
    required String customer_id,
    required String service_id,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/betting/verify"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "customer_id": customer_id,
          "service_id": service_id,
        }),
      );
      print(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return -1;
    }
  }

  Future<int> fundBettingHandler({
    required BuildContext context,
    required String customer_id,
    required String service_id,
    required String amount,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/betting/fund"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "customer_id": customer_id,
          "service_id": service_id,
          "amount": amount,
        }),
      );
      print(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return -1;
    }
  }

  Future<int> getCableVariationsHandler({
    required BuildContext context,
    required String service
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/cable/plans"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "service": service
        }),
      );
      print(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return -1;
    }
  }

  // Import your model at the top of the file
  // import 'path_to_your/electricity_verification_model.dart';

  Future<ElectricityVerificationModel?> verifyElectricityHandler({
    required BuildContext context,
    required String customer_id,
    required String service_id,
    required String variation_id,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/electricity/verify"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "customer_id": customer_id,
          "service_id": service_id,
          "variation_id": variation_id,
        }),
      );
      print(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        final decodedJson = json.decode(response.body);
        return ElectricityVerificationModel.fromJson(decodedJson);
      } else {
        return null;
      }
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  Future<int> buyElectricityHandler({
    required BuildContext context,
    required String customer_id,
    required String service_id,
    required String variation_id,
    required String amount,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/wallet/electricity/buy"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "customer_id": customer_id,
          "service_id": service_id,
          "variation_id": variation_id,
          "amount": amount,
        }),
      );
      print(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      return -1;
    }
  }
}