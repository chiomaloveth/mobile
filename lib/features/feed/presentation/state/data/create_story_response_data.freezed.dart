// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_story_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateStoryResponseData _$CreateStoryResponseDataFromJson(
    Map<String, dynamic> json) {
  return _CreateStoryResponseData.fromJson(json);
}

/// @nodoc
mixin _$CreateStoryResponseData {
  @JsonKey(name: 'success')
  bool? get success => throw _privateConstructorUsedError;
  @JsonKey(name: 'data')
  CreateStoryData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateStoryResponseDataCopyWith<CreateStoryResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStoryResponseDataCopyWith<$Res> {
  factory $CreateStoryResponseDataCopyWith(CreateStoryResponseData value,
          $Res Function(CreateStoryResponseData) then) =
      _$CreateStoryResponseDataCopyWithImpl<$Res, CreateStoryResponseData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'success') bool? success,
      @JsonKey(name: 'data') CreateStoryData? data});

  $CreateStoryDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$CreateStoryResponseDataCopyWithImpl<$Res,
        $Val extends CreateStoryResponseData>
    implements $CreateStoryResponseDataCopyWith<$Res> {
  _$CreateStoryResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CreateStoryData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CreateStoryDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $CreateStoryDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateStoryResponseDataImplCopyWith<$Res>
    implements $CreateStoryResponseDataCopyWith<$Res> {
  factory _$$CreateStoryResponseDataImplCopyWith(
          _$CreateStoryResponseDataImpl value,
          $Res Function(_$CreateStoryResponseDataImpl) then) =
      __$$CreateStoryResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'success') bool? success,
      @JsonKey(name: 'data') CreateStoryData? data});

  @override
  $CreateStoryDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CreateStoryResponseDataImplCopyWithImpl<$Res>
    extends _$CreateStoryResponseDataCopyWithImpl<$Res,
        _$CreateStoryResponseDataImpl>
    implements _$$CreateStoryResponseDataImplCopyWith<$Res> {
  __$$CreateStoryResponseDataImplCopyWithImpl(
      _$CreateStoryResponseDataImpl _value,
      $Res Function(_$CreateStoryResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_$CreateStoryResponseDataImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CreateStoryData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStoryResponseDataImpl implements _CreateStoryResponseData {
  const _$CreateStoryResponseDataImpl(
      {@JsonKey(name: 'success') this.success,
      @JsonKey(name: 'data') this.data});

  factory _$CreateStoryResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStoryResponseDataImplFromJson(json);

  @override
  @JsonKey(name: 'success')
  final bool? success;
  @override
  @JsonKey(name: 'data')
  final CreateStoryData? data;

  @override
  String toString() {
    return 'CreateStoryResponseData(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStoryResponseDataImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateStoryResponseDataImplCopyWith<_$CreateStoryResponseDataImpl>
      get copyWith => __$$CreateStoryResponseDataImplCopyWithImpl<
          _$CreateStoryResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateStoryResponseDataImplToJson(
      this,
    );
  }
}

abstract class _CreateStoryResponseData implements CreateStoryResponseData {
  const factory _CreateStoryResponseData(
          {@JsonKey(name: 'success') final bool? success,
          @JsonKey(name: 'data') final CreateStoryData? data}) =
      _$CreateStoryResponseDataImpl;

  factory _CreateStoryResponseData.fromJson(Map<String, dynamic> json) =
      _$CreateStoryResponseDataImpl.fromJson;

  @override
  @JsonKey(name: 'success')
  bool? get success;
  @override
  @JsonKey(name: 'data')
  CreateStoryData? get data;
  @override
  @JsonKey(ignore: true)
  _$$CreateStoryResponseDataImplCopyWith<_$CreateStoryResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreateStoryData _$CreateStoryDataFromJson(Map<String, dynamic> json) {
  return _CreateStoryData.fromJson(json);
}

/// @nodoc
mixin _$CreateStoryData {
  @JsonKey(name: 'user')
  String? get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'media')
  String? get media => throw _privateConstructorUsedError;
  @JsonKey(name: 'mediaType')
  String? get mediaType => throw _privateConstructorUsedError;
  @JsonKey(name: 'caption')
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'viewers')
  List<dynamic>? get viewers => throw _privateConstructorUsedError;
  @JsonKey(name: 'expiresAt')
  String? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'overlayText')
  String? get overlayText => throw _privateConstructorUsedError;
  @JsonKey(name: 'overlayVideos')
  List<String>? get overlayVideos => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateStoryDataCopyWith<CreateStoryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStoryDataCopyWith<$Res> {
  factory $CreateStoryDataCopyWith(
          CreateStoryData value, $Res Function(CreateStoryData) then) =
      _$CreateStoryDataCopyWithImpl<$Res, CreateStoryData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user') String? user,
      @JsonKey(name: 'media') String? media,
      @JsonKey(name: 'mediaType') String? mediaType,
      @JsonKey(name: 'caption') String? caption,
      @JsonKey(name: '_id') String? id,
      @JsonKey(name: 'viewers') List<dynamic>? viewers,
      @JsonKey(name: 'expiresAt') String? expiresAt,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      @JsonKey(name: 'overlayText') String? overlayText,
      @JsonKey(name: 'overlayVideos') List<String>? overlayVideos,
      @JsonKey(name: '__v') int? v});
}

/// @nodoc
class _$CreateStoryDataCopyWithImpl<$Res, $Val extends CreateStoryData>
    implements $CreateStoryDataCopyWith<$Res> {
  _$CreateStoryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? media = freezed,
    Object? mediaType = freezed,
    Object? caption = freezed,
    Object? id = freezed,
    Object? viewers = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? v = freezed,
  }) {
    return _then(_value.copyWith(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      viewers: freezed == viewers
          ? _value.viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value.overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateStoryDataImplCopyWith<$Res>
    implements $CreateStoryDataCopyWith<$Res> {
  factory _$$CreateStoryDataImplCopyWith(_$CreateStoryDataImpl value,
          $Res Function(_$CreateStoryDataImpl) then) =
      __$$CreateStoryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user') String? user,
      @JsonKey(name: 'media') String? media,
      @JsonKey(name: 'mediaType') String? mediaType,
      @JsonKey(name: 'caption') String? caption,
      @JsonKey(name: '_id') String? id,
      @JsonKey(name: 'viewers') List<dynamic>? viewers,
      @JsonKey(name: 'expiresAt') String? expiresAt,
      @JsonKey(name: 'createdAt') String? createdAt,
      @JsonKey(name: 'updatedAt') String? updatedAt,
      @JsonKey(name: 'overlayText') String? overlayText,
      @JsonKey(name: 'overlayVideos') List<String>? overlayVideos,
      @JsonKey(name: '__v') int? v});
}

/// @nodoc
class __$$CreateStoryDataImplCopyWithImpl<$Res>
    extends _$CreateStoryDataCopyWithImpl<$Res, _$CreateStoryDataImpl>
    implements _$$CreateStoryDataImplCopyWith<$Res> {
  __$$CreateStoryDataImplCopyWithImpl(
      _$CreateStoryDataImpl _value, $Res Function(_$CreateStoryDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? media = freezed,
    Object? mediaType = freezed,
    Object? caption = freezed,
    Object? id = freezed,
    Object? viewers = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? v = freezed,
  }) {
    return _then(_$CreateStoryDataImpl(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      viewers: freezed == viewers
          ? _value._viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value._overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStoryDataImpl implements _CreateStoryData {
  const _$CreateStoryDataImpl(
      {@JsonKey(name: 'user') this.user,
      @JsonKey(name: 'media') this.media,
      @JsonKey(name: 'mediaType') this.mediaType,
      @JsonKey(name: 'caption') this.caption,
      @JsonKey(name: '_id') this.id,
      @JsonKey(name: 'viewers') final List<dynamic>? viewers,
      @JsonKey(name: 'expiresAt') this.expiresAt,
      @JsonKey(name: 'createdAt') this.createdAt,
      @JsonKey(name: 'updatedAt') this.updatedAt,
      @JsonKey(name: 'overlayText') this.overlayText,
      @JsonKey(name: 'overlayVideos') final List<String>? overlayVideos,
      @JsonKey(name: '__v') this.v})
      : _viewers = viewers,
        _overlayVideos = overlayVideos;

  factory _$CreateStoryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStoryDataImplFromJson(json);

  @override
  @JsonKey(name: 'user')
  final String? user;
  @override
  @JsonKey(name: 'media')
  final String? media;
  @override
  @JsonKey(name: 'mediaType')
  final String? mediaType;
  @override
  @JsonKey(name: 'caption')
  final String? caption;
  @override
  @JsonKey(name: '_id')
  final String? id;
  final List<dynamic>? _viewers;
  @override
  @JsonKey(name: 'viewers')
  List<dynamic>? get viewers {
    final value = _viewers;
    if (value == null) return null;
    if (_viewers is EqualUnmodifiableListView) return _viewers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'expiresAt')
  final String? expiresAt;
  @override
  @JsonKey(name: 'createdAt')
  final String? createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final String? updatedAt;
  @override
  @JsonKey(name: 'overlayText')
  final String? overlayText;
  final List<String>? _overlayVideos;
  @override
  @JsonKey(name: 'overlayVideos')
  List<String>? get overlayVideos {
    final value = _overlayVideos;
    if (value == null) return null;
    if (_overlayVideos is EqualUnmodifiableListView) return _overlayVideos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: '__v')
  final int? v;

  @override
  String toString() {
    return 'CreateStoryData(user: $user, media: $media, mediaType: $mediaType, caption: $caption, id: $id, viewers: $viewers, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, overlayText: $overlayText, overlayVideos: $overlayVideos, v: $v)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStoryDataImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.media, media) || other.media == media) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._viewers, _viewers) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.overlayText, overlayText) ||
                other.overlayText == overlayText) &&
            const DeepCollectionEquality()
                .equals(other._overlayVideos, _overlayVideos) &&
            (identical(other.v, v) || other.v == v));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      media,
      mediaType,
      caption,
      id,
      const DeepCollectionEquality().hash(_viewers),
      expiresAt,
      createdAt,
      updatedAt,
      overlayText,
      const DeepCollectionEquality().hash(_overlayVideos),
      v);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateStoryDataImplCopyWith<_$CreateStoryDataImpl> get copyWith =>
      __$$CreateStoryDataImplCopyWithImpl<_$CreateStoryDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateStoryDataImplToJson(
      this,
    );
  }
}

abstract class _CreateStoryData implements CreateStoryData {
  const factory _CreateStoryData(
      {@JsonKey(name: 'user') final String? user,
      @JsonKey(name: 'media') final String? media,
      @JsonKey(name: 'mediaType') final String? mediaType,
      @JsonKey(name: 'caption') final String? caption,
      @JsonKey(name: '_id') final String? id,
      @JsonKey(name: 'viewers') final List<dynamic>? viewers,
      @JsonKey(name: 'expiresAt') final String? expiresAt,
      @JsonKey(name: 'createdAt') final String? createdAt,
      @JsonKey(name: 'updatedAt') final String? updatedAt,
      @JsonKey(name: 'overlayText') final String? overlayText,
      @JsonKey(name: 'overlayVideos') final List<String>? overlayVideos,
      @JsonKey(name: '__v') final int? v}) = _$CreateStoryDataImpl;

  factory _CreateStoryData.fromJson(Map<String, dynamic> json) =
      _$CreateStoryDataImpl.fromJson;

  @override
  @JsonKey(name: 'user')
  String? get user;
  @override
  @JsonKey(name: 'media')
  String? get media;
  @override
  @JsonKey(name: 'mediaType')
  String? get mediaType;
  @override
  @JsonKey(name: 'caption')
  String? get caption;
  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  @JsonKey(name: 'viewers')
  List<dynamic>? get viewers;
  @override
  @JsonKey(name: 'expiresAt')
  String? get expiresAt;
  @override
  @JsonKey(name: 'createdAt')
  String? get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  String? get updatedAt;
  @override
  @JsonKey(name: 'overlayText')
  String? get overlayText;
  @override
  @JsonKey(name: 'overlayVideos')
  List<String>? get overlayVideos;
  @override
  @JsonKey(name: '__v')
  int? get v;
  @override
  @JsonKey(ignore: true)
  _$$CreateStoryDataImplCopyWith<_$CreateStoryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
