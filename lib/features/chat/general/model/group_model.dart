class GroupModel {
  final String id;
  final String chatName;
  final String? description;
  final bool isGroupChat;
  final List<GroupMember> users;
  final List<GroupMember> groupAdmins;
  final String? groupImage;
  final GroupSettings? settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel({
    required this.id,
    required this.chatName,
    this.description,
    required this.isGroupChat,
    required this.users,
    required this.groupAdmins,
    this.groupImage,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── Safely parse members — handles full objects, bare ID strings, or missing ───
  static List<GroupMember> _parseMembers(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw
        .map((item) {
          if (item is Map<String, dynamic>) {
            return GroupMember.fromJson(item);
          } else if (item is String && item.isNotEmpty) {
            return GroupMember(id: item, username: 'Member');
          }
          return null;
        })
        .whereType<GroupMember>()
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  static List<GroupMember> _parseAdmins(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw
        .map((item) {
          if (item is Map<String, dynamic>) {
            return GroupMember.fromJson(item);
          } else if (item is String && item.isNotEmpty) {
            return GroupMember(id: item, username: 'Admin');
          }
          return null;
        })
        .whereType<GroupMember>()
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    // For community sub-groups the backend omits chatName entirely.
    // The name lives inside the nested 'community' object as 'chatName'.
    String? communityName;
    final communityField = json['community'];
    if (communityField is Map<String, dynamic>) {
      communityName =
          communityField['chatName'] as String? ??
          communityField['name'] as String?;
    }

    final chatName =
        json['chatName'] as String? ??
        json['name'] as String? ??
        communityName ??
        'Unnamed Group';

    // Parse users — getAllChat may NOT include a users array at all.
    // The group profile endpoint does. Try multiple field names.
    final parsedUsers = _parseMembers(
      json['users'] ?? json['members'] ?? json['components'],
    );

    // Parse admins
    final parsedAdmins = _parseAdmins(
      json['groupAdmin'] ?? json['groupAdmins'],
    );

    // ── Member count fallback ────────────────────────────────────────────────
    // When getAllChat doesn't return a users array, the backend might still
    // include a numeric count field. Use it to build stub members so that
    // group.memberCount returns the right number in AddToGroupsScreen.
    final rawCount =
        json['memberCount'] as int? ??
        json['usersCount'] as int? ??
        json['totalMembers'] as int? ??
        json['membersCount'] as int?;

    final effectiveUsers = parsedUsers.isNotEmpty
        ? parsedUsers
        : (rawCount != null && rawCount > 0)
        ? List.generate(
            rawCount,
            (i) => GroupMember(id: 'stub_$i', username: 'Member'),
          )
        : <GroupMember>[];

    // Also check if admins can tell us there's at least 1 member
    // (admins are users too — use them when users list is empty)
    final finalUsers = effectiveUsers.isNotEmpty
        ? effectiveUsers
        : parsedAdmins.isNotEmpty
        ? parsedAdmins // at minimum the admins are members
        : <GroupMember>[];

    return GroupModel(
      id: json['_id'] as String? ?? '',
      chatName: chatName,
      description: json['description'] as String?,
      isGroupChat: json['isGroupChat'] as bool? ?? true,
      users: finalUsers,
      groupAdmins: parsedAdmins,
      groupImage:
          json['groupIcon'] as String? ??
          json['chatImage'] as String? ??
          json['groupImage'] as String?,
      settings: json['settings'] is Map<String, dynamic>
          ? GroupSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Use this after a rename so the correct name is always shown even if the
  /// API response uses a different field or returns a stale value.
  factory GroupModel.fromJsonWithFallbackName(
    Map<String, dynamic> json,
    String fallbackName,
  ) {
    final parsed = GroupModel.fromJson(json);
    final resolvedName =
        (parsed.chatName == 'Unnamed Group' || parsed.chatName.isEmpty)
        ? fallbackName
        : parsed.chatName;
    return GroupModel(
      id: parsed.id,
      chatName: resolvedName,
      description: parsed.description,
      isGroupChat: parsed.isGroupChat,
      users: parsed.users,
      groupAdmins: parsed.groupAdmins,
      groupImage: parsed.groupImage,
      settings: parsed.settings,
      createdAt: parsed.createdAt,
      updatedAt: parsed.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'chatName': chatName,
    'description': description,
    'isGroupChat': isGroupChat,
    'users': users.map((u) => u.toJson()).toList(),
    'groupAdmin': groupAdmins.map((a) => a.toJson()).toList(),
    'chatImage': groupImage,
    'settings': settings?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  bool isAdmin(String userId) => groupAdmins.any((admin) => admin.id == userId);

  /// True member count — never 0 if we have real data
  int get memberCount =>
      users.where((u) => !u.id.startsWith('stub_')).length +
      users.where((u) => u.id.startsWith('stub_')).length;

  GroupMember? getMember(String userId) {
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP MEMBER
// ─────────────────────────────────────────────────────────────────────────────

class GroupMember {
  final String id;
  final String username;
  final String? profilePicture;
  final String? phoneNumber;
  final bool? isOnline;
  final DateTime? lastActive;

  GroupMember({
    required this.id,
    required this.username,
    this.profilePicture,
    this.phoneNumber,
    this.isOnline,
    this.lastActive,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username:
          json['username'] as String? ?? json['name'] as String? ?? 'Member',
      profilePicture: json['profilePicture'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isOnline: json['isOnline'] as bool?,
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': username,
    'profilePicture': profilePicture,
    'phoneNumber': phoneNumber,
    'isOnline': isOnline,
    'lastActive': lastActive?.toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP SETTINGS
// ─────────────────────────────────────────────────────────────────────────────

class GroupSettings {
  final DisappearingMessages? disappearingMessages;
  final bool onlyAdminsCanMessage;
  final bool onlyAdminsCanEditInfo;

  GroupSettings({
    this.disappearingMessages,
    required this.onlyAdminsCanMessage,
    required this.onlyAdminsCanEditInfo,
  });

  factory GroupSettings.fromJson(Map<String, dynamic> json) => GroupSettings(
    disappearingMessages: json['disappearingMessages'] is Map
        ? DisappearingMessages.fromJson(
            json['disappearingMessages'] as Map<String, dynamic>,
          )
        : null,
    onlyAdminsCanMessage: json['onlyAdminsCanMessage'] as bool? ?? false,
    onlyAdminsCanEditInfo: json['onlyAdminsCanEditInfo'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'disappearingMessages': disappearingMessages?.toJson(),
    'onlyAdminsCanMessage': onlyAdminsCanMessage,
    'onlyAdminsCanEditInfo': onlyAdminsCanEditInfo,
  };
}

class DisappearingMessages {
  final bool enabled;
  final int duration;

  DisappearingMessages({required this.enabled, required this.duration});

  factory DisappearingMessages.fromJson(Map<String, dynamic> json) =>
      DisappearingMessages(
        enabled: json['enabled'] as bool? ?? false,
        duration: json['duration'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {'enabled': enabled, 'duration': duration};
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSE / RESULT MODELS
// ─────────────────────────────────────────────────────────────────────────────

class GroupResponse {
  final bool success;
  final String message;
  final GroupModel? group;
  final int? statusCode;

  GroupResponse({
    required this.success,
    required this.message,
    this.group,
    this.statusCode,
  });
}

class GroupMembersResult {
  final List<GroupMember> members;
  final List<String> adminIds;

  GroupMembersResult({required this.members, required this.adminIds});
}

class GroupInviteResult {
  final bool success;
  final String link;
  final String? message;

  GroupInviteResult({required this.success, this.link = '', this.message});
}

class GroupJoinResult {
  final bool success;
  final bool alreadyMember;
  final GroupModel? group;
  final String message;

  GroupJoinResult({
    required this.success,
    required this.alreadyMember,
    this.group,
    required this.message,
  });
}
