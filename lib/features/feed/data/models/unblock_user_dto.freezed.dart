// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unblock_user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UnblockUserDto _$UnblockUserDtoFromJson(Map<String, dynamic> json) {
  return _UnblockUserDto.fromJson(json);
}

/// @nodoc
mixin _$UnblockUserDto {
  String get userIdToUnblock => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UnblockUserDtoCopyWith<UnblockUserDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnblockUserDtoCopyWith<$Res> {
  factory $UnblockUserDtoCopyWith(
          UnblockUserDto value, $Res Function(UnblockUserDto) then) =
      _$UnblockUserDtoCopyWithImpl<$Res, UnblockUserDto>;
  @useResult
  $Res call({String userIdToUnblock});
}

/// @nodoc
class _$UnblockUserDtoCopyWithImpl<$Res, $Val extends UnblockUserDto>
    implements $UnblockUserDtoCopyWith<$Res> {
  _$UnblockUserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIdToUnblock = null,
  }) {
    return _then(_value.copyWith(
      userIdToUnblock: null == userIdToUnblock
          ? _value.userIdToUnblock
          : userIdToUnblock // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnblockUserDtoImplCopyWith<$Res>
    implements $UnblockUserDtoCopyWith<$Res> {
  factory _$$UnblockUserDtoImplCopyWith(_$UnblockUserDtoImpl value,
          $Res Function(_$UnblockUserDtoImpl) then) =
      __$$UnblockUserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userIdToUnblock});
}

/// @nodoc
class __$$UnblockUserDtoImplCopyWithImpl<$Res>
    extends _$UnblockUserDtoCopyWithImpl<$Res, _$UnblockUserDtoImpl>
    implements _$$UnblockUserDtoImplCopyWith<$Res> {
  __$$UnblockUserDtoImplCopyWithImpl(
      _$UnblockUserDtoImpl _value, $Res Function(_$UnblockUserDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIdToUnblock = null,
  }) {
    return _then(_$UnblockUserDtoImpl(
      userIdToUnblock: null == userIdToUnblock
          ? _value.userIdToUnblock
          : userIdToUnblock // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$UnblockUserDtoImpl implements _UnblockUserDto {
  const _$UnblockUserDtoImpl({required this.userIdToUnblock});

  factory _$UnblockUserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnblockUserDtoImplFromJson(json);

  @override
  final String userIdToUnblock;

  @override
  String toString() {
    return 'UnblockUserDto(userIdToUnblock: $userIdToUnblock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnblockUserDtoImpl &&
            (identical(other.userIdToUnblock, userIdToUnblock) ||
                other.userIdToUnblock == userIdToUnblock));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userIdToUnblock);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnblockUserDtoImplCopyWith<_$UnblockUserDtoImpl> get copyWith =>
      __$$UnblockUserDtoImplCopyWithImpl<_$UnblockUserDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnblockUserDtoImplToJson(
      this,
    );
  }
}

abstract class _UnblockUserDto implements UnblockUserDto {
  const factory _UnblockUserDto({required final String userIdToUnblock}) =
      _$UnblockUserDtoImpl;

  factory _UnblockUserDto.fromJson(Map<String, dynamic> json) =
      _$UnblockUserDtoImpl.fromJson;

  @override
  String get userIdToUnblock;
  @override
  @JsonKey(ignore: true)
  _$$UnblockUserDtoImplCopyWith<_$UnblockUserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
