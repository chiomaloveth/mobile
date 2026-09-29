import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_preference_list.freezed.dart';
part 'get_preference_list.g.dart';

@freezed
class GetPreferenceList with _$GetPreferenceList {
  const factory GetPreferenceList({
    required bool success,
    CategoriesData? data,
  }) = _GetPreferenceList;

  factory GetPreferenceList.fromJson(Map<String, dynamic> json) =>
      _$GetPreferenceListFromJson(json);
}

@freezed
class CategoriesData with _$CategoriesData {
  const factory CategoriesData({
    List<String>? entertainment,
    List<String>? homeFamily,
    List<String>? fashionBeauty,
    @Default(false) bool? isPreferenceSet,
  }) = _CategoriesData;

  factory CategoriesData.fromJson(Map<String, dynamic> json) =>
      _$CategoriesDataFromJson(json);
}
