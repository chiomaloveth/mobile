class ProfileResponseModel {
  final bool success;
  final ProfileData data;

  ProfileResponseModel({
    required this.success,
    required this.data,
  });

  factory ProfileResponseModel.fromMap(Map<String, dynamic> map) {
    return ProfileResponseModel(
      success: map['success'] ?? false,
      data: ProfileData.fromMap(map['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': data.toMap(),
    };
  }
}

class ProfileData {
  final ExternalAccount externalAccount;
  final Profile profile;

  ProfileData({
    required this.externalAccount,
    required this.profile,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {


    ExternalAccount externalAccount;
    if (map['externalAccount'] != null && map['externalAccount'] is Map) {
      try {
        externalAccount = ExternalAccount.fromMap(map['externalAccount']);
      } catch (e) {
        externalAccount = ExternalAccount.fromMap({});
      }
    } else {
      externalAccount = ExternalAccount.fromMap({});
    }

    return ProfileData(
      externalAccount: externalAccount,
      profile: Profile.fromMap(map['profile'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'externalAccount': externalAccount.toMap(),
      'profile': profile.toMap(),
    };
  }
}

class ExternalAccount {
  final String accountNumber;
  final String bankName;
  final String accountName;
  final String userName;

  ExternalAccount({
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    required this.userName,
  });

  factory ExternalAccount.fromMap(Map<String, dynamic> map) {
    return ExternalAccount(
      accountNumber: map['accountNumber'] ?? '',
      bankName: map['bankName'] ?? '',
      accountName: map['accountName'] ?? '',
      userName: map['userName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountNumber': accountNumber,
      'bankName': bankName,
      'accountName': accountName,
      'userName': userName,
    };
  }
}

class Profile {
  final String id;
  final String phone;
  final String about;
  final String username;
  final String email;
  final String role;
  final bool isOnline;
  final bool hasPassword;
  final bool isProfileComplete;
  final String profilePicture;
  final String lastActive;

  final Security security;
  final AdminFlags adminFlags;
  final Privacy privacy;
  final Settings settings;

  final List<String> contacts;
  final List<String> fcmTokens;

  Profile({
    required this.id,
    required this.phone,
    required this.about,
    required this.username,
    required this.email,
    required this.role,
    required this.isOnline,
    required this.hasPassword,
    required this.isProfileComplete,
    required this.profilePicture,
    required this.lastActive,
    required this.security,
    required this.adminFlags,
    required this.privacy,
    required this.settings,
    required this.contacts,
    required this.fcmTokens,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['_id'] ?? '',
      phone: map['phone'] ?? '',
      about: map['about'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      isOnline: map['isOnline'] ?? false,
      hasPassword: map['hasPassword'] ?? false,
      isProfileComplete: map['isProfileComplete'] ?? false,
      profilePicture: map['profilePicture'] ?? '',
      lastActive: map['lastActive'] ?? '',
      security: Security.fromMap(map['security'] ?? {}),
      adminFlags: AdminFlags.fromMap(map['adminFlags'] ?? {}),
      privacy: Privacy.fromMap(map['privacy'] ?? {}),
      settings: Settings.fromMap(map['settings'] ?? {}),
      contacts: List<String>.from(map['contacts'] ?? []),
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'phone': phone,
      'about': about,
      'username': username,
      'email': email,
      'role': role,
      'isOnline': isOnline,
      'hasPassword': hasPassword,
      'isProfileComplete': isProfileComplete,
      'profilePicture': profilePicture,
      'lastActive': lastActive,
      'security': security.toMap(),
      'adminFlags': adminFlags.toMap(),
      'privacy': privacy.toMap(),
      'settings': settings.toMap(),
      'contacts': contacts,
      'fcmTokens': fcmTokens,
    };
  }
}

class Security {
  final bool twoFactorEnabled;

  Security({required this.twoFactorEnabled});

  factory Security.fromMap(Map<String, dynamic> map) {
    return Security(
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'twoFactorEnabled': twoFactorEnabled,
    };
  }
}

class AdminFlags {
  final bool isFlagged;
  final String reason;
  final List<Warning> warnings;

  AdminFlags({
    required this.isFlagged,
    required this.reason,
    required this.warnings,
  });

  factory AdminFlags.fromMap(Map<String, dynamic> map) {
    return AdminFlags(
      isFlagged: map['isFlagged'] ?? false,
      reason: map['reason'] ?? '',
      warnings: (map['warnings'] as List? ?? [])
          .map((e) => Warning.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isFlagged': isFlagged,
      'reason': reason,
      'warnings': warnings.map((e) => e.toMap()).toList(),
    };
  }
}

class Warning {
  final String reason;
  final String warnedAt;
  final String warnedBy;
  final String id;

  Warning({
    required this.reason,
    required this.warnedAt,
    required this.warnedBy,
    required this.id,
  });

  factory Warning.fromMap(Map<String, dynamic> map) {
    return Warning(
      reason: map['reason'] ?? '',
      warnedAt: map['warnedAt'] ?? '',
      warnedBy: map['warnedBy'] ?? '',
      id: map['_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
      'warnedAt': warnedAt,
      'warnedBy': warnedBy,
      '_id': id,
    };
  }
}

class Privacy {
  final String about;
  final String groups;
  final String lastSeen;
  final String profilePhoto;
  final bool readReceipts;

  Privacy({
    required this.about,
    required this.groups,
    required this.lastSeen,
    required this.profilePhoto,
    required this.readReceipts,
  });

  factory Privacy.fromMap(Map<String, dynamic> map) {
    return Privacy(
      about: map['about'] ?? '',
      groups: map['groups'] ?? '',
      lastSeen: map['lastSeen'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      readReceipts: map['readReceipts'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'about': about,
      'groups': groups,
      'lastSeen': lastSeen,
      'profilePhoto': profilePhoto,
      'readReceipts': readReceipts,
    };
  }
}

class Settings {
  final Notifications notifications;
  final bool allowScreenshots;
  final bool isAppLockEnabled;
  final String themeMode;

  Settings({
    required this.notifications,
    required this.allowScreenshots,
    required this.isAppLockEnabled,
    required this.themeMode,
  });

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      notifications: Notifications.fromMap(map['notifications'] ?? {}),
      allowScreenshots: map['allowScreenshots'] ?? false,
      isAppLockEnabled: map['isAppLockEnabled'] ?? false,
      themeMode: map['themeMode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications.toMap(),
      'allowScreenshots': allowScreenshots,
      'isAppLockEnabled': isAppLockEnabled,
      'themeMode': themeMode,
    };
  }
}

class Notifications {
  final bool calls;
  final bool groups;
  final bool messages;
  final bool sound;
  final bool vibrate;

  Notifications({
    required this.calls,
    required this.groups,
    required this.messages,
    required this.sound,
    required this.vibrate,
  });

  factory Notifications.fromMap(Map<String, dynamic> map) {
    return Notifications(
      calls: map['calls'] ?? false,
      groups: map['groups'] ?? false,
      messages: map['messages'] ?? false,
      sound: map['sound'] ?? false,
      vibrate: map['vibrate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calls': calls,
      'groups': groups,
      'messages': messages,
      'sound': sound,
      'vibrate': vibrate,
    };
  }
}