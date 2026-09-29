import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_profile_dto.freezed.dart';
part 'update_profile_dto.g.dart';

@freezed
class UpdateProfileDto with _$UpdateProfileDto {
  const factory UpdateProfileDto({
     String? fullName,
      String? username,
       String? dob,
        String? about,
       int? phone,
         bool? hidePhone,
        String? instagram,
        String? youtube,
        String? profilePicture,
        String? link,
        


  }) = _UpdateProfileDto;

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) => _$UpdateProfileDtoFromJson(json);
}