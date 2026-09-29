// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unblock_user_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UnblockUserResponse _$UnblockUserResponseFromJson(Map<String, dynamic> json) {
  return _UnblockUserResponse.fromJson(json);
}

/// @nodoc
mixin _$UnblockUserResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<String> get blockedUsers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UnblockUserResponseCopyWith<UnblockUserResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnblockUserResponseCopyWith<$Res> {
  factory $UnblockUserResponseCopyWith(
          UnblockUserResponse value, $Res Function(UnblockUserResponse) then) =
      _$UnblockUserResponseCopyWithImpl<$Res, UnblockUserResponse>;
  @useResult
  $Res call({bool success, String message, List<String> blockedUsers});
}

/// @nodoc
class _$UnblockUserResponseCopyWithImpl<$Res, $Val extends UnblockUserResponse>
    implements $UnblockUserResponseCopyWith<$Res> {
  _$UnblockUserResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? blockedUsers = null,
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
      blockedUsers: null == blockedUsers
          ? _value.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnblockUserResponseImplCopyWith<$Res>
    implements $UnblockUserResponseCopyWith<$Res> {
  factory _$$UnblockUserResponseImplCopyWith(_$UnblockUserResponseImpl value,
          $Res Function(_$UnblockUserResponseImpl) then) =
      __$$UnblockUserResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, List<String> blockedUsers});
}

/// @nodoc
class __$$UnblockUserResponseImplCopyWithImpl<$Res>
    extends _$UnblockUserResponseCopyWithImpl<$Res, _$UnblockUserResponseImpl>
    implements _$$UnblockUserResponseImplCopyWith<$Res> {
  __$$UnblockUserResponseImplCopyWithImpl(_$UnblockUserResponseImpl _value,
      $Res Function(_$UnblockUserResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? blockedUsers = null,
  }) {
    return _then(_$UnblockUserResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      blockedUsers: null == blockedUsers
          ? _value._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UnblockUserResponseImpl implements _UnblockUserResponse {
  const _$UnblockUserResponseImpl(
      {required this.success,
      required this.message,
      required final List<String> blockedUsers})
      : _blockedUsers = blockedUsers;

  factory _$UnblockUserResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnblockUserResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<String> _blockedUsers;
  @override
  List<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  @override
  String toString() {
    return 'UnblockUserResponse(success: $success, message: $message, blockedUsers: $blockedUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnblockUserResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_blockedUsers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnblockUserResponseImplCopyWith<_$UnblockUserResponseImpl> get copyWith =>
      __$$UnblockUserResponseImplCopyWithImpl<_$UnblockUserResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnblockUserResponseImplToJson(
      this,
    );
  }
}

abstract class _UnblockUserResponse implements UnblockUserResponse {
  const factory _UnblockUserResponse(
      {required final bool success,
      required final String message,
      required final List<String> blockedUsers}) = _$UnblockUserResponseImpl;

  factory _UnblockUserResponse.fromJson(Map<String, dynamic> json) =
      _$UnblockUserResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<String> get blockedUsers;
  @override
  @JsonKey(ignore: true)
  _$$UnblockUserResponseImplCopyWith<_$UnblockUserResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
