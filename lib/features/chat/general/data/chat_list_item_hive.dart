import 'dart:convert';
import 'package:hive_ce/hive.dart';
import '../model/get_chat_model.dart';
part 'chat_list_item_hive.g.dart';

@HiveType(typeId: 0)
class ChatListItemHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final bool isGroupChat;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String lastMessageJson;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final String profilePicture;

  @HiveField(6)
  final String about;

  @HiveField(7)
  final String userId;

  @HiveField(8)
  final bool isArchived;

  @HiveField(9)
  final bool isMuted;

  @HiveField(10)
  final DateTime? muteUntil;

  @HiveField(11)
  final String? wallpaperPath;

  @HiveField(12)
  final int memberCount;

  @HiveField(13)
  final bool isBroadcast;

  @HiveField(14)
  final bool isCommunity;

  @HiveField(15)
  final bool isPinned;

  @HiveField(16)
  final DateTime? pinnedAt;

  @HiveField(17)
  final List<String> membersAvatarUrls;

  @HiveField(18)
  final List<String> memberUserIds;

  @HiveField(19)
  final bool? isBlocked; // <-- made nullable

  ChatListItemHive({
    required this.id,
    required this.isGroupChat,
    required this.title,
    required this.lastMessageJson,
    required this.updatedAt,
    this.profilePicture = '',
    this.about = '',
    required this.userId,
    this.isArchived = false,
    this.isMuted = false,
    this.muteUntil,
    this.wallpaperPath,
    this.memberCount = 0,
    this.isBroadcast = false,
    this.isCommunity = false,
    this.isPinned = false,
    this.pinnedAt,
    this.membersAvatarUrls = const [],
    this.memberUserIds = const [],
    this.isBlocked, // allow null, handle default in getter
  });

  LatestMessage? get lastMessage {
    if (lastMessageJson.isEmpty) return null;
    try {
      final jsonMap = json.decode(lastMessageJson);
      return LatestMessage.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  bool get isCurrentlyMuted {
    if (!isMuted) return false;
    if (muteUntil == null) return true;
    return DateTime.now().isBefore(muteUntil!);
  }

  // Safe getter for blocked state
  bool get blocked => isBlocked ?? false;

  ChatListItemHive copyWith({
    String? id,
    bool? isGroupChat,
    String? title,
    String? lastMessageJson,
    DateTime? updatedAt,
    String? profilePicture,
    String? about,
    String? userId,
    bool? isArchived,
    bool? isMuted,
    Object? muteUntil = _sentinel,
    String? wallpaperPath,
    int? memberCount,
    bool? isBroadcast,
    bool? isCommunity,
    bool? isPinned,
    Object? pinnedAt = _sentinel,
    List<String>? membersAvatarUrls,
    List<String>? memberUserIds,
    bool? isBlocked,
  }) {
    return ChatListItemHive(
      id: id ?? this.id,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      title: title ?? this.title,
      lastMessageJson: lastMessageJson ?? this.lastMessageJson,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePicture: profilePicture ?? this.profilePicture,
      about: about ?? this.about,
      userId: userId ?? this.userId,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      muteUntil: identical(muteUntil, _sentinel)
          ? this.muteUntil
          : muteUntil as DateTime?,
      wallpaperPath: wallpaperPath ?? this.wallpaperPath,
      memberCount: memberCount ?? this.memberCount,
      isBroadcast: isBroadcast ?? this.isBroadcast,
      isCommunity: isCommunity ?? this.isCommunity,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: identical(pinnedAt, _sentinel)
          ? this.pinnedAt
          : pinnedAt as DateTime?,
      membersAvatarUrls: membersAvatarUrls ?? this.membersAvatarUrls,
      memberUserIds: memberUserIds ?? this.memberUserIds,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
