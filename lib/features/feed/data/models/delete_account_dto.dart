import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_account_dto.freezed.dart';
part 'delete_account_dto.g.dart';

@freezed
class DeleteAccountDto with _$DeleteAccountDto {
  @JsonSerializable(includeIfNull: false)
  const factory DeleteAccountDto({
    @Default('DELETE') String confirmation,
  }) = _DeleteAccountDto;

  factory DeleteAccountDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountDtoFromJson(json);
}
