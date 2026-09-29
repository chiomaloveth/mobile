// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_preference_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetPreferenceListImpl _$$GetPreferenceListImplFromJson(
        Map<String, dynamic> json) =>
    _$GetPreferenceListImpl(
      success: json['success'] as bool,
      data: json['data'] == null
          ? null
          : CategoriesData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GetPreferenceListImplToJson(
    _$GetPreferenceListImpl instance) {
  final val = <String, dynamic>{
    'success': instance.success,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', instance.data?.toJson());
  return val;
}

_$CategoriesDataImpl _$$CategoriesDataImplFromJson(Map<String, dynamic> json) =>
    _$CategoriesDataImpl(
      entertainment: (json['entertainment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      homeFamily: (json['homeFamily'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      fashionBeauty: (json['fashionBeauty'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isPreferenceSet: json['isPreferenceSet'] as bool? ?? false,
    );

Map<String, dynamic> _$$CategoriesDataImplToJson(
    _$CategoriesDataImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('entertainment', instance.entertainment);
  writeNotNull('homeFamily', instance.homeFamily);
  writeNotNull('fashionBeauty', instance.fashionBeauty);
  writeNotNull('isPreferenceSet', instance.isPreferenceSet);
  return val;
}
