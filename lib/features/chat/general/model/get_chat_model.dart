import 'dart:convert';

class ChatListItem {
  final String id;
  final bool isGroupChat;
  final bool isCommunity;
  final bool isBroadcast;

  final String chatName;
  final UserSummary currentUser;
  final UserSummary? otherUser;
  final List<UserSummary> members;
  final LatestMessage? latestMessage;
  final DateTime updatedAt;
  final String? chatImage;

  // ── NEW: pin data from API ─────────────────────────────────────────────────
  // Each entry looks like: { "user": "<userId>", "pinnedAt": "<iso>" }
  final List<Map<String, dynamic>>? pinnedChatBy;
  // ──────────────────────────────────────────────────────────────────────────

  ChatListItem({
    required this.id,
    required this.isGroupChat,
    this.isCommunity = false,
    this.isBroadcast = false,
    required this.chatName,
    required this.currentUser,
    this.otherUser,
    required this.members,
    this.latestMessage,
    required this.updatedAt,
    this.chatImage,
    this.pinnedChatBy,
  });

  int get memberCount => members.length;
  String get groupImage => chatImage ?? '';

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    return ChatListItem(
      id: json['_id'],
      isGroupChat: json['isGroupChat'] ?? false,
      isCommunity: json['isCommunity'] as bool? ?? false,
      isBroadcast: json['isBroadcast'] as bool? ?? false,
      chatName: json['chatName'] ?? '',
      currentUser: UserSummary.fromJson(json['currentUser']),
      otherUser: json['otherUser'] != null
          ? UserSummary.fromJson(json['otherUser'])
          : null,
      members:
          ((json['users'] ?? json['members'] ?? json['components'])
                      as List<dynamic>? ??
                  [])
              .map((e) => UserSummary.fromJson(e))
              .toList(),
      latestMessage: json['latestMessage'] != null
          ? LatestMessage.fromJson(json['latestMessage'])
          : null,
      updatedAt: DateTime.parse(json['updatedAt']),
      chatImage: json['chatImage'] ?? json['groupImage'],
      // ── parse pinnedChatBy ─────────────────────────────────────────────────
      pinnedChatBy: (json['pinnedChatBy'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      // ────────────────────────────────────────────────────────────────────────
    );
  }
}

class UserSummary {
  final String id;
  final String username;
  final String profilePicture;
  final String? about;
  final bool isOnline;
  final DateTime? lastActive;

  UserSummary({
    required this.id,
    required this.username,
    required this.profilePicture,
    this.about,
    required this.isOnline,
    this.lastActive,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['_id'],
      username: json['username'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      about: json['about'],
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
    );
  }
}

class LatestMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime createdAt;
  final bool isRead;
  final String? status; // ✅ NEW: Track delivery status (sent, delivered, read)

  final bool isVoiceNote;
  final bool isImage;
  final bool isAudio;
  final bool isVideo;
  final bool isDocument;
  final bool isContact;

  LatestMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.isRead = false,
    this.status,
    this.isVoiceNote = false,
    this.isImage = false,
    this.isAudio = false,
    this.isVideo = false,
    this.isDocument = false,
    this.isContact = false,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    final attachments = json['attachments'] as List<dynamic>?;

    bool hasVoiceNote =
        attachments?.any(
          (a) => a['fileType'] == 'voice_note' || a['isVoiceNote'] == true,
        ) ??
        json['isVoiceNote'] == true;

    // Also check contentType field which backend sends back
    final contentType = json['contentType']?.toString() ?? '';

    bool hasImage =
        !hasVoiceNote &&
        (contentType == 'image' ||
            attachments?.any(
                  (a) =>
                      a['fileType'] == 'image' ||
                      a['fileType'] == 'image/jpeg' ||
                      a['fileType'] == 'image/png' ||
                      a['mimeType']?.startsWith('image/') == true ||
                      (a['url']?.toString().contains('/qiktalk-media/') ==
                              true &&
                          !a['url'].toString().contains('.m4a') &&
                          !a['url'].toString().contains('.ogg') &&
                          !a['url'].toString().contains('.opus') &&
                          !a['url'].toString().contains('.mp3') &&
                          !a['url'].toString().contains('.wav') &&
                          !a['url'].toString().contains('.mp4') &&
                          !a['url'].toString().contains('.mov')),
                ) ==
                true ||
            json['isImage'] == true);

    bool hasAudio =
        contentType == 'audio' ||
        attachments?.any(
              (a) =>
                  a['fileType'] == 'audio' ||
                  a['mimeType']?.startsWith('audio/') == true,
            ) ==
            true ||
        json['isAudio'] == true;

    bool hasVideo =
        contentType == 'video' ||
        attachments?.any(
              (a) =>
                  a['fileType'] == 'video' ||
                  a['mimeType']?.startsWith('video/') == true,
            ) ==
            true ||
        json['isVideo'] == true;

    bool hasDocument =
        contentType == 'document' ||
        attachments?.any(
              (a) =>
                  a['fileType'] == 'document' ||
                  a['mimeType']?.startsWith('application/') == true ||
                  a['mimeType'] == 'application/pdf' ||
                  a['mimeType'] == 'application/msword' ||
                  a['mimeType']?.contains('spreadsheet') == true ||
                  a['mimeType']?.contains('presentation') == true,
            ) ==
            true ||
        json['isDocument'] == true;

    // Documents must NOT be classified as images
    if (hasDocument) {
      hasImage = false;
      hasAudio = false;
      hasVideo = false;
    }

    bool hasContact =
        attachments?.any((a) => a['fileType'] == 'contact') ??
        json['isContact'] == true;

    final String parsedSenderId =
        json['sender']?['_id']?.toString() ??
        json['senderId']?.toString() ??
        '';

    final List<dynamic> readBy = json['readBy'] as List<dynamic>? ?? [];
    final bool isRead =
        json['isRead'] == true ||
        readBy.any(
          (id) => id.toString() != parsedSenderId && id.toString().isNotEmpty,
        );

    return LatestMessage(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: parsedSenderId,
      senderName: json['sender']?['username'] ?? '',
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      isRead: isRead,
      status: json['status']?.toString(),
      isVoiceNote: hasVoiceNote,
      isImage: hasImage,
      isAudio: hasAudio,
      isVideo: hasVideo,
      isDocument: hasDocument,
      isContact: hasContact,
    );
  }
}
