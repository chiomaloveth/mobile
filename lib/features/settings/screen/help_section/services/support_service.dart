import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../utilities/database/save_values.dart';
import '../../../../../utilities/services/app_pref_helper.dart';

class SupportService {
  final SaveValues _saveValues = SaveValues();

  Future<String> submitContactSupport({
    required String subject,
    required String message,
    required String category,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}support/contact'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subject': subject,
          'message': message,
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['message'] ?? 'Support ticket submitted successfully';
        }
      }
      
      throw Exception('Failed to submit support ticket');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<String> submitBugReport({
    required String title,
    required String description,
    required String stepsToReproduce,
    required String expectedBehavior,
    required String actualBehavior,
    required String deviceInfo,
    required String appVersion,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}support/bug-report'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'stepsToReproduce': stepsToReproduce,
          'expectedBehavior': expectedBehavior,
          'actualBehavior': actualBehavior,
          'deviceInfo': deviceInfo,
          'appVersion': appVersion,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['message'] ?? 'Bug report submitted successfully';
        }
      }
      
      throw Exception('Failed to submit bug report');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getFAQs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiStrings.baseUri}support/faqs'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }
      
      // Return default FAQs if API fails
      return _getDefaultFAQs();
    } catch (e) {
      // Return default FAQs on error
      return _getDefaultFAQs();
    }
  }

  Future<bool> submitFeedback({
    required String faqId,
    required bool wasHelpful,
    String? additionalFeedback,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}support/faq-feedback'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'faqId': faqId,
          'wasHelpful': wasHelpful,
          'additionalFeedback': additionalFeedback,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  List<Map<String, dynamic>> _getDefaultFAQs() {
    return [
      {
        'id': '1',
        'category': 'Account',
        'question': 'How do I change my password?',
        'answer': 'Go to Settings > Account > Change Password. Enter your current password and new password to update it.',
      },
      {
        'id': '2',
        'category': 'Privacy',
        'question': 'How do I control who can see my last seen?',
        'answer': 'Go to Settings > Account > Privacy > Last Seen & Online. You can choose Everyone, My Contacts, or Nobody.',
      },
      {
        'id': '3',
        'category': 'Messages',
        'question': 'How do I enable disappearing messages?',
        'answer': 'Go to Settings > Account > Privacy > Default Message Timer. Choose from 24 hours, 7 days, or 90 days.',
      },
      {
        'id': '4',
        'category': 'Notifications',
        'question': 'How do I customize notification settings?',
        'answer': 'Go to Settings > Notifications. You can control message notifications, sounds, vibration, and group notifications.',
      },
      {
        'id': '5',
        'category': 'Storage',
        'question': 'How do I free up storage space?',
        'answer': 'Go to Settings > Data and Storage. You can clear cache, manage auto-download settings, and view storage usage.',
      },
    ];
  }
}