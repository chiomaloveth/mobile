// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'like_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LikeResponseData _$LikeResponseDataFromJson(Map<String, dynamic> json) {
  return _LikeResponseData.fromJson(json);
}

/// @nodoc
mixin _$LikeResponseData {
  @JsonKey(name: 'liked')
  bool? get liked => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LikeResponseDataCopyWith<LikeResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeResponseDataCopyWith<$Res> {
  factory $LikeResponseDataCopyWith(
          LikeResponseData value, $Res Function(LikeResponseData) then) =
      _$LikeResponseDataCopyWithImpl<$Res, LikeResponseData>;
  @useResult
  $Res call({@JsonKey(name: 'liked') bool? liked});
}

/// @nodoc
class _$LikeResponseDataCopyWithImpl<$Res, $Val extends LikeResponseData>
    implements $LikeResponseDataCopyWith<$Res> {
  _$LikeResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liked = freezed,
  }) {
    return _then(_value.copyWith(
      liked: freezed == liked
          ? _value.liked
          : liked // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LikeResponseDataImplCopyWith<$Res>
    implements $LikeResponseDataCopyWith<$Res> {
  factory _$$LikeResponseDataImplCopyWith(_$LikeResponseDataImpl value,
          $Res Function(_$LikeResponseDataImpl) then) =
      __$$LikeResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'liked') bool? liked});
}

/// @nodoc
class __$$LikeResponseDataImplCopyWithImpl<$Res>
    extends _$LikeResponseDataCopyWithImpl<$Res, _$LikeResponseDataImpl>
    implements _$$LikeResponseDataImplCopyWith<$Res> {
  __$$LikeResponseDataImplCopyWithImpl(_$LikeResponseDataImpl _value,
      $Res Function(_$LikeResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liked = freezed,
  }) {
    return _then(_$LikeResponseDataImpl(
      liked: freezed == liked
          ? _value.liked
          : liked // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LikeResponseDataImpl implements _LikeResponseData {
  const _$LikeResponseDataImpl({@JsonKey(name: 'liked') this.liked});

  factory _$LikeResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikeResponseDataImplFromJson(json);

  @override
  @JsonKey(name: 'liked')
  final bool? liked;

  @override
  String toString() {
    return 'LikeResponseData(liked: $liked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeResponseDataImpl &&
            (identical(other.liked, liked) || other.liked == liked));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, liked);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeResponseDataImplCopyWith<_$LikeResponseDataImpl> get copyWith =>
      __$$LikeResponseDataImplCopyWithImpl<_$LikeResponseDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikeResponseDataImplToJson(
      this,
    );
  }
}

abstract class _LikeResponseData implements LikeResponseData {
  const factory _LikeResponseData({@JsonKey(name: 'liked') final bool? liked}) =
      _$LikeResponseDataImpl;

  factory _LikeResponseData.fromJson(Map<String, dynamic> json) =
      _$LikeResponseDataImpl.fromJson;

  @override
  @JsonKey(name: 'liked')
  bool? get liked;
  @override
  @JsonKey(ignore: true)
  _$$LikeResponseDataImplCopyWith<_$LikeResponseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
