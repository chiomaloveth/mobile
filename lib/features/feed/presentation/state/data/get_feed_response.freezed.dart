// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_feed_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetFeedResponse _$GetFeedResponseFromJson(Map<String, dynamic> json) {
  return _GetFeedResponse.fromJson(json);
}

/// @nodoc
mixin _$GetFeedResponse {
  bool get success => throw _privateConstructorUsedError;
  List<GetFeedResponseData> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetFeedResponseCopyWith<GetFeedResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetFeedResponseCopyWith<$Res> {
  factory $GetFeedResponseCopyWith(
          GetFeedResponse value, $Res Function(GetFeedResponse) then) =
      _$GetFeedResponseCopyWithImpl<$Res, GetFeedResponse>;
  @useResult
  $Res call({bool success, List<GetFeedResponseData> data});
}

/// @nodoc
class _$GetFeedResponseCopyWithImpl<$Res, $Val extends GetFeedResponse>
    implements $GetFeedResponseCopyWith<$Res> {
  _$GetFeedResponseCopyWithImpl(this._value, this._then);

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
              as List<GetFeedResponseData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetFeedResponseImplCopyWith<$Res>
    implements $GetFeedResponseCopyWith<$Res> {
  factory _$$GetFeedResponseImplCopyWith(_$GetFeedResponseImpl value,
          $Res Function(_$GetFeedResponseImpl) then) =
      __$$GetFeedResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, List<GetFeedResponseData> data});
}

/// @nodoc
class __$$GetFeedResponseImplCopyWithImpl<$Res>
    extends _$GetFeedResponseCopyWithImpl<$Res, _$GetFeedResponseImpl>
    implements _$$GetFeedResponseImplCopyWith<$Res> {
  __$$GetFeedResponseImplCopyWithImpl(
      _$GetFeedResponseImpl _value, $Res Function(_$GetFeedResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$GetFeedResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<GetFeedResponseData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetFeedResponseImpl implements _GetFeedResponse {
  const _$GetFeedResponseImpl(
      {required this.success, required final List<GetFeedResponseData> data})
      : _data = data;

  factory _$GetFeedResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetFeedResponseImplFromJson(json);

  @override
  final bool success;
  final List<GetFeedResponseData> _data;
  @override
  List<GetFeedResponseData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetFeedResponse(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetFeedResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetFeedResponseImplCopyWith<_$GetFeedResponseImpl> get copyWith =>
      __$$GetFeedResponseImplCopyWithImpl<_$GetFeedResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetFeedResponseImplToJson(
      this,
    );
  }
}

abstract class _GetFeedResponse implements GetFeedResponse {
  const factory _GetFeedResponse(
      {required final bool success,
      required final List<GetFeedResponseData> data}) = _$GetFeedResponseImpl;

  factory _GetFeedResponse.fromJson(Map<String, dynamic> json) =
      _$GetFeedResponseImpl.fromJson;

  @override
  bool get success;
  @override
  List<GetFeedResponseData> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetFeedResponseImplCopyWith<_$GetFeedResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
