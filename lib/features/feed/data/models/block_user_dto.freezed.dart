// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block_user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BlockUserDto _$BlockUserDtoFromJson(Map<String, dynamic> json) {
  return _BlockUserDto.fromJson(json);
}

/// @nodoc
mixin _$BlockUserDto {
  String get userIdToBlock => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BlockUserDtoCopyWith<BlockUserDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockUserDtoCopyWith<$Res> {
  factory $BlockUserDtoCopyWith(
          BlockUserDto value, $Res Function(BlockUserDto) then) =
      _$BlockUserDtoCopyWithImpl<$Res, BlockUserDto>;
  @useResult
  $Res call({String userIdToBlock});
}

/// @nodoc
class _$BlockUserDtoCopyWithImpl<$Res, $Val extends BlockUserDto>
    implements $BlockUserDtoCopyWith<$Res> {
  _$BlockUserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIdToBlock = null,
  }) {
    return _then(_value.copyWith(
      userIdToBlock: null == userIdToBlock
          ? _value.userIdToBlock
          : userIdToBlock // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlockUserDtoImplCopyWith<$Res>
    implements $BlockUserDtoCopyWith<$Res> {
  factory _$$BlockUserDtoImplCopyWith(
          _$BlockUserDtoImpl value, $Res Function(_$BlockUserDtoImpl) then) =
      __$$BlockUserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userIdToBlock});
}

/// @nodoc
class __$$BlockUserDtoImplCopyWithImpl<$Res>
    extends _$BlockUserDtoCopyWithImpl<$Res, _$BlockUserDtoImpl>
    implements _$$BlockUserDtoImplCopyWith<$Res> {
  __$$BlockUserDtoImplCopyWithImpl(
      _$BlockUserDtoImpl _value, $Res Function(_$BlockUserDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIdToBlock = null,
  }) {
    return _then(_$BlockUserDtoImpl(
      userIdToBlock: null == userIdToBlock
          ? _value.userIdToBlock
          : userIdToBlock // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$BlockUserDtoImpl implements _BlockUserDto {
  const _$BlockUserDtoImpl({required this.userIdToBlock});

  factory _$BlockUserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockUserDtoImplFromJson(json);

  @override
  final String userIdToBlock;

  @override
  String toString() {
    return 'BlockUserDto(userIdToBlock: $userIdToBlock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockUserDtoImpl &&
            (identical(other.userIdToBlock, userIdToBlock) ||
                other.userIdToBlock == userIdToBlock));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userIdToBlock);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockUserDtoImplCopyWith<_$BlockUserDtoImpl> get copyWith =>
      __$$BlockUserDtoImplCopyWithImpl<_$BlockUserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockUserDtoImplToJson(
      this,
    );
  }
}

abstract class _BlockUserDto implements BlockUserDto {
  const factory _BlockUserDto({required final String userIdToBlock}) =
      _$BlockUserDtoImpl;

  factory _BlockUserDto.fromJson(Map<String, dynamic> json) =
      _$BlockUserDtoImpl.fromJson;

  @override
  String get userIdToBlock;
  @override
  @JsonKey(ignore: true)
  _$$BlockUserDtoImplCopyWith<_$BlockUserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
