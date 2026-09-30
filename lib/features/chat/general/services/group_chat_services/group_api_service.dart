import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qik_talk/features/chat/general/model/group_model.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class GroupApiService {
  final SaveValues _saveValues = SaveValues();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool _isHtmlResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final body = response.body.trim();
    return body.startsWith('<!') ||
        body.startsWith('<html') ||
        body.startsWith('<HTML') ||
        (!contentType.contains('application/json') && body.startsWith('<'));
  }

  // ── Safely unwrap any response shape into a flat group map ────────────────
  Map<String, dynamic>? _unwrapGroup(Map<String, dynamic> json) {
    if (json.containsKey('_id')) return json;
    if (json['data'] is Map<String, dynamic>) {
      final d = json['data'] as Map<String, dynamic>;
      if (d.containsKey('_id')) return d;
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CREATE GROUP
  // POST /chat/group   body: { name, users, description?, communityId? }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupResponse?> createGroup({
    required String chatName,
    required List<String> userIds,
    String? description,
    String? communityId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}chat/group'),
        headers: headers,
        body: jsonEncode({
          'name': chatName,
          'users': userIds,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (communityId != null) 'communityId': communityId,
        }),
      );

      print('📡 createGroup: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        return GroupResponse(
          success: true,
          message: 'Group created successfully',
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupResponse(
        success: false,
        message: (error['message'] as String?) ?? 'Failed to create group',
      );
    } catch (e) {
      print('❌ createGroup: $e');
      return GroupResponse(success: false, message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GET GROUP PROFILE
  // GET /chat/group/:groupId
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupModel?> getGroupProfile({required String groupId}) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${ApiStrings.baseUri}chat/group/$groupId'),
        headers: headers,
      );

      print('📡 getGroupProfile $groupId: ${response.statusCode}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        print('📡 getGroupProfile raw keys: ${json.keys.toList()}');

        final groupData = _unwrapGroup(json);
        if (groupData == null) {
          print(
            '❌ getGroupProfile: could not find _id. Keys: ${json.keys.toList()}',
          );
          return null;
        }

        print('📡 getGroupProfile inner keys: ${groupData.keys.toList()}');
        print(
          '📡 chatName: ${groupData['chatName']} | name: ${groupData['name']}',
        );
        print(
          '🖼 chatImage: ${groupData['chatImage']} | groupIcon: ${groupData['groupIcon']}',
        );
        return GroupModel.fromJson(groupData);
      }
      return null;
    } catch (e) {
      print('❌ getGroupProfile: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GET GROUP MEMBERS
  // GET /chat/group/:groupId/members
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupMembersResult?> getGroupMembers({required String groupId}) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${ApiStrings.baseUri}chat/group/$groupId/members'),
        headers: headers,
      );

      print('📡 getGroupMembers $groupId: ${response.statusCode}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final membersData =
            (json['data'] ?? json['members'] ?? json) as dynamic;
        if (membersData is List) {
          return GroupMembersResult(
            members: membersData
                .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
                .toList(),
            adminIds: [],
          );
        }
      }
      // Fallback to group profile
      final group = await getGroupProfile(groupId: groupId);
      if (group != null) {
        return GroupMembersResult(
          members: group.users,
          adminIds: group.groupAdmins.map((a) => a.id).toList(),
        );
      }
      return null;
    } catch (e) {
      print('❌ getGroupMembers: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // RENAME GROUP
  // PUT /chat/group/rename   body: { chatId, chatName }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupResponse?> renameGroup({
    required String groupId,
    required String newName,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('${ApiStrings.baseUri}chat/group/rename'),
        headers: headers,
        body: jsonEncode({'chatId': groupId, 'chatName': newName}),
      );

      print('✏️ renameGroup $groupId → "$newName": ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        return GroupResponse(
          success: true,
          message: 'Group renamed successfully',
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupResponse(
        success: false,
        message: (error['message'] as String?) ?? 'Failed to rename group',
      );
    } catch (e) {
      print('❌ renameGroup: $e');
      return GroupResponse(success: false, message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UPDATE DESCRIPTION
  // PUT /chat/group/:groupId/description   body: { description }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupResponse?> updateDescription({
    required String groupId,
    required String description,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/group/$groupId/description'),
            headers: headers,
            body: jsonEncode({'description': description}),
          )
          .timeout(const Duration(seconds: 15));

      print('✏️ updateDescription $groupId: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        return GroupResponse(
          success: true,
          message: 'Description updated',
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupResponse(
        success: false,
        message:
            (error['message'] as String?) ?? 'Failed to update description',
      );
    } catch (e) {
      print('❌ updateDescription: $e');
      return GroupResponse(success: false, message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ADD USER TO GROUP
  // PUT /chat/group/add   body: { chatId, userId }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupResponse?> addUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('${ApiStrings.baseUri}chat/group/add'),
        headers: headers,
        body: jsonEncode({'chatId': groupId, 'userId': userId}),
      );

      print('👥 addUserToGroup $groupId/$userId: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        return GroupResponse(
          success: true,
          message: 'User added successfully',
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupResponse(
        success: false,
        message: (error['message'] as String?) ?? 'Failed to add user',
      );
    } catch (e) {
      print('❌ addUserToGroup: $e');
      return GroupResponse(success: false, message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // REMOVE USER FROM GROUP
  // PUT /chat/group/remove   body: { chatId, userId }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupResponse?> removeUserFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('${ApiStrings.baseUri}chat/group/remove'),
        headers: headers,
        body: jsonEncode({'chatId': groupId, 'userId': userId}),
      );

      print('👥 removeUserFromGroup $groupId/$userId: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        return GroupResponse(
          success: true,
          message: 'User removed successfully',
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
        );
      } else if (response.statusCode == 403) {
        return GroupResponse(
          success: false,
          message: 'Only admins can remove members',
          statusCode: 403,
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupResponse(
        success: false,
        message: (error['message'] as String?) ?? 'Failed to remove user',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ removeUserFromGroup: $e');
      return GroupResponse(success: false, message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PROMOTE TO ADMIN
  // PUT /chat/group/promote   body: { chatId, userId }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupResponse?> makeUserAdmin({
    required String groupId,
    required String userId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse(ApiStrings.makeUserAdmin),
        headers: headers,
        body: jsonEncode({'chatId': groupId, 'userId': userId}),
      );

      print('👑 makeUserAdmin $groupId/$userId: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        return GroupResponse(
          success: true,
          message: 'User is now an admin',
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
        );
      } else if (response.statusCode == 403) {
        return GroupResponse(
          success: false,
          message: 'Only admins can promote members',
          statusCode: 403,
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupResponse(
        success: false,
        message: (error['message'] as String?) ?? 'Failed to make admin',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ makeUserAdmin: $e');
      return GroupResponse(success: false, message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DEMOTE ADMIN
  // PUT /chat/group/demote   body: { chatId, userId }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupResponse?> removeAdmin({
    required String groupId,
    required String userId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse(ApiStrings.removeUserFromAdmin),
        headers: headers,
        body: jsonEncode({'chatId': groupId, 'userId': userId}),
      );
      print('👑 removeAdmin $groupId/$userId: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        return GroupResponse(
          success: true,
          message: 'Admin role removed',
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
        );
      } else if (response.statusCode == 403) {
        return GroupResponse(
          success: false,
          message: 'Only admins can demote other admins',
          statusCode: 403,
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupResponse(
        success: false,
        message: (error['message'] as String?) ?? 'Failed to remove admin',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ removeAdmin: $e');
      return GroupResponse(success: false, message: 'Error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GENERATE GROUP INVITE LINK
  // PUT /chat/group/invite   body: { chatId }
  // Backend generates a real invite code and returns it.
  // We then build: https://qiktalk.app/join?code=<inviteCode>
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupInviteResult?> generateGroupInviteLink({
    required String groupId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.put(
        Uri.parse('${ApiStrings.baseUri}chat/group/invite'),
        headers: headers,
        body: jsonEncode({'chatId': groupId}),
      );

      print(
        '📡 generateGroupInviteLink: ${response.statusCode} | body: ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Backend may return the code in different fields — try all common ones
        final inviteCode =
            data['inviteCode'] as String? ??
            data['code'] as String? ??
            data['invite_code'] as String? ??
            data['joinCode'] as String? ??
            (data['data'] is Map
                ? (data['data'] as Map)['inviteCode'] as String?
                : null) ??
            (data['data'] is Map
                ? (data['data'] as Map)['code'] as String?
                : null);

        if (inviteCode == null || inviteCode.isEmpty) {
          print(
            '❌ generateGroupInviteLink: no invite code in response. Keys: ${data.keys.toList()}',
          );
          return GroupInviteResult(success: false, link: '');
        }

        final link = 'https://qiktalk.app/join?code=$inviteCode';
        print('📡 generateGroupInviteLink: link=$link');
        return GroupInviteResult(success: true, link: link);
      }

      print('❌ generateGroupInviteLink failed: ${response.body}');
      return GroupInviteResult(success: false, link: '');
    } catch (e) {
      print('❌ generateGroupInviteLink: $e');
      return GroupInviteResult(success: false, link: '');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // JOIN GROUP VIA INVITE CODE
  // POST /chat/group/join   body: { inviteCode }
  // ✅ inviteCode is the groupId extracted from the deep link ?code= param
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupJoinResult?> joinGroupViaInviteLink({
    required String inviteCode,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}chat/group/join'),
        headers: headers,
        body: jsonEncode({'inviteCode': inviteCode}),
      );

      print('📡 joinGroupViaInviteLink: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final groupRaw = data['data'] ?? data['chat'] ?? data;
        final groupData = groupRaw is Map<String, dynamic>
            ? _unwrapGroup(groupRaw)
            : null;
        return GroupJoinResult(
          success: true,
          alreadyMember: false,
          group: groupData != null ? GroupModel.fromJson(groupData) : null,
          message: 'Joined successfully',
        );
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = (error['message'] as String? ?? '').toLowerCase();
        if (msg.contains('already') || msg.contains('member')) {
          final groupRaw = error['data'] ?? error['chat'];
          final groupData = groupRaw is Map<String, dynamic>
              ? _unwrapGroup(groupRaw)
              : null;
          return GroupJoinResult(
            success: true,
            alreadyMember: true,
            group: groupData != null ? GroupModel.fromJson(groupData) : null,
            message: 'You are already a member of this group',
          );
        }
        return GroupJoinResult(
          success: false,
          alreadyMember: false,
          message: error['message'] as String? ?? 'Failed to join group',
        );
      }
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      return GroupJoinResult(
        success: false,
        alreadyMember: false,
        message: error['message'] as String? ?? 'Failed to join group',
      );
    } catch (e) {
      print('❌ joinGroupViaInviteLink: $e');
      return GroupJoinResult(
        success: false,
        alreadyMember: false,
        message: 'Error: $e',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LEAVE GROUP
  // DELETE /chat/group/:groupId/leave
  // ─────────────────────────────────────────────────────────────────────────────
  Future<bool> leaveGroup({required String groupId}) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('${ApiStrings.baseUri}chat/group/$groupId/leave'),
        headers: headers,
      );
      print('📡 leaveGroup $groupId: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ leaveGroup: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GET GROUP DETAILS (legacy fallback)
  // GET /chat/:groupId
  // ─────────────────────────────────────────────────────────────────────────────
  Future<GroupModel?> getGroupDetails({required String groupId}) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${ApiStrings.baseUri}chat/$groupId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final groupData = _unwrapGroup(json);
        if (groupData == null) return null;
        return GroupModel.fromJson(groupData);
      }
      return null;
    } catch (e) {
      print('❌ getGroupDetails: $e');
      return null;
    }
  }
}
