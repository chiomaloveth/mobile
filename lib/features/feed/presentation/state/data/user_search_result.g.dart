// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSearchResultImpl _$$UserSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSearchResultImpl(
      id: json['_id'] as String,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String? ?? '',
      fullName: json['fullName'] as String?,
    );

Map<String, dynamic> _$$UserSearchResultImplToJson(
    _$UserSearchResultImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'username': instance.username,
    'profilePicture': instance.profilePicture,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('fullName', instance.fullName);
  return val;
}
