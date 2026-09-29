import 'package:freezed_annotation/freezed_annotation.dart';

part 'unblock_user_dto.freezed.dart';
part 'unblock_user_dto.g.dart';

@freezed
class UnblockUserDto with _$UnblockUserDto {
  @JsonSerializable(includeIfNull: false)
  const factory UnblockUserDto({
    required String userIdToUnblock,
  }) = _UnblockUserDto;

  factory UnblockUserDto.fromJson(Map<String, dynamic> json) =>
      _$UnblockUserDtoFromJson(json);
}
