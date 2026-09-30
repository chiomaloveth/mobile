// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_item_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

// Sentinel used by copyWith to distinguish "not passed" from explicit null.
const Object _sentinel = Object();

class ChatListItemHiveAdapter extends TypeAdapter<ChatListItemHive> {
  @override
  final int typeId = 0;

  @override
  ChatListItemHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatListItemHive(
      id: fields[0] as String,
      isGroupChat: fields[1] as bool,
      title: fields[2] as String,
      lastMessageJson: fields[3] as String,
      updatedAt: fields[4] as DateTime,
      profilePicture: fields[5] as String,
      about: fields[6] as String,
      userId: fields[7] as String,
      isArchived: fields[8] as bool,
      isMuted: fields[9] as bool,
      muteUntil: fields[10] as DateTime?,
      wallpaperPath: fields[11] as String?,
      memberCount: (fields[12] as num).toInt(),
      isBroadcast: fields[13] as bool,
      isCommunity: fields[14] as bool,
      isPinned: fields[15] as bool,
      pinnedAt: fields[16] as DateTime?,
      membersAvatarUrls: (fields[17] as List).cast<String>(),
      memberUserIds: (fields[18] as List).cast<String>(),
      isBlocked: fields[19] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatListItemHive obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isGroupChat)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.lastMessageJson)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.profilePicture)
      ..writeByte(6)
      ..write(obj.about)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.isArchived)
      ..writeByte(9)
      ..write(obj.isMuted)
      ..writeByte(10)
      ..write(obj.muteUntil)
      ..writeByte(11)
      ..write(obj.wallpaperPath)
      ..writeByte(12)
      ..write(obj.memberCount)
      ..writeByte(13)
      ..write(obj.isBroadcast)
      ..writeByte(14)
      ..write(obj.isCommunity)
      ..writeByte(15)
      ..write(obj.isPinned)
      ..writeByte(16)
      ..write(obj.pinnedAt)
      ..writeByte(17)
      ..write(obj.membersAvatarUrls)
      ..writeByte(18)
      ..write(obj.memberUserIds)
      ..writeByte(19)
      ..write(obj.isBlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatListItemHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
