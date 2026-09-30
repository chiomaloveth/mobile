// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY MODELS — matches GET /chat/community/:id response
//
// Real API shape (from backend):
// { "success": true, "data": { "community": { _id, chatName, isCommunity,
//   isGroupChat, users: [...], groupAdmin: [...], subGroups: [...],
//   description, chatImage, createdAt, updatedAt },
//   "memberCount": N, "isMember": bool, "subGroupCount": N } }
// ─────────────────────────────────────────────────────────────────────────────

class CommunityMember {
  final String id;
  final String username;
  final String profilePicture;
  final bool isOnline;
  final String? phone;
  final String? about;

  const CommunityMember({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.isOnline,
    this.phone,
    this.about,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? 'Member',
      profilePicture: json['profilePicture'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      phone: json['phone'] as String?,
      about: json['about'] as String?,
    );
  }

  factory CommunityMember.stub(String id) => CommunityMember(
    id: id,
    username: 'Member',
    profilePicture: '',
    isOnline: false,
  );
}

// ── Sub-group inside a community ─────────────────────────────────────────────

class CommunitySubGroup {
  final String id;
  final String chatName;
  final String? chatImage;
  final String? description;
  final List<String> userIds;
  final List<String> adminIds;
  final bool isGroupChat;
  final bool isCommunity;
  final List<String> membersAvatarUrls;

  const CommunitySubGroup({
    required this.id,
    required this.chatName,
    this.chatImage,
    this.description,
    required this.userIds,
    required this.adminIds,
    required this.isGroupChat,
    required this.isCommunity,
    this.membersAvatarUrls = const [],
  });

  int get memberCount => userIds.length;
  bool isMember(String userId) => userIds.contains(userId);
  bool isAdmin(String userId) => adminIds.contains(userId);

