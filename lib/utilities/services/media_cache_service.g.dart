// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_cache_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaCacheEntryAdapter extends TypeAdapter<MediaCacheEntry> {
  @override
  final int typeId = 4;

  @override
  MediaCacheEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaCacheEntry(
      url: fields[0] as String,
      localPath: fields[1] as String,
      thumbnailPath: fields[2] as String?,
      cachedAt: fields[3] as DateTime,
      fileSize: (fields[4] as num).toInt(),
      mediaType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MediaCacheEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.localPath)
      ..writeByte(2)
      ..write(obj.thumbnailPath)
      ..writeByte(3)
      ..write(obj.cachedAt)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.mediaType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaCacheEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
