// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MusicSearchResponseImpl _$$MusicSearchResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$MusicSearchResponseImpl(
      success: json['success'] as bool,
      count: (json['count'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => MusicData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MusicSearchResponseImplToJson(
        _$MusicSearchResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

_$MusicDataImpl _$$MusicDataImplFromJson(Map<String, dynamic> json) =>
    _$MusicDataImpl(
      thirdPartyId: json['thirdPartyId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      coverImage: json['coverImage'] as String?,
      audioUrl: json['audioUrl'] as String,
    );

Map<String, dynamic> _$$MusicDataImplToJson(_$MusicDataImpl instance) {
  final val = <String, dynamic>{
    'thirdPartyId': instance.thirdPartyId,
    'title': instance.title,
    'artist': instance.artist,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('coverImage', instance.coverImage);
  val['audioUrl'] = instance.audioUrl;
  return val;
}
