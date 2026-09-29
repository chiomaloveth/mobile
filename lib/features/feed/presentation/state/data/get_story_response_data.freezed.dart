// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_story_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetStoryResponseData _$GetStoryResponseDataFromJson(Map<String, dynamic> json) {
  return _GetStoryResponseData.fromJson(json);
}

/// @nodoc
mixin _$GetStoryResponseData {
  bool get success => throw _privateConstructorUsedError;
  List<StoryData> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetStoryResponseDataCopyWith<GetStoryResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetStoryResponseDataCopyWith<$Res> {
  factory $GetStoryResponseDataCopyWith(GetStoryResponseData value,
          $Res Function(GetStoryResponseData) then) =
      _$GetStoryResponseDataCopyWithImpl<$Res, GetStoryResponseData>;
  @useResult
  $Res call({bool success, List<StoryData> data});
}

/// @nodoc
class _$GetStoryResponseDataCopyWithImpl<$Res,
        $Val extends GetStoryResponseData>
    implements $GetStoryResponseDataCopyWith<$Res> {
  _$GetStoryResponseDataCopyWithImpl(this._value, this._then);

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
              as List<StoryData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetStoryResponseDataImplCopyWith<$Res>
    implements $GetStoryResponseDataCopyWith<$Res> {
  factory _$$GetStoryResponseDataImplCopyWith(_$GetStoryResponseDataImpl value,
          $Res Function(_$GetStoryResponseDataImpl) then) =
      __$$GetStoryResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, List<StoryData> data});
}

