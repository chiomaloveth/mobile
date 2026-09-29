// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_list_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FollowUserInfo _$FollowUserInfoFromJson(Map<String, dynamic> json) {
  return _FollowUserInfo.fromJson(json);
}

/// @nodoc
mixin _$FollowUserInfo {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowUserInfoCopyWith<FollowUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowUserInfoCopyWith<$Res> {
  factory $FollowUserInfoCopyWith(
          FollowUserInfo value, $Res Function(FollowUserInfo) then) =
      _$FollowUserInfoCopyWithImpl<$Res, FollowUserInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String username,
      String profilePicture});
}

/// @nodoc
class _$FollowUserInfoCopyWithImpl<$Res, $Val extends FollowUserInfo>
    implements $FollowUserInfoCopyWith<$Res> {
  _$FollowUserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? profilePicture = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FollowUserInfoImplCopyWith<$Res>
    implements $FollowUserInfoCopyWith<$Res> {
  factory _$$FollowUserInfoImplCopyWith(_$FollowUserInfoImpl value,
          $Res Function(_$FollowUserInfoImpl) then) =
      __$$FollowUserInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String username,
      String profilePicture});
}

/// @nodoc
class __$$FollowUserInfoImplCopyWithImpl<$Res>
    extends _$FollowUserInfoCopyWithImpl<$Res, _$FollowUserInfoImpl>
    implements _$$FollowUserInfoImplCopyWith<$Res> {
  __$$FollowUserInfoImplCopyWithImpl(
      _$FollowUserInfoImpl _value, $Res Function(_$FollowUserInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? profilePicture = null,
  }) {
    return _then(_$FollowUserInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowUserInfoImpl implements _FollowUserInfo {
  const _$FollowUserInfoImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.username,
      this.profilePicture = ''});

  factory _$FollowUserInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowUserInfoImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String username;
  @override
  @JsonKey()
  final String profilePicture;

  @override
  String toString() {
    return 'FollowUserInfo(id: $id, username: $username, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowUserInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, username, profilePicture);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowUserInfoImplCopyWith<_$FollowUserInfoImpl> get copyWith =>
      __$$FollowUserInfoImplCopyWithImpl<_$FollowUserInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowUserInfoImplToJson(
      this,
    );
  }
}

abstract class _FollowUserInfo implements FollowUserInfo {
  const factory _FollowUserInfo(
      {@JsonKey(name: '_id') required final String id,
      required final String username,
      final String profilePicture}) = _$FollowUserInfoImpl;

  factory _FollowUserInfo.fromJson(Map<String, dynamic> json) =
      _$FollowUserInfoImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get username;
  @override
  String get profilePicture;
  @override
  @JsonKey(ignore: true)
  _$$FollowUserInfoImplCopyWith<_$FollowUserInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowerItem _$FollowerItemFromJson(Map<String, dynamic> json) {
  return _FollowerItem.fromJson(json);
}

/// @nodoc
mixin _$FollowerItem {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  FollowUserInfo get follower => throw _privateConstructorUsedError;
  String get following => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowerItemCopyWith<FollowerItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowerItemCopyWith<$Res> {
  factory $FollowerItemCopyWith(
          FollowerItem value, $Res Function(FollowerItem) then) =
      _$FollowerItemCopyWithImpl<$Res, FollowerItem>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      FollowUserInfo follower,
      String following,
      DateTime createdAt,
      DateTime updatedAt});

  $FollowUserInfoCopyWith<$Res> get follower;
}

/// @nodoc
class _$FollowerItemCopyWithImpl<$Res, $Val extends FollowerItem>
    implements $FollowerItemCopyWith<$Res> {
  _$FollowerItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? follower = null,
    Object? following = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      follower: null == follower
          ? _value.follower
          : follower // ignore: cast_nullable_to_non_nullable
              as FollowUserInfo,
      following: null == following
          ? _value.following
          : following // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FollowUserInfoCopyWith<$Res> get follower {
    return $FollowUserInfoCopyWith<$Res>(_value.follower, (value) {
      return _then(_value.copyWith(follower: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FollowerItemImplCopyWith<$Res>
    implements $FollowerItemCopyWith<$Res> {
  factory _$$FollowerItemImplCopyWith(
          _$FollowerItemImpl value, $Res Function(_$FollowerItemImpl) then) =
      __$$FollowerItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      FollowUserInfo follower,
      String following,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $FollowUserInfoCopyWith<$Res> get follower;
}

/// @nodoc
class __$$FollowerItemImplCopyWithImpl<$Res>
    extends _$FollowerItemCopyWithImpl<$Res, _$FollowerItemImpl>
    implements _$$FollowerItemImplCopyWith<$Res> {
  __$$FollowerItemImplCopyWithImpl(
      _$FollowerItemImpl _value, $Res Function(_$FollowerItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? follower = null,
    Object? following = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$FollowerItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      follower: null == follower
          ? _value.follower
          : follower // ignore: cast_nullable_to_non_nullable
              as FollowUserInfo,
      following: null == following
          ? _value.following
          : following // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowerItemImpl implements _FollowerItem {
  const _$FollowerItemImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.follower,
      required this.following,
      required this.createdAt,
      required this.updatedAt});

  factory _$FollowerItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowerItemImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final FollowUserInfo follower;
  @override
  final String following;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FollowerItem(id: $id, follower: $follower, following: $following, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowerItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.follower, follower) ||
                other.follower == follower) &&
            (identical(other.following, following) ||
                other.following == following) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, follower, following, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowerItemImplCopyWith<_$FollowerItemImpl> get copyWith =>
      __$$FollowerItemImplCopyWithImpl<_$FollowerItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowerItemImplToJson(
      this,
    );
  }
}

abstract class _FollowerItem implements FollowerItem {
  const factory _FollowerItem(
      {@JsonKey(name: '_id') required final String id,
      required final FollowUserInfo follower,
      required final String following,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$FollowerItemImpl;

  factory _FollowerItem.fromJson(Map<String, dynamic> json) =
      _$FollowerItemImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  FollowUserInfo get follower;
  @override
  String get following;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FollowerItemImplCopyWith<_$FollowerItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetFollowersResponse _$GetFollowersResponseFromJson(Map<String, dynamic> json) {
  return _GetFollowersResponse.fromJson(json);
}

/// @nodoc
mixin _$GetFollowersResponse {
  bool get success => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<FollowerItem> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetFollowersResponseCopyWith<GetFollowersResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetFollowersResponseCopyWith<$Res> {
  factory $GetFollowersResponseCopyWith(GetFollowersResponse value,
          $Res Function(GetFollowersResponse) then) =
      _$GetFollowersResponseCopyWithImpl<$Res, GetFollowersResponse>;
  @useResult
  $Res call({bool success, int count, List<FollowerItem> data});
}

/// @nodoc
class _$GetFollowersResponseCopyWithImpl<$Res,
        $Val extends GetFollowersResponse>
    implements $GetFollowersResponseCopyWith<$Res> {
  _$GetFollowersResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<FollowerItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetFollowersResponseImplCopyWith<$Res>
    implements $GetFollowersResponseCopyWith<$Res> {
  factory _$$GetFollowersResponseImplCopyWith(_$GetFollowersResponseImpl value,
          $Res Function(_$GetFollowersResponseImpl) then) =
      __$$GetFollowersResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, int count, List<FollowerItem> data});
}

/// @nodoc
class __$$GetFollowersResponseImplCopyWithImpl<$Res>
    extends _$GetFollowersResponseCopyWithImpl<$Res, _$GetFollowersResponseImpl>
    implements _$$GetFollowersResponseImplCopyWith<$Res> {
  __$$GetFollowersResponseImplCopyWithImpl(_$GetFollowersResponseImpl _value,
      $Res Function(_$GetFollowersResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_$GetFollowersResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<FollowerItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetFollowersResponseImpl implements _GetFollowersResponse {
  const _$GetFollowersResponseImpl(
      {required this.success,
      required this.count,
      required final List<FollowerItem> data})
      : _data = data;

  factory _$GetFollowersResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetFollowersResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final int count;
  final List<FollowerItem> _data;
  @override
  List<FollowerItem> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetFollowersResponse(success: $success, count: $count, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetFollowersResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, count, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetFollowersResponseImplCopyWith<_$GetFollowersResponseImpl>
      get copyWith =>
          __$$GetFollowersResponseImplCopyWithImpl<_$GetFollowersResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetFollowersResponseImplToJson(
      this,
    );
  }
}

abstract class _GetFollowersResponse implements GetFollowersResponse {
  const factory _GetFollowersResponse(
      {required final bool success,
      required final int count,
      required final List<FollowerItem> data}) = _$GetFollowersResponseImpl;

  factory _GetFollowersResponse.fromJson(Map<String, dynamic> json) =
      _$GetFollowersResponseImpl.fromJson;

  @override
  bool get success;
  @override
  int get count;
  @override
  List<FollowerItem> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetFollowersResponseImplCopyWith<_$GetFollowersResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FollowingItem _$FollowingItemFromJson(Map<String, dynamic> json) {
  return _FollowingItem.fromJson(json);
}

/// @nodoc
mixin _$FollowingItem {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get follower => throw _privateConstructorUsedError;
  FollowingUserInfo get following => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowingItemCopyWith<FollowingItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowingItemCopyWith<$Res> {
  factory $FollowingItemCopyWith(
          FollowingItem value, $Res Function(FollowingItem) then) =
      _$FollowingItemCopyWithImpl<$Res, FollowingItem>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String follower,
      FollowingUserInfo following,
      DateTime createdAt,
      DateTime updatedAt});

  $FollowingUserInfoCopyWith<$Res> get following;
}

/// @nodoc
class _$FollowingItemCopyWithImpl<$Res, $Val extends FollowingItem>
    implements $FollowingItemCopyWith<$Res> {
  _$FollowingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? follower = null,
    Object? following = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      follower: null == follower
          ? _value.follower
          : follower // ignore: cast_nullable_to_non_nullable
              as String,
      following: null == following
          ? _value.following
          : following // ignore: cast_nullable_to_non_nullable
              as FollowingUserInfo,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FollowingUserInfoCopyWith<$Res> get following {
    return $FollowingUserInfoCopyWith<$Res>(_value.following, (value) {
      return _then(_value.copyWith(following: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FollowingItemImplCopyWith<$Res>
    implements $FollowingItemCopyWith<$Res> {
  factory _$$FollowingItemImplCopyWith(
          _$FollowingItemImpl value, $Res Function(_$FollowingItemImpl) then) =
      __$$FollowingItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String follower,
      FollowingUserInfo following,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $FollowingUserInfoCopyWith<$Res> get following;
}

/// @nodoc
class __$$FollowingItemImplCopyWithImpl<$Res>
    extends _$FollowingItemCopyWithImpl<$Res, _$FollowingItemImpl>
    implements _$$FollowingItemImplCopyWith<$Res> {
  __$$FollowingItemImplCopyWithImpl(
      _$FollowingItemImpl _value, $Res Function(_$FollowingItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? follower = null,
    Object? following = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$FollowingItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      follower: null == follower
          ? _value.follower
          : follower // ignore: cast_nullable_to_non_nullable
              as String,
      following: null == following
          ? _value.following
          : following // ignore: cast_nullable_to_non_nullable
              as FollowingUserInfo,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowingItemImpl implements _FollowingItem {
  const _$FollowingItemImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.follower,
      required this.following,
      required this.createdAt,
      required this.updatedAt});

  factory _$FollowingItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowingItemImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String follower;
  @override
  final FollowingUserInfo following;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FollowingItem(id: $id, follower: $follower, following: $following, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowingItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.follower, follower) ||
                other.follower == follower) &&
            (identical(other.following, following) ||
                other.following == following) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, follower, following, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowingItemImplCopyWith<_$FollowingItemImpl> get copyWith =>
      __$$FollowingItemImplCopyWithImpl<_$FollowingItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowingItemImplToJson(
      this,
    );
  }
}

abstract class _FollowingItem implements FollowingItem {
  const factory _FollowingItem(
      {@JsonKey(name: '_id') required final String id,
      required final String follower,
      required final FollowingUserInfo following,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$FollowingItemImpl;

  factory _FollowingItem.fromJson(Map<String, dynamic> json) =
      _$FollowingItemImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get follower;
  @override
  FollowingUserInfo get following;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FollowingItemImplCopyWith<_$FollowingItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowingUserInfo _$FollowingUserInfoFromJson(Map<String, dynamic> json) {
  return _FollowingUserInfo.fromJson(json);
}

/// @nodoc
mixin _$FollowingUserInfo {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowingUserInfoCopyWith<FollowingUserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowingUserInfoCopyWith<$Res> {
  factory $FollowingUserInfoCopyWith(
          FollowingUserInfo value, $Res Function(FollowingUserInfo) then) =
      _$FollowingUserInfoCopyWithImpl<$Res, FollowingUserInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String username,
      String profilePicture});
}

/// @nodoc
class _$FollowingUserInfoCopyWithImpl<$Res, $Val extends FollowingUserInfo>
    implements $FollowingUserInfoCopyWith<$Res> {
  _$FollowingUserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? profilePicture = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FollowingUserInfoImplCopyWith<$Res>
    implements $FollowingUserInfoCopyWith<$Res> {
  factory _$$FollowingUserInfoImplCopyWith(_$FollowingUserInfoImpl value,
          $Res Function(_$FollowingUserInfoImpl) then) =
      __$$FollowingUserInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String username,
      String profilePicture});
}

/// @nodoc
class __$$FollowingUserInfoImplCopyWithImpl<$Res>
    extends _$FollowingUserInfoCopyWithImpl<$Res, _$FollowingUserInfoImpl>
    implements _$$FollowingUserInfoImplCopyWith<$Res> {
  __$$FollowingUserInfoImplCopyWithImpl(_$FollowingUserInfoImpl _value,
      $Res Function(_$FollowingUserInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? profilePicture = null,
  }) {
    return _then(_$FollowingUserInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowingUserInfoImpl implements _FollowingUserInfo {
  const _$FollowingUserInfoImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.username,
      this.profilePicture = ''});

  factory _$FollowingUserInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowingUserInfoImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String username;
  @override
  @JsonKey()
  final String profilePicture;

  @override
  String toString() {
    return 'FollowingUserInfo(id: $id, username: $username, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowingUserInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, username, profilePicture);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowingUserInfoImplCopyWith<_$FollowingUserInfoImpl> get copyWith =>
      __$$FollowingUserInfoImplCopyWithImpl<_$FollowingUserInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowingUserInfoImplToJson(
      this,
    );
  }
}

abstract class _FollowingUserInfo implements FollowingUserInfo {
  const factory _FollowingUserInfo(
      {@JsonKey(name: '_id') required final String id,
      required final String username,
      final String profilePicture}) = _$FollowingUserInfoImpl;

  factory _FollowingUserInfo.fromJson(Map<String, dynamic> json) =
      _$FollowingUserInfoImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get username;
  @override
  String get profilePicture;
  @override
  @JsonKey(ignore: true)
  _$$FollowingUserInfoImplCopyWith<_$FollowingUserInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetFollowingResponse _$GetFollowingResponseFromJson(Map<String, dynamic> json) {
  return _GetFollowingResponse.fromJson(json);
}

/// @nodoc
mixin _$GetFollowingResponse {
  bool get success => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<FollowingItem> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetFollowingResponseCopyWith<GetFollowingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetFollowingResponseCopyWith<$Res> {
  factory $GetFollowingResponseCopyWith(GetFollowingResponse value,
          $Res Function(GetFollowingResponse) then) =
      _$GetFollowingResponseCopyWithImpl<$Res, GetFollowingResponse>;
  @useResult
  $Res call({bool success, int count, List<FollowingItem> data});
}

/// @nodoc
class _$GetFollowingResponseCopyWithImpl<$Res,
        $Val extends GetFollowingResponse>
    implements $GetFollowingResponseCopyWith<$Res> {
  _$GetFollowingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<FollowingItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetFollowingResponseImplCopyWith<$Res>
    implements $GetFollowingResponseCopyWith<$Res> {
  factory _$$GetFollowingResponseImplCopyWith(_$GetFollowingResponseImpl value,
          $Res Function(_$GetFollowingResponseImpl) then) =
      __$$GetFollowingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, int count, List<FollowingItem> data});
}

/// @nodoc
class __$$GetFollowingResponseImplCopyWithImpl<$Res>
    extends _$GetFollowingResponseCopyWithImpl<$Res, _$GetFollowingResponseImpl>
    implements _$$GetFollowingResponseImplCopyWith<$Res> {
  __$$GetFollowingResponseImplCopyWithImpl(_$GetFollowingResponseImpl _value,
      $Res Function(_$GetFollowingResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_$GetFollowingResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<FollowingItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetFollowingResponseImpl implements _GetFollowingResponse {
  const _$GetFollowingResponseImpl(
      {required this.success,
      required this.count,
      required final List<FollowingItem> data})
      : _data = data;

  factory _$GetFollowingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetFollowingResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final int count;
  final List<FollowingItem> _data;
  @override
  List<FollowingItem> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetFollowingResponse(success: $success, count: $count, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetFollowingResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, count, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetFollowingResponseImplCopyWith<_$GetFollowingResponseImpl>
      get copyWith =>
          __$$GetFollowingResponseImplCopyWithImpl<_$GetFollowingResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetFollowingResponseImplToJson(
      this,
    );
  }
}

abstract class _GetFollowingResponse implements GetFollowingResponse {
  const factory _GetFollowingResponse(
      {required final bool success,
      required final int count,
      required final List<FollowingItem> data}) = _$GetFollowingResponseImpl;

  factory _GetFollowingResponse.fromJson(Map<String, dynamic> json) =
      _$GetFollowingResponseImpl.fromJson;

  @override
  bool get success;
  @override
  int get count;
  @override
  List<FollowingItem> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetFollowingResponseImplCopyWith<_$GetFollowingResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
