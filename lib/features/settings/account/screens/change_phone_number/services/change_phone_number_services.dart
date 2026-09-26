import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import '../../../../../../utilities/database/save_values.dart';
import '../../../../../../utilities/services/app_pref_helper.dart';

class ChangePhoneNumberServices {
  final SaveValues _saveValues = SaveValues();

  Future<String> requestPhoneNumberChange({
    required String phoneNumber,
  }) async {
    try {
      final token =
          await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      print('📱 REQUEST URL: ${ApiStrings.changeNumberRequest}');
      print('📱 REQUEST BODY: ${jsonEncode({'newPhone': phoneNumber})}');

      final response = await http.post(
        Uri.parse(ApiStrings.changeNumberRequest),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newPhone': phoneNumber}),
      );

      print('📱 RESPONSE STATUS: ${response.statusCode}');
      print('📱 RESPONSE BODY: ${response.body}');

      final body = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        if (body['data'] != null && body['data']['otp'] != null) {
          print('📱 DEBUG OTP: ${body['data']['otp']}');
        }
        return body['data']?['message'] ??
            body['message'] ??
            'OTP sent successfully';
      } else {
        throw Exception(
          body['message'] ??
              body['data']?['message'] ??
              'Failed to send OTP',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> confirmPhoneNumberChange({required String otp}) async {
    try {
      final token =
          await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);

      print('📱 VERIFY URL: ${ApiStrings.changeNumberVerify}');
      print('📱 VERIFY BODY: ${jsonEncode({'otp': otp})}');

      final response = await http.post(
        Uri.parse(ApiStrings.changeNumberVerify),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otp': otp}),
      );

      print('📱 VERIFY STATUS: ${response.statusCode}');
      print('📱 VERIFY BODY: ${response.body}');

      final body = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        return body['message'] ?? 'Phone number changed successfully';
      } else {
        throw Exception(body['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}