// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShareResponseData _$ShareResponseDataFromJson(Map<String, dynamic> json) {
  return _ShareResponseData.fromJson(json);
}

/// @nodoc
mixin _$ShareResponseData {
  @JsonKey(name: 'success')
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(name: 'message')
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'data')
  ShareData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShareResponseDataCopyWith<ShareResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareResponseDataCopyWith<$Res> {
  factory $ShareResponseDataCopyWith(
          ShareResponseData value, $Res Function(ShareResponseData) then) =
      _$ShareResponseDataCopyWithImpl<$Res, ShareResponseData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'success') bool success,
      @JsonKey(name: 'message') String message,
      @JsonKey(name: 'data') ShareData data});

  $ShareDataCopyWith<$Res> get data;
}

/// @nodoc
class _$ShareResponseDataCopyWithImpl<$Res, $Val extends ShareResponseData>
    implements $ShareResponseDataCopyWith<$Res> {
  _$ShareResponseDataCopyWithImpl(this._value, this._then);

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
              as ShareData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ShareDataCopyWith<$Res> get data {
    return $ShareDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ShareResponseDataImplCopyWith<$Res>
    implements $ShareResponseDataCopyWith<$Res> {
  factory _$$ShareResponseDataImplCopyWith(_$ShareResponseDataImpl value,
          $Res Function(_$ShareResponseDataImpl) then) =
      __$$ShareResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'success') bool success,
      @JsonKey(name: 'message') String message,
      @JsonKey(name: 'data') ShareData data});

  @override
  $ShareDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$ShareResponseDataImplCopyWithImpl<$Res>
    extends _$ShareResponseDataCopyWithImpl<$Res, _$ShareResponseDataImpl>
    implements _$$ShareResponseDataImplCopyWith<$Res> {
  __$$ShareResponseDataImplCopyWithImpl(_$ShareResponseDataImpl _value,
      $Res Function(_$ShareResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$ShareResponseDataImpl(
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
              as ShareData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareResponseDataImpl implements _ShareResponseData {
  const _$ShareResponseDataImpl(
      {@JsonKey(name: 'success') required this.success,
      @JsonKey(name: 'message') required this.message,
      @JsonKey(name: 'data') required this.data});

  factory _$ShareResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareResponseDataImplFromJson(json);

  @override
  @JsonKey(name: 'success')
  final bool success;
  @override
  @JsonKey(name: 'message')
  final String message;
  @override
  @JsonKey(name: 'data')
  final ShareData data;

  @override
  String toString() {
    return 'ShareResponseData(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareResponseDataImpl &&
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
  _$$ShareResponseDataImplCopyWith<_$ShareResponseDataImpl> get copyWith =>
      __$$ShareResponseDataImplCopyWithImpl<_$ShareResponseDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareResponseDataImplToJson(
      this,
    );
  }
}

abstract class _ShareResponseData implements ShareResponseData {
  const factory _ShareResponseData(
          {@JsonKey(name: 'success') required final bool success,
          @JsonKey(name: 'message') required final String message,
          @JsonKey(name: 'data') required final ShareData data}) =
      _$ShareResponseDataImpl;

  factory _ShareResponseData.fromJson(Map<String, dynamic> json) =
      _$ShareResponseDataImpl.fromJson;

  @override
  @JsonKey(name: 'success')
  bool get success;
  @override
  @JsonKey(name: 'message')
  String get message;
  @override
  @JsonKey(name: 'data')
  ShareData get data;
  @override
  @JsonKey(ignore: true)
  _$$ShareResponseDataImplCopyWith<_$ShareResponseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareData _$ShareDataFromJson(Map<String, dynamic> json) {
  return _ShareData.fromJson(json);
}

/// @nodoc
mixin _$ShareData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user')
  String get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'content')
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'media')
  List<String> get media => throw _privateConstructorUsedError;
  @JsonKey(name: 'likes')
  List<String> get likes => throw _privateConstructorUsedError;
  @JsonKey(name: 'shares')
  List<String> get shares => throw _privateConstructorUsedError;
  @JsonKey(name: 'sharedFrom')
  dynamic get sharedFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'privacy')
  String get privacy => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updatedAt')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShareDataCopyWith<ShareData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareDataCopyWith<$Res> {
  factory $ShareDataCopyWith(ShareData value, $Res Function(ShareData) then) =
      _$ShareDataCopyWithImpl<$Res, ShareData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      @JsonKey(name: 'user') String user,
      @JsonKey(name: 'content') String content,
      @JsonKey(name: 'media') List<String> media,
      @JsonKey(name: 'likes') List<String> likes,
      @JsonKey(name: 'shares') List<String> shares,
      @JsonKey(name: 'sharedFrom') dynamic sharedFrom,
      @JsonKey(name: 'privacy') String privacy,
      @JsonKey(name: 'createdAt') DateTime createdAt,
      @JsonKey(name: 'updatedAt') DateTime updatedAt,
      @JsonKey(name: '__v') int? v});
}

/// @nodoc
class _$ShareDataCopyWithImpl<$Res, $Val extends ShareData>
    implements $ShareDataCopyWith<$Res> {
  _$ShareDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? content = null,
    Object? media = null,
    Object? likes = null,
    Object? shares = null,
    Object? sharedFrom = freezed,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      media: null == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as dynamic,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShareDataImplCopyWith<$Res>
    implements $ShareDataCopyWith<$Res> {
  factory _$$ShareDataImplCopyWith(
          _$ShareDataImpl value, $Res Function(_$ShareDataImpl) then) =
      __$$ShareDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      @JsonKey(name: 'user') String user,
      @JsonKey(name: 'content') String content,
      @JsonKey(name: 'media') List<String> media,
      @JsonKey(name: 'likes') List<String> likes,
      @JsonKey(name: 'shares') List<String> shares,
      @JsonKey(name: 'sharedFrom') dynamic sharedFrom,
      @JsonKey(name: 'privacy') String privacy,
      @JsonKey(name: 'createdAt') DateTime createdAt,
      @JsonKey(name: 'updatedAt') DateTime updatedAt,
      @JsonKey(name: '__v') int? v});
}

/// @nodoc
class __$$ShareDataImplCopyWithImpl<$Res>
    extends _$ShareDataCopyWithImpl<$Res, _$ShareDataImpl>
    implements _$$ShareDataImplCopyWith<$Res> {
  __$$ShareDataImplCopyWithImpl(
      _$ShareDataImpl _value, $Res Function(_$ShareDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? content = null,
    Object? media = null,
    Object? likes = null,
    Object? shares = null,
    Object? sharedFrom = freezed,
    Object? privacy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? v = freezed,
  }) {
    return _then(_$ShareDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      media: null == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shares: null == shares
          ? _value._shares
          : shares // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sharedFrom: freezed == sharedFrom
          ? _value.sharedFrom
          : sharedFrom // ignore: cast_nullable_to_non_nullable
              as dynamic,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareDataImpl implements _ShareData {
  const _$ShareDataImpl(
      {@JsonKey(name: '_id') required this.id,
      @JsonKey(name: 'user') required this.user,
      @JsonKey(name: 'content') required this.content,
      @JsonKey(name: 'media') required final List<String> media,
      @JsonKey(name: 'likes') required final List<String> likes,
      @JsonKey(name: 'shares') required final List<String> shares,
      @JsonKey(name: 'sharedFrom') this.sharedFrom,
      @JsonKey(name: 'privacy') required this.privacy,
      @JsonKey(name: 'createdAt') required this.createdAt,
      @JsonKey(name: 'updatedAt') required this.updatedAt,
      @JsonKey(name: '__v') this.v})
      : _media = media,
        _likes = likes,
        _shares = shares;

  factory _$ShareDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  @JsonKey(name: 'user')
  final String user;
  @override
  @JsonKey(name: 'content')
  final String content;
  final List<String> _media;
  @override
  @JsonKey(name: 'media')
  List<String> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  final List<String> _likes;
  @override
  @JsonKey(name: 'likes')
  List<String> get likes {
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likes);
  }

  final List<String> _shares;
  @override
  @JsonKey(name: 'shares')
  List<String> get shares {
    if (_shares is EqualUnmodifiableListView) return _shares;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shares);
  }

  @override
  @JsonKey(name: 'sharedFrom')
  final dynamic sharedFrom;
  @override
  @JsonKey(name: 'privacy')
  final String privacy;
  @override
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;

  @override
  String toString() {
    return 'ShareData(id: $id, user: $user, content: $content, media: $media, likes: $likes, shares: $shares, sharedFrom: $sharedFrom, privacy: $privacy, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._shares, _shares) &&
            const DeepCollectionEquality()
                .equals(other.sharedFrom, sharedFrom) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      content,
      const DeepCollectionEquality().hash(_media),
      const DeepCollectionEquality().hash(_likes),
      const DeepCollectionEquality().hash(_shares),
      const DeepCollectionEquality().hash(sharedFrom),
      privacy,
      createdAt,
      updatedAt,
      v);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareDataImplCopyWith<_$ShareDataImpl> get copyWith =>
      __$$ShareDataImplCopyWithImpl<_$ShareDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareDataImplToJson(
      this,
    );
  }
}

abstract class _ShareData implements ShareData {
  const factory _ShareData(
      {@JsonKey(name: '_id') required final String id,
      @JsonKey(name: 'user') required final String user,
      @JsonKey(name: 'content') required final String content,
      @JsonKey(name: 'media') required final List<String> media,
      @JsonKey(name: 'likes') required final List<String> likes,
      @JsonKey(name: 'shares') required final List<String> shares,
      @JsonKey(name: 'sharedFrom') final dynamic sharedFrom,
      @JsonKey(name: 'privacy') required final String privacy,
      @JsonKey(name: 'createdAt') required final DateTime createdAt,
      @JsonKey(name: 'updatedAt') required final DateTime updatedAt,
      @JsonKey(name: '__v') final int? v}) = _$ShareDataImpl;

  factory _ShareData.fromJson(Map<String, dynamic> json) =
      _$ShareDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  @JsonKey(name: 'user')
  String get user;
  @override
  @JsonKey(name: 'content')
  String get content;
  @override
  @JsonKey(name: 'media')
  List<String> get media;
  @override
  @JsonKey(name: 'likes')
  List<String> get likes;
  @override
  @JsonKey(name: 'shares')
  List<String> get shares;
  @override
  @JsonKey(name: 'sharedFrom')
  dynamic get sharedFrom;
  @override
  @JsonKey(name: 'privacy')
  String get privacy;
  @override
  @JsonKey(name: 'createdAt')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updatedAt')
  DateTime get updatedAt;
  @override
  @JsonKey(name: '__v')
  int? get v;
  @override
  @JsonKey(ignore: true)
  _$$ShareDataImplCopyWith<_$ShareDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
