// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_notifications.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetNotifications _$GetNotificationsFromJson(Map<String, dynamic> json) {
  return _GetNotifications.fromJson(json);
}

/// @nodoc
mixin _$GetNotifications {
  bool get success => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  int get readCount => throw _privateConstructorUsedError;
  int get badgeCount => throw _privateConstructorUsedError;
  List<NotificationData> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetNotificationsCopyWith<GetNotifications> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetNotificationsCopyWith<$Res> {
  factory $GetNotificationsCopyWith(
          GetNotifications value, $Res Function(GetNotifications) then) =
      _$GetNotificationsCopyWithImpl<$Res, GetNotifications>;
  @useResult
  $Res call(
      {bool success,
      int count,
      int totalCount,
      int unreadCount,
      int readCount,
      int badgeCount,
      List<NotificationData> data});
}

/// @nodoc
class _$GetNotificationsCopyWithImpl<$Res, $Val extends GetNotifications>
    implements $GetNotificationsCopyWith<$Res> {
  _$GetNotificationsCopyWithImpl(this._value, this._then);

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
              as List<NotificationData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetNotificationsImplCopyWith<$Res>
    implements $GetNotificationsCopyWith<$Res> {
  factory _$$GetNotificationsImplCopyWith(_$GetNotificationsImpl value,
          $Res Function(_$GetNotificationsImpl) then) =
      __$$GetNotificationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      int count,
      int totalCount,
      int unreadCount,
      int readCount,
      int badgeCount,
      List<NotificationData> data});
}

