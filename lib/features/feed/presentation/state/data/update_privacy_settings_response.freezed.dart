// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_privacy_settings_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpdatePrivacySettingsResponse _$UpdatePrivacySettingsResponseFromJson(
    Map<String, dynamic> json) {
  return _UpdatePrivacySettingsResponse.fromJson(json);
}

/// @nodoc
mixin _$UpdatePrivacySettingsResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  PrivacySettingsResponseData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdatePrivacySettingsResponseCopyWith<UpdatePrivacySettingsResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdatePrivacySettingsResponseCopyWith<$Res> {
  factory $UpdatePrivacySettingsResponseCopyWith(
          UpdatePrivacySettingsResponse value,
          $Res Function(UpdatePrivacySettingsResponse) then) =
      _$UpdatePrivacySettingsResponseCopyWithImpl<$Res,
          UpdatePrivacySettingsResponse>;
  @useResult
  $Res call({bool success, String message, PrivacySettingsResponseData data});

  $PrivacySettingsResponseDataCopyWith<$Res> get data;
}

/// @nodoc
class _$UpdatePrivacySettingsResponseCopyWithImpl<$Res,
        $Val extends UpdatePrivacySettingsResponse>
    implements $UpdatePrivacySettingsResponseCopyWith<$Res> {
  _$UpdatePrivacySettingsResponseCopyWithImpl(this._value, this._then);

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
              as PrivacySettingsResponseData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PrivacySettingsResponseDataCopyWith<$Res> get data {
    return $PrivacySettingsResponseDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdatePrivacySettingsResponseImplCopyWith<$Res>
    implements $UpdatePrivacySettingsResponseCopyWith<$Res> {
  factory _$$UpdatePrivacySettingsResponseImplCopyWith(
          _$UpdatePrivacySettingsResponseImpl value,
          $Res Function(_$UpdatePrivacySettingsResponseImpl) then) =
      __$$UpdatePrivacySettingsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, PrivacySettingsResponseData data});

  @override
  $PrivacySettingsResponseDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$UpdatePrivacySettingsResponseImplCopyWithImpl<$Res>
    extends _$UpdatePrivacySettingsResponseCopyWithImpl<$Res,
        _$UpdatePrivacySettingsResponseImpl>
    implements _$$UpdatePrivacySettingsResponseImplCopyWith<$Res> {
  __$$UpdatePrivacySettingsResponseImplCopyWithImpl(
      _$UpdatePrivacySettingsResponseImpl _value,
      $Res Function(_$UpdatePrivacySettingsResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$UpdatePrivacySettingsResponseImpl(
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
              as PrivacySettingsResponseData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdatePrivacySettingsResponseImpl
    implements _UpdatePrivacySettingsResponse {
  const _$UpdatePrivacySettingsResponseImpl(
      {required this.success, required this.message, required this.data});

  factory _$UpdatePrivacySettingsResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$UpdatePrivacySettingsResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final PrivacySettingsResponseData data;

  @override
  String toString() {
    return 'UpdatePrivacySettingsResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdatePrivacySettingsResponseImpl &&
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
  _$$UpdatePrivacySettingsResponseImplCopyWith<
          _$UpdatePrivacySettingsResponseImpl>
      get copyWith => __$$UpdatePrivacySettingsResponseImplCopyWithImpl<
          _$UpdatePrivacySettingsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdatePrivacySettingsResponseImplToJson(
      this,
    );
  }
}

abstract class _UpdatePrivacySettingsResponse
    implements UpdatePrivacySettingsResponse {
  const factory _UpdatePrivacySettingsResponse(
          {required final bool success,
          required final String message,
          required final PrivacySettingsResponseData data}) =
      _$UpdatePrivacySettingsResponseImpl;

  factory _UpdatePrivacySettingsResponse.fromJson(Map<String, dynamic> json) =
      _$UpdatePrivacySettingsResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  PrivacySettingsResponseData get data;
  @override
  @JsonKey(ignore: true)
  _$$UpdatePrivacySettingsResponseImplCopyWith<
          _$UpdatePrivacySettingsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PrivacySettingsResponseData _$PrivacySettingsResponseDataFromJson(
    Map<String, dynamic> json) {
  return _PrivacySettingsResponseData.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettingsResponseData {
  bool get isPrivateAccount => throw _privateConstructorUsedError;
  PrivacyResponseData get privacy => throw _privateConstructorUsedError;
  String get defaultMessageTimer => throw _privateConstructorUsedError;
  SettingsResponseData get settings => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrivacySettingsResponseDataCopyWith<PrivacySettingsResponseData>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacySettingsResponseDataCopyWith<$Res> {
  factory $PrivacySettingsResponseDataCopyWith(
          PrivacySettingsResponseData value,
          $Res Function(PrivacySettingsResponseData) then) =
      _$PrivacySettingsResponseDataCopyWithImpl<$Res,
          PrivacySettingsResponseData>;
  @useResult
  $Res call(
      {bool isPrivateAccount,
      PrivacyResponseData privacy,
      String defaultMessageTimer,
      SettingsResponseData settings});

  $PrivacyResponseDataCopyWith<$Res> get privacy;
  $SettingsResponseDataCopyWith<$Res> get settings;
}

/// @nodoc
class _$PrivacySettingsResponseDataCopyWithImpl<$Res,
        $Val extends PrivacySettingsResponseData>
    implements $PrivacySettingsResponseDataCopyWith<$Res> {
  _$PrivacySettingsResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPrivateAccount = null,
    Object? privacy = null,
    Object? defaultMessageTimer = null,
    Object? settings = null,
  }) {
    return _then(_value.copyWith(
      isPrivateAccount: null == isPrivateAccount
          ? _value.isPrivateAccount
          : isPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as PrivacyResponseData,
      defaultMessageTimer: null == defaultMessageTimer
          ? _value.defaultMessageTimer
          : defaultMessageTimer // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as SettingsResponseData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PrivacyResponseDataCopyWith<$Res> get privacy {
    return $PrivacyResponseDataCopyWith<$Res>(_value.privacy, (value) {
      return _then(_value.copyWith(privacy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SettingsResponseDataCopyWith<$Res> get settings {
    return $SettingsResponseDataCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PrivacySettingsResponseDataImplCopyWith<$Res>
    implements $PrivacySettingsResponseDataCopyWith<$Res> {
  factory _$$PrivacySettingsResponseDataImplCopyWith(
          _$PrivacySettingsResponseDataImpl value,
          $Res Function(_$PrivacySettingsResponseDataImpl) then) =
      __$$PrivacySettingsResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPrivateAccount,
      PrivacyResponseData privacy,
      String defaultMessageTimer,
      SettingsResponseData settings});

  @override
  $PrivacyResponseDataCopyWith<$Res> get privacy;
  @override
  $SettingsResponseDataCopyWith<$Res> get settings;
}

/// @nodoc
class __$$PrivacySettingsResponseDataImplCopyWithImpl<$Res>
    extends _$PrivacySettingsResponseDataCopyWithImpl<$Res,
        _$PrivacySettingsResponseDataImpl>
    implements _$$PrivacySettingsResponseDataImplCopyWith<$Res> {
  __$$PrivacySettingsResponseDataImplCopyWithImpl(
      _$PrivacySettingsResponseDataImpl _value,
      $Res Function(_$PrivacySettingsResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPrivateAccount = null,
    Object? privacy = null,
    Object? defaultMessageTimer = null,
    Object? settings = null,
  }) {
    return _then(_$PrivacySettingsResponseDataImpl(
      isPrivateAccount: null == isPrivateAccount
          ? _value.isPrivateAccount
          : isPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as PrivacyResponseData,
      defaultMessageTimer: null == defaultMessageTimer
          ? _value.defaultMessageTimer
          : defaultMessageTimer // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as SettingsResponseData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacySettingsResponseDataImpl
    implements _PrivacySettingsResponseData {
  const _$PrivacySettingsResponseDataImpl(
      {required this.isPrivateAccount,
      required this.privacy,
      required this.defaultMessageTimer,
      required this.settings});

  factory _$PrivacySettingsResponseDataImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$PrivacySettingsResponseDataImplFromJson(json);

  @override
  final bool isPrivateAccount;
  @override
  final PrivacyResponseData privacy;
  @override
  final String defaultMessageTimer;
  @override
  final SettingsResponseData settings;

  @override
  String toString() {
    return 'PrivacySettingsResponseData(isPrivateAccount: $isPrivateAccount, privacy: $privacy, defaultMessageTimer: $defaultMessageTimer, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsResponseDataImpl &&
            (identical(other.isPrivateAccount, isPrivateAccount) ||
                other.isPrivateAccount == isPrivateAccount) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.defaultMessageTimer, defaultMessageTimer) ||
                other.defaultMessageTimer == defaultMessageTimer) &&
            (identical(other.settings, settings) ||
                other.settings == settings));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, isPrivateAccount, privacy, defaultMessageTimer, settings);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacySettingsResponseDataImplCopyWith<_$PrivacySettingsResponseDataImpl>
      get copyWith => __$$PrivacySettingsResponseDataImplCopyWithImpl<
          _$PrivacySettingsResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacySettingsResponseDataImplToJson(
      this,
    );
  }
}

abstract class _PrivacySettingsResponseData
    implements PrivacySettingsResponseData {
  const factory _PrivacySettingsResponseData(
          {required final bool isPrivateAccount,
          required final PrivacyResponseData privacy,
          required final String defaultMessageTimer,
          required final SettingsResponseData settings}) =
      _$PrivacySettingsResponseDataImpl;

  factory _PrivacySettingsResponseData.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsResponseDataImpl.fromJson;

  @override
  bool get isPrivateAccount;
  @override
  PrivacyResponseData get privacy;
  @override
  String get defaultMessageTimer;
  @override
  SettingsResponseData get settings;
  @override
  @JsonKey(ignore: true)
  _$$PrivacySettingsResponseDataImplCopyWith<_$PrivacySettingsResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PrivacyResponseData _$PrivacyResponseDataFromJson(Map<String, dynamic> json) {
  return _PrivacyResponseData.fromJson(json);
}

/// @nodoc
mixin _$PrivacyResponseData {
  List<String> get profilePhotoExceptions => throw _privateConstructorUsedError;
  List<String> get aboutExceptions => throw _privateConstructorUsedError;
  List<String> get groupExceptions => throw _privateConstructorUsedError;
  String get statusVisibility => throw _privateConstructorUsedError;
  List<String> get statusExceptions => throw _privateConstructorUsedError;
  List<String> get statusIncluded => throw _privateConstructorUsedError;
  String get likedVideosVisibility => throw _privateConstructorUsedError;
  String get commentPermissions => throw _privateConstructorUsedError;
  String get duetPermissions => throw _privateConstructorUsedError;
  String get messagePermissions => throw _privateConstructorUsedError;
  String get about => throw _privateConstructorUsedError;
  String get groups => throw _privateConstructorUsedError;
  String get lastSeen => throw _privateConstructorUsedError;
  String get profilePhoto => throw _privateConstructorUsedError;
  bool get readReceipts => throw _privateConstructorUsedError;
  List<String> get lastSeenExceptions => throw _privateConstructorUsedError;
  String get videosVisibility => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrivacyResponseDataCopyWith<PrivacyResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacyResponseDataCopyWith<$Res> {
  factory $PrivacyResponseDataCopyWith(
          PrivacyResponseData value, $Res Function(PrivacyResponseData) then) =
      _$PrivacyResponseDataCopyWithImpl<$Res, PrivacyResponseData>;
  @useResult
  $Res call(
      {List<String> profilePhotoExceptions,
      List<String> aboutExceptions,
      List<String> groupExceptions,
      String statusVisibility,
      List<String> statusExceptions,
      List<String> statusIncluded,
      String likedVideosVisibility,
      String commentPermissions,
      String duetPermissions,
      String messagePermissions,
      String about,
      String groups,
      String lastSeen,
      String profilePhoto,
      bool readReceipts,
      List<String> lastSeenExceptions,
      String videosVisibility});
}

/// @nodoc
class _$PrivacyResponseDataCopyWithImpl<$Res, $Val extends PrivacyResponseData>
    implements $PrivacyResponseDataCopyWith<$Res> {
  _$PrivacyResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profilePhotoExceptions = null,
    Object? aboutExceptions = null,
    Object? groupExceptions = null,
    Object? statusVisibility = null,
    Object? statusExceptions = null,
    Object? statusIncluded = null,
    Object? likedVideosVisibility = null,
    Object? commentPermissions = null,
    Object? duetPermissions = null,
    Object? messagePermissions = null,
    Object? about = null,
    Object? groups = null,
    Object? lastSeen = null,
    Object? profilePhoto = null,
    Object? readReceipts = null,
    Object? lastSeenExceptions = null,
    Object? videosVisibility = null,
  }) {
    return _then(_value.copyWith(
      profilePhotoExceptions: null == profilePhotoExceptions
          ? _value.profilePhotoExceptions
          : profilePhotoExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      aboutExceptions: null == aboutExceptions
          ? _value.aboutExceptions
          : aboutExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      groupExceptions: null == groupExceptions
          ? _value.groupExceptions
          : groupExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      statusVisibility: null == statusVisibility
          ? _value.statusVisibility
          : statusVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      statusExceptions: null == statusExceptions
          ? _value.statusExceptions
          : statusExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      statusIncluded: null == statusIncluded
          ? _value.statusIncluded
          : statusIncluded // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likedVideosVisibility: null == likedVideosVisibility
          ? _value.likedVideosVisibility
          : likedVideosVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      commentPermissions: null == commentPermissions
          ? _value.commentPermissions
          : commentPermissions // ignore: cast_nullable_to_non_nullable
              as String,
      duetPermissions: null == duetPermissions
          ? _value.duetPermissions
          : duetPermissions // ignore: cast_nullable_to_non_nullable
              as String,
      messagePermissions: null == messagePermissions
          ? _value.messagePermissions
          : messagePermissions // ignore: cast_nullable_to_non_nullable
              as String,
      about: null == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String,
      groups: null == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as String,
      profilePhoto: null == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      readReceipts: null == readReceipts
          ? _value.readReceipts
          : readReceipts // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeenExceptions: null == lastSeenExceptions
          ? _value.lastSeenExceptions
          : lastSeenExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      videosVisibility: null == videosVisibility
          ? _value.videosVisibility
          : videosVisibility // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrivacyResponseDataImplCopyWith<$Res>
    implements $PrivacyResponseDataCopyWith<$Res> {
  factory _$$PrivacyResponseDataImplCopyWith(_$PrivacyResponseDataImpl value,
          $Res Function(_$PrivacyResponseDataImpl) then) =
      __$$PrivacyResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> profilePhotoExceptions,
      List<String> aboutExceptions,
      List<String> groupExceptions,
      String statusVisibility,
      List<String> statusExceptions,
      List<String> statusIncluded,
      String likedVideosVisibility,
      String commentPermissions,
      String duetPermissions,
      String messagePermissions,
      String about,
      String groups,
      String lastSeen,
      String profilePhoto,
      bool readReceipts,
      List<String> lastSeenExceptions,
      String videosVisibility});
}

/// @nodoc
class __$$PrivacyResponseDataImplCopyWithImpl<$Res>
    extends _$PrivacyResponseDataCopyWithImpl<$Res, _$PrivacyResponseDataImpl>
    implements _$$PrivacyResponseDataImplCopyWith<$Res> {
  __$$PrivacyResponseDataImplCopyWithImpl(_$PrivacyResponseDataImpl _value,
      $Res Function(_$PrivacyResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profilePhotoExceptions = null,
    Object? aboutExceptions = null,
    Object? groupExceptions = null,
    Object? statusVisibility = null,
    Object? statusExceptions = null,
    Object? statusIncluded = null,
    Object? likedVideosVisibility = null,
    Object? commentPermissions = null,
    Object? duetPermissions = null,
    Object? messagePermissions = null,
    Object? about = null,
    Object? groups = null,
    Object? lastSeen = null,
    Object? profilePhoto = null,
    Object? readReceipts = null,
    Object? lastSeenExceptions = null,
    Object? videosVisibility = null,
  }) {
    return _then(_$PrivacyResponseDataImpl(
      profilePhotoExceptions: null == profilePhotoExceptions
          ? _value._profilePhotoExceptions
          : profilePhotoExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      aboutExceptions: null == aboutExceptions
          ? _value._aboutExceptions
          : aboutExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      groupExceptions: null == groupExceptions
          ? _value._groupExceptions
          : groupExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      statusVisibility: null == statusVisibility
          ? _value.statusVisibility
          : statusVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      statusExceptions: null == statusExceptions
          ? _value._statusExceptions
          : statusExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      statusIncluded: null == statusIncluded
          ? _value._statusIncluded
          : statusIncluded // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likedVideosVisibility: null == likedVideosVisibility
          ? _value.likedVideosVisibility
          : likedVideosVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      commentPermissions: null == commentPermissions
          ? _value.commentPermissions
          : commentPermissions // ignore: cast_nullable_to_non_nullable
              as String,
      duetPermissions: null == duetPermissions
          ? _value.duetPermissions
          : duetPermissions // ignore: cast_nullable_to_non_nullable
              as String,
      messagePermissions: null == messagePermissions
          ? _value.messagePermissions
          : messagePermissions // ignore: cast_nullable_to_non_nullable
              as String,
      about: null == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String,
      groups: null == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as String,
      profilePhoto: null == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      readReceipts: null == readReceipts
          ? _value.readReceipts
          : readReceipts // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeenExceptions: null == lastSeenExceptions
          ? _value._lastSeenExceptions
          : lastSeenExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      videosVisibility: null == videosVisibility
          ? _value.videosVisibility
          : videosVisibility // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacyResponseDataImpl implements _PrivacyResponseData {
  const _$PrivacyResponseDataImpl(
      {final List<String> profilePhotoExceptions = const [],
      final List<String> aboutExceptions = const [],
      final List<String> groupExceptions = const [],
      this.statusVisibility = 'contacts',
      final List<String> statusExceptions = const [],
      final List<String> statusIncluded = const [],
      this.likedVideosVisibility = 'everyone',
      this.commentPermissions = 'everyone',
      this.duetPermissions = 'everyone',
      this.messagePermissions = 'everyone',
      this.about = 'everyone',
      this.groups = 'everyone',
      this.lastSeen = 'everyone',
      this.profilePhoto = 'everyone',
      this.readReceipts = true,
      final List<String> lastSeenExceptions = const [],
      this.videosVisibility = 'everyone'})
      : _profilePhotoExceptions = profilePhotoExceptions,
        _aboutExceptions = aboutExceptions,
        _groupExceptions = groupExceptions,
        _statusExceptions = statusExceptions,
        _statusIncluded = statusIncluded,
        _lastSeenExceptions = lastSeenExceptions;

  factory _$PrivacyResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacyResponseDataImplFromJson(json);

  final List<String> _profilePhotoExceptions;
  @override
  @JsonKey()
  List<String> get profilePhotoExceptions {
    if (_profilePhotoExceptions is EqualUnmodifiableListView)
      return _profilePhotoExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profilePhotoExceptions);
  }

  final List<String> _aboutExceptions;
  @override
  @JsonKey()
  List<String> get aboutExceptions {
    if (_aboutExceptions is EqualUnmodifiableListView) return _aboutExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aboutExceptions);
  }

  final List<String> _groupExceptions;
  @override
  @JsonKey()
  List<String> get groupExceptions {
    if (_groupExceptions is EqualUnmodifiableListView) return _groupExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groupExceptions);
  }

  @override
  @JsonKey()
  final String statusVisibility;
  final List<String> _statusExceptions;
  @override
  @JsonKey()
  List<String> get statusExceptions {
    if (_statusExceptions is EqualUnmodifiableListView)
      return _statusExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusExceptions);
  }

  final List<String> _statusIncluded;
  @override
  @JsonKey()
  List<String> get statusIncluded {
    if (_statusIncluded is EqualUnmodifiableListView) return _statusIncluded;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusIncluded);
  }

  @override
  @JsonKey()
  final String likedVideosVisibility;
  @override
  @JsonKey()
  final String commentPermissions;
  @override
  @JsonKey()
  final String duetPermissions;
  @override
  @JsonKey()
  final String messagePermissions;
  @override
  @JsonKey()
  final String about;
  @override
  @JsonKey()
  final String groups;
  @override
  @JsonKey()
  final String lastSeen;
  @override
  @JsonKey()
  final String profilePhoto;
  @override
  @JsonKey()
  final bool readReceipts;
  final List<String> _lastSeenExceptions;
  @override
  @JsonKey()
  List<String> get lastSeenExceptions {
    if (_lastSeenExceptions is EqualUnmodifiableListView)
      return _lastSeenExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lastSeenExceptions);
  }

  @override
  @JsonKey()
  final String videosVisibility;

  @override
  String toString() {
    return 'PrivacyResponseData(profilePhotoExceptions: $profilePhotoExceptions, aboutExceptions: $aboutExceptions, groupExceptions: $groupExceptions, statusVisibility: $statusVisibility, statusExceptions: $statusExceptions, statusIncluded: $statusIncluded, likedVideosVisibility: $likedVideosVisibility, commentPermissions: $commentPermissions, duetPermissions: $duetPermissions, messagePermissions: $messagePermissions, about: $about, groups: $groups, lastSeen: $lastSeen, profilePhoto: $profilePhoto, readReceipts: $readReceipts, lastSeenExceptions: $lastSeenExceptions, videosVisibility: $videosVisibility)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacyResponseDataImpl &&
            const DeepCollectionEquality().equals(
                other._profilePhotoExceptions, _profilePhotoExceptions) &&
            const DeepCollectionEquality()
                .equals(other._aboutExceptions, _aboutExceptions) &&
            const DeepCollectionEquality()
                .equals(other._groupExceptions, _groupExceptions) &&
            (identical(other.statusVisibility, statusVisibility) ||
                other.statusVisibility == statusVisibility) &&
            const DeepCollectionEquality()
                .equals(other._statusExceptions, _statusExceptions) &&
            const DeepCollectionEquality()
                .equals(other._statusIncluded, _statusIncluded) &&
            (identical(other.likedVideosVisibility, likedVideosVisibility) ||
                other.likedVideosVisibility == likedVideosVisibility) &&
            (identical(other.commentPermissions, commentPermissions) ||
                other.commentPermissions == commentPermissions) &&
            (identical(other.duetPermissions, duetPermissions) ||
                other.duetPermissions == duetPermissions) &&
            (identical(other.messagePermissions, messagePermissions) ||
                other.messagePermissions == messagePermissions) &&
            (identical(other.about, about) || other.about == about) &&
            (identical(other.groups, groups) || other.groups == groups) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.profilePhoto, profilePhoto) ||
                other.profilePhoto == profilePhoto) &&
            (identical(other.readReceipts, readReceipts) ||
                other.readReceipts == readReceipts) &&
            const DeepCollectionEquality()
                .equals(other._lastSeenExceptions, _lastSeenExceptions) &&
            (identical(other.videosVisibility, videosVisibility) ||
                other.videosVisibility == videosVisibility));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_profilePhotoExceptions),
      const DeepCollectionEquality().hash(_aboutExceptions),
      const DeepCollectionEquality().hash(_groupExceptions),
      statusVisibility,
      const DeepCollectionEquality().hash(_statusExceptions),
      const DeepCollectionEquality().hash(_statusIncluded),
      likedVideosVisibility,
      commentPermissions,
      duetPermissions,
      messagePermissions,
      about,
      groups,
      lastSeen,
      profilePhoto,
      readReceipts,
      const DeepCollectionEquality().hash(_lastSeenExceptions),
      videosVisibility);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacyResponseDataImplCopyWith<_$PrivacyResponseDataImpl> get copyWith =>
      __$$PrivacyResponseDataImplCopyWithImpl<_$PrivacyResponseDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacyResponseDataImplToJson(
      this,
    );
  }
}

abstract class _PrivacyResponseData implements PrivacyResponseData {
  const factory _PrivacyResponseData(
      {final List<String> profilePhotoExceptions,
      final List<String> aboutExceptions,
      final List<String> groupExceptions,
      final String statusVisibility,
      final List<String> statusExceptions,
      final List<String> statusIncluded,
      final String likedVideosVisibility,
      final String commentPermissions,
      final String duetPermissions,
      final String messagePermissions,
      final String about,
      final String groups,
      final String lastSeen,
      final String profilePhoto,
      final bool readReceipts,
      final List<String> lastSeenExceptions,
      final String videosVisibility}) = _$PrivacyResponseDataImpl;

  factory _PrivacyResponseData.fromJson(Map<String, dynamic> json) =
      _$PrivacyResponseDataImpl.fromJson;

  @override
  List<String> get profilePhotoExceptions;
  @override
  List<String> get aboutExceptions;
  @override
  List<String> get groupExceptions;
  @override
  String get statusVisibility;
  @override
  List<String> get statusExceptions;
  @override
  List<String> get statusIncluded;
  @override
  String get likedVideosVisibility;
  @override
  String get commentPermissions;
  @override
  String get duetPermissions;
  @override
  String get messagePermissions;
  @override
  String get about;
  @override
  String get groups;
  @override
  String get lastSeen;
  @override
  String get profilePhoto;
  @override
  bool get readReceipts;
  @override
  List<String> get lastSeenExceptions;
  @override
  String get videosVisibility;
  @override
  @JsonKey(ignore: true)
  _$$PrivacyResponseDataImplCopyWith<_$PrivacyResponseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SettingsResponseData _$SettingsResponseDataFromJson(Map<String, dynamic> json) {
  return _SettingsResponseData.fromJson(json);
}

/// @nodoc
mixin _$SettingsResponseData {
  NotificationsResponseData get notifications =>
      throw _privateConstructorUsedError;
  CommentFiltersResponseData get commentFilters =>
      throw _privateConstructorUsedError;
  bool get allowScreenshots => throw _privateConstructorUsedError;
  String get chatWallpaper => throw _privateConstructorUsedError;
  bool get isAppLockEnabled => throw _privateConstructorUsedError;
  String get themeMode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettingsResponseDataCopyWith<SettingsResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsResponseDataCopyWith<$Res> {
  factory $SettingsResponseDataCopyWith(SettingsResponseData value,
          $Res Function(SettingsResponseData) then) =
      _$SettingsResponseDataCopyWithImpl<$Res, SettingsResponseData>;
  @useResult
  $Res call(
      {NotificationsResponseData notifications,
      CommentFiltersResponseData commentFilters,
      bool allowScreenshots,
      String chatWallpaper,
      bool isAppLockEnabled,
      String themeMode});

  $NotificationsResponseDataCopyWith<$Res> get notifications;
  $CommentFiltersResponseDataCopyWith<$Res> get commentFilters;
}

/// @nodoc
class _$SettingsResponseDataCopyWithImpl<$Res,
        $Val extends SettingsResponseData>
    implements $SettingsResponseDataCopyWith<$Res> {
  _$SettingsResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? commentFilters = null,
    Object? allowScreenshots = null,
    Object? chatWallpaper = null,
    Object? isAppLockEnabled = null,
    Object? themeMode = null,
  }) {
    return _then(_value.copyWith(
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as NotificationsResponseData,
      commentFilters: null == commentFilters
          ? _value.commentFilters
          : commentFilters // ignore: cast_nullable_to_non_nullable
              as CommentFiltersResponseData,
      allowScreenshots: null == allowScreenshots
          ? _value.allowScreenshots
          : allowScreenshots // ignore: cast_nullable_to_non_nullable
              as bool,
      chatWallpaper: null == chatWallpaper
          ? _value.chatWallpaper
          : chatWallpaper // ignore: cast_nullable_to_non_nullable
              as String,
      isAppLockEnabled: null == isAppLockEnabled
          ? _value.isAppLockEnabled
          : isAppLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationsResponseDataCopyWith<$Res> get notifications {
    return $NotificationsResponseDataCopyWith<$Res>(_value.notifications,
        (value) {
      return _then(_value.copyWith(notifications: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CommentFiltersResponseDataCopyWith<$Res> get commentFilters {
    return $CommentFiltersResponseDataCopyWith<$Res>(_value.commentFilters,
        (value) {
      return _then(_value.copyWith(commentFilters: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SettingsResponseDataImplCopyWith<$Res>
    implements $SettingsResponseDataCopyWith<$Res> {
  factory _$$SettingsResponseDataImplCopyWith(_$SettingsResponseDataImpl value,
          $Res Function(_$SettingsResponseDataImpl) then) =
      __$$SettingsResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {NotificationsResponseData notifications,
      CommentFiltersResponseData commentFilters,
      bool allowScreenshots,
      String chatWallpaper,
      bool isAppLockEnabled,
      String themeMode});

  @override
  $NotificationsResponseDataCopyWith<$Res> get notifications;
  @override
  $CommentFiltersResponseDataCopyWith<$Res> get commentFilters;
}

/// @nodoc
class __$$SettingsResponseDataImplCopyWithImpl<$Res>
    extends _$SettingsResponseDataCopyWithImpl<$Res, _$SettingsResponseDataImpl>
    implements _$$SettingsResponseDataImplCopyWith<$Res> {
  __$$SettingsResponseDataImplCopyWithImpl(_$SettingsResponseDataImpl _value,
      $Res Function(_$SettingsResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? commentFilters = null,
    Object? allowScreenshots = null,
    Object? chatWallpaper = null,
    Object? isAppLockEnabled = null,
    Object? themeMode = null,
  }) {
    return _then(_$SettingsResponseDataImpl(
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as NotificationsResponseData,
      commentFilters: null == commentFilters
          ? _value.commentFilters
          : commentFilters // ignore: cast_nullable_to_non_nullable
              as CommentFiltersResponseData,
      allowScreenshots: null == allowScreenshots
          ? _value.allowScreenshots
          : allowScreenshots // ignore: cast_nullable_to_non_nullable
              as bool,
      chatWallpaper: null == chatWallpaper
          ? _value.chatWallpaper
          : chatWallpaper // ignore: cast_nullable_to_non_nullable
              as String,
      isAppLockEnabled: null == isAppLockEnabled
          ? _value.isAppLockEnabled
          : isAppLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsResponseDataImpl implements _SettingsResponseData {
  const _$SettingsResponseDataImpl(
      {required this.notifications,
      required this.commentFilters,
      this.allowScreenshots = true,
      this.chatWallpaper = '',
      this.isAppLockEnabled = false,
      this.themeMode = 'system'});

  factory _$SettingsResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsResponseDataImplFromJson(json);

  @override
  final NotificationsResponseData notifications;
  @override
  final CommentFiltersResponseData commentFilters;
  @override
  @JsonKey()
  final bool allowScreenshots;
  @override
  @JsonKey()
  final String chatWallpaper;
  @override
  @JsonKey()
  final bool isAppLockEnabled;
  @override
  @JsonKey()
  final String themeMode;

  @override
  String toString() {
    return 'SettingsResponseData(notifications: $notifications, commentFilters: $commentFilters, allowScreenshots: $allowScreenshots, chatWallpaper: $chatWallpaper, isAppLockEnabled: $isAppLockEnabled, themeMode: $themeMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsResponseDataImpl &&
            (identical(other.notifications, notifications) ||
                other.notifications == notifications) &&
            (identical(other.commentFilters, commentFilters) ||
                other.commentFilters == commentFilters) &&
            (identical(other.allowScreenshots, allowScreenshots) ||
                other.allowScreenshots == allowScreenshots) &&
            (identical(other.chatWallpaper, chatWallpaper) ||
                other.chatWallpaper == chatWallpaper) &&
            (identical(other.isAppLockEnabled, isAppLockEnabled) ||
                other.isAppLockEnabled == isAppLockEnabled) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, notifications, commentFilters,
      allowScreenshots, chatWallpaper, isAppLockEnabled, themeMode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsResponseDataImplCopyWith<_$SettingsResponseDataImpl>
      get copyWith =>
          __$$SettingsResponseDataImplCopyWithImpl<_$SettingsResponseDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsResponseDataImplToJson(
      this,
    );
  }
}

abstract class _SettingsResponseData implements SettingsResponseData {
  const factory _SettingsResponseData(
      {required final NotificationsResponseData notifications,
      required final CommentFiltersResponseData commentFilters,
      final bool allowScreenshots,
      final String chatWallpaper,
      final bool isAppLockEnabled,
      final String themeMode}) = _$SettingsResponseDataImpl;

  factory _SettingsResponseData.fromJson(Map<String, dynamic> json) =
      _$SettingsResponseDataImpl.fromJson;

  @override
  NotificationsResponseData get notifications;
  @override
  CommentFiltersResponseData get commentFilters;
  @override
  bool get allowScreenshots;
  @override
  String get chatWallpaper;
  @override
  bool get isAppLockEnabled;
  @override
  String get themeMode;
  @override
  @JsonKey(ignore: true)
  _$$SettingsResponseDataImplCopyWith<_$SettingsResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationsResponseData _$NotificationsResponseDataFromJson(
    Map<String, dynamic> json) {
  return _NotificationsResponseData.fromJson(json);
}

/// @nodoc
mixin _$NotificationsResponseData {
  bool get calls => throw _privateConstructorUsedError;
  bool get groups => throw _privateConstructorUsedError;
  bool get messages => throw _privateConstructorUsedError;
  bool get sound => throw _privateConstructorUsedError;
  bool get vibrate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationsResponseDataCopyWith<NotificationsResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationsResponseDataCopyWith<$Res> {
  factory $NotificationsResponseDataCopyWith(NotificationsResponseData value,
          $Res Function(NotificationsResponseData) then) =
      _$NotificationsResponseDataCopyWithImpl<$Res, NotificationsResponseData>;
  @useResult
  $Res call({bool calls, bool groups, bool messages, bool sound, bool vibrate});
}

/// @nodoc
class _$NotificationsResponseDataCopyWithImpl<$Res,
        $Val extends NotificationsResponseData>
    implements $NotificationsResponseDataCopyWith<$Res> {
  _$NotificationsResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calls = null,
    Object? groups = null,
    Object? messages = null,
    Object? sound = null,
    Object? vibrate = null,
  }) {
    return _then(_value.copyWith(
      calls: null == calls
          ? _value.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as bool,
      groups: null == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as bool,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as bool,
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrate: null == vibrate
          ? _value.vibrate
          : vibrate // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationsResponseDataImplCopyWith<$Res>
    implements $NotificationsResponseDataCopyWith<$Res> {
  factory _$$NotificationsResponseDataImplCopyWith(
          _$NotificationsResponseDataImpl value,
          $Res Function(_$NotificationsResponseDataImpl) then) =
      __$$NotificationsResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool calls, bool groups, bool messages, bool sound, bool vibrate});
}

/// @nodoc
class __$$NotificationsResponseDataImplCopyWithImpl<$Res>
    extends _$NotificationsResponseDataCopyWithImpl<$Res,
        _$NotificationsResponseDataImpl>
    implements _$$NotificationsResponseDataImplCopyWith<$Res> {
  __$$NotificationsResponseDataImplCopyWithImpl(
      _$NotificationsResponseDataImpl _value,
      $Res Function(_$NotificationsResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calls = null,
    Object? groups = null,
    Object? messages = null,
    Object? sound = null,
    Object? vibrate = null,
  }) {
    return _then(_$NotificationsResponseDataImpl(
      calls: null == calls
          ? _value.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as bool,
      groups: null == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as bool,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as bool,
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrate: null == vibrate
          ? _value.vibrate
          : vibrate // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationsResponseDataImpl implements _NotificationsResponseData {
  const _$NotificationsResponseDataImpl(
      {this.calls = true,
      this.groups = true,
      this.messages = true,
      this.sound = true,
      this.vibrate = true});

  factory _$NotificationsResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationsResponseDataImplFromJson(json);

  @override
  @JsonKey()
  final bool calls;
  @override
  @JsonKey()
  final bool groups;
  @override
  @JsonKey()
  final bool messages;
  @override
  @JsonKey()
  final bool sound;
  @override
  @JsonKey()
  final bool vibrate;

  @override
  String toString() {
    return 'NotificationsResponseData(calls: $calls, groups: $groups, messages: $messages, sound: $sound, vibrate: $vibrate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationsResponseDataImpl &&
            (identical(other.calls, calls) || other.calls == calls) &&
            (identical(other.groups, groups) || other.groups == groups) &&
            (identical(other.messages, messages) ||
                other.messages == messages) &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.vibrate, vibrate) || other.vibrate == vibrate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, calls, groups, messages, sound, vibrate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationsResponseDataImplCopyWith<_$NotificationsResponseDataImpl>
      get copyWith => __$$NotificationsResponseDataImplCopyWithImpl<
          _$NotificationsResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationsResponseDataImplToJson(
      this,
    );
  }
}

abstract class _NotificationsResponseData implements NotificationsResponseData {
  const factory _NotificationsResponseData(
      {final bool calls,
      final bool groups,
      final bool messages,
      final bool sound,
      final bool vibrate}) = _$NotificationsResponseDataImpl;

  factory _NotificationsResponseData.fromJson(Map<String, dynamic> json) =
      _$NotificationsResponseDataImpl.fromJson;

  @override
  bool get calls;
  @override
  bool get groups;
  @override
  bool get messages;
  @override
  bool get sound;
  @override
  bool get vibrate;
  @override
  @JsonKey(ignore: true)
  _$$NotificationsResponseDataImplCopyWith<_$NotificationsResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CommentFiltersResponseData _$CommentFiltersResponseDataFromJson(
    Map<String, dynamic> json) {
  return _CommentFiltersResponseData.fromJson(json);
}

/// @nodoc
mixin _$CommentFiltersResponseData {
  bool get filterOffensiveWords => throw _privateConstructorUsedError;
  bool get filterSpam => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommentFiltersResponseDataCopyWith<CommentFiltersResponseData>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentFiltersResponseDataCopyWith<$Res> {
  factory $CommentFiltersResponseDataCopyWith(CommentFiltersResponseData value,
          $Res Function(CommentFiltersResponseData) then) =
      _$CommentFiltersResponseDataCopyWithImpl<$Res,
          CommentFiltersResponseData>;
  @useResult
  $Res call({bool filterOffensiveWords, bool filterSpam});
}

/// @nodoc
class _$CommentFiltersResponseDataCopyWithImpl<$Res,
        $Val extends CommentFiltersResponseData>
    implements $CommentFiltersResponseDataCopyWith<$Res> {
  _$CommentFiltersResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filterOffensiveWords = null,
    Object? filterSpam = null,
  }) {
    return _then(_value.copyWith(
      filterOffensiveWords: null == filterOffensiveWords
          ? _value.filterOffensiveWords
          : filterOffensiveWords // ignore: cast_nullable_to_non_nullable
              as bool,
      filterSpam: null == filterSpam
          ? _value.filterSpam
          : filterSpam // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentFiltersResponseDataImplCopyWith<$Res>
    implements $CommentFiltersResponseDataCopyWith<$Res> {
  factory _$$CommentFiltersResponseDataImplCopyWith(
          _$CommentFiltersResponseDataImpl value,
          $Res Function(_$CommentFiltersResponseDataImpl) then) =
      __$$CommentFiltersResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool filterOffensiveWords, bool filterSpam});
}

/// @nodoc
class __$$CommentFiltersResponseDataImplCopyWithImpl<$Res>
    extends _$CommentFiltersResponseDataCopyWithImpl<$Res,
        _$CommentFiltersResponseDataImpl>
    implements _$$CommentFiltersResponseDataImplCopyWith<$Res> {
  __$$CommentFiltersResponseDataImplCopyWithImpl(
      _$CommentFiltersResponseDataImpl _value,
      $Res Function(_$CommentFiltersResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filterOffensiveWords = null,
    Object? filterSpam = null,
  }) {
    return _then(_$CommentFiltersResponseDataImpl(
      filterOffensiveWords: null == filterOffensiveWords
          ? _value.filterOffensiveWords
          : filterOffensiveWords // ignore: cast_nullable_to_non_nullable
              as bool,
      filterSpam: null == filterSpam
          ? _value.filterSpam
          : filterSpam // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentFiltersResponseDataImpl implements _CommentFiltersResponseData {
  const _$CommentFiltersResponseDataImpl(
      {this.filterOffensiveWords = true, this.filterSpam = false});

  factory _$CommentFiltersResponseDataImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CommentFiltersResponseDataImplFromJson(json);

  @override
  @JsonKey()
  final bool filterOffensiveWords;
  @override
  @JsonKey()
  final bool filterSpam;

  @override
  String toString() {
    return 'CommentFiltersResponseData(filterOffensiveWords: $filterOffensiveWords, filterSpam: $filterSpam)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentFiltersResponseDataImpl &&
            (identical(other.filterOffensiveWords, filterOffensiveWords) ||
                other.filterOffensiveWords == filterOffensiveWords) &&
            (identical(other.filterSpam, filterSpam) ||
                other.filterSpam == filterSpam));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, filterOffensiveWords, filterSpam);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentFiltersResponseDataImplCopyWith<_$CommentFiltersResponseDataImpl>
      get copyWith => __$$CommentFiltersResponseDataImplCopyWithImpl<
          _$CommentFiltersResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentFiltersResponseDataImplToJson(
      this,
    );
  }
}

abstract class _CommentFiltersResponseData
    implements CommentFiltersResponseData {
  const factory _CommentFiltersResponseData(
      {final bool filterOffensiveWords,
      final bool filterSpam}) = _$CommentFiltersResponseDataImpl;

  factory _CommentFiltersResponseData.fromJson(Map<String, dynamic> json) =
      _$CommentFiltersResponseDataImpl.fromJson;

  @override
  bool get filterOffensiveWords;
  @override
  bool get filterSpam;
  @override
  @JsonKey(ignore: true)
  _$$CommentFiltersResponseDataImplCopyWith<_$CommentFiltersResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
