// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageHiveAdapter extends TypeAdapter<ChatMessageHive> {
  @override
  final int typeId = 1;

  @override
  ChatMessageHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageHive(
      id: fields[0] as String,
      text: fields[1] as String,
      chatId: fields[2] as String,
      audioUrl: fields[3] as String?,
      isMe: fields[4] as bool,
      isRead: fields[5] as bool,
      timestamp: fields[6] as String,
      isImage: fields[7] as bool,
      imageUrls: (fields[8] as List?)?.cast<String>(),
      isVideo: fields[9] as bool,
      videoUrl: fields[10] as String?,
      isDocument: fields[11] as bool,
      documentUrl: fields[12] as String?,
      documentName: fields[13] as String?,
      isVoiceNote: fields[14] as bool,
      isAudioFile: fields[15] as bool,
      audioName: fields[16] as String?,
      videoThumbnail: fields[17] as String?,
      isEdited: fields[18] as bool,
      isDeleted: fields[19] as bool,
      replyToMessageId: fields[20] as String?,
      replyToText: fields[21] as String?,
      replyToIsMe: fields[22] as bool?,
      senderName: fields[23] as String?,
      senderAvatar: fields[24] as String?,
      isCallEvent: fields[25] as bool,
      callType: fields[26] as String?,
      callStatus: fields[27] as String?,
      callDuration: (fields[28] as num?)?.toInt(),
      isForwarded: fields[29] as bool,
      mentionedUserIds: (fields[30] as List).cast<String>(),
      replyToSenderName: fields[31] as String?,
      replyToMediaType: fields[32] as String?,
      replyToThumbnailUrl: fields[33] as String?,
      status: fields[34] as String? ?? 'sent',
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageHive obj) {
    writer
      ..writeByte(35)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.chatId)
      ..writeByte(3)
      ..write(obj.audioUrl)
      ..writeByte(4)
      ..write(obj.isMe)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.isImage)
      ..writeByte(8)
      ..write(obj.imageUrls)
      ..writeByte(9)
      ..write(obj.isVideo)
      ..writeByte(10)
      ..write(obj.videoUrl)
      ..writeByte(11)
      ..write(obj.isDocument)
      ..writeByte(12)
      ..write(obj.documentUrl)
      ..writeByte(13)
      ..write(obj.documentName)
      ..writeByte(14)
      ..write(obj.isVoiceNote)
      ..writeByte(15)
      ..write(obj.isAudioFile)
      ..writeByte(16)
      ..write(obj.audioName)
      ..writeByte(17)
      ..write(obj.videoThumbnail)
      ..writeByte(18)
      ..write(obj.isEdited)
      ..writeByte(19)
      ..write(obj.isDeleted)
      ..writeByte(20)
      ..write(obj.replyToMessageId)
      ..writeByte(21)
      ..write(obj.replyToText)
      ..writeByte(22)
      ..write(obj.replyToIsMe)
      ..writeByte(23)
      ..write(obj.senderName)
      ..writeByte(24)
      ..write(obj.senderAvatar)
      ..writeByte(25)
      ..write(obj.isCallEvent)
      ..writeByte(26)
      ..write(obj.callType)
      ..writeByte(27)
      ..write(obj.callStatus)
      ..writeByte(28)
      ..write(obj.callDuration)
      ..writeByte(29)
      ..write(obj.isForwarded)
      ..writeByte(30)
      ..write(obj.mentionedUserIds)
      ..writeByte(31)
      ..write(obj.replyToSenderName)
      ..writeByte(32)
      ..write(obj.replyToMediaType)
      ..writeByte(33)
      ..write(obj.replyToThumbnailUrl)
      ..writeByte(34)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
