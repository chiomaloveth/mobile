// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_preference_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatePreferenceDtoImpl _$$CreatePreferenceDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CreatePreferenceDtoImpl(
      entertainment: (json['entertainment'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      homeFamily: (json['homeFamily'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      fashionBeauty: (json['fashionBeauty'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$CreatePreferenceDtoImplToJson(
        _$CreatePreferenceDtoImpl instance) =>
    <String, dynamic>{
      'entertainment': instance.entertainment,
      'homeFamily': instance.homeFamily,
      'fashionBeauty': instance.fashionBeauty,
    };