/// @nodoc
class __$$GetNotificationsImplCopyWithImpl<$Res>
    extends _$GetNotificationsCopyWithImpl<$Res, _$GetNotificationsImpl>
    implements _$$GetNotificationsImplCopyWith<$Res> {
  __$$GetNotificationsImplCopyWithImpl(_$GetNotificationsImpl _value,
      $Res Function(_$GetNotificationsImpl) _then)
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
    return _then(_$GetNotificationsImpl(
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
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<NotificationData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetNotificationsImpl implements _GetNotifications {
  const _$GetNotificationsImpl(
      {required this.success,
      this.count = 0,
      this.totalCount = 0,
      this.unreadCount = 0,
      this.readCount = 0,
      this.badgeCount = 0,
      required final List<NotificationData> data})
      : _data = data;

  factory _$GetNotificationsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetNotificationsImplFromJson(json);

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
  final List<NotificationData> _data;
  @override
  List<NotificationData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetNotifications(success: $success, count: $count, totalCount: $totalCount, unreadCount: $unreadCount, readCount: $readCount, badgeCount: $badgeCount, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetNotificationsImpl &&
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
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      count,
      totalCount,
      unreadCount,
      readCount,
      badgeCount,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetNotificationsImplCopyWith<_$GetNotificationsImpl> get copyWith =>
      __$$GetNotificationsImplCopyWithImpl<_$GetNotificationsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetNotificationsImplToJson(
      this,
    );
  }
}

abstract class _GetNotifications implements GetNotifications {
  const factory _GetNotifications(
      {required final bool success,
      final int count,
      final int totalCount,
      final int unreadCount,
      final int readCount,
      final int badgeCount,
      required final List<NotificationData> data}) = _$GetNotificationsImpl;

  factory _GetNotifications.fromJson(Map<String, dynamic> json) =
      _$GetNotificationsImpl.fromJson;

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
  List<NotificationData> get data;
  @override
  @JsonKey(ignore: true)
  _$$GetNotificationsImplCopyWith<_$GetNotificationsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) {
  return _NotificationData.fromJson(json);
}

/// @nodoc
mixin _$NotificationData {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String? get user => throw _privateConstructorUsedError;
  dynamic get actor => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  bool? get read => throw _privateConstructorUsedError;
  String? get recipient => throw _privateConstructorUsedError;
  dynamic get sender =>
      throw _privateConstructorUsedError; // Can be String (ID) or Map (User object)
  String? get message => throw _privateConstructorUsedError;
  String? get priority => throw _privateConstructorUsedError;
  bool? get isRead => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get relatedId => throw _privateConstructorUsedError;
  String? get onModel => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationDataCopyWith<NotificationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationDataCopyWith<$Res> {
  factory $NotificationDataCopyWith(
          NotificationData value, $Res Function(NotificationData) then) =
      _$NotificationDataCopyWithImpl<$Res, NotificationData>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String? user,
      dynamic actor,
      String? body,
      bool? read,
      String? recipient,
      dynamic sender,
      String? message,
      String? priority,
      bool? isRead,
      String? type,
      String? title,
      String? description,
      String? relatedId,
      String? onModel,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$NotificationDataCopyWithImpl<$Res, $Val extends NotificationData>
    implements $NotificationDataCopyWith<$Res> {
  _$NotificationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = freezed,
    Object? actor = freezed,
    Object? body = freezed,
    Object? read = freezed,
    Object? recipient = freezed,
    Object? sender = freezed,
    Object? message = freezed,
    Object? priority = freezed,
    Object? isRead = freezed,
    Object? type = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? relatedId = freezed,
    Object? onModel = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      actor: freezed == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as dynamic,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      read: freezed == read
          ? _value.read
          : read // ignore: cast_nullable_to_non_nullable
              as bool?,
      recipient: freezed == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String?,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as dynamic,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: freezed == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedId: freezed == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as String?,
      onModel: freezed == onModel
          ? _value.onModel
          : onModel // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationDataImplCopyWith<$Res>
    implements $NotificationDataCopyWith<$Res> {
  factory _$$NotificationDataImplCopyWith(_$NotificationDataImpl value,
          $Res Function(_$NotificationDataImpl) then) =
      __$$NotificationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String? user,
      dynamic actor,
      String? body,
      bool? read,
      String? recipient,
      dynamic sender,
      String? message,
      String? priority,
      bool? isRead,
      String? type,
      String? title,
      String? description,
      String? relatedId,
      String? onModel,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$NotificationDataImplCopyWithImpl<$Res>
    extends _$NotificationDataCopyWithImpl<$Res, _$NotificationDataImpl>
    implements _$$NotificationDataImplCopyWith<$Res> {
  __$$NotificationDataImplCopyWithImpl(_$NotificationDataImpl _value,
      $Res Function(_$NotificationDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = freezed,
    Object? actor = freezed,
    Object? body = freezed,
    Object? read = freezed,
    Object? recipient = freezed,
    Object? sender = freezed,
    Object? message = freezed,
    Object? priority = freezed,
    Object? isRead = freezed,
    Object? type = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? relatedId = freezed,
    Object? onModel = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$NotificationDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      actor: freezed == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as dynamic,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      read: freezed == read
          ? _value.read
          : read // ignore: cast_nullable_to_non_nullable
              as bool?,
      recipient: freezed == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String?,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as dynamic,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: freezed == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedId: freezed == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as String?,
      onModel: freezed == onModel
          ? _value.onModel
          : onModel // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationDataImpl implements _NotificationData {
  const _$NotificationDataImpl(
      {@JsonKey(name: '_id') required this.id,
      this.user,
      this.actor,
      this.body,
      this.read,
      this.recipient,
      this.sender,
      this.message,
      this.priority,
      this.isRead,
      this.type,
      this.title,
      this.description,
      this.relatedId,
      this.onModel,
      this.createdAt,
      this.updatedAt});

  factory _$NotificationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String? user;
  @override
  final dynamic actor;
  @override
  final String? body;
  @override
  final bool? read;
  @override
  final String? recipient;
  @override
  final dynamic sender;
// Can be String (ID) or Map (User object)
  @override
  final String? message;
  @override
  final String? priority;
  @override
  final bool? isRead;
  @override
  final String? type;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? relatedId;
  @override
  final String? onModel;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'NotificationData(id: $id, user: $user, actor: $actor, body: $body, read: $read, recipient: $recipient, sender: $sender, message: $message, priority: $priority, isRead: $isRead, type: $type, title: $title, description: $description, relatedId: $relatedId, onModel: $onModel, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other.actor, actor) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.read, read) || other.read == read) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            const DeepCollectionEquality().equals(other.sender, sender) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.relatedId, relatedId) ||
                other.relatedId == relatedId) &&
            (identical(other.onModel, onModel) || other.onModel == onModel) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      const DeepCollectionEquality().hash(actor),
      body,
      read,
      recipient,
      const DeepCollectionEquality().hash(sender),
      message,
      priority,
      isRead,
      type,
      title,
      description,
      relatedId,
      onModel,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationDataImplCopyWith<_$NotificationDataImpl> get copyWith =>
      __$$NotificationDataImplCopyWithImpl<_$NotificationDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationDataImplToJson(
      this,
    );
  }
}

abstract class _NotificationData implements NotificationData {
  const factory _NotificationData(
      {@JsonKey(name: '_id') required final String id,
      final String? user,
      final dynamic actor,
      final String? body,
      final bool? read,
      final String? recipient,
      final dynamic sender,
      final String? message,
      final String? priority,
      final bool? isRead,
      final String? type,
      final String? title,
      final String? description,
      final String? relatedId,
      final String? onModel,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$NotificationDataImpl;

  factory _NotificationData.fromJson(Map<String, dynamic> json) =
      _$NotificationDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String? get user;
  @override
  dynamic get actor;
  @override
  String? get body;
  @override
  bool? get read;
  @override
  String? get recipient;
  @override
  dynamic get sender;
  @override // Can be String (ID) or Map (User object)
  String? get message;
  @override
  String? get priority;
  @override
  bool? get isRead;
  @override
  String? get type;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get relatedId;
  @override
  String? get onModel;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$NotificationDataImplCopyWith<_$NotificationDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
