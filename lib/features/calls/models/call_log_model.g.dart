// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallLogAdapter extends TypeAdapter<CallLog> {
  @override
  final int typeId = 5;

  @override
  CallLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallLog(
      id: fields[0] as String,
      callerId: fields[1] as String,
      callerName: fields[2] as String,
      callerPhoto: fields[3] as String,
      callType: fields[4] as CallType,
      callStatus: fields[5] as CallStatus,
      timestamp: fields[6] as DateTime,
      duration: (fields[7] as num).toInt(),
      isGroupCall: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CallLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.callerId)
      ..writeByte(2)
      ..write(obj.callerName)
      ..writeByte(3)
      ..write(obj.callerPhoto)
      ..writeByte(4)
      ..write(obj.callType)
      ..writeByte(5)
      ..write(obj.callStatus)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.isGroupCall);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CallTypeAdapter extends TypeAdapter<CallType> {
  @override
  final int typeId = 6;

  @override
  CallType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CallType.audio;
      case 1:
        return CallType.video;
      default:
        return CallType.audio;
    }
  }

  @override
  void write(BinaryWriter writer, CallType obj) {
    switch (obj) {
      case CallType.audio:
        writer.writeByte(0);
        break;
      case CallType.video:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CallStatusAdapter extends TypeAdapter<CallStatus> {
  @override
  final int typeId = 7;

  @override
  CallStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CallStatus.missed;
      case 1:
        return CallStatus.incoming;
      case 2:
        return CallStatus.outgoing;
      default:
        return CallStatus.missed;
    }
  }

  @override
  void write(BinaryWriter writer, CallStatus obj) {
    switch (obj) {
      case CallStatus.missed:
        writer.writeByte(0);
        break;
      case CallStatus.incoming:
        writer.writeByte(1);
        break;
      case CallStatus.outgoing:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
