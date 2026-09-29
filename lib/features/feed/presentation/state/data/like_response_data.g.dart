// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LikeResponseDataImpl _$$LikeResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$LikeResponseDataImpl(
      liked: json['liked'] as bool?,
    );

Map<String, dynamic> _$$LikeResponseDataImplToJson(
    _$LikeResponseDataImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('liked', instance.liked);
  return val;
}
