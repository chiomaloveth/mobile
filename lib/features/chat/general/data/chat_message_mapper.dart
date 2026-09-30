import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';

extension ChatMessageToHive on ChatMessage {
  ChatMessageHive toHive() {
    return ChatMessageHive(
      id: id,
      text: text,
      chatId: chatId,
      audioUrl: audioUrl,
      isMe: isMe,
      isRead: isRead,
      timestamp: timestamp,
      isImage: isImage,
      imageUrls: imageUrls,
      isVideo: isVideo,
      videoUrl: videoUrl,
      isDocument: isDocument,
      documentUrl: documentUrl,
      documentName: documentName,
      isVoiceNote: isVoiceNote,
      isAudioFile: isAudioFile,
      audioName: audioName,
      videoThumbnail: videoThumbnail,
      isEdited: isEdited,
      isDeleted: isDeleted,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToIsMe: replyToIsMe,
      replyToSenderName: replyToSenderName,
      replyToMediaType: replyToMediaType,
      replyToThumbnailUrl: replyToThumbnailUrl,
      // ✅ FIX: persist sender info so group chat names survive reload
      senderName: senderName,
      senderAvatar: senderAvatar,
      isCallEvent: isCallEvent,
      callType: callType,
      callStatus: callStatus,
      callDuration: callDuration,
      isForwarded: isForwarded,
      mentionedUserIds: mentionedUserIds,
    );
  }
}

extension ChatMessageHiveToChat on ChatMessageHive {
  ChatMessage toChat() {
    return ChatMessage(
      id: id,
      text: text,
      chatId: chatId,
      audioUrl: audioUrl,
      isMe: isMe,
      isRead: isRead,
      timestamp: timestamp,
      status: MessageStatus.sent,
      isImage: isImage,
      imageUrls: imageUrls,
      isVideo: isVideo,
      videoUrl: videoUrl,
      isDocument: isDocument,
      documentUrl: documentUrl,
      documentName: documentName,
      isVoiceNote: isVoiceNote,
      isAudioFile: isAudioFile,
      audioName: audioName,
      videoThumbnail: videoThumbnail,
      isEdited: isEdited,
      isDeleted: isDeleted,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToIsMe: replyToIsMe,
      // ✅ FIX: Restore reply preview fields from Hive
      replyToSenderName: replyToSenderName,
      replyToMediaType: replyToMediaType,
      replyToThumbnailUrl: replyToThumbnailUrl,
      isCallEvent: isCallEvent,
      callType: callType,
      callStatus: callStatus,
      callDuration: callDuration,
      isForwarded: isForwarded,
      mentionedUserIds: mentionedUserIds,
    );
  }
}
