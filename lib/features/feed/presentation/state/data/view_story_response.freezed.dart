// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_story_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ViewStoryResponse _$ViewStoryResponseFromJson(Map<String, dynamic> json) {
  return _ViewStoryResponse.fromJson(json);
}

/// @nodoc
mixin _$ViewStoryResponse {
  bool get success => throw _privateConstructorUsedError;
  Update get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ViewStoryResponseCopyWith<ViewStoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewStoryResponseCopyWith<$Res> {
  factory $ViewStoryResponseCopyWith(
          ViewStoryResponse value, $Res Function(ViewStoryResponse) then) =
      _$ViewStoryResponseCopyWithImpl<$Res, ViewStoryResponse>;
  @useResult
  $Res call({bool success, Update data});

  $UpdateCopyWith<$Res> get data;
}

/// @nodoc
class _$ViewStoryResponseCopyWithImpl<$Res, $Val extends ViewStoryResponse>
    implements $ViewStoryResponseCopyWith<$Res> {
  _$ViewStoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Update,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UpdateCopyWith<$Res> get data {
    return $UpdateCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ViewStoryResponseImplCopyWith<$Res>
    implements $ViewStoryResponseCopyWith<$Res> {
  factory _$$ViewStoryResponseImplCopyWith(_$ViewStoryResponseImpl value,
          $Res Function(_$ViewStoryResponseImpl) then) =
      __$$ViewStoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, Update data});

  @override
  $UpdateCopyWith<$Res> get data;
}

/// @nodoc
class __$$ViewStoryResponseImplCopyWithImpl<$Res>
    extends _$ViewStoryResponseCopyWithImpl<$Res, _$ViewStoryResponseImpl>
    implements _$$ViewStoryResponseImplCopyWith<$Res> {
  __$$ViewStoryResponseImplCopyWithImpl(_$ViewStoryResponseImpl _value,
      $Res Function(_$ViewStoryResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$ViewStoryResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Update,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ViewStoryResponseImpl implements _ViewStoryResponse {
  const _$ViewStoryResponseImpl({required this.success, required this.data});

  factory _$ViewStoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ViewStoryResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final Update data;

  @override
  String toString() {
    return 'ViewStoryResponse(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewStoryResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewStoryResponseImplCopyWith<_$ViewStoryResponseImpl> get copyWith =>
      __$$ViewStoryResponseImplCopyWithImpl<_$ViewStoryResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ViewStoryResponseImplToJson(
      this,
    );
  }
}

abstract class _ViewStoryResponse implements ViewStoryResponse {
  const factory _ViewStoryResponse(
      {required final bool success,
      required final Update data}) = _$ViewStoryResponseImpl;

  factory _ViewStoryResponse.fromJson(Map<String, dynamic> json) =
      _$ViewStoryResponseImpl.fromJson;

  @override
  bool get success;
  @override
  Update get data;
  @override
  @JsonKey(ignore: true)
  _$$ViewStoryResponseImplCopyWith<_$ViewStoryResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
