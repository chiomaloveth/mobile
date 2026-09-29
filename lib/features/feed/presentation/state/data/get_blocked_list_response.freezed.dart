// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_blocked_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetBlockedListResponse _$GetBlockedListResponseFromJson(
    Map<String, dynamic> json) {
  return _GetBlockedListResponse.fromJson(json);
}

/// @nodoc
mixin _$GetBlockedListResponse {
  bool get success => throw _privateConstructorUsedError;
  List<BlockedUserData> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetBlockedListResponseCopyWith<GetBlockedListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetBlockedListResponseCopyWith<$Res> {
  factory $GetBlockedListResponseCopyWith(GetBlockedListResponse value,
          $Res Function(GetBlockedListResponse) then) =
      _$GetBlockedListResponseCopyWithImpl<$Res, GetBlockedListResponse>;
  @useResult
  $Res call({bool success, List<BlockedUserData> data});
}

/// @nodoc
class _$GetBlockedListResponseCopyWithImpl<$Res,
        $Val extends GetBlockedListResponse>
    implements $GetBlockedListResponseCopyWith<$Res> {
  _$GetBlockedListResponseCopyWithImpl(this._value, this._then);

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
              as List<BlockedUserData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetBlockedListResponseImplCopyWith<$Res>
    implements $GetBlockedListResponseCopyWith<$Res> {
  factory _$$GetBlockedListResponseImplCopyWith(
          _$GetBlockedListResponseImpl value,
          $Res Function(_$GetBlockedListResponseImpl) then) =
      __$$GetBlockedListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, List<BlockedUserData> data});
}

/// @nodoc
class __$$GetBlockedListResponseImplCopyWithImpl<$Res>
    extends _$GetBlockedListResponseCopyWithImpl<$Res,
        _$GetBlockedListResponseImpl>
    implements _$$GetBlockedListResponseImplCopyWith<$Res> {
  __$$GetBlockedListResponseImplCopyWithImpl(
      _$GetBlockedListResponseImpl _value,
      $Res Function(_$GetBlockedListResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$GetBlockedListResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<BlockedUserData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetBlockedListResponseImpl implements _GetBlockedListResponse {
  const _$GetBlockedListResponseImpl(
      {required this.success, required final List<BlockedUserData> data})
      : _data = data;

  factory _$GetBlockedListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetBlockedListResponseImplFromJson(json);

  @override
  final bool success;
  final List<BlockedUserData> _data;
  @override
  List<BlockedUserData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetBlockedListResponse(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetBlockedListResponseImpl &&
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
  _$$GetBlockedListResponseImplCopyWith<_$GetBlockedListResponseImpl>
      get copyWith => __$$GetBlockedListResponseImplCopyWithImpl<
          _$GetBlockedListResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetBlockedListResponseImplToJson(
      this,
    );
  }
}

abstract class _GetBlockedListResponse implements GetBlockedListResponse {
  const factory _GetBlockedListResponse(
          {required final bool success,
          required final List<BlockedUserData> data}) =
      _$GetBlockedListResponseImpl;

  factory _GetBlockedListResponse.fromJson(Map<String, dynamic> json) =
      _$GetBlockedListResponseImpl.fromJson;

  @override
  bool get success;
  @override
  List<BlockedUserData> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetBlockedListResponseImplCopyWith<_$GetBlockedListResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BlockedUserData _$BlockedUserDataFromJson(Map<String, dynamic> json) {
  return _BlockedUserData.fromJson(json);
}

/// @nodoc
mixin _$BlockedUserData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BlockedUserDataCopyWith<BlockedUserData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockedUserDataCopyWith<$Res> {
  factory $BlockedUserDataCopyWith(
          BlockedUserData value, $Res Function(BlockedUserData) then) =
      _$BlockedUserDataCopyWithImpl<$Res, BlockedUserData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String phone,
      String profilePicture,
      String? username});
}

/// @nodoc
class _$BlockedUserDataCopyWithImpl<$Res, $Val extends BlockedUserData>
    implements $BlockedUserDataCopyWith<$Res> {
  _$BlockedUserDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? profilePicture = null,
    Object? username = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlockedUserDataImplCopyWith<$Res>
    implements $BlockedUserDataCopyWith<$Res> {
  factory _$$BlockedUserDataImplCopyWith(_$BlockedUserDataImpl value,
          $Res Function(_$BlockedUserDataImpl) then) =
      __$$BlockedUserDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String phone,
      String profilePicture,
      String? username});
}

/// @nodoc
class __$$BlockedUserDataImplCopyWithImpl<$Res>
    extends _$BlockedUserDataCopyWithImpl<$Res, _$BlockedUserDataImpl>
    implements _$$BlockedUserDataImplCopyWith<$Res> {
  __$$BlockedUserDataImplCopyWithImpl(
      _$BlockedUserDataImpl _value, $Res Function(_$BlockedUserDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? profilePicture = null,
    Object? username = freezed,
  }) {
    return _then(_$BlockedUserDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockedUserDataImpl implements _BlockedUserData {
  const _$BlockedUserDataImpl(
      {@JsonKey(name: '_id') required this.id,
      this.phone = '',
      this.profilePicture = '',
      this.username});

  factory _$BlockedUserDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockedUserDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String profilePicture;
  @override
  final String? username;

  @override
  String toString() {
    return 'BlockedUserData(id: $id, phone: $phone, profilePicture: $profilePicture, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockedUserDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, phone, profilePicture, username);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockedUserDataImplCopyWith<_$BlockedUserDataImpl> get copyWith =>
      __$$BlockedUserDataImplCopyWithImpl<_$BlockedUserDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockedUserDataImplToJson(
      this,
    );
  }
}

abstract class _BlockedUserData implements BlockedUserData {
  const factory _BlockedUserData(
      {@JsonKey(name: '_id') required final String id,
      final String phone,
      final String profilePicture,
      final String? username}) = _$BlockedUserDataImpl;

  factory _BlockedUserData.fromJson(Map<String, dynamic> json) =
      _$BlockedUserDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get phone;
  @override
  String get profilePicture;
  @override
  String? get username;
  @override
  @JsonKey(ignore: true)
  _$$BlockedUserDataImplCopyWith<_$BlockedUserDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
