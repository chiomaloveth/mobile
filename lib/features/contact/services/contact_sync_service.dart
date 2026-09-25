import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../../utilities/services/app_pref_helper.dart';
import '../../../utilities/database/save_values.dart';
import '../../../utilities/constants/app_strings/api_strings.dart';

class ContactSyncService {
  final SaveValues _saveValues = SaveValues();

  /// Standardizes a phone number to international format
  String standardizePhoneNumber(
    String phoneNumber, {
    String defaultCountryCode = 'NG',
  }) {
    try {
      // Remove all non-numeric characters except +
      String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // If already has +, parse it directly
      if (cleaned.startsWith('+')) {
        PhoneNumber phone = PhoneNumber.parse(cleaned);
        return phone.international.replaceAll(' ', ''); // e.g., +2348033489436
      }

      // If starts with 0 (Nigerian local format), replace with country code
      if (cleaned.startsWith('0')) {
        cleaned = '+234${cleaned.substring(1)}';
      }
      // If doesn't start with country code, add it
      else if (!cleaned.startsWith('234')) {
        cleaned = '+234$cleaned';
      } else if (cleaned.startsWith('234')) {
        cleaned = '+$cleaned';
      }

      PhoneNumber phone = PhoneNumber.parse(cleaned);
      return phone.international.replaceAll(
        ' ',
        '',
      ); // Return format: +2348033489436
    } catch (e) {
      print('❌ Error standardizing phone number $phoneNumber: $e');
      // Return the cleaned number with +234 prefix as fallback
      String fallback = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      if (fallback.startsWith('0')) {
        return '+234${fallback.substring(1)}';
      }
      return '+234$fallback';
    }
  }

  /// Fetches all contacts and standardizes their phone numbers
  Future<List<String>> getStandardizedContacts() async {
    try {
      // Request permission to access contacts
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        throw Exception('Contact permission denied');
      }

      // Fetch all contacts with phone numbers
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      print('📱 Total contacts fetched: ${contacts.length}');

      // Extract and standardize phone numbers
      Set<String> standardizedNumbers = {};

      for (Contact contact in contacts) {
        if (contact.phones.isNotEmpty) {
          for (var phone in contact.phones) {
            String standardized = standardizePhoneNumber(phone.number);
            if (standardized.isNotEmpty) {
              standardizedNumbers.add(standardized);
              print('📞 Standardized: ${phone.number} → $standardized');
            }
          }
        }
      }

      print('✅ Standardized ${standardizedNumbers.length} phone numbers');
      return standardizedNumbers.toList();
    } catch (e) {
      print('❌ Error getting standardized contacts: $e');
      rethrow;
    }
  }

  /// Syncs contacts with backend and returns registered/non-registered users
  Future<ContactSyncResponse> syncContactsWithBackend(
    List<String> phoneNumbers,
  ) async {
    try {
      String? token = await _saveValues.getString(
        AppPreferenceHelper.AUTH_TOKEN,
      );

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      print('📤 Sending ${phoneNumbers.length} contacts to backend...');
      print('📤 Sample contacts: ${phoneNumbers.take(5).toList()}');

      final response = await http.post(
        Uri.parse(ApiStrings.syncContacts),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"contacts": phoneNumbers}),
      );

      print('📡 Sync Contacts Response Status: ${response.statusCode}');
      print('📡 Sync Contacts Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Debug: Print the keys in the response
        print('🔍 Response keys: ${responseData.keys.toList()}');
        print('🔍 Users key exists: ${responseData.containsKey("users")}');
        print(
          '🔍 RegisteredUsers key exists: ${responseData.containsKey("registeredUsers")}',
        );

        // Debug: Print the actual data
        if (responseData.containsKey("users")) {
          print(
            '👥 Found ${(responseData["users"] as List?)?.length ?? 0} registered users',
          );
        }
        if (responseData.containsKey("nonRegisteredUsers")) {
          print(
            '👤 Found ${(responseData["nonRegisteredUsers"] as List?)?.length ?? 0} non-registered users',
          );
        }

        ContactSyncResponse syncResponse = ContactSyncResponse.fromJson(
          responseData,
        );

        print('✅ Parsed Response:');
        print('   - Registered Users: ${syncResponse.registeredUsers.length}');
        print(
          '   - Non-Registered Users: ${syncResponse.nonRegisteredUsers.length}',
        );

        // Debug: Print registered users details
        for (var user in syncResponse.registeredUsers) {
          print('   📱 ${user.username}: ${user.phone}');
        }

        return syncResponse;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Failed to sync contacts';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error syncing contacts: $e');
      rethrow;
    }
  }

  /// Complete contact sync workflow
  Future<ContactSyncResponse> performFullContactSync() async {
    print('🚀 Starting full contact sync...');

    // Step 1: Get all standardized contacts
    List<String> standardizedContacts = await getStandardizedContacts();

    // Step 2: Sync with backend
    ContactSyncResponse syncResponse = await syncContactsWithBackend(
      standardizedContacts,
    );

    print('✅ Contact Sync Complete:');
    print('   - Registered Users: ${syncResponse.registeredUsers.length}');
    print(
      '   - Non-Registered Users: ${syncResponse.nonRegisteredUsers.length}',
    );

    return syncResponse;
  }
}