  static List<String> _parseIds(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map<String>((u) {
          if (u is String) return u;
          if (u is Map) return (u['_id'] ?? '') as String;
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  factory CommunitySubGroup.fromJson(Map<String, dynamic> json) {
    // Extract avatar URLs from membersPreview or membersAvatar fields
    List<String> avatarUrls = [];
    final preview = json['membersPreview'] ?? json['membersAvatar'];
    if (preview is List) {
      avatarUrls = preview
          .take(3)
          .map((m) {
            if (m is Map) return (m['profilePicture'] ?? '') as String;
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }
    // Fallback: extract from users array if they are full objects
    if (avatarUrls.isEmpty) {
      final users = json['users'];
      if (users is List) {
        avatarUrls = users
            .take(3)
            .where((u) => u is Map)
            .map((u) => (u['profilePicture'] ?? '') as String)
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }

    return CommunitySubGroup(
      id: json['_id'] as String? ?? '',
      chatName: json['chatName'] as String? ?? 'Group',
      chatImage: json['chatImage'] as String? ?? json['groupImage'] as String?,
      description: json['description'] as String?,
      userIds: _parseIds(json['users']),
      adminIds: _parseIds(json['groupAdmin'] ?? json['groupAdmins']),
      isGroupChat: json['isGroupChat'] as bool? ?? true,
      isCommunity: json['isCommunity'] as bool? ?? false,
      membersAvatarUrls: avatarUrls,
    );
  }
}

// ── Main community model ──────────────────────────────────────────────────────

class CommunityModel {
  final String id;
  final String chatName;
  final String? description;
  final String? communityDescription;
  final String? chatImage;
  final String? communityBackground;
  final Map<String, dynamic>? settings;
  final bool isCommunity;
  final bool isGroupChat;
  final List<CommunityMember> users;
  final List<CommunityMember> groupAdmins;
  final List<CommunitySubGroup> subGroups;
  final List<String> adminIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Injected from the API wrapper { memberCount: N } — more reliable than
  /// users.length when the users array is partially populated
  final int? _injectedMemberCount;

  const CommunityModel({
    required this.id,
    required this.chatName,
    this.description,
    this.communityDescription,
    this.chatImage,
    this.communityBackground,
    this.settings,
    required this.isCommunity,
    required this.isGroupChat,
    required this.users,
    required this.groupAdmins,
    required this.subGroups,
    required this.adminIds,
    required this.createdAt,
    required this.updatedAt,
    int? injectedMemberCount,
  }) : _injectedMemberCount = injectedMemberCount;

  /// Prefer the server-provided memberCount, fall back to users list length
  int get memberCount => _injectedMemberCount ?? users.length;

  /// Check admin via multiple sources:
  /// 1. groupAdmins list (populated objects)
  /// 2. adminIds list (raw IDs extracted from groupAdmin array)
  bool isAdmin(String userId) {
    if (userId.isEmpty) return false;
    if (groupAdmins.any((a) => a.id == userId)) return true;
    if (adminIds.contains(userId)) return true;
    return false;
  }

  String get displayDescription {
    final d = description?.trim() ?? '';
    final c = communityDescription?.trim() ?? '';
    return d.isNotEmpty ? d : c;
  }

  static List<CommunityMember> _parseMembers(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map((item) {
          if (item is Map<String, dynamic>)
            return CommunityMember.fromJson(item);
          if (item is String && item.isNotEmpty)
            return CommunityMember.stub(item);
          return null;
        })
        .whereType<CommunityMember>()
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  static List<String> _parseAdminIds(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .map<String>((item) {
          if (item is String) return item;
          if (item is Map) return (item['_id'] ?? '') as String;
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    // ── Unwrap API envelope ───────────────────────────────────────────────────
    // Shape A (getCommunityInfo): { success, data: { community: {...}, memberCount, isMember } }
    // Shape B (createCommunity):  { success, data: { _id, chatName, ... } }
    // Shape C: already unwrapped  { _id, chatName, ... }
    Map<String, dynamic> map;
    int? injectedMemberCount;

    if (json['data'] is Map<String, dynamic>) {
      final d = json['data'] as Map<String, dynamic>;
      if (d['community'] is Map<String, dynamic>) {
        // Shape A — drill into data.community
        map = Map<String, dynamic>.from(d['community'] as Map<String, dynamic>);
        injectedMemberCount = d['memberCount'] as int?;
      } else {
        // Shape B — data is the community directly
        map = d;
      }
    } else {
      // Shape C — already unwrapped (passed directly from service after unwrapping)
      map = json;
    }

    final rawAdmins = map['groupAdmin'] ?? map['groupAdmins'];
    final rawSubs = map['subGroups'];
    final subs = (rawSubs is List)
        ? rawSubs
              .whereType<Map<String, dynamic>>()
              .map((s) => CommunitySubGroup.fromJson(s))
              .where((s) => s.id.isNotEmpty)
              .toList()
        : <CommunitySubGroup>[];

    return CommunityModel(
      id: map['_id'] as String? ?? '',
      chatName: map['chatName'] as String? ?? 'Community',
      description: map['description'] as String?,
      communityDescription: map['communityDescription'] as String?,
      chatImage: map['chatImage'] as String? ?? map['groupImage'] as String?,
      communityBackground: map['communityBackground'] as String?,
      settings: map['settings'] is Map
          ? Map<String, dynamic>.from(map['settings'] as Map)
          : null,
      isCommunity: map['isCommunity'] as bool? ?? true,
      isGroupChat: map['isGroupChat'] as bool? ?? true,
      users: _parseMembers(map['users']),
      groupAdmins: _parseMembers(rawAdmins),
      adminIds: _parseAdminIds(rawAdmins),
      subGroups: subs,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      injectedMemberCount:
          injectedMemberCount ??
          (map['_memberCount'] as int?) ??
          (map['memberCount'] as int?) ??
          (map['injectedMemberCount'] as int?),
    );
  }

  CommunityModel copyWith({
    String? chatName,
    String? description,
    String? chatImage,
    String? communityBackground,
    Map<String, dynamic>? settings,
    List<CommunitySubGroup>? subGroups,
    List<CommunityMember>? users,
  }) => CommunityModel(
    id: id,
    chatName: chatName ?? this.chatName,
    description: description ?? this.description,
    communityDescription: communityDescription,
    chatImage: chatImage ?? this.chatImage,
    communityBackground: communityBackground ?? this.communityBackground,
    settings: settings ?? this.settings,
    isCommunity: isCommunity,
    isGroupChat: isGroupChat,
    users: users ?? this.users,
    groupAdmins: groupAdmins,
    adminIds: adminIds,
    subGroups: subGroups ?? this.subGroups,
    createdAt: createdAt,
    updatedAt: updatedAt,
    injectedMemberCount: _injectedMemberCount,
  );

  /// Serialise to JSON for SharedPreferences persistence.
  /// Only stores the fields needed to render the community card offline.
  Map<String, dynamic> toJson() => {
    '_id': id,
    'chatName': chatName,
    'description': description,
    'communityDescription': communityDescription,
    'chatImage': chatImage,
    'communityBackground': communityBackground,
    if (settings != null) 'settings': settings,
    'isCommunity': isCommunity,
    'isGroupChat': isGroupChat,
    'memberCount': memberCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    // Lightweight user list — just enough for avatar initials offline
    'users': users
        .map(
          (u) => {
            '_id': u.id,
            'username': u.username,
            'profilePicture': u.profilePicture,
            'isOnline': u.isOnline,
          },
        )
        .toList(),
    'groupAdmin': groupAdmins
        .map(
          (a) => {
            '_id': a.id,
            'username': a.username,
            'profilePicture': a.profilePicture,
            'isOnline': a.isOnline,
          },
        )
        .toList(),
    // Subgroups — enough to display count and names
    'subGroups': subGroups
        .map(
          (s) => {
            '_id': s.id,
            'chatName': s.chatName,
            'chatImage': s.chatImage,
            'description': s.description,
            'isGroupChat': s.isGroupChat,
            'isCommunity': s.isCommunity,
            'users': s.userIds.map((id) => {'_id': id}).toList(),
            'groupAdmin': s.adminIds.map((id) => {'_id': id}).toList(),
          },
        )
        .toList(),
    // Inject the member count so fromJson reads it back correctly
    'injectedMemberCount': memberCount,
  };
}

class CommunityResponse {
  final bool success;
  final String message;
  final CommunityModel? community;
  final int? statusCode;

  const CommunityResponse({
    required this.success,
    required this.message,
    this.community,
    this.statusCode,
  });
}
