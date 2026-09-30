import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';

class ChatHistoryResponse {
  final List<ChatMessage> messages;
  final bool hasMore;
  final String? nextCursor;
  final String? prevCursor;

  ChatHistoryResponse({
    required this.messages,
    required this.hasMore,
    this.nextCursor,
    this.prevCursor,
  });

  factory ChatHistoryResponse.fromJson(
    Map<String, dynamic> json,
    String myUserId,
  ) {
    return ChatHistoryResponse(
      messages: (json['messages'] as List)
          .map((e) => ChatMessage.fromJson(e, myUserId))
          .toList(),
      hasMore: json['hasMore'],
      nextCursor: json['nextCursor'],
      prevCursor: json['prevCursor'],
    );
  }
}

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String chatId;
  final String text;
  final bool isMe;
  bool isRead;
  final String timestamp;
  MessageStatus status;
  final bool isEdited;
  final bool isDeleted;
  final List<Map<String, dynamic>>? reactions;

  final bool isSaved;
  final String? replyToMessageId;
  final String? replyToText;
  final bool? replyToIsMe;
  final String? replyToSenderName;
  final String? replyToMediaType;
  final String? replyToThumbnailUrl;

  bool isVoiceNote;
  bool isAudioFile;
  String? audioUrl;
  String? audioName;
  bool isImage;
  List<String>? imageUrls;
  bool isDocument;
  String? documentUrl;
  String? documentName;

  bool isVideo;
  String? videoUrl;
  String? videoThumbnail;

  // ✅ Group chat sender info
  final String? senderName;
  final String? senderAvatar;

  // ✅ Call event
  final bool isCallEvent;
  final String? callType;
  final String? callStatus;
  final int? callDuration;

  // ✅ Forwarded message flag
  final bool isForwarded;

  // ✅ Mentions
  final List<Map<String, dynamic>> mentions;
  final List<String> mentionedUserIds;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.text,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.isEdited = false,
    this.isDeleted = false,
    this.reactions,
    this.isSaved = false,
    this.replyToMessageId,
    this.replyToText,
    this.replyToIsMe,
    this.replyToSenderName,
    this.replyToMediaType,
    this.replyToThumbnailUrl,
    this.isVoiceNote = false,
    this.isAudioFile = false,
    this.audioUrl,
    this.audioName,
    this.isImage = false,
    this.imageUrls,
    this.isDocument = false,
    this.documentUrl,
    this.documentName,
    this.isVideo = false,
    this.videoUrl,
    this.videoThumbnail,
    this.senderName,
    this.senderAvatar,
    this.isCallEvent = false,
    this.callType,
    this.callStatus,
    this.callDuration,
    this.isForwarded = false,
    this.mentions = const [],
    this.mentionedUserIds = const [],
  });

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? text,
    String? timestamp,
    bool? isMe,
    bool? isRead,
    MessageStatus? status,
    bool? isEdited,
    bool? isDeleted,
    List<Map<String, dynamic>>? reactions,
    bool? isSaved,
    String? replyToMessageId,
    String? replyToText,
    bool? replyToIsMe,
    String? replyToSenderName,
    String? replyToMediaType,
    String? replyToThumbnailUrl,
    bool? isVoiceNote,
    bool? isAudioFile,
    String? audioUrl,
    String? audioName,
    bool? isImage,
    List<String>? imageUrls,
    bool? isDocument,
    String? documentUrl,
    String? documentName,
    bool? isVideo,
    String? videoUrl,
    String? videoThumbnail,
    String? senderName,
    String? senderAvatar,
    bool? isCallEvent,
    String? callType,
    String? callStatus,
    int? callDuration,
    bool? isForwarded,
    List<Map<String, dynamic>>? mentions,
    List<String>? mentionedUserIds,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      isSaved: isSaved ?? this.isSaved,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      replyToIsMe: replyToIsMe ?? this.replyToIsMe,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      replyToMediaType: replyToMediaType ?? this.replyToMediaType,
      replyToThumbnailUrl: replyToThumbnailUrl ?? this.replyToThumbnailUrl,
      isVoiceNote: isVoiceNote ?? this.isVoiceNote,
      isAudioFile: isAudioFile ?? this.isAudioFile,
      audioUrl: audioUrl ?? this.audioUrl,
      audioName: audioName ?? this.audioName,
      isImage: isImage ?? this.isImage,
      imageUrls: imageUrls ?? this.imageUrls,
      isDocument: isDocument ?? this.isDocument,
      documentUrl: documentUrl ?? this.documentUrl,
      documentName: documentName ?? this.documentName,
      isVideo: isVideo ?? this.isVideo,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnail: videoThumbnail ?? this.videoThumbnail,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      isCallEvent: isCallEvent ?? this.isCallEvent,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      callDuration: callDuration ?? this.callDuration,
      isForwarded: isForwarded ?? this.isForwarded,
      mentions: mentions ?? this.mentions,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
    );
  }

  // ✅ Convert to Hive for caching
  ChatMessageHive toHive() {
    return ChatMessageHive(
      id: id,
      chatId: chatId,
      text: text,
      isMe: isMe,
      isRead: isRead,
      timestamp: timestamp,
      isEdited: isEdited,
      isDeleted: isDeleted,
      isVoiceNote: isVoiceNote,
      isAudioFile: isAudioFile,
      audioUrl: audioUrl,
      audioName: audioName,
      isImage: isImage,
      imageUrls: imageUrls,
      isDocument: isDocument,
      documentUrl: documentUrl,
      documentName: documentName,
      isVideo: isVideo,
      videoUrl: videoUrl,
      videoThumbnail: videoThumbnail,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToIsMe: replyToIsMe,
      // ✅ FIX: Persist reply preview fields so they survive reload
      replyToSenderName: replyToSenderName,
      replyToMediaType: replyToMediaType,
      replyToThumbnailUrl: replyToThumbnailUrl,
      senderName: senderName,
      senderAvatar: senderAvatar,
      isCallEvent: isCallEvent,
      callType: callType,
      callStatus: callStatus,
      callDuration: callDuration,
      isForwarded: isForwarded,
      mentionedUserIds: mentionedUserIds,
      status: status.name,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myUserId) {
    // ── Sender ──
    final sender = json['sender'];
    final String senderId = sender is Map
        ? sender['_id']?.toString() ?? ''
        : sender?.toString() ?? '';

    final isMe = senderId == myUserId;

    final String? senderName = (!isMe && sender is Map)
        ? sender['username']?.toString()
        : null;
    final String? senderAvatar = (!isMe && sender is Map)
        ? sender['profilePicture']?.toString()
        : null;

    // ── Read status ──
    final List<String> readBy =
        (json['readBy'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final List<String> readByOthers = readBy
        .where((id) => id != myUserId)
        .toList();
    final List<String> deliveredTo =
        ((json['deliveredTo'] ?? json['deliveredBy']) as List?)
            ?.map((e) {
              if (e is Map) return (e['_id'] ?? e['id'] ?? '').toString();
              return e.toString();
            })
            .where((id) => id.isNotEmpty)
            .toList() ??
        [];
    final serverStatus = json['status']?.toString().toLowerCase();
    final isRead = isMe
        ? readByOthers
              .isNotEmpty // only true if someone else actually read it
        : readBy.contains(myUserId);

    // ── Attachments ──
    final attachments = (json['attachments'] as List?) ?? [];

    Map<String, dynamic>? voiceAttachment;
    Map<String, dynamic>? audioFileAttachment;
    Map<String, dynamic>? documentAttachment;
    Map<String, dynamic>? videoAttachment;
    final List<String> imageUrls = [];

    // Also check top-level contentType for messages sent via our app
    final topLevelContentType = json['contentType']?.toString() ?? '';

    for (final a in attachments) {
      final fileType = a['fileType']?.toString() ?? '';
      final url = a['url']?.toString() ?? '';
      final mimeType = a['mimeType']?.toString() ?? '';

      // Detect by fileType, mimeType, or URL pattern
      if (fileType == 'voice_note') {
        voiceAttachment = a;
      } else if (fileType == 'audio' || mimeType.startsWith('audio/')) {
        audioFileAttachment = a;
      } else if (fileType == 'document' ||
          mimeType.startsWith('application/')) {
        documentAttachment = a;
      } else if (fileType == 'video' || mimeType.startsWith('video/')) {
        videoAttachment = a;
      } else if (fileType == 'image' || mimeType.startsWith('image/')) {
        if (url.isNotEmpty) imageUrls.add(url);
      } else if (url.isNotEmpty) {
        // Fallback: detect from top-level contentType
        if (topLevelContentType == 'image') {
          imageUrls.add(url);
        } else if (topLevelContentType == 'video') {
          videoAttachment = a;
        } else if (topLevelContentType == 'audio') {
          audioFileAttachment = a;
        } else if (topLevelContentType == 'document') {
          documentAttachment = a;
        }
      }
    }

    // If attachments were empty but contentType tells us what it is,
    // try to build from attachmentUrls field directly
    if (attachments.isEmpty && topLevelContentType.isNotEmpty) {
      final attachmentUrls =
          (json['attachmentUrls'] as List?)
              ?.map((u) => u.toString())
              .where((u) => u.isNotEmpty)
              .toList() ??
          [];
      for (final url in attachmentUrls) {
        if (topLevelContentType == 'image') imageUrls.add(url);
      }
    }

    // ── Chat ID ──
    final String chatId = json['chat'] is String
        ? json['chat']
        : json['chat']?['_id']?.toString() ?? json['chatId'] ?? '';

    final replyTo = json['replyTo'];
    String? replyMediaType;
    String? replyThumbnail;
    if (replyTo is Map<String, dynamic>) {
      final replyAttachments = (replyTo['attachments'] as List?) ?? const [];
      if (replyAttachments.isNotEmpty) {
        final first = replyAttachments.first as Map<String, dynamic>;
        final fileType = (first['fileType'] ?? '').toString();
        replyMediaType = fileType;
        if (fileType == 'image') {
          replyThumbnail = first['url']?.toString();
        } else if (fileType == 'video') {
          replyThumbnail =
              first['thumbnailUrl']?.toString() ?? first['url']?.toString();
        }
      }
    }

    return ChatMessage(
      id: json['_id'].toString(),
      chatId: chatId,
      text: json['content'] ?? '',
      isMe: isMe,
      isRead: isRead,
      timestamp: json['createdAt'],
      isEdited: json['isEdited'] ?? false,
      reactions: List<Map<String, dynamic>>.from(json['reactions'] ?? []),

      // ── Reply ──
      replyToMessageId: replyTo is Map<String, dynamic>
          ? replyTo['_id']?.toString()
          : (replyTo is String && replyTo.isNotEmpty ? replyTo : null),
      replyToText: replyTo is Map<String, dynamic>
          ? (replyTo['content']?.toString() ??
                ((replyTo['attachments'] as List?)?.isNotEmpty == true
                    ? _getAttachmentPreview(replyTo['attachments'])
                    : null))
          : null,
      replyToIsMe: replyTo is Map<String, dynamic>
          ? ((replyTo['sender'] as Map?)?['_id']?.toString() ??
                    replyTo['sender']?.toString()) ==
                myUserId
          : null,
      replyToSenderName: replyTo is Map<String, dynamic>
          ? ((replyTo['sender'] as Map?)?['username']?.toString())
          : null,
      replyToMediaType: replyMediaType,
      replyToThumbnailUrl: replyThumbnail,

      // ── Voice / Audio ──
      isVoiceNote: voiceAttachment != null,
      isAudioFile: audioFileAttachment != null && voiceAttachment == null,
      audioUrl: voiceAttachment?['url'] ?? audioFileAttachment?['url'],
      audioName: audioFileAttachment?['filename'],

      // ── Images ──
      isImage: imageUrls.isNotEmpty,
      imageUrls: imageUrls.isNotEmpty ? imageUrls : null,

      // ── Document ──
      isDocument: documentAttachment != null,
      documentUrl: documentAttachment?['url'],
      documentName: documentAttachment?['filename'],

      // ── Video ──
      isVideo: videoAttachment != null,
      videoUrl: videoAttachment?['url'],
      videoThumbnail: videoAttachment?['thumbnailUrl'],

      // ── Sender info ──
      senderName: senderName,
      senderAvatar: senderAvatar,

      // ── Call event ──
      isCallEvent: json['contentType'] == 'call',
      callType: json['callType']?.toString(),
      callStatus: json['callStatus']?.toString(),
      callDuration: json['callDuration'] is int
          ? json['callDuration']
          : int.tryParse(json['callDuration']?.toString() ?? ''),

      // ── Forwarded ──
      isForwarded:
          json['isForwarded'] == true ||
          (json['forwardCount'] != null &&
              (json['forwardCount'] is int
                      ? json['forwardCount'] as int
                      : int.tryParse(json['forwardCount']?.toString() ?? '0') ??
                            0) >
                  0) ||
          json['isForwarded'] == 'true',

      // ── Mentions ──
      mentions: (json['mentions'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList(),
      mentionedUserIds: (json['mentions'] as List? ?? [])
          .map((m) {
            if (m is Map<String, dynamic>) return m['_id']?.toString() ?? '';
            if (m is String) return m;
            return '';
          })
          .where((id) => id.isNotEmpty)
          .toList(),

      // Status derivation from server data:
      //   read/readByOthers          → MessageStatus.read       (2 blue ticks)
      //   deliveredTo/status field   → MessageStatus.delivered  (2 gray ticks)
      //   otherwise                  → MessageStatus.sent       (1 gray tick)
      status: isRead || serverStatus == 'read'
          ? MessageStatus.read
          : (serverStatus == 'delivered' || deliveredTo.isNotEmpty
                ? MessageStatus.delivered
                : MessageStatus.sent),
    );
  }

  static String _getAttachmentPreview(List<dynamic>? attachments) {
    if (attachments == null || attachments.isEmpty) return '';
    final attachment = attachments.first;
    final fileType = attachment['fileType'] ?? 'file';
    switch (fileType) {
      case 'image':
        return '🖼️ Image';
      case 'video':
        return '🎥 Video';
      case 'audio':
        return '🎵 Audio';
      case 'voice_note':
        return '🎤 Voice Note';
      case 'document':
        return '📄 ${attachment['filename'] ?? 'Document'}';
      default:
        return '📎 Attachment';
    }
  }
}
