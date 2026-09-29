// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_preference_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreatePreferenceDto _$CreatePreferenceDtoFromJson(Map<String, dynamic> json) {
  return _CreatePreferenceDto.fromJson(json);
}

/// @nodoc
mixin _$CreatePreferenceDto {
  List<String> get entertainment => throw _privateConstructorUsedError;
  List<String> get homeFamily => throw _privateConstructorUsedError;
  List<String> get fashionBeauty => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreatePreferenceDtoCopyWith<CreatePreferenceDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePreferenceDtoCopyWith<$Res> {
  factory $CreatePreferenceDtoCopyWith(
          CreatePreferenceDto value, $Res Function(CreatePreferenceDto) then) =
      _$CreatePreferenceDtoCopyWithImpl<$Res, CreatePreferenceDto>;
  @useResult
  $Res call(
      {List<String> entertainment,
      List<String> homeFamily,
      List<String> fashionBeauty});
}

/// @nodoc
class _$CreatePreferenceDtoCopyWithImpl<$Res, $Val extends CreatePreferenceDto>
    implements $CreatePreferenceDtoCopyWith<$Res> {
  _$CreatePreferenceDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entertainment = null,
    Object? homeFamily = null,
    Object? fashionBeauty = null,
  }) {
    return _then(_value.copyWith(
      entertainment: null == entertainment
          ? _value.entertainment
          : entertainment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      homeFamily: null == homeFamily
          ? _value.homeFamily
          : homeFamily // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fashionBeauty: null == fashionBeauty
          ? _value.fashionBeauty
          : fashionBeauty // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreatePreferenceDtoImplCopyWith<$Res>
    implements $CreatePreferenceDtoCopyWith<$Res> {
  factory _$$CreatePreferenceDtoImplCopyWith(_$CreatePreferenceDtoImpl value,
          $Res Function(_$CreatePreferenceDtoImpl) then) =
      __$$CreatePreferenceDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> entertainment,
      List<String> homeFamily,
      List<String> fashionBeauty});
}

/// @nodoc
class __$$CreatePreferenceDtoImplCopyWithImpl<$Res>
    extends _$CreatePreferenceDtoCopyWithImpl<$Res, _$CreatePreferenceDtoImpl>
    implements _$$CreatePreferenceDtoImplCopyWith<$Res> {
  __$$CreatePreferenceDtoImplCopyWithImpl(_$CreatePreferenceDtoImpl _value,
      $Res Function(_$CreatePreferenceDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entertainment = null,
    Object? homeFamily = null,
    Object? fashionBeauty = null,
  }) {
    return _then(_$CreatePreferenceDtoImpl(
      entertainment: null == entertainment
          ? _value._entertainment
          : entertainment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      homeFamily: null == homeFamily
          ? _value._homeFamily
          : homeFamily // ignore: cast_nullable_to_non_nullable
              as List<String>,
      fashionBeauty: null == fashionBeauty
          ? _value._fashionBeauty
          : fashionBeauty // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatePreferenceDtoImpl implements _CreatePreferenceDto {
  const _$CreatePreferenceDtoImpl(
      {required final List<String> entertainment,
      required final List<String> homeFamily,
      required final List<String> fashionBeauty})
      : _entertainment = entertainment,
        _homeFamily = homeFamily,
        _fashionBeauty = fashionBeauty;

  factory _$CreatePreferenceDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatePreferenceDtoImplFromJson(json);

  final List<String> _entertainment;
  @override
  List<String> get entertainment {
    if (_entertainment is EqualUnmodifiableListView) return _entertainment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entertainment);
  }

  final List<String> _homeFamily;
  @override
  List<String> get homeFamily {
    if (_homeFamily is EqualUnmodifiableListView) return _homeFamily;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_homeFamily);
  }

  final List<String> _fashionBeauty;
  @override
  List<String> get fashionBeauty {
    if (_fashionBeauty is EqualUnmodifiableListView) return _fashionBeauty;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fashionBeauty);
  }

  @override
  String toString() {
    return 'CreatePreferenceDto(entertainment: $entertainment, homeFamily: $homeFamily, fashionBeauty: $fashionBeauty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePreferenceDtoImpl &&
            const DeepCollectionEquality()
                .equals(other._entertainment, _entertainment) &&
            const DeepCollectionEquality()
                .equals(other._homeFamily, _homeFamily) &&
            const DeepCollectionEquality()
                .equals(other._fashionBeauty, _fashionBeauty));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_entertainment),
      const DeepCollectionEquality().hash(_homeFamily),
      const DeepCollectionEquality().hash(_fashionBeauty));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePreferenceDtoImplCopyWith<_$CreatePreferenceDtoImpl> get copyWith =>
      __$$CreatePreferenceDtoImplCopyWithImpl<_$CreatePreferenceDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatePreferenceDtoImplToJson(
      this,
    );
  }
}

abstract class _CreatePreferenceDto implements CreatePreferenceDto {
  const factory _CreatePreferenceDto(
      {required final List<String> entertainment,
      required final List<String> homeFamily,
      required final List<String> fashionBeauty}) = _$CreatePreferenceDtoImpl;

  factory _CreatePreferenceDto.fromJson(Map<String, dynamic> json) =
      _$CreatePreferenceDtoImpl.fromJson;

  @override
  List<String> get entertainment;
  @override
  List<String> get homeFamily;
  @override
  List<String> get fashionBeauty;
  @override
  @JsonKey(ignore: true)
  _$$CreatePreferenceDtoImplCopyWith<_$CreatePreferenceDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