/// @nodoc
class __$$GetStoryResponseDataImplCopyWithImpl<$Res>
    extends _$GetStoryResponseDataCopyWithImpl<$Res, _$GetStoryResponseDataImpl>
    implements _$$GetStoryResponseDataImplCopyWith<$Res> {
  __$$GetStoryResponseDataImplCopyWithImpl(_$GetStoryResponseDataImpl _value,
      $Res Function(_$GetStoryResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$GetStoryResponseDataImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<StoryData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetStoryResponseDataImpl implements _GetStoryResponseData {
  const _$GetStoryResponseDataImpl(
      {required this.success, required final List<StoryData> data})
      : _data = data;

  factory _$GetStoryResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetStoryResponseDataImplFromJson(json);

  @override
  final bool success;
  final List<StoryData> _data;
  @override
  List<StoryData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetStoryResponseData(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetStoryResponseDataImpl &&
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
  _$$GetStoryResponseDataImplCopyWith<_$GetStoryResponseDataImpl>
      get copyWith =>
          __$$GetStoryResponseDataImplCopyWithImpl<_$GetStoryResponseDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetStoryResponseDataImplToJson(
      this,
    );
  }
}

abstract class _GetStoryResponseData implements GetStoryResponseData {
  const factory _GetStoryResponseData(
      {required final bool success,
      required final List<StoryData> data}) = _$GetStoryResponseDataImpl;

  factory _GetStoryResponseData.fromJson(Map<String, dynamic> json) =
      _$GetStoryResponseDataImpl.fromJson;

  @override
  bool get success;
  @override
  List<StoryData> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetStoryResponseDataImplCopyWith<_$GetStoryResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

StoryData _$StoryDataFromJson(Map<String, dynamic> json) {
  return _StoryData.fromJson(json);
}

/// @nodoc
mixin _$StoryData {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  MyUser? get user => throw _privateConstructorUsedError;
  List<Update>? get updates => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StoryDataCopyWith<StoryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryDataCopyWith<$Res> {
  factory $StoryDataCopyWith(StoryData value, $Res Function(StoryData) then) =
      _$StoryDataCopyWithImpl<$Res, StoryData>;
  @useResult
  $Res call(
      {@JsonKey(name: "_id") String? id, MyUser? user, List<Update>? updates});

  $MyUserCopyWith<$Res>? get user;
}

/// @nodoc
class _$StoryDataCopyWithImpl<$Res, $Val extends StoryData>
    implements $StoryDataCopyWith<$Res> {
  _$StoryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? user = freezed,
    Object? updates = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser?,
      updates: freezed == updates
          ? _value.updates
          : updates // ignore: cast_nullable_to_non_nullable
              as List<Update>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MyUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $MyUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoryDataImplCopyWith<$Res>
    implements $StoryDataCopyWith<$Res> {
  factory _$$StoryDataImplCopyWith(
          _$StoryDataImpl value, $Res Function(_$StoryDataImpl) then) =
      __$$StoryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "_id") String? id, MyUser? user, List<Update>? updates});

  @override
  $MyUserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$StoryDataImplCopyWithImpl<$Res>
    extends _$StoryDataCopyWithImpl<$Res, _$StoryDataImpl>
    implements _$$StoryDataImplCopyWith<$Res> {
  __$$StoryDataImplCopyWithImpl(
      _$StoryDataImpl _value, $Res Function(_$StoryDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? user = freezed,
    Object? updates = freezed,
  }) {
    return _then(_$StoryDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser?,
      updates: freezed == updates
          ? _value._updates
          : updates // ignore: cast_nullable_to_non_nullable
              as List<Update>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryDataImpl implements _StoryData {
  const _$StoryDataImpl(
      {@JsonKey(name: "_id") this.id, this.user, final List<Update>? updates})
      : _updates = updates;

  factory _$StoryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryDataImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  final MyUser? user;
  final List<Update>? _updates;
  @override
  List<Update>? get updates {
    final value = _updates;
    if (value == null) return null;
    if (_updates is EqualUnmodifiableListView) return _updates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'StoryData(id: $id, user: $user, updates: $updates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._updates, _updates));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, user, const DeepCollectionEquality().hash(_updates));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryDataImplCopyWith<_$StoryDataImpl> get copyWith =>
      __$$StoryDataImplCopyWithImpl<_$StoryDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryDataImplToJson(
      this,
    );
  }
}

abstract class _StoryData implements StoryData {
  const factory _StoryData(
      {@JsonKey(name: "_id") final String? id,
      final MyUser? user,
      final List<Update>? updates}) = _$StoryDataImpl;

  factory _StoryData.fromJson(Map<String, dynamic> json) =
      _$StoryDataImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  MyUser? get user;
  @override
  List<Update>? get updates;
  @override
  @JsonKey(ignore: true)
  _$$StoryDataImplCopyWith<_$StoryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Update _$UpdateFromJson(Map<String, dynamic> json) {
  return _Update.fromJson(json);
}

/// @nodoc
mixin _$Update {
  @JsonKey(name: "_id")
  String? get updateId => throw _privateConstructorUsedError;
  MyUser? get user => throw _privateConstructorUsedError;
  String? get media => throw _privateConstructorUsedError;
  String? get mediaType => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  List<StoryViewer>? get viewers => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
  int? get v => throw _privateConstructorUsedError;
  String? get bgColor => throw _privateConstructorUsedError;
  int? get backgroundColor => throw _privateConstructorUsedError;
  int? get viewCount => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  bool? get hasViewed => throw _privateConstructorUsedError;
  String? get overlayText => throw _privateConstructorUsedError;
  List<String>? get overlayVideos => throw _privateConstructorUsedError;
  List<dynamic>? get overlays => throw _privateConstructorUsedError;
  Music? get music => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateCopyWith<Update> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateCopyWith<$Res> {
  factory $UpdateCopyWith(Update value, $Res Function(Update) then) =
      _$UpdateCopyWithImpl<$Res, Update>;
  @useResult
  $Res call(
      {@JsonKey(name: "_id") String? updateId,
      MyUser? user,
      String? media,
      String? mediaType,
      String? caption,
      List<StoryViewer>? viewers,
      DateTime? expiresAt,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(name: "__v") int? v,
      String? bgColor,
      int? backgroundColor,
      int? viewCount,
      String? id,
      bool? hasViewed,
      String? overlayText,
      List<String>? overlayVideos,
      List<dynamic>? overlays,
      Music? music});

  $MyUserCopyWith<$Res>? get user;
  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class _$UpdateCopyWithImpl<$Res, $Val extends Update>
    implements $UpdateCopyWith<$Res> {
  _$UpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updateId = freezed,
    Object? user = freezed,
    Object? media = freezed,
    Object? mediaType = freezed,
    Object? caption = freezed,
    Object? viewers = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? bgColor = freezed,
    Object? backgroundColor = freezed,
    Object? viewCount = freezed,
    Object? id = freezed,
    Object? hasViewed = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? overlays = freezed,
    Object? music = freezed,
  }) {
    return _then(_value.copyWith(
      updateId: freezed == updateId
          ? _value.updateId
          : updateId // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser?,
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
      viewers: freezed == viewers
          ? _value.viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<StoryViewer>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      bgColor: freezed == bgColor
          ? _value.bgColor
          : bgColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as int?,
      viewCount: freezed == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      hasViewed: freezed == hasViewed
          ? _value.hasViewed
          : hasViewed // ignore: cast_nullable_to_non_nullable
              as bool?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value.overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      overlays: freezed == overlays
          ? _value.overlays
          : overlays // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as Music?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MyUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $MyUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MusicCopyWith<$Res>? get music {
    if (_value.music == null) {
      return null;
    }

    return $MusicCopyWith<$Res>(_value.music!, (value) {
      return _then(_value.copyWith(music: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateImplCopyWith<$Res> implements $UpdateCopyWith<$Res> {
  factory _$$UpdateImplCopyWith(
          _$UpdateImpl value, $Res Function(_$UpdateImpl) then) =
      __$$UpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "_id") String? updateId,
      MyUser? user,
      String? media,
      String? mediaType,
      String? caption,
      List<StoryViewer>? viewers,
      DateTime? expiresAt,
      DateTime? createdAt,
      DateTime? updatedAt,
      @JsonKey(name: "__v") int? v,
      String? bgColor,
      int? backgroundColor,
      int? viewCount,
      String? id,
      bool? hasViewed,
      String? overlayText,
      List<String>? overlayVideos,
      List<dynamic>? overlays,
      Music? music});

  @override
  $MyUserCopyWith<$Res>? get user;
  @override
  $MusicCopyWith<$Res>? get music;
}

/// @nodoc
class __$$UpdateImplCopyWithImpl<$Res>
    extends _$UpdateCopyWithImpl<$Res, _$UpdateImpl>
    implements _$$UpdateImplCopyWith<$Res> {
  __$$UpdateImplCopyWithImpl(
      _$UpdateImpl _value, $Res Function(_$UpdateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updateId = freezed,
    Object? user = freezed,
    Object? media = freezed,
    Object? mediaType = freezed,
    Object? caption = freezed,
    Object? viewers = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? bgColor = freezed,
    Object? backgroundColor = freezed,
    Object? viewCount = freezed,
    Object? id = freezed,
    Object? hasViewed = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? overlays = freezed,
    Object? music = freezed,
  }) {
    return _then(_$UpdateImpl(
      updateId: freezed == updateId
          ? _value.updateId
          : updateId // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as MyUser?,
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
      viewers: freezed == viewers
          ? _value._viewers
          : viewers // ignore: cast_nullable_to_non_nullable
              as List<StoryViewer>?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
      bgColor: freezed == bgColor
          ? _value.bgColor
          : bgColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as int?,
      viewCount: freezed == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      hasViewed: freezed == hasViewed
          ? _value.hasViewed
          : hasViewed // ignore: cast_nullable_to_non_nullable
              as bool?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value._overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      overlays: freezed == overlays
          ? _value._overlays
          : overlays // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as Music?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateImpl implements _Update {
  const _$UpdateImpl(
      {@JsonKey(name: "_id") this.updateId,
      this.user,
      this.media,
      this.mediaType,
      this.caption,
      final List<StoryViewer>? viewers,
      this.expiresAt,
      this.createdAt,
      this.updatedAt,
      @JsonKey(name: "__v") this.v,
      this.bgColor,
      this.backgroundColor,
      this.viewCount,
      this.id,
      this.hasViewed,
      this.overlayText,
      final List<String>? overlayVideos,
      final List<dynamic>? overlays,
      this.music})
      : _viewers = viewers,
        _overlayVideos = overlayVideos,
        _overlays = overlays;

  factory _$UpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? updateId;
  @override
  final MyUser? user;
  @override
  final String? media;
  @override
  final String? mediaType;
  @override
  final String? caption;
  final List<StoryViewer>? _viewers;
  @override
  List<StoryViewer>? get viewers {
    final value = _viewers;
    if (value == null) return null;
    if (_viewers is EqualUnmodifiableListView) return _viewers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? expiresAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: "__v")
  final int? v;
  @override
  final String? bgColor;
  @override
  final int? backgroundColor;
  @override
  final int? viewCount;
  @override
  final String? id;
  @override
  final bool? hasViewed;
  @override
  final String? overlayText;
  final List<String>? _overlayVideos;
  @override
  List<String>? get overlayVideos {
    final value = _overlayVideos;
    if (value == null) return null;
    if (_overlayVideos is EqualUnmodifiableListView) return _overlayVideos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _overlays;
  @override
  List<dynamic>? get overlays {
    final value = _overlays;
    if (value == null) return null;
    if (_overlays is EqualUnmodifiableListView) return _overlays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Music? music;

  @override
  String toString() {
    return 'Update(updateId: $updateId, user: $user, media: $media, mediaType: $mediaType, caption: $caption, viewers: $viewers, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, bgColor: $bgColor, backgroundColor: $backgroundColor, viewCount: $viewCount, id: $id, hasViewed: $hasViewed, overlayText: $overlayText, overlayVideos: $overlayVideos, overlays: $overlays, music: $music)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateImpl &&
            (identical(other.updateId, updateId) ||
                other.updateId == updateId) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.media, media) || other.media == media) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            const DeepCollectionEquality().equals(other._viewers, _viewers) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.bgColor, bgColor) || other.bgColor == bgColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hasViewed, hasViewed) ||
                other.hasViewed == hasViewed) &&
            (identical(other.overlayText, overlayText) ||
                other.overlayText == overlayText) &&
            const DeepCollectionEquality()
                .equals(other._overlayVideos, _overlayVideos) &&
            const DeepCollectionEquality().equals(other._overlays, _overlays) &&
            (identical(other.music, music) || other.music == music));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        updateId,
        user,
        media,
        mediaType,
        caption,
        const DeepCollectionEquality().hash(_viewers),
        expiresAt,
        createdAt,
        updatedAt,
        v,
        bgColor,
        backgroundColor,
        viewCount,
        id,
        hasViewed,
        overlayText,
        const DeepCollectionEquality().hash(_overlayVideos),
        const DeepCollectionEquality().hash(_overlays),
        music
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateImplCopyWith<_$UpdateImpl> get copyWith =>
      __$$UpdateImplCopyWithImpl<_$UpdateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateImplToJson(
      this,
    );
  }
}

abstract class _Update implements Update {
  const factory _Update(
      {@JsonKey(name: "_id") final String? updateId,
      final MyUser? user,
      final String? media,
      final String? mediaType,
      final String? caption,
      final List<StoryViewer>? viewers,
      final DateTime? expiresAt,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      @JsonKey(name: "__v") final int? v,
      final String? bgColor,
      final int? backgroundColor,
      final int? viewCount,
      final String? id,
      final bool? hasViewed,
      final String? overlayText,
      final List<String>? overlayVideos,
      final List<dynamic>? overlays,
      final Music? music}) = _$UpdateImpl;

  factory _Update.fromJson(Map<String, dynamic> json) = _$UpdateImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get updateId;
  @override
  MyUser? get user;
  @override
  String? get media;
  @override
  String? get mediaType;
  @override
  String? get caption;
  @override
  List<StoryViewer>? get viewers;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(name: "__v")
  int? get v;
  @override
  String? get bgColor;
  @override
  int? get backgroundColor;
  @override
  int? get viewCount;
  @override
  String? get id;
  @override
  bool? get hasViewed;
  @override
  String? get overlayText;
  @override
  List<String>? get overlayVideos;
  @override
  List<dynamic>? get overlays;
  @override
  Music? get music;
  @override
  @JsonKey(ignore: true)
  _$$UpdateImplCopyWith<_$UpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoryViewer _$StoryViewerFromJson(Map<String, dynamic> json) {
  return _StoryViewer.fromJson(json);
}

/// @nodoc
mixin _$StoryViewer {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get profilePicture => throw _privateConstructorUsedError;
  DateTime? get viewedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StoryViewerCopyWith<StoryViewer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryViewerCopyWith<$Res> {
  factory $StoryViewerCopyWith(
          StoryViewer value, $Res Function(StoryViewer) then) =
      _$StoryViewerCopyWithImpl<$Res, StoryViewer>;
  @useResult
  $Res call(
      {@JsonKey(name: "_id") String? id,
      String? userId,
      String? username,
      String? profilePicture,
      DateTime? viewedAt});
}

/// @nodoc
class _$StoryViewerCopyWithImpl<$Res, $Val extends StoryViewer>
    implements $StoryViewerCopyWith<$Res> {
  _$StoryViewerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? username = freezed,
    Object? profilePicture = freezed,
    Object? viewedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      viewedAt: freezed == viewedAt
          ? _value.viewedAt
          : viewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoryViewerImplCopyWith<$Res>
    implements $StoryViewerCopyWith<$Res> {
  factory _$$StoryViewerImplCopyWith(
          _$StoryViewerImpl value, $Res Function(_$StoryViewerImpl) then) =
      __$$StoryViewerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "_id") String? id,
      String? userId,
      String? username,
      String? profilePicture,
      DateTime? viewedAt});
}

/// @nodoc
class __$$StoryViewerImplCopyWithImpl<$Res>
    extends _$StoryViewerCopyWithImpl<$Res, _$StoryViewerImpl>
    implements _$$StoryViewerImplCopyWith<$Res> {
  __$$StoryViewerImplCopyWithImpl(
      _$StoryViewerImpl _value, $Res Function(_$StoryViewerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? username = freezed,
    Object? profilePicture = freezed,
    Object? viewedAt = freezed,
  }) {
    return _then(_$StoryViewerImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      viewedAt: freezed == viewedAt
          ? _value.viewedAt
          : viewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryViewerImpl implements _StoryViewer {
  const _$StoryViewerImpl(
      {@JsonKey(name: "_id") this.id,
      this.userId,
      this.username,
      this.profilePicture,
      this.viewedAt});

  factory _$StoryViewerImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryViewerImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  final String? userId;
  @override
  final String? username;
  @override
  final String? profilePicture;
  @override
  final DateTime? viewedAt;

  @override
  String toString() {
    return 'StoryViewer(id: $id, userId: $userId, username: $username, profilePicture: $profilePicture, viewedAt: $viewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryViewerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.viewedAt, viewedAt) ||
                other.viewedAt == viewedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, username, profilePicture, viewedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryViewerImplCopyWith<_$StoryViewerImpl> get copyWith =>
      __$$StoryViewerImplCopyWithImpl<_$StoryViewerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryViewerImplToJson(
      this,
    );
  }
}

abstract class _StoryViewer implements StoryViewer {
  const factory _StoryViewer(
      {@JsonKey(name: "_id") final String? id,
      final String? userId,
      final String? username,
      final String? profilePicture,
      final DateTime? viewedAt}) = _$StoryViewerImpl;

  factory _StoryViewer.fromJson(Map<String, dynamic> json) =
      _$StoryViewerImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  String? get userId;
  @override
  String? get username;
  @override
  String? get profilePicture;
  @override
  DateTime? get viewedAt;
  @override
  @JsonKey(ignore: true)
  _$$StoryViewerImplCopyWith<_$StoryViewerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
