// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_other_info_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetOtherInfoResponseData _$GetOtherInfoResponseDataFromJson(
    Map<String, dynamic> json) {
  return _GetOtherInfoResponseData.fromJson(json);
}

/// @nodoc
mixin _$GetOtherInfoResponseData {
  bool get success =>
      throw _privateConstructorUsedError; //required String message,
  GetOtherInfoResponseDataInner get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetOtherInfoResponseDataCopyWith<GetOtherInfoResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetOtherInfoResponseDataCopyWith<$Res> {
  factory $GetOtherInfoResponseDataCopyWith(GetOtherInfoResponseData value,
          $Res Function(GetOtherInfoResponseData) then) =
      _$GetOtherInfoResponseDataCopyWithImpl<$Res, GetOtherInfoResponseData>;
  @useResult
  $Res call({bool success, GetOtherInfoResponseDataInner data});

  $GetOtherInfoResponseDataInnerCopyWith<$Res> get data;
}

/// @nodoc
class _$GetOtherInfoResponseDataCopyWithImpl<$Res,
        $Val extends GetOtherInfoResponseData>
    implements $GetOtherInfoResponseDataCopyWith<$Res> {
  _$GetOtherInfoResponseDataCopyWithImpl(this._value, this._then);

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
              as GetOtherInfoResponseDataInner,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GetOtherInfoResponseDataInnerCopyWith<$Res> get data {
    return $GetOtherInfoResponseDataInnerCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetOtherInfoResponseDataImplCopyWith<$Res>
    implements $GetOtherInfoResponseDataCopyWith<$Res> {
  factory _$$GetOtherInfoResponseDataImplCopyWith(
          _$GetOtherInfoResponseDataImpl value,
          $Res Function(_$GetOtherInfoResponseDataImpl) then) =
      __$$GetOtherInfoResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, GetOtherInfoResponseDataInner data});

  @override
  $GetOtherInfoResponseDataInnerCopyWith<$Res> get data;
}

/// @nodoc
class __$$GetOtherInfoResponseDataImplCopyWithImpl<$Res>
    extends _$GetOtherInfoResponseDataCopyWithImpl<$Res,
        _$GetOtherInfoResponseDataImpl>
    implements _$$GetOtherInfoResponseDataImplCopyWith<$Res> {
  __$$GetOtherInfoResponseDataImplCopyWithImpl(
      _$GetOtherInfoResponseDataImpl _value,
      $Res Function(_$GetOtherInfoResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$GetOtherInfoResponseDataImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as GetOtherInfoResponseDataInner,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetOtherInfoResponseDataImpl implements _GetOtherInfoResponseData {
  const _$GetOtherInfoResponseDataImpl(
      {required this.success, required this.data});

  factory _$GetOtherInfoResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetOtherInfoResponseDataImplFromJson(json);

  @override
  final bool success;
//required String message,
  @override
  final GetOtherInfoResponseDataInner data;

  @override
  String toString() {
    return 'GetOtherInfoResponseData(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetOtherInfoResponseDataImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetOtherInfoResponseDataImplCopyWith<_$GetOtherInfoResponseDataImpl>
      get copyWith => __$$GetOtherInfoResponseDataImplCopyWithImpl<
          _$GetOtherInfoResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetOtherInfoResponseDataImplToJson(
      this,
    );
  }
}

abstract class _GetOtherInfoResponseData implements GetOtherInfoResponseData {
  const factory _GetOtherInfoResponseData(
          {required final bool success,
          required final GetOtherInfoResponseDataInner data}) =
      _$GetOtherInfoResponseDataImpl;

  factory _GetOtherInfoResponseData.fromJson(Map<String, dynamic> json) =
      _$GetOtherInfoResponseDataImpl.fromJson;

  @override
  bool get success;
  @override //required String message,
  GetOtherInfoResponseDataInner get data;
  @override
  @JsonKey(ignore: true)
  _$$GetOtherInfoResponseDataImplCopyWith<_$GetOtherInfoResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GetOtherInfoResponseDataInner _$GetOtherInfoResponseDataInnerFromJson(
    Map<String, dynamic> json) {
  return _GetOtherInfoResponseDataInner.fromJson(json);
}

/// @nodoc
mixin _$GetOtherInfoResponseDataInner {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String? get profilePicture => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  int get postsCount => throw _privateConstructorUsedError;
  int get followersCount => throw _privateConstructorUsedError;
  int get followingCount => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  bool get followsYou => throw _privateConstructorUsedError;
  String? get instagram => throw _privateConstructorUsedError;
  String? get youtube => throw _privateConstructorUsedError;
  String? get link => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetOtherInfoResponseDataInnerCopyWith<GetOtherInfoResponseDataInner>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetOtherInfoResponseDataInnerCopyWith<$Res> {
  factory $GetOtherInfoResponseDataInnerCopyWith(
          GetOtherInfoResponseDataInner value,
          $Res Function(GetOtherInfoResponseDataInner) then) =
      _$GetOtherInfoResponseDataInnerCopyWithImpl<$Res,
          GetOtherInfoResponseDataInner>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String? profilePicture,
      String? username,
      int postsCount,
      int followersCount,
      int followingCount,
      bool isFollowing,
      bool followsYou,
      String? instagram,
      String? youtube,
      String? link});
}

/// @nodoc
class _$GetOtherInfoResponseDataInnerCopyWithImpl<$Res,
        $Val extends GetOtherInfoResponseDataInner>
    implements $GetOtherInfoResponseDataInnerCopyWith<$Res> {
  _$GetOtherInfoResponseDataInnerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = freezed,
    Object? username = freezed,
    Object? postsCount = null,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? isFollowing = null,
    Object? followsYou = null,
    Object? instagram = freezed,
    Object? youtube = freezed,
    Object? link = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      postsCount: null == postsCount
          ? _value.postsCount
          : postsCount // ignore: cast_nullable_to_non_nullable
              as int,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      followsYou: null == followsYou
          ? _value.followsYou
          : followsYou // ignore: cast_nullable_to_non_nullable
              as bool,
      instagram: freezed == instagram
          ? _value.instagram
          : instagram // ignore: cast_nullable_to_non_nullable
              as String?,
      youtube: freezed == youtube
          ? _value.youtube
          : youtube // ignore: cast_nullable_to_non_nullable
              as String?,
      link: freezed == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetOtherInfoResponseDataInnerImplCopyWith<$Res>
    implements $GetOtherInfoResponseDataInnerCopyWith<$Res> {
  factory _$$GetOtherInfoResponseDataInnerImplCopyWith(
          _$GetOtherInfoResponseDataInnerImpl value,
          $Res Function(_$GetOtherInfoResponseDataInnerImpl) then) =
      __$$GetOtherInfoResponseDataInnerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String? profilePicture,
      String? username,
      int postsCount,
      int followersCount,
      int followingCount,
      bool isFollowing,
      bool followsYou,
      String? instagram,
      String? youtube,
      String? link});
}

/// @nodoc
class __$$GetOtherInfoResponseDataInnerImplCopyWithImpl<$Res>
    extends _$GetOtherInfoResponseDataInnerCopyWithImpl<$Res,
        _$GetOtherInfoResponseDataInnerImpl>
    implements _$$GetOtherInfoResponseDataInnerImplCopyWith<$Res> {
  __$$GetOtherInfoResponseDataInnerImplCopyWithImpl(
      _$GetOtherInfoResponseDataInnerImpl _value,
      $Res Function(_$GetOtherInfoResponseDataInnerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = freezed,
    Object? username = freezed,
    Object? postsCount = null,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? isFollowing = null,
    Object? followsYou = null,
    Object? instagram = freezed,
    Object? youtube = freezed,
    Object? link = freezed,
  }) {
    return _then(_$GetOtherInfoResponseDataInnerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      postsCount: null == postsCount
          ? _value.postsCount
          : postsCount // ignore: cast_nullable_to_non_nullable
              as int,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      followsYou: null == followsYou
          ? _value.followsYou
          : followsYou // ignore: cast_nullable_to_non_nullable
              as bool,
      instagram: freezed == instagram
          ? _value.instagram
          : instagram // ignore: cast_nullable_to_non_nullable
              as String?,
      youtube: freezed == youtube
          ? _value.youtube
          : youtube // ignore: cast_nullable_to_non_nullable
              as String?,
      link: freezed == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetOtherInfoResponseDataInnerImpl
    implements _GetOtherInfoResponseDataInner {
  const _$GetOtherInfoResponseDataInnerImpl(
      {@JsonKey(name: '_id') required this.id,
      this.profilePicture,
      this.username,
      required this.postsCount,
      required this.followersCount,
      required this.followingCount,
      required this.isFollowing,
      required this.followsYou,
      this.instagram,
      this.youtube,
      this.link});

  factory _$GetOtherInfoResponseDataInnerImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$GetOtherInfoResponseDataInnerImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String? profilePicture;
  @override
  final String? username;
  @override
  final int postsCount;
  @override
  final int followersCount;
  @override
  final int followingCount;
  @override
  final bool isFollowing;
  @override
  final bool followsYou;
  @override
  final String? instagram;
  @override
  final String? youtube;
  @override
  final String? link;

  @override
  String toString() {
    return 'GetOtherInfoResponseDataInner(id: $id, profilePicture: $profilePicture, username: $username, postsCount: $postsCount, followersCount: $followersCount, followingCount: $followingCount, isFollowing: $isFollowing, followsYou: $followsYou, instagram: $instagram, youtube: $youtube, link: $link)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetOtherInfoResponseDataInnerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.postsCount, postsCount) ||
                other.postsCount == postsCount) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.followsYou, followsYou) ||
                other.followsYou == followsYou) &&
            (identical(other.instagram, instagram) ||
                other.instagram == instagram) &&
            (identical(other.youtube, youtube) || other.youtube == youtube) &&
            (identical(other.link, link) || other.link == link));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      profilePicture,
      username,
      postsCount,
      followersCount,
      followingCount,
      isFollowing,
      followsYou,
      instagram,
      youtube,
      link);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetOtherInfoResponseDataInnerImplCopyWith<
          _$GetOtherInfoResponseDataInnerImpl>
      get copyWith => __$$GetOtherInfoResponseDataInnerImplCopyWithImpl<
          _$GetOtherInfoResponseDataInnerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetOtherInfoResponseDataInnerImplToJson(
      this,
    );
  }
}

abstract class _GetOtherInfoResponseDataInner
    implements GetOtherInfoResponseDataInner {
  const factory _GetOtherInfoResponseDataInner(
      {@JsonKey(name: '_id') required final String id,
      final String? profilePicture,
      final String? username,
      required final int postsCount,
      required final int followersCount,
      required final int followingCount,
      required final bool isFollowing,
      required final bool followsYou,
      final String? instagram,
      final String? youtube,
      final String? link}) = _$GetOtherInfoResponseDataInnerImpl;

  factory _GetOtherInfoResponseDataInner.fromJson(Map<String, dynamic> json) =
      _$GetOtherInfoResponseDataInnerImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String? get profilePicture;
  @override
  String? get username;
  @override
  int get postsCount;
  @override
  int get followersCount;
  @override
  int get followingCount;
  @override
  bool get isFollowing;
  @override
  bool get followsYou;
  @override
  String? get instagram;
  @override
  String? get youtube;
  @override
  String? get link;
  @override
  @JsonKey(ignore: true)
  _$$GetOtherInfoResponseDataInnerImplCopyWith<
          _$GetOtherInfoResponseDataInnerImpl>
      get copyWith => throw _privateConstructorUsedError;
}