/// Response provider for contact sync
class ContactSyncResponse {
  final List<RegisteredUser> registeredUsers;
  final List<String> nonRegisteredUsers;

  ContactSyncResponse({
    required this.registeredUsers,
    required this.nonRegisteredUsers,
  });

  factory ContactSyncResponse.fromJson(Map<String, dynamic> json) {
    print('🔧 Parsing ContactSyncResponse from JSON...');

    // Try both "users" (backend actual key) and "registeredUsers" (fallback)
    List<RegisteredUser> users = [];
    try {
      if (json.containsKey('users') && json['users'] != null) {
        print('✅ Found "users" key in response');
        final usersList = json['users'] as List?;
        if (usersList != null) {
          users = usersList
              .where((user) => user != null)
              .map((user) {
                try {
                  return RegisteredUser.fromJson(user as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing user: $e');
                  return null;
                }
              })
              .whereType<RegisteredUser>()
              .toList();
        }
      } else if (json.containsKey('registeredUsers') &&
          json['registeredUsers'] != null) {
        print('✅ Found "registeredUsers" key in response');
        final usersList = json['registeredUsers'] as List?;
        if (usersList != null) {
          users = usersList
              .where((user) => user != null)
              .map((user) {
                try {
                  return RegisteredUser.fromJson(user as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing user: $e');
                  return null;
                }
              })
              .whereType<RegisteredUser>()
              .toList();
        }
      } else {
        print('⚠️ Neither "users" nor "registeredUsers" found in response');
      }
    } catch (e) {
      print('❌ Error parsing registered users: $e');
    }

    List<String> nonRegistered = [];
    try {
      if (json.containsKey('nonRegisteredUsers') &&
          json['nonRegisteredUsers'] != null) {
        print('✅ Found "nonRegisteredUsers" key in response');
        final nonRegList = json['nonRegisteredUsers'] as List?;
        if (nonRegList != null) {
          nonRegistered = nonRegList
              .where((phone) => phone != null)
              .map((phone) => phone.toString())
              .toList();
        }
      } else {
        print('⚠️ "nonRegisteredUsers" not found in response');
      }
    } catch (e) {
      print('❌ Error parsing non-registered users: $e');
    }

    print(
      '🔧 Parsed ${users.length} registered users and ${nonRegistered.length} non-registered users',
    );

    return ContactSyncResponse(
      registeredUsers: users,
      nonRegisteredUsers: nonRegistered,
    );
  }
}

/// Model for registered user
class RegisteredUser {
  final String id;
  final String phone;
  final String username;
  final String? profilePicture;
  final String? about;
  final bool? isOnline;
  final String? lastActive;

  RegisteredUser({
    required this.id,
    required this.phone,
    required this.username,
    this.profilePicture,
    this.about,
    this.isOnline,
    this.lastActive,
  });

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    try {
      return RegisteredUser(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        username: json['username']?.toString() ?? 'Unknown User',
        profilePicture: json['profilePicture']?.toString(),
        about: json['about']?.toString(),
        isOnline: json['isOnline'] as bool?,
        lastActive: json['lastActive']?.toString(),
      );
    } catch (e) {
      print('❌ Error creating RegisteredUser from JSON: $e');
      // Return a default user object to prevent crashes
      return RegisteredUser(
        id: '',
        phone: json['phone']?.toString() ?? '',
        username: 'Unknown User',
      );
    }
  }

  @override
  String toString() {
    return 'RegisteredUser(id: $id, phone: $phone, username: $username, isOnline: $isOnline)';
  }
}
