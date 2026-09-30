import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';

part 'chat_message_hive.g.dart';

@HiveType(typeId: 1)
class ChatMessageHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String chatId;

  @HiveField(3)
  final String? audioUrl;

  @HiveField(4)
  final bool isMe;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final String timestamp;

  @HiveField(7)
  final bool isImage;

  @HiveField(8)
  final List<String>? imageUrls;

  @HiveField(9)
  final bool isVideo;

  @HiveField(10)
  final String? videoUrl;

  @HiveField(11)
  final bool isDocument;

  @HiveField(12)
  final String? documentUrl;

  @HiveField(13)
  final String? documentName;

  @HiveField(14)
  final bool isVoiceNote;

  @HiveField(15)
  final bool isAudioFile;

  @HiveField(16)
  final String? audioName;

  @HiveField(17)
  final String? videoThumbnail;

  @HiveField(18)
  final bool isEdited;

  @HiveField(19)
  final bool isDeleted;

  @HiveField(20)
  final String? replyToMessageId;

  @HiveField(21)
  final String? replyToText;

  @HiveField(22)
  final bool? replyToIsMe;

  @HiveField(23)
  final String? senderName;

  @HiveField(24)
  final String? senderAvatar;

  @HiveField(25)
  final bool isCallEvent;

  @HiveField(26)
  final String? callType;

  @HiveField(27)
  final String? callStatus;

  @HiveField(28)
  final int? callDuration;

  // ✅ Forwarded message flag
  @HiveField(29)
  final bool isForwarded;

  // ✅ Mentions (store IDs only for persistence)
  @HiveField(30)
  final List<String> mentionedUserIds;

  // ✅ Reply preview persistence — these were missing, causing blank reply previews after reload
  @HiveField(31)
  final String? replyToSenderName;

  @HiveField(32)
  final String? replyToMediaType;

  @HiveField(33)
  final String? replyToThumbnailUrl;

  @HiveField(34)
  final String status;

  ChatMessageHive({
    required this.id,
    required this.text,
    required this.chatId,
    this.audioUrl,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
    this.isImage = false,
    this.imageUrls,
    this.isVideo = false,
    this.videoUrl,
    this.isDocument = false,
    this.documentUrl,
    this.documentName,
    this.isVoiceNote = false,
    this.isAudioFile = false,
    this.audioName,
    this.videoThumbnail,
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToMessageId,
    this.replyToText,
    this.replyToIsMe,
    this.senderName,
    this.senderAvatar,
    this.isCallEvent = false,
    this.callType,
    this.callStatus,
    this.callDuration,
    this.isForwarded = false,
    this.mentionedUserIds = const [],
    this.replyToSenderName,
    this.replyToMediaType,
    this.replyToThumbnailUrl,
    this.status = 'sent',
  });

  ChatMessage toChat() {
    return ChatMessage(
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
      status: MessageStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => isRead ? MessageStatus.read : MessageStatus.sent,
      ),
    );
  }
}
