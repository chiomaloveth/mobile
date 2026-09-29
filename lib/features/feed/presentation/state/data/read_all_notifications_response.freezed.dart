// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'read_all_notifications_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReadAllNotificationsResponse _$ReadAllNotificationsResponseFromJson(
    Map<String, dynamic> json) {
  return _ReadAllNotificationsResponse.fromJson(json);
}

/// @nodoc
mixin _$ReadAllNotificationsResponse {
  bool get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  int get readCount => throw _privateConstructorUsedError;
  int get badgeCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadAllNotificationsResponseCopyWith<ReadAllNotificationsResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadAllNotificationsResponseCopyWith<$Res> {
  factory $ReadAllNotificationsResponseCopyWith(
          ReadAllNotificationsResponse value,
          $Res Function(ReadAllNotificationsResponse) then) =
      _$ReadAllNotificationsResponseCopyWithImpl<$Res,
          ReadAllNotificationsResponse>;
  @useResult
  $Res call(
      {bool success,
      String? message,
      int count,
      int totalCount,
      int unreadCount,
      int readCount,
      int badgeCount});
}

/// @nodoc
class _$ReadAllNotificationsResponseCopyWithImpl<$Res,
        $Val extends ReadAllNotificationsResponse>
    implements $ReadAllNotificationsResponseCopyWith<$Res> {
  _$ReadAllNotificationsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? count = null,
    Object? totalCount = null,
    Object? unreadCount = null,
    Object? readCount = null,
    Object? badgeCount = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      readCount: null == readCount
          ? _value.readCount
          : readCount // ignore: cast_nullable_to_non_nullable
              as int,
      badgeCount: null == badgeCount
          ? _value.badgeCount
          : badgeCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReadAllNotificationsResponseImplCopyWith<$Res>
    implements $ReadAllNotificationsResponseCopyWith<$Res> {
  factory _$$ReadAllNotificationsResponseImplCopyWith(
          _$ReadAllNotificationsResponseImpl value,
          $Res Function(_$ReadAllNotificationsResponseImpl) then) =
      __$$ReadAllNotificationsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String? message,
      int count,
      int totalCount,
      int unreadCount,
      int readCount,
      int badgeCount});
}

/// @nodoc
class __$$ReadAllNotificationsResponseImplCopyWithImpl<$Res>
    extends _$ReadAllNotificationsResponseCopyWithImpl<$Res,
        _$ReadAllNotificationsResponseImpl>
    implements _$$ReadAllNotificationsResponseImplCopyWith<$Res> {
  __$$ReadAllNotificationsResponseImplCopyWithImpl(
      _$ReadAllNotificationsResponseImpl _value,
      $Res Function(_$ReadAllNotificationsResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? count = null,
    Object? totalCount = null,
    Object? unreadCount = null,
    Object? readCount = null,
    Object? badgeCount = null,
  }) {
    return _then(_$ReadAllNotificationsResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      readCount: null == readCount
          ? _value.readCount
          : readCount // ignore: cast_nullable_to_non_nullable
              as int,
      badgeCount: null == badgeCount
          ? _value.badgeCount
          : badgeCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadAllNotificationsResponseImpl
    implements _ReadAllNotificationsResponse {
  const _$ReadAllNotificationsResponseImpl(
      {required this.success,
      this.message,
      this.count = 0,
      this.totalCount = 0,
      this.unreadCount = 0,
      this.readCount = 0,
      this.badgeCount = 0});

  factory _$ReadAllNotificationsResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ReadAllNotificationsResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String? message;
  @override
  @JsonKey()
  final int count;
  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final int readCount;
  @override
  @JsonKey()
  final int badgeCount;

  @override
  String toString() {
    return 'ReadAllNotificationsResponse(success: $success, message: $message, count: $count, totalCount: $totalCount, unreadCount: $unreadCount, readCount: $readCount, badgeCount: $badgeCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadAllNotificationsResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.readCount, readCount) ||
                other.readCount == readCount) &&
            (identical(other.badgeCount, badgeCount) ||
                other.badgeCount == badgeCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, count,
      totalCount, unreadCount, readCount, badgeCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadAllNotificationsResponseImplCopyWith<
          _$ReadAllNotificationsResponseImpl>
      get copyWith => __$$ReadAllNotificationsResponseImplCopyWithImpl<
          _$ReadAllNotificationsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadAllNotificationsResponseImplToJson(
      this,
    );
  }
}

abstract class _ReadAllNotificationsResponse
    implements ReadAllNotificationsResponse {
  const factory _ReadAllNotificationsResponse(
      {required final bool success,
      final String? message,
      final int count,
      final int totalCount,
      final int unreadCount,
      final int readCount,
      final int badgeCount}) = _$ReadAllNotificationsResponseImpl;

  factory _ReadAllNotificationsResponse.fromJson(Map<String, dynamic> json) =
      _$ReadAllNotificationsResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String? get message;
  @override
  int get count;
  @override
  int get totalCount;
  @override
  int get unreadCount;
  @override
  int get readCount;
  @override
  int get badgeCount;
  @override
  @JsonKey(ignore: true)
  _$$ReadAllNotificationsResponseImplCopyWith<
          _$ReadAllNotificationsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
