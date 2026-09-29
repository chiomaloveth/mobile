// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'read_notification_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReadNotificationResponse _$ReadNotificationResponseFromJson(
    Map<String, dynamic> json) {
  return _ReadNotificationResponse.fromJson(json);
}

/// @nodoc
mixin _$ReadNotificationResponse {
  bool get success => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  int get readCount => throw _privateConstructorUsedError;
  int get badgeCount => throw _privateConstructorUsedError;
  NotificationData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadNotificationResponseCopyWith<ReadNotificationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadNotificationResponseCopyWith<$Res> {
  factory $ReadNotificationResponseCopyWith(ReadNotificationResponse value,
          $Res Function(ReadNotificationResponse) then) =
      _$ReadNotificationResponseCopyWithImpl<$Res, ReadNotificationResponse>;
  @useResult
  $Res call(
      {bool success,
      int count,
      int totalCount,
      int unreadCount,
      int readCount,
      int badgeCount,
      NotificationData data});

  $NotificationDataCopyWith<$Res> get data;
}

/// @nodoc
class _$ReadNotificationResponseCopyWithImpl<$Res,
        $Val extends ReadNotificationResponse>
    implements $ReadNotificationResponseCopyWith<$Res> {
  _$ReadNotificationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? totalCount = null,
    Object? unreadCount = null,
    Object? readCount = null,
    Object? badgeCount = null,
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
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as NotificationData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationDataCopyWith<$Res> get data {
    return $NotificationDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReadNotificationResponseImplCopyWith<$Res>
    implements $ReadNotificationResponseCopyWith<$Res> {
  factory _$$ReadNotificationResponseImplCopyWith(
          _$ReadNotificationResponseImpl value,
          $Res Function(_$ReadNotificationResponseImpl) then) =
      __$$ReadNotificationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      int count,
      int totalCount,
      int unreadCount,
      int readCount,
      int badgeCount,
      NotificationData data});

  @override
  $NotificationDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$ReadNotificationResponseImplCopyWithImpl<$Res>
    extends _$ReadNotificationResponseCopyWithImpl<$Res,
        _$ReadNotificationResponseImpl>
    implements _$$ReadNotificationResponseImplCopyWith<$Res> {
  __$$ReadNotificationResponseImplCopyWithImpl(
      _$ReadNotificationResponseImpl _value,
      $Res Function(_$ReadNotificationResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? totalCount = null,
    Object? unreadCount = null,
    Object? readCount = null,
    Object? badgeCount = null,
    Object? data = null,
  }) {
    return _then(_$ReadNotificationResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
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
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as NotificationData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadNotificationResponseImpl implements _ReadNotificationResponse {
  const _$ReadNotificationResponseImpl(
      {required this.success,
      this.count = 0,
      this.totalCount = 0,
      this.unreadCount = 0,
      this.readCount = 0,
      this.badgeCount = 0,
      required this.data});

  factory _$ReadNotificationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadNotificationResponseImplFromJson(json);

  @override
  final bool success;
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
  final NotificationData data;

  @override
  String toString() {
    return 'ReadNotificationResponse(success: $success, count: $count, totalCount: $totalCount, unreadCount: $unreadCount, readCount: $readCount, badgeCount: $badgeCount, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadNotificationResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.readCount, readCount) ||
                other.readCount == readCount) &&
            (identical(other.badgeCount, badgeCount) ||
                other.badgeCount == badgeCount) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, count, totalCount,
      unreadCount, readCount, badgeCount, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadNotificationResponseImplCopyWith<_$ReadNotificationResponseImpl>
      get copyWith => __$$ReadNotificationResponseImplCopyWithImpl<
          _$ReadNotificationResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadNotificationResponseImplToJson(
      this,
    );
  }
}

abstract class _ReadNotificationResponse implements ReadNotificationResponse {
  const factory _ReadNotificationResponse(
      {required final bool success,
      final int count,
      final int totalCount,
      final int unreadCount,
      final int readCount,
      final int badgeCount,
      required final NotificationData data}) = _$ReadNotificationResponseImpl;

  factory _ReadNotificationResponse.fromJson(Map<String, dynamic> json) =
      _$ReadNotificationResponseImpl.fromJson;

  @override
  bool get success;
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
  NotificationData get data;
  @override
  @JsonKey(ignore: true)
  _$$ReadNotificationResponseImplCopyWith<_$ReadNotificationResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
