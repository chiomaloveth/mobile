import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_preference_dto.freezed.dart';
part 'create_preference_dto.g.dart';

@freezed
class CreatePreferenceDto with _$CreatePreferenceDto {
  const factory CreatePreferenceDto({
    required List<String> entertainment,
    required List<String> homeFamily,
    required List<String> fashionBeauty,
  }) = _CreatePreferenceDto;

  factory CreatePreferenceDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePreferenceDtoFromJson(json);
}
