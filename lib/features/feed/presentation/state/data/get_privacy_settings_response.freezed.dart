// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_privacy_settings_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetPrivacySettingsResponse _$GetPrivacySettingsResponseFromJson(
    Map<String, dynamic> json) {
  return _GetPrivacySettingsResponse.fromJson(json);
}

/// @nodoc
mixin _$GetPrivacySettingsResponse {
  bool get success => throw _privateConstructorUsedError;
  GetPrivacySettingsData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetPrivacySettingsResponseCopyWith<GetPrivacySettingsResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPrivacySettingsResponseCopyWith<$Res> {
  factory $GetPrivacySettingsResponseCopyWith(GetPrivacySettingsResponse value,
          $Res Function(GetPrivacySettingsResponse) then) =
      _$GetPrivacySettingsResponseCopyWithImpl<$Res,
          GetPrivacySettingsResponse>;
  @useResult
  $Res call({bool success, GetPrivacySettingsData data});

  $GetPrivacySettingsDataCopyWith<$Res> get data;
}

/// @nodoc
class _$GetPrivacySettingsResponseCopyWithImpl<$Res,
        $Val extends GetPrivacySettingsResponse>
    implements $GetPrivacySettingsResponseCopyWith<$Res> {
  _$GetPrivacySettingsResponseCopyWithImpl(this._value, this._then);

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
              as GetPrivacySettingsData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GetPrivacySettingsDataCopyWith<$Res> get data {
    return $GetPrivacySettingsDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetPrivacySettingsResponseImplCopyWith<$Res>
    implements $GetPrivacySettingsResponseCopyWith<$Res> {
  factory _$$GetPrivacySettingsResponseImplCopyWith(
          _$GetPrivacySettingsResponseImpl value,
          $Res Function(_$GetPrivacySettingsResponseImpl) then) =
      __$$GetPrivacySettingsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, GetPrivacySettingsData data});

  @override
  $GetPrivacySettingsDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$GetPrivacySettingsResponseImplCopyWithImpl<$Res>
    extends _$GetPrivacySettingsResponseCopyWithImpl<$Res,
        _$GetPrivacySettingsResponseImpl>
    implements _$$GetPrivacySettingsResponseImplCopyWith<$Res> {
  __$$GetPrivacySettingsResponseImplCopyWithImpl(
      _$GetPrivacySettingsResponseImpl _value,
      $Res Function(_$GetPrivacySettingsResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$GetPrivacySettingsResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as GetPrivacySettingsData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetPrivacySettingsResponseImpl implements _GetPrivacySettingsResponse {
  const _$GetPrivacySettingsResponseImpl(
      {required this.success, required this.data});

  factory _$GetPrivacySettingsResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$GetPrivacySettingsResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final GetPrivacySettingsData data;

  @override
  String toString() {
    return 'GetPrivacySettingsResponse(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPrivacySettingsResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetPrivacySettingsResponseImplCopyWith<_$GetPrivacySettingsResponseImpl>
      get copyWith => __$$GetPrivacySettingsResponseImplCopyWithImpl<
          _$GetPrivacySettingsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPrivacySettingsResponseImplToJson(
      this,
    );
  }
}

abstract class _GetPrivacySettingsResponse
    implements GetPrivacySettingsResponse {
  const factory _GetPrivacySettingsResponse(
          {required final bool success,
          required final GetPrivacySettingsData data}) =
      _$GetPrivacySettingsResponseImpl;

  factory _GetPrivacySettingsResponse.fromJson(Map<String, dynamic> json) =
      _$GetPrivacySettingsResponseImpl.fromJson;

  @override
  bool get success;
  @override
  GetPrivacySettingsData get data;
  @override
  @JsonKey(ignore: true)
  _$$GetPrivacySettingsResponseImplCopyWith<_$GetPrivacySettingsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GetPrivacySettingsData _$GetPrivacySettingsDataFromJson(
    Map<String, dynamic> json) {
  return _GetPrivacySettingsData.fromJson(json);
}

/// @nodoc
mixin _$GetPrivacySettingsData {
  bool get isPrivateAccount => throw _privateConstructorUsedError;
  GetPrivacyData get privacy => throw _privateConstructorUsedError;
  String get defaultMessageTimer => throw _privateConstructorUsedError;
  GetPrivacyAppSettings get settings => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetPrivacySettingsDataCopyWith<GetPrivacySettingsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPrivacySettingsDataCopyWith<$Res> {
  factory $GetPrivacySettingsDataCopyWith(GetPrivacySettingsData value,
          $Res Function(GetPrivacySettingsData) then) =
      _$GetPrivacySettingsDataCopyWithImpl<$Res, GetPrivacySettingsData>;
  @useResult
  $Res call(
      {bool isPrivateAccount,
      GetPrivacyData privacy,
      String defaultMessageTimer,
      GetPrivacyAppSettings settings});

  $GetPrivacyDataCopyWith<$Res> get privacy;
  $GetPrivacyAppSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class _$GetPrivacySettingsDataCopyWithImpl<$Res,
        $Val extends GetPrivacySettingsData>
    implements $GetPrivacySettingsDataCopyWith<$Res> {
  _$GetPrivacySettingsDataCopyWithImpl(this._value, this._then);

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
              as GetPrivacyData,
      defaultMessageTimer: null == defaultMessageTimer
          ? _value.defaultMessageTimer
          : defaultMessageTimer // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GetPrivacyAppSettings,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GetPrivacyDataCopyWith<$Res> get privacy {
    return $GetPrivacyDataCopyWith<$Res>(_value.privacy, (value) {
      return _then(_value.copyWith(privacy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GetPrivacyAppSettingsCopyWith<$Res> get settings {
    return $GetPrivacyAppSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetPrivacySettingsDataImplCopyWith<$Res>
    implements $GetPrivacySettingsDataCopyWith<$Res> {
  factory _$$GetPrivacySettingsDataImplCopyWith(
          _$GetPrivacySettingsDataImpl value,
          $Res Function(_$GetPrivacySettingsDataImpl) then) =
      __$$GetPrivacySettingsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPrivateAccount,
      GetPrivacyData privacy,
      String defaultMessageTimer,
      GetPrivacyAppSettings settings});

  @override
  $GetPrivacyDataCopyWith<$Res> get privacy;
  @override
  $GetPrivacyAppSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class __$$GetPrivacySettingsDataImplCopyWithImpl<$Res>
    extends _$GetPrivacySettingsDataCopyWithImpl<$Res,
        _$GetPrivacySettingsDataImpl>
    implements _$$GetPrivacySettingsDataImplCopyWith<$Res> {
  __$$GetPrivacySettingsDataImplCopyWithImpl(
      _$GetPrivacySettingsDataImpl _value,
      $Res Function(_$GetPrivacySettingsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPrivateAccount = null,
    Object? privacy = null,
    Object? defaultMessageTimer = null,
    Object? settings = null,
  }) {
    return _then(_$GetPrivacySettingsDataImpl(
      isPrivateAccount: null == isPrivateAccount
          ? _value.isPrivateAccount
          : isPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as GetPrivacyData,
      defaultMessageTimer: null == defaultMessageTimer
          ? _value.defaultMessageTimer
          : defaultMessageTimer // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GetPrivacyAppSettings,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetPrivacySettingsDataImpl implements _GetPrivacySettingsData {
  const _$GetPrivacySettingsDataImpl(
      {this.isPrivateAccount = false,
      required this.privacy,
      this.defaultMessageTimer = 'off',
      required this.settings});

  factory _$GetPrivacySettingsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetPrivacySettingsDataImplFromJson(json);

  @override
  @JsonKey()
  final bool isPrivateAccount;
  @override
  final GetPrivacyData privacy;
  @override
  @JsonKey()
  final String defaultMessageTimer;
  @override
  final GetPrivacyAppSettings settings;

  @override
  String toString() {
    return 'GetPrivacySettingsData(isPrivateAccount: $isPrivateAccount, privacy: $privacy, defaultMessageTimer: $defaultMessageTimer, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPrivacySettingsDataImpl &&
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
  _$$GetPrivacySettingsDataImplCopyWith<_$GetPrivacySettingsDataImpl>
      get copyWith => __$$GetPrivacySettingsDataImplCopyWithImpl<
          _$GetPrivacySettingsDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPrivacySettingsDataImplToJson(
      this,
    );
  }
}

abstract class _GetPrivacySettingsData implements GetPrivacySettingsData {
  const factory _GetPrivacySettingsData(
          {final bool isPrivateAccount,
          required final GetPrivacyData privacy,
          final String defaultMessageTimer,
          required final GetPrivacyAppSettings settings}) =
      _$GetPrivacySettingsDataImpl;

  factory _GetPrivacySettingsData.fromJson(Map<String, dynamic> json) =
      _$GetPrivacySettingsDataImpl.fromJson;

  @override
  bool get isPrivateAccount;
  @override
  GetPrivacyData get privacy;
  @override
  String get defaultMessageTimer;
  @override
  GetPrivacyAppSettings get settings;
  @override
  @JsonKey(ignore: true)
  _$$GetPrivacySettingsDataImplCopyWith<_$GetPrivacySettingsDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GetPrivacyData _$GetPrivacyDataFromJson(Map<String, dynamic> json) {
  return _GetPrivacyData.fromJson(json);
}

/// @nodoc
mixin _$GetPrivacyData {
  List<dynamic> get profilePhotoExceptions =>
      throw _privateConstructorUsedError;
  List<dynamic> get aboutExceptions => throw _privateConstructorUsedError;
  List<dynamic> get groupExceptions => throw _privateConstructorUsedError;
  String get statusVisibility => throw _privateConstructorUsedError;
  List<dynamic> get statusExceptions => throw _privateConstructorUsedError;
  List<dynamic> get statusIncluded => throw _privateConstructorUsedError;
  String get videosVisibility => throw _privateConstructorUsedError;
  String get likedVideosVisibility => throw _privateConstructorUsedError;
  String get commentPermissions => throw _privateConstructorUsedError;
  String get duetPermissions => throw _privateConstructorUsedError;
  String get messagePermissions => throw _privateConstructorUsedError;
  String get about => throw _privateConstructorUsedError;
  String get groups => throw _privateConstructorUsedError;
  String get lastSeen => throw _privateConstructorUsedError;
  String get profilePhoto => throw _privateConstructorUsedError;
  bool get readReceipts => throw _privateConstructorUsedError;
  List<PrivacyExceptionUser> get lastSeenExceptions =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetPrivacyDataCopyWith<GetPrivacyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPrivacyDataCopyWith<$Res> {
  factory $GetPrivacyDataCopyWith(
          GetPrivacyData value, $Res Function(GetPrivacyData) then) =
      _$GetPrivacyDataCopyWithImpl<$Res, GetPrivacyData>;
  @useResult
  $Res call(
      {List<dynamic> profilePhotoExceptions,
      List<dynamic> aboutExceptions,
      List<dynamic> groupExceptions,
      String statusVisibility,
      List<dynamic> statusExceptions,
      List<dynamic> statusIncluded,
      String videosVisibility,
      String likedVideosVisibility,
      String commentPermissions,
      String duetPermissions,
      String messagePermissions,
      String about,
      String groups,
      String lastSeen,
      String profilePhoto,
      bool readReceipts,
      List<PrivacyExceptionUser> lastSeenExceptions});
}

/// @nodoc
class _$GetPrivacyDataCopyWithImpl<$Res, $Val extends GetPrivacyData>
    implements $GetPrivacyDataCopyWith<$Res> {
  _$GetPrivacyDataCopyWithImpl(this._value, this._then);

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
    Object? videosVisibility = null,
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
  }) {
    return _then(_value.copyWith(
      profilePhotoExceptions: null == profilePhotoExceptions
          ? _value.profilePhotoExceptions
          : profilePhotoExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      aboutExceptions: null == aboutExceptions
          ? _value.aboutExceptions
          : aboutExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      groupExceptions: null == groupExceptions
          ? _value.groupExceptions
          : groupExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      statusVisibility: null == statusVisibility
          ? _value.statusVisibility
          : statusVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      statusExceptions: null == statusExceptions
          ? _value.statusExceptions
          : statusExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      statusIncluded: null == statusIncluded
          ? _value.statusIncluded
          : statusIncluded // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      videosVisibility: null == videosVisibility
          ? _value.videosVisibility
          : videosVisibility // ignore: cast_nullable_to_non_nullable
              as String,
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
              as List<PrivacyExceptionUser>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetPrivacyDataImplCopyWith<$Res>
    implements $GetPrivacyDataCopyWith<$Res> {
  factory _$$GetPrivacyDataImplCopyWith(_$GetPrivacyDataImpl value,
          $Res Function(_$GetPrivacyDataImpl) then) =
      __$$GetPrivacyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<dynamic> profilePhotoExceptions,
      List<dynamic> aboutExceptions,
      List<dynamic> groupExceptions,
      String statusVisibility,
      List<dynamic> statusExceptions,
      List<dynamic> statusIncluded,
      String videosVisibility,
      String likedVideosVisibility,
      String commentPermissions,
      String duetPermissions,
      String messagePermissions,
      String about,
      String groups,
      String lastSeen,
      String profilePhoto,
      bool readReceipts,
      List<PrivacyExceptionUser> lastSeenExceptions});
}

/// @nodoc
class __$$GetPrivacyDataImplCopyWithImpl<$Res>
    extends _$GetPrivacyDataCopyWithImpl<$Res, _$GetPrivacyDataImpl>
    implements _$$GetPrivacyDataImplCopyWith<$Res> {
  __$$GetPrivacyDataImplCopyWithImpl(
      _$GetPrivacyDataImpl _value, $Res Function(_$GetPrivacyDataImpl) _then)
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
    Object? videosVisibility = null,
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
  }) {
    return _then(_$GetPrivacyDataImpl(
      profilePhotoExceptions: null == profilePhotoExceptions
          ? _value._profilePhotoExceptions
          : profilePhotoExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      aboutExceptions: null == aboutExceptions
          ? _value._aboutExceptions
          : aboutExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      groupExceptions: null == groupExceptions
          ? _value._groupExceptions
          : groupExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      statusVisibility: null == statusVisibility
          ? _value.statusVisibility
          : statusVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      statusExceptions: null == statusExceptions
          ? _value._statusExceptions
          : statusExceptions // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      statusIncluded: null == statusIncluded
          ? _value._statusIncluded
          : statusIncluded // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      videosVisibility: null == videosVisibility
          ? _value.videosVisibility
          : videosVisibility // ignore: cast_nullable_to_non_nullable
              as String,
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
              as List<PrivacyExceptionUser>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetPrivacyDataImpl implements _GetPrivacyData {
  const _$GetPrivacyDataImpl(
      {final List<dynamic> profilePhotoExceptions = const [],
      final List<dynamic> aboutExceptions = const [],
      final List<dynamic> groupExceptions = const [],
      this.statusVisibility = 'contacts',
      final List<dynamic> statusExceptions = const [],
      final List<dynamic> statusIncluded = const [],
      this.videosVisibility = 'everyone',
      this.likedVideosVisibility = 'everyone',
      this.commentPermissions = 'everyone',
      this.duetPermissions = 'everyone',
      this.messagePermissions = 'everyone',
      this.about = 'everyone',
      this.groups = 'everyone',
      this.lastSeen = 'everyone',
      this.profilePhoto = 'everyone',
      this.readReceipts = true,
      final List<PrivacyExceptionUser> lastSeenExceptions = const []})
      : _profilePhotoExceptions = profilePhotoExceptions,
        _aboutExceptions = aboutExceptions,
        _groupExceptions = groupExceptions,
        _statusExceptions = statusExceptions,
        _statusIncluded = statusIncluded,
        _lastSeenExceptions = lastSeenExceptions;

  factory _$GetPrivacyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetPrivacyDataImplFromJson(json);

  final List<dynamic> _profilePhotoExceptions;
  @override
  @JsonKey()
  List<dynamic> get profilePhotoExceptions {
    if (_profilePhotoExceptions is EqualUnmodifiableListView)
      return _profilePhotoExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profilePhotoExceptions);
  }

  final List<dynamic> _aboutExceptions;
  @override
  @JsonKey()
  List<dynamic> get aboutExceptions {
    if (_aboutExceptions is EqualUnmodifiableListView) return _aboutExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aboutExceptions);
  }

  final List<dynamic> _groupExceptions;
  @override
  @JsonKey()
  List<dynamic> get groupExceptions {
    if (_groupExceptions is EqualUnmodifiableListView) return _groupExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groupExceptions);
  }

  @override
  @JsonKey()
  final String statusVisibility;
  final List<dynamic> _statusExceptions;
  @override
  @JsonKey()
  List<dynamic> get statusExceptions {
    if (_statusExceptions is EqualUnmodifiableListView)
      return _statusExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusExceptions);
  }

  final List<dynamic> _statusIncluded;
  @override
  @JsonKey()
  List<dynamic> get statusIncluded {
    if (_statusIncluded is EqualUnmodifiableListView) return _statusIncluded;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusIncluded);
  }

  @override
  @JsonKey()
  final String videosVisibility;
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
  final List<PrivacyExceptionUser> _lastSeenExceptions;
  @override
  @JsonKey()
  List<PrivacyExceptionUser> get lastSeenExceptions {
    if (_lastSeenExceptions is EqualUnmodifiableListView)
      return _lastSeenExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lastSeenExceptions);
  }

  @override
  String toString() {
    return 'GetPrivacyData(profilePhotoExceptions: $profilePhotoExceptions, aboutExceptions: $aboutExceptions, groupExceptions: $groupExceptions, statusVisibility: $statusVisibility, statusExceptions: $statusExceptions, statusIncluded: $statusIncluded, videosVisibility: $videosVisibility, likedVideosVisibility: $likedVideosVisibility, commentPermissions: $commentPermissions, duetPermissions: $duetPermissions, messagePermissions: $messagePermissions, about: $about, groups: $groups, lastSeen: $lastSeen, profilePhoto: $profilePhoto, readReceipts: $readReceipts, lastSeenExceptions: $lastSeenExceptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPrivacyDataImpl &&
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
            (identical(other.videosVisibility, videosVisibility) ||
                other.videosVisibility == videosVisibility) &&
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
                .equals(other._lastSeenExceptions, _lastSeenExceptions));
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
      videosVisibility,
      likedVideosVisibility,
      commentPermissions,
      duetPermissions,
      messagePermissions,
      about,
      groups,
      lastSeen,
      profilePhoto,
      readReceipts,
      const DeepCollectionEquality().hash(_lastSeenExceptions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetPrivacyDataImplCopyWith<_$GetPrivacyDataImpl> get copyWith =>
      __$$GetPrivacyDataImplCopyWithImpl<_$GetPrivacyDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPrivacyDataImplToJson(
      this,
    );
  }
}

abstract class _GetPrivacyData implements GetPrivacyData {
  const factory _GetPrivacyData(
          {final List<dynamic> profilePhotoExceptions,
          final List<dynamic> aboutExceptions,
          final List<dynamic> groupExceptions,
          final String statusVisibility,
          final List<dynamic> statusExceptions,
          final List<dynamic> statusIncluded,
          final String videosVisibility,
          final String likedVideosVisibility,
          final String commentPermissions,
          final String duetPermissions,
          final String messagePermissions,
          final String about,
          final String groups,
          final String lastSeen,
          final String profilePhoto,
          final bool readReceipts,
          final List<PrivacyExceptionUser> lastSeenExceptions}) =
      _$GetPrivacyDataImpl;

  factory _GetPrivacyData.fromJson(Map<String, dynamic> json) =
      _$GetPrivacyDataImpl.fromJson;

  @override
  List<dynamic> get profilePhotoExceptions;
  @override
  List<dynamic> get aboutExceptions;
  @override
  List<dynamic> get groupExceptions;
  @override
  String get statusVisibility;
  @override
  List<dynamic> get statusExceptions;
  @override
  List<dynamic> get statusIncluded;
  @override
  String get videosVisibility;
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
  List<PrivacyExceptionUser> get lastSeenExceptions;
  @override
  @JsonKey(ignore: true)
  _$$GetPrivacyDataImplCopyWith<_$GetPrivacyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PrivacyExceptionUser _$PrivacyExceptionUserFromJson(Map<String, dynamic> json) {
  return _PrivacyExceptionUser.fromJson(json);
}

/// @nodoc
mixin _$PrivacyExceptionUser {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrivacyExceptionUserCopyWith<PrivacyExceptionUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacyExceptionUserCopyWith<$Res> {
  factory $PrivacyExceptionUserCopyWith(PrivacyExceptionUser value,
          $Res Function(PrivacyExceptionUser) then) =
      _$PrivacyExceptionUserCopyWithImpl<$Res, PrivacyExceptionUser>;
  @useResult
  $Res call({@JsonKey(name: '_id') String id, String profilePicture});
}

/// @nodoc
class _$PrivacyExceptionUserCopyWithImpl<$Res,
        $Val extends PrivacyExceptionUser>
    implements $PrivacyExceptionUserCopyWith<$Res> {
  _$PrivacyExceptionUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrivacyExceptionUserImplCopyWith<$Res>
    implements $PrivacyExceptionUserCopyWith<$Res> {
  factory _$$PrivacyExceptionUserImplCopyWith(_$PrivacyExceptionUserImpl value,
          $Res Function(_$PrivacyExceptionUserImpl) then) =
      __$$PrivacyExceptionUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: '_id') String id, String profilePicture});
}

/// @nodoc
class __$$PrivacyExceptionUserImplCopyWithImpl<$Res>
    extends _$PrivacyExceptionUserCopyWithImpl<$Res, _$PrivacyExceptionUserImpl>
    implements _$$PrivacyExceptionUserImplCopyWith<$Res> {
  __$$PrivacyExceptionUserImplCopyWithImpl(_$PrivacyExceptionUserImpl _value,
      $Res Function(_$PrivacyExceptionUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profilePicture = null,
  }) {
    return _then(_$PrivacyExceptionUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
class _$PrivacyExceptionUserImpl implements _PrivacyExceptionUser {
  const _$PrivacyExceptionUserImpl(
      {@JsonKey(name: '_id') required this.id, this.profilePicture = ''});

  factory _$PrivacyExceptionUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacyExceptionUserImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  @JsonKey()
  final String profilePicture;

  @override
  String toString() {
    return 'PrivacyExceptionUser(id: $id, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacyExceptionUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, profilePicture);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacyExceptionUserImplCopyWith<_$PrivacyExceptionUserImpl>
      get copyWith =>
          __$$PrivacyExceptionUserImplCopyWithImpl<_$PrivacyExceptionUserImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacyExceptionUserImplToJson(
      this,
    );
  }
}

abstract class _PrivacyExceptionUser implements PrivacyExceptionUser {
  const factory _PrivacyExceptionUser(
      {@JsonKey(name: '_id') required final String id,
      final String profilePicture}) = _$PrivacyExceptionUserImpl;

  factory _PrivacyExceptionUser.fromJson(Map<String, dynamic> json) =
      _$PrivacyExceptionUserImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get profilePicture;
  @override
  @JsonKey(ignore: true)
  _$$PrivacyExceptionUserImplCopyWith<_$PrivacyExceptionUserImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GetPrivacyAppSettings _$GetPrivacyAppSettingsFromJson(
    Map<String, dynamic> json) {
  return _GetPrivacyAppSettings.fromJson(json);
}

/// @nodoc
mixin _$GetPrivacyAppSettings {
  GetPrivacyNotifications get notifications =>
      throw _privateConstructorUsedError;
  GetPrivacyCommentFilters get commentFilters =>
      throw _privateConstructorUsedError;
  bool get allowScreenshots => throw _privateConstructorUsedError;
  String get chatWallpaper => throw _privateConstructorUsedError;
  bool get isAppLockEnabled => throw _privateConstructorUsedError;
  String get themeMode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetPrivacyAppSettingsCopyWith<GetPrivacyAppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPrivacyAppSettingsCopyWith<$Res> {
  factory $GetPrivacyAppSettingsCopyWith(GetPrivacyAppSettings value,
          $Res Function(GetPrivacyAppSettings) then) =
      _$GetPrivacyAppSettingsCopyWithImpl<$Res, GetPrivacyAppSettings>;
  @useResult
  $Res call(
      {GetPrivacyNotifications notifications,
      GetPrivacyCommentFilters commentFilters,
      bool allowScreenshots,
      String chatWallpaper,
      bool isAppLockEnabled,
      String themeMode});

  $GetPrivacyNotificationsCopyWith<$Res> get notifications;
  $GetPrivacyCommentFiltersCopyWith<$Res> get commentFilters;
}

/// @nodoc
class _$GetPrivacyAppSettingsCopyWithImpl<$Res,
        $Val extends GetPrivacyAppSettings>
    implements $GetPrivacyAppSettingsCopyWith<$Res> {
  _$GetPrivacyAppSettingsCopyWithImpl(this._value, this._then);

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
              as GetPrivacyNotifications,
      commentFilters: null == commentFilters
          ? _value.commentFilters
          : commentFilters // ignore: cast_nullable_to_non_nullable
              as GetPrivacyCommentFilters,
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
  $GetPrivacyNotificationsCopyWith<$Res> get notifications {
    return $GetPrivacyNotificationsCopyWith<$Res>(_value.notifications,
        (value) {
      return _then(_value.copyWith(notifications: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GetPrivacyCommentFiltersCopyWith<$Res> get commentFilters {
    return $GetPrivacyCommentFiltersCopyWith<$Res>(_value.commentFilters,
        (value) {
      return _then(_value.copyWith(commentFilters: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetPrivacyAppSettingsImplCopyWith<$Res>
    implements $GetPrivacyAppSettingsCopyWith<$Res> {
  factory _$$GetPrivacyAppSettingsImplCopyWith(
          _$GetPrivacyAppSettingsImpl value,
          $Res Function(_$GetPrivacyAppSettingsImpl) then) =
      __$$GetPrivacyAppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GetPrivacyNotifications notifications,
      GetPrivacyCommentFilters commentFilters,
      bool allowScreenshots,
      String chatWallpaper,
      bool isAppLockEnabled,
      String themeMode});

  @override
  $GetPrivacyNotificationsCopyWith<$Res> get notifications;
  @override
  $GetPrivacyCommentFiltersCopyWith<$Res> get commentFilters;
}

/// @nodoc
class __$$GetPrivacyAppSettingsImplCopyWithImpl<$Res>
    extends _$GetPrivacyAppSettingsCopyWithImpl<$Res,
        _$GetPrivacyAppSettingsImpl>
    implements _$$GetPrivacyAppSettingsImplCopyWith<$Res> {
  __$$GetPrivacyAppSettingsImplCopyWithImpl(_$GetPrivacyAppSettingsImpl _value,
      $Res Function(_$GetPrivacyAppSettingsImpl) _then)
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
    return _then(_$GetPrivacyAppSettingsImpl(
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as GetPrivacyNotifications,
      commentFilters: null == commentFilters
          ? _value.commentFilters
          : commentFilters // ignore: cast_nullable_to_non_nullable
              as GetPrivacyCommentFilters,
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
class _$GetPrivacyAppSettingsImpl implements _GetPrivacyAppSettings {
  const _$GetPrivacyAppSettingsImpl(
      {required this.notifications,
      required this.commentFilters,
      this.allowScreenshots = true,
      this.chatWallpaper = '',
      this.isAppLockEnabled = false,
      this.themeMode = 'system'});

  factory _$GetPrivacyAppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetPrivacyAppSettingsImplFromJson(json);

  @override
  final GetPrivacyNotifications notifications;
  @override
  final GetPrivacyCommentFilters commentFilters;
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
    return 'GetPrivacyAppSettings(notifications: $notifications, commentFilters: $commentFilters, allowScreenshots: $allowScreenshots, chatWallpaper: $chatWallpaper, isAppLockEnabled: $isAppLockEnabled, themeMode: $themeMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPrivacyAppSettingsImpl &&
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
  _$$GetPrivacyAppSettingsImplCopyWith<_$GetPrivacyAppSettingsImpl>
      get copyWith => __$$GetPrivacyAppSettingsImplCopyWithImpl<
          _$GetPrivacyAppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPrivacyAppSettingsImplToJson(
      this,
    );
  }
}

abstract class _GetPrivacyAppSettings implements GetPrivacyAppSettings {
  const factory _GetPrivacyAppSettings(
      {required final GetPrivacyNotifications notifications,
      required final GetPrivacyCommentFilters commentFilters,
      final bool allowScreenshots,
      final String chatWallpaper,
      final bool isAppLockEnabled,
      final String themeMode}) = _$GetPrivacyAppSettingsImpl;

  factory _GetPrivacyAppSettings.fromJson(Map<String, dynamic> json) =
      _$GetPrivacyAppSettingsImpl.fromJson;

  @override
  GetPrivacyNotifications get notifications;
  @override
  GetPrivacyCommentFilters get commentFilters;
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
  _$$GetPrivacyAppSettingsImplCopyWith<_$GetPrivacyAppSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GetPrivacyNotifications _$GetPrivacyNotificationsFromJson(
    Map<String, dynamic> json) {
  return _GetPrivacyNotifications.fromJson(json);
}

/// @nodoc
mixin _$GetPrivacyNotifications {
  bool get calls => throw _privateConstructorUsedError;
  bool get groups => throw _privateConstructorUsedError;
  bool get messages => throw _privateConstructorUsedError;
  bool get sound => throw _privateConstructorUsedError;
  bool get vibrate => throw _privateConstructorUsedError;
  String get messageTone => throw _privateConstructorUsedError;
  String get groupTone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetPrivacyNotificationsCopyWith<GetPrivacyNotifications> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPrivacyNotificationsCopyWith<$Res> {
  factory $GetPrivacyNotificationsCopyWith(GetPrivacyNotifications value,
          $Res Function(GetPrivacyNotifications) then) =
      _$GetPrivacyNotificationsCopyWithImpl<$Res, GetPrivacyNotifications>;
  @useResult
  $Res call(
      {bool calls,
      bool groups,
      bool messages,
      bool sound,
      bool vibrate,
      String messageTone,
      String groupTone});
}

/// @nodoc
class _$GetPrivacyNotificationsCopyWithImpl<$Res,
        $Val extends GetPrivacyNotifications>
    implements $GetPrivacyNotificationsCopyWith<$Res> {
  _$GetPrivacyNotificationsCopyWithImpl(this._value, this._then);

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
    Object? messageTone = null,
    Object? groupTone = null,
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
      messageTone: null == messageTone
          ? _value.messageTone
          : messageTone // ignore: cast_nullable_to_non_nullable
              as String,
      groupTone: null == groupTone
          ? _value.groupTone
          : groupTone // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetPrivacyNotificationsImplCopyWith<$Res>
    implements $GetPrivacyNotificationsCopyWith<$Res> {
  factory _$$GetPrivacyNotificationsImplCopyWith(
          _$GetPrivacyNotificationsImpl value,
          $Res Function(_$GetPrivacyNotificationsImpl) then) =
      __$$GetPrivacyNotificationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool calls,
      bool groups,
      bool messages,
      bool sound,
      bool vibrate,
      String messageTone,
      String groupTone});
}

/// @nodoc
class __$$GetPrivacyNotificationsImplCopyWithImpl<$Res>
    extends _$GetPrivacyNotificationsCopyWithImpl<$Res,
        _$GetPrivacyNotificationsImpl>
    implements _$$GetPrivacyNotificationsImplCopyWith<$Res> {
  __$$GetPrivacyNotificationsImplCopyWithImpl(
      _$GetPrivacyNotificationsImpl _value,
      $Res Function(_$GetPrivacyNotificationsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calls = null,
    Object? groups = null,
    Object? messages = null,
    Object? sound = null,
    Object? vibrate = null,
    Object? messageTone = null,
    Object? groupTone = null,
  }) {
    return _then(_$GetPrivacyNotificationsImpl(
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
      messageTone: null == messageTone
          ? _value.messageTone
          : messageTone // ignore: cast_nullable_to_non_nullable
              as String,
      groupTone: null == groupTone
          ? _value.groupTone
          : groupTone // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetPrivacyNotificationsImpl implements _GetPrivacyNotifications {
  const _$GetPrivacyNotificationsImpl(
      {this.calls = true,
      this.groups = true,
      this.messages = true,
      this.sound = true,
      this.vibrate = true,
      this.messageTone = 'Default',
      this.groupTone = 'Default'});

  factory _$GetPrivacyNotificationsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetPrivacyNotificationsImplFromJson(json);

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
  @JsonKey()
  final String messageTone;
  @override
  @JsonKey()
  final String groupTone;

  @override
  String toString() {
    return 'GetPrivacyNotifications(calls: $calls, groups: $groups, messages: $messages, sound: $sound, vibrate: $vibrate, messageTone: $messageTone, groupTone: $groupTone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPrivacyNotificationsImpl &&
            (identical(other.calls, calls) || other.calls == calls) &&
            (identical(other.groups, groups) || other.groups == groups) &&
            (identical(other.messages, messages) ||
                other.messages == messages) &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.vibrate, vibrate) || other.vibrate == vibrate) &&
            (identical(other.messageTone, messageTone) ||
                other.messageTone == messageTone) &&
            (identical(other.groupTone, groupTone) ||
                other.groupTone == groupTone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, calls, groups, messages, sound,
      vibrate, messageTone, groupTone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetPrivacyNotificationsImplCopyWith<_$GetPrivacyNotificationsImpl>
      get copyWith => __$$GetPrivacyNotificationsImplCopyWithImpl<
          _$GetPrivacyNotificationsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPrivacyNotificationsImplToJson(
      this,
    );
  }
}

abstract class _GetPrivacyNotifications implements GetPrivacyNotifications {
  const factory _GetPrivacyNotifications(
      {final bool calls,
      final bool groups,
      final bool messages,
      final bool sound,
      final bool vibrate,
      final String messageTone,
      final String groupTone}) = _$GetPrivacyNotificationsImpl;

  factory _GetPrivacyNotifications.fromJson(Map<String, dynamic> json) =
      _$GetPrivacyNotificationsImpl.fromJson;

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
  String get messageTone;
  @override
  String get groupTone;
  @override
  @JsonKey(ignore: true)
  _$$GetPrivacyNotificationsImplCopyWith<_$GetPrivacyNotificationsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GetPrivacyCommentFilters _$GetPrivacyCommentFiltersFromJson(
    Map<String, dynamic> json) {
  return _GetPrivacyCommentFilters.fromJson(json);
}

/// @nodoc
mixin _$GetPrivacyCommentFilters {
  bool get filterSpam => throw _privateConstructorUsedError;
  bool get filterOffensiveWords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetPrivacyCommentFiltersCopyWith<GetPrivacyCommentFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPrivacyCommentFiltersCopyWith<$Res> {
  factory $GetPrivacyCommentFiltersCopyWith(GetPrivacyCommentFilters value,
          $Res Function(GetPrivacyCommentFilters) then) =
      _$GetPrivacyCommentFiltersCopyWithImpl<$Res, GetPrivacyCommentFilters>;
  @useResult
  $Res call({bool filterSpam, bool filterOffensiveWords});
}

/// @nodoc
class _$GetPrivacyCommentFiltersCopyWithImpl<$Res,
        $Val extends GetPrivacyCommentFilters>
    implements $GetPrivacyCommentFiltersCopyWith<$Res> {
  _$GetPrivacyCommentFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filterSpam = null,
    Object? filterOffensiveWords = null,
  }) {
    return _then(_value.copyWith(
      filterSpam: null == filterSpam
          ? _value.filterSpam
          : filterSpam // ignore: cast_nullable_to_non_nullable
              as bool,
      filterOffensiveWords: null == filterOffensiveWords
          ? _value.filterOffensiveWords
          : filterOffensiveWords // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetPrivacyCommentFiltersImplCopyWith<$Res>
    implements $GetPrivacyCommentFiltersCopyWith<$Res> {
  factory _$$GetPrivacyCommentFiltersImplCopyWith(
          _$GetPrivacyCommentFiltersImpl value,
          $Res Function(_$GetPrivacyCommentFiltersImpl) then) =
      __$$GetPrivacyCommentFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool filterSpam, bool filterOffensiveWords});
}

/// @nodoc
class __$$GetPrivacyCommentFiltersImplCopyWithImpl<$Res>
    extends _$GetPrivacyCommentFiltersCopyWithImpl<$Res,
        _$GetPrivacyCommentFiltersImpl>
    implements _$$GetPrivacyCommentFiltersImplCopyWith<$Res> {
  __$$GetPrivacyCommentFiltersImplCopyWithImpl(
      _$GetPrivacyCommentFiltersImpl _value,
      $Res Function(_$GetPrivacyCommentFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filterSpam = null,
    Object? filterOffensiveWords = null,
  }) {
    return _then(_$GetPrivacyCommentFiltersImpl(
      filterSpam: null == filterSpam
          ? _value.filterSpam
          : filterSpam // ignore: cast_nullable_to_non_nullable
              as bool,
      filterOffensiveWords: null == filterOffensiveWords
          ? _value.filterOffensiveWords
          : filterOffensiveWords // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetPrivacyCommentFiltersImpl implements _GetPrivacyCommentFilters {
  const _$GetPrivacyCommentFiltersImpl(
      {this.filterSpam = true, this.filterOffensiveWords = true});

  factory _$GetPrivacyCommentFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetPrivacyCommentFiltersImplFromJson(json);

  @override
  @JsonKey()
  final bool filterSpam;
  @override
  @JsonKey()
  final bool filterOffensiveWords;

  @override
  String toString() {
    return 'GetPrivacyCommentFilters(filterSpam: $filterSpam, filterOffensiveWords: $filterOffensiveWords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPrivacyCommentFiltersImpl &&
            (identical(other.filterSpam, filterSpam) ||
                other.filterSpam == filterSpam) &&
            (identical(other.filterOffensiveWords, filterOffensiveWords) ||
                other.filterOffensiveWords == filterOffensiveWords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, filterSpam, filterOffensiveWords);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetPrivacyCommentFiltersImplCopyWith<_$GetPrivacyCommentFiltersImpl>
      get copyWith => __$$GetPrivacyCommentFiltersImplCopyWithImpl<
          _$GetPrivacyCommentFiltersImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPrivacyCommentFiltersImplToJson(
      this,
    );
  }
}

abstract class _GetPrivacyCommentFilters implements GetPrivacyCommentFilters {
  const factory _GetPrivacyCommentFilters(
      {final bool filterSpam,
      final bool filterOffensiveWords}) = _$GetPrivacyCommentFiltersImpl;

  factory _GetPrivacyCommentFilters.fromJson(Map<String, dynamic> json) =
      _$GetPrivacyCommentFiltersImpl.fromJson;

  @override
  bool get filterSpam;
  @override
  bool get filterOffensiveWords;
  @override
  @JsonKey(ignore: true)
  _$$GetPrivacyCommentFiltersImplCopyWith<_$GetPrivacyCommentFiltersImpl>
      get copyWith => throw _privateConstructorUsedError;
}
