// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_single_post_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetSinglePostResponse _$GetSinglePostResponseFromJson(
    Map<String, dynamic> json) {
  return _GetSinglePostResponse.fromJson(json);
}

/// @nodoc
mixin _$GetSinglePostResponse {
  bool get success => throw _privateConstructorUsedError;
  GetFeedResponseData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetSinglePostResponseCopyWith<GetSinglePostResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetSinglePostResponseCopyWith<$Res> {
  factory $GetSinglePostResponseCopyWith(GetSinglePostResponse value,
          $Res Function(GetSinglePostResponse) then) =
      _$GetSinglePostResponseCopyWithImpl<$Res, GetSinglePostResponse>;
  @useResult
  $Res call({bool success, GetFeedResponseData data});

  $GetFeedResponseDataCopyWith<$Res> get data;
}

/// @nodoc
class _$GetSinglePostResponseCopyWithImpl<$Res,
        $Val extends GetSinglePostResponse>
    implements $GetSinglePostResponseCopyWith<$Res> {
  _$GetSinglePostResponseCopyWithImpl(this._value, this._then);

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
              as GetFeedResponseData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GetFeedResponseDataCopyWith<$Res> get data {
    return $GetFeedResponseDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetSinglePostResponseImplCopyWith<$Res>
    implements $GetSinglePostResponseCopyWith<$Res> {
  factory _$$GetSinglePostResponseImplCopyWith(
          _$GetSinglePostResponseImpl value,
          $Res Function(_$GetSinglePostResponseImpl) then) =
      __$$GetSinglePostResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, GetFeedResponseData data});

  @override
  $GetFeedResponseDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$GetSinglePostResponseImplCopyWithImpl<$Res>
    extends _$GetSinglePostResponseCopyWithImpl<$Res,
        _$GetSinglePostResponseImpl>
    implements _$$GetSinglePostResponseImplCopyWith<$Res> {
  __$$GetSinglePostResponseImplCopyWithImpl(_$GetSinglePostResponseImpl _value,
      $Res Function(_$GetSinglePostResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$GetSinglePostResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as GetFeedResponseData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetSinglePostResponseImpl implements _GetSinglePostResponse {
  const _$GetSinglePostResponseImpl(
      {required this.success, required this.data});

  factory _$GetSinglePostResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetSinglePostResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final GetFeedResponseData data;

  @override
  String toString() {
    return 'GetSinglePostResponse(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetSinglePostResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetSinglePostResponseImplCopyWith<_$GetSinglePostResponseImpl>
      get copyWith => __$$GetSinglePostResponseImplCopyWithImpl<
          _$GetSinglePostResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetSinglePostResponseImplToJson(
      this,
    );
  }
}

abstract class _GetSinglePostResponse implements GetSinglePostResponse {
  const factory _GetSinglePostResponse(
      {required final bool success,
      required final GetFeedResponseData data}) = _$GetSinglePostResponseImpl;

  factory _GetSinglePostResponse.fromJson(Map<String, dynamic> json) =
      _$GetSinglePostResponseImpl.fromJson;

  @override
  bool get success;
  @override
  GetFeedResponseData get data;
  @override
  @JsonKey(ignore: true)
  _$$GetSinglePostResponseImplCopyWith<_$GetSinglePostResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
