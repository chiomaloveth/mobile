import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../utilities/constants/app_strings/api_strings.dart';
import '../../../../../../utilities/database/save_values.dart';
import '../../../../../../utilities/services/app_pref_helper.dart';

class DataStorageService {
  final SaveValues _saveValues = SaveValues();

  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse('${ApiStrings.baseUri}user/storage-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'] as Map<String, dynamic>;
        }
      }
      
      // Fallback to default values if API fails
      return _getDefaultStorageInfo();
    } catch (e) {
      // Return default values on error
      return _getDefaultStorageInfo();
    }
  }

  Future<Map<String, dynamic>> updateAutoDownloadSettings(Map<String, dynamic> settings) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.put(
        Uri.parse('${ApiStrings.baseUri}user/settings/data-storage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(settings),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'] as Map<String, dynamic>;
        }
      }
      
      throw Exception('Failed to update settings');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<bool> clearCache() async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.delete(
        Uri.parse('${ApiStrings.baseUri}user/clear-cache'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearMediaCache() async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.delete(
        Uri.parse('${ApiStrings.baseUri}user/clear-media-cache'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _getDefaultStorageInfo() {
    return {
      'totalStorage': 64000000000, // 64GB in bytes
      'usedStorage': 2500000000,   // 2.5GB in bytes
      'mediaStorage': 1800000000,  // 1.8GB in bytes
      'documentsStorage': 450000000, // 450MB in bytes
      'cacheStorage': 250000000,   // 250MB in bytes
      'autoDownload': {
        'wifi': {
          'photos': true,
          'videos': true,
          'documents': false,
        },
        'cellular': {
          'photos': false,
          'videos': false,
          'documents': false,
        },
        'roaming': {
          'photos': false,
          'videos': false,
          'documents': false,
        },
      },
      'networkUsage': {
        'totalSent': 1200000000,     // 1.2GB
        'totalReceived': 3400000000, // 3.4GB
        'mediaReceived': 2100000000, // 2.1GB
        'callsData': 150000000,      // 150MB
      }
    };
  }
}