// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_account_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeleteAccountDto _$DeleteAccountDtoFromJson(Map<String, dynamic> json) {
  return _DeleteAccountDto.fromJson(json);
}

/// @nodoc
mixin _$DeleteAccountDto {
  String get confirmation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeleteAccountDtoCopyWith<DeleteAccountDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeleteAccountDtoCopyWith<$Res> {
  factory $DeleteAccountDtoCopyWith(
          DeleteAccountDto value, $Res Function(DeleteAccountDto) then) =
      _$DeleteAccountDtoCopyWithImpl<$Res, DeleteAccountDto>;
  @useResult
  $Res call({String confirmation});
}

/// @nodoc
class _$DeleteAccountDtoCopyWithImpl<$Res, $Val extends DeleteAccountDto>
    implements $DeleteAccountDtoCopyWith<$Res> {
  _$DeleteAccountDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? confirmation = null,
  }) {
    return _then(_value.copyWith(
      confirmation: null == confirmation
          ? _value.confirmation
          : confirmation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeleteAccountDtoImplCopyWith<$Res>
    implements $DeleteAccountDtoCopyWith<$Res> {
  factory _$$DeleteAccountDtoImplCopyWith(_$DeleteAccountDtoImpl value,
          $Res Function(_$DeleteAccountDtoImpl) then) =
      __$$DeleteAccountDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String confirmation});
}

/// @nodoc
class __$$DeleteAccountDtoImplCopyWithImpl<$Res>
    extends _$DeleteAccountDtoCopyWithImpl<$Res, _$DeleteAccountDtoImpl>
    implements _$$DeleteAccountDtoImplCopyWith<$Res> {
  __$$DeleteAccountDtoImplCopyWithImpl(_$DeleteAccountDtoImpl _value,
      $Res Function(_$DeleteAccountDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? confirmation = null,
  }) {
    return _then(_$DeleteAccountDtoImpl(
      confirmation: null == confirmation
          ? _value.confirmation
          : confirmation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$DeleteAccountDtoImpl implements _DeleteAccountDto {
  const _$DeleteAccountDtoImpl({this.confirmation = 'DELETE'});

  factory _$DeleteAccountDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeleteAccountDtoImplFromJson(json);

  @override
  @JsonKey()
  final String confirmation;

  @override
  String toString() {
    return 'DeleteAccountDto(confirmation: $confirmation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteAccountDtoImpl &&
            (identical(other.confirmation, confirmation) ||
                other.confirmation == confirmation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, confirmation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteAccountDtoImplCopyWith<_$DeleteAccountDtoImpl> get copyWith =>
      __$$DeleteAccountDtoImplCopyWithImpl<_$DeleteAccountDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeleteAccountDtoImplToJson(
      this,
    );
  }
}

abstract class _DeleteAccountDto implements DeleteAccountDto {
  const factory _DeleteAccountDto({final String confirmation}) =
      _$DeleteAccountDtoImpl;

  factory _DeleteAccountDto.fromJson(Map<String, dynamic> json) =
      _$DeleteAccountDtoImpl.fromJson;

  @override
  String get confirmation;
  @override
  @JsonKey(ignore: true)
  _$$DeleteAccountDtoImplCopyWith<_$DeleteAccountDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
