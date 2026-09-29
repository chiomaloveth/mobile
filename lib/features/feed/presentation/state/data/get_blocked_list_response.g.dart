// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_blocked_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetBlockedListResponseImpl _$$GetBlockedListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GetBlockedListResponseImpl(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => BlockedUserData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GetBlockedListResponseImplToJson(
        _$GetBlockedListResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

_$BlockedUserDataImpl _$$BlockedUserDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BlockedUserDataImpl(
      id: json['_id'] as String,
      phone: json['phone'] as String? ?? '',
      profilePicture: json['profilePicture'] as String? ?? '',
      username: json['username'] as String?,
    );

Map<String, dynamic> _$$BlockedUserDataImplToJson(
    _$BlockedUserDataImpl instance) {
  final val = <String, dynamic>{
    '_id': instance.id,
    'phone': instance.phone,
    'profilePicture': instance.profilePicture,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('username', instance.username);
  return val;
}
