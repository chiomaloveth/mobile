// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_message_queue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueuedMessageAdapter extends TypeAdapter<QueuedMessage> {
  @override
  final int typeId = 3;

  @override
  QueuedMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedMessage(
      tempId: fields[0] as String,
      chatId: fields[1] as String,
      content: fields[2] as String,
      replyToId: fields[3] as String?,
      queuedAt: fields[4] as DateTime,
      type: fields[5] as String,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
      retryCount: (fields[7] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QueuedMessage obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.tempId)
      ..writeByte(1)
      ..write(obj.chatId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.replyToId)
      ..writeByte(4)
      ..write(obj.queuedAt)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.metadata)
      ..writeByte(7)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
