// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedUser _$FeedUserFromJson(Map<String, dynamic> json) {
  return _FeedUser.fromJson(json);
}

/// @nodoc
mixin _$FeedUser {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedUserCopyWith<FeedUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedUserCopyWith<$Res> {
  factory $FeedUserCopyWith(FeedUser value, $Res Function(FeedUser) then) =
      _$FeedUserCopyWithImpl<$Res, FeedUser>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String profilePicture,
      String username});
}

/// @nodoc
class _$FeedUserCopyWithImpl<$Res, $Val extends FeedUser>
    implements $FeedUserCopyWith<$Res> {
  _$FeedUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = null,
    Object? username = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedUserImplCopyWith<$Res>
    implements $FeedUserCopyWith<$Res> {
  factory _$$FeedUserImplCopyWith(
          _$FeedUserImpl value, $Res Function(_$FeedUserImpl) then) =
      __$$FeedUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String profilePicture,
      String username});
}

/// @nodoc
class __$$FeedUserImplCopyWithImpl<$Res>
    extends _$FeedUserCopyWithImpl<$Res, _$FeedUserImpl>
    implements _$$FeedUserImplCopyWith<$Res> {
  __$$FeedUserImplCopyWithImpl(
      _$FeedUserImpl _value, $Res Function(_$FeedUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = null,
    Object? username = null,
  }) {
    return _then(_$FeedUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedUserImpl implements _FeedUser {
  const _$FeedUserImpl(
      {@JsonKey(name: '_id') required this.id,
      this.profilePicture = '',
      this.username = ''});

  factory _$FeedUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedUserImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  @JsonKey()
  final String profilePicture;
  @override
  @JsonKey()
  final String username;

  @override
  String toString() {
    return 'FeedUser(id: $id, profilePicture: $profilePicture, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, profilePicture, username);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedUserImplCopyWith<_$FeedUserImpl> get copyWith =>
      __$$FeedUserImplCopyWithImpl<_$FeedUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedUserImplToJson(
      this,
    );
  }
}

abstract class _FeedUser implements FeedUser {
  const factory _FeedUser(
      {@JsonKey(name: '_id') required final String id,
      final String profilePicture,
      final String username}) = _$FeedUserImpl;

  factory _FeedUser.fromJson(Map<String, dynamic> json) =
      _$FeedUserImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get profilePicture;
  @override
  String get username;
  @override
  @JsonKey(ignore: true)
  _$$FeedUserImplCopyWith<_$FeedUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
