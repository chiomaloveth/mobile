// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_story_viewers_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetStoryViewersResponse _$GetStoryViewersResponseFromJson(
    Map<String, dynamic> json) {
  return _GetStoryViewersResponse.fromJson(json);
}

/// @nodoc
mixin _$GetStoryViewersResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  StoryViewersData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStoryViewersResponseCopyWith<GetStoryViewersResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStoryViewersResponseCopyWith<$Res> {
  factory $GetStoryViewersResponseCopyWith(GetStoryViewersResponse value,
          $Res Function(GetStoryViewersResponse) then) =
      _$GetStoryViewersResponseCopyWithImpl<$Res, GetStoryViewersResponse>;
  @useResult
  $Res call({bool success, String message, StoryViewersData data});

  $StoryViewersDataCopyWith<$Res> get data;
}

/// @nodoc
class _$GetStoryViewersResponseCopyWithImpl<$Res,
        $Val extends GetStoryViewersResponse>
    implements $GetStoryViewersResponseCopyWith<$Res> {
  _$GetStoryViewersResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as StoryViewersData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $StoryViewersDataCopyWith<$Res> get data {
    return $StoryViewersDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetStoryViewersResponseImplCopyWith<$Res>
    implements $GetStoryViewersResponseCopyWith<$Res> {
  factory _$$GetStoryViewersResponseImplCopyWith(
          _$GetStoryViewersResponseImpl value,
          $Res Function(_$GetStoryViewersResponseImpl) then) =
      __$$GetStoryViewersResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, StoryViewersData data});

  @override
  $StoryViewersDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$GetStoryViewersResponseImplCopyWithImpl<$Res>
    extends _$GetStoryViewersResponseCopyWithImpl<$Res,
        _$GetStoryViewersResponseImpl>
    implements _$$GetStoryViewersResponseImplCopyWith<$Res> {
  __$$GetStoryViewersResponseImplCopyWithImpl(
      _$GetStoryViewersResponseImpl _value,
      $Res Function(_$GetStoryViewersResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$GetStoryViewersResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as StoryViewersData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetStoryViewersResponseImpl implements _GetStoryViewersResponse {
  const _$GetStoryViewersResponseImpl(
      {required this.success, required this.message, required this.data});

  factory _$GetStoryViewersResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetStoryViewersResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final StoryViewersData data;

  @override
  String toString() {
    return 'GetStoryViewersResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetStoryViewersResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetStoryViewersResponseImplCopyWith<_$GetStoryViewersResponseImpl>
      get copyWith => __$$GetStoryViewersResponseImplCopyWithImpl<
          _$GetStoryViewersResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetStoryViewersResponseImplToJson(
      this,
    );
  }
}

abstract class _GetStoryViewersResponse implements GetStoryViewersResponse {
  const factory _GetStoryViewersResponse(
      {required final bool success,
      required final String message,
      required final StoryViewersData data}) = _$GetStoryViewersResponseImpl;

  factory _GetStoryViewersResponse.fromJson(Map<String, dynamic> json) =
      _$GetStoryViewersResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  StoryViewersData get data;
  @override
  @JsonKey(ignore: true)
  _$$GetStoryViewersResponseImplCopyWith<_$GetStoryViewersResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

StoryViewersData _$StoryViewersDataFromJson(Map<String, dynamic> json) {
  return _StoryViewersData.fromJson(json);
}

/// @nodoc
mixin _$StoryViewersData {
  int get totalViews => throw _privateConstructorUsedError;
  List<StoryViewer> get viewers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StoryViewersDataCopyWith<StoryViewersData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryViewersDataCopyWith<$Res> {
  factory $StoryViewersDataCopyWith(
          StoryViewersData value, $Res Function(StoryViewersData) then) =
      _$StoryViewersDataCopyWithImpl<$Res, StoryViewersData>;
  @useResult
  $Res call({int totalViews, List<StoryViewer> viewers});
}

/// @nodoc
class _$StoryViewersDataCopyWithImpl<$Res, $Val extends StoryViewersData>
    implements $StoryViewersDataCopyWith<$Res> {
  _$StoryViewersDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalViews = null,
    Object? viewers = null,
  }) {
    return _then(_value.copyWith(
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      viewers: null == viewers
          ? _value.viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<StoryViewer>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoryViewersDataImplCopyWith<$Res>
    implements $StoryViewersDataCopyWith<$Res> {
  factory _$$StoryViewersDataImplCopyWith(_$StoryViewersDataImpl value,
          $Res Function(_$StoryViewersDataImpl) then) =
      __$$StoryViewersDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalViews, List<StoryViewer> viewers});
}

/// @nodoc
class __$$StoryViewersDataImplCopyWithImpl<$Res>
    extends _$StoryViewersDataCopyWithImpl<$Res, _$StoryViewersDataImpl>
    implements _$$StoryViewersDataImplCopyWith<$Res> {
  __$$StoryViewersDataImplCopyWithImpl(_$StoryViewersDataImpl _value,
      $Res Function(_$StoryViewersDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalViews = null,
    Object? viewers = null,
  }) {
    return _then(_$StoryViewersDataImpl(
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      viewers: null == viewers
          ? _value._viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<StoryViewer>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryViewersDataImpl implements _StoryViewersData {
  const _$StoryViewersDataImpl(
      {required this.totalViews, required final List<StoryViewer> viewers})
      : _viewers = viewers;

  factory _$StoryViewersDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryViewersDataImplFromJson(json);

  @override
  final int totalViews;
  final List<StoryViewer> _viewers;
  @override
  List<StoryViewer> get viewers {
    if (_viewers is EqualUnmodifiableListView) return _viewers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_viewers);
  }

  @override
  String toString() {
    return 'StoryViewersData(totalViews: $totalViews, viewers: $viewers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryViewersDataImpl &&
            (identical(other.totalViews, totalViews) ||
                other.totalViews == totalViews) &&
            const DeepCollectionEquality().equals(other._viewers, _viewers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, totalViews, const DeepCollectionEquality().hash(_viewers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryViewersDataImplCopyWith<_$StoryViewersDataImpl> get copyWith =>
      __$$StoryViewersDataImplCopyWithImpl<_$StoryViewersDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryViewersDataImplToJson(
      this,
    );
  }
}

abstract class _StoryViewersData implements StoryViewersData {
  const factory _StoryViewersData(
      {required final int totalViews,
      required final List<StoryViewer> viewers}) = _$StoryViewersDataImpl;

  factory _StoryViewersData.fromJson(Map<String, dynamic> json) =
      _$StoryViewersDataImpl.fromJson;

  @override
  int get totalViews;
  @override
  List<StoryViewer> get viewers;
  @override
  @JsonKey(ignore: true)
  _$$StoryViewersDataImplCopyWith<_$StoryViewersDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
