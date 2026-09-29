import 'package:freezed_annotation/freezed_annotation.dart';

part 'block_user_dto.freezed.dart';
part 'block_user_dto.g.dart';

@freezed
class BlockUserDto with _$BlockUserDto {
  @JsonSerializable(includeIfNull: false)
  const factory BlockUserDto({
    required String userIdToBlock,
  }) = _BlockUserDto;

  factory BlockUserDto.fromJson(Map<String, dynamic> json) =>
      _$BlockUserDtoFromJson(json);
}
