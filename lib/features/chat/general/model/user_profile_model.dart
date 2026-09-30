class UserProfile {
  final String id;
  final String username;
  final String phone;
  final String profilePicture;
  final String about;
  final bool isOnline;
  final DateTime? lastActive;
  final UserPrivacy privacy;
  final List<String>? profilePictures;

  UserProfile({
    required this.id,
    required this.username,
    required this.phone,
    required this.profilePicture,
    required this.about,
    required this.isOnline,
    this.lastActive,
    required this.privacy,
    this.profilePictures,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      about: json['about'] ?? 'Hey there! I am using QikTalk.',
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      privacy: json['privacy'] != null
          ? UserPrivacy.fromJson(json['privacy'])
          : UserPrivacy.defaultPrivacy(),
      profilePictures: json['profilePictures'] != null
          ? List<String>.from(json['profilePictures'])
          : (json['profilePicture'] != null &&
                json['profilePicture'].isNotEmpty)
          ? [json['profilePicture']]
          : null,
    );
  }

  String getLastSeenText() {
    if (isOnline) {
      return 'Online';
    }

    if (lastActive == null) {
      return 'Last seen recently';
    }

    final now = DateTime.now();
    final difference = now.difference(lastActive!);

    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Last seen yesterday';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays}d ago';
    } else {
      return 'Last seen a long time ago';
    }
  }
}

class UserPrivacy {
  final bool showPhone;
  final bool showAbout;
  final bool showProfilePicture;
  final bool showLastSeen;
  final bool showOnlineStatus;

  UserPrivacy({
    required this.showPhone,
    required this.showAbout,
    required this.showProfilePicture,
    required this.showLastSeen,
    required this.showOnlineStatus,
  });

  factory UserPrivacy.fromJson(Map<String, dynamic> json) {
    // The API returns privacy settings like:
    // "privacy": {
    //   "lastSeen": "everyone",
    //   "profilePhoto": "everyone",
    //   "about": "everyone",
    //   "readReceipts": true,
    //   "groups": "everyone"
    // }

    // Convert "everyone" | "contacts" | "nobody" to boolean
    bool _parsePrivacy(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is String) {
        return value == "everyone" || value == "contacts";
      }
      return true;
    }

    return UserPrivacy(
      showPhone: true, // Phone is always visible in this API
      showAbout: _parsePrivacy(json['about']),
      showProfilePicture: _parsePrivacy(json['profilePhoto']),
      showLastSeen: _parsePrivacy(json['lastSeen']),
      showOnlineStatus: _parsePrivacy(json['lastSeen']), // Use same as lastSeen
    );
  }

  factory UserPrivacy.defaultPrivacy() {
    return UserPrivacy(
      showPhone: true,
      showAbout: true,
      showProfilePicture: true,
      showLastSeen: true,
      showOnlineStatus: true,
    );
  }
}
