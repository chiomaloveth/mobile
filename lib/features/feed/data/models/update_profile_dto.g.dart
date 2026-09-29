// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateProfileDtoImpl _$$UpdateProfileDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateProfileDtoImpl(
      fullName: json['fullName'] as String?,
      username: json['username'] as String?,
      dob: json['dob'] as String?,
      about: json['about'] as String?,
      phone: (json['phone'] as num?)?.toInt(),
      hidePhone: json['hidePhone'] as bool?,
      instagram: json['instagram'] as String?,
      youtube: json['youtube'] as String?,
      profilePicture: json['profilePicture'] as String?,
      link: json['link'] as String?,
    );

Map<String, dynamic> _$$UpdateProfileDtoImplToJson(
    _$UpdateProfileDtoImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('fullName', instance.fullName);
  writeNotNull('username', instance.username);
  writeNotNull('dob', instance.dob);
  writeNotNull('about', instance.about);
  writeNotNull('phone', instance.phone);
  writeNotNull('hidePhone', instance.hidePhone);
  writeNotNull('instagram', instance.instagram);
  writeNotNull('youtube', instance.youtube);
  writeNotNull('profilePicture', instance.profilePicture);
  writeNotNull('link', instance.link);
  return val;
}
