// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_privacy_settings_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpdatePrivacySettingsDto _$UpdatePrivacySettingsDtoFromJson(
    Map<String, dynamic> json) {
  return _UpdatePrivacySettingsDto.fromJson(json);
}

/// @nodoc
mixin _$UpdatePrivacySettingsDto {
  bool? get isPrivateAccount => throw _privateConstructorUsedError;
  PrivacySettingsDto? get privacy => throw _privateConstructorUsedError;
  AppSettingsDto? get settings => throw _privateConstructorUsedError;
  String? get defaultMessageTimer => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdatePrivacySettingsDtoCopyWith<UpdatePrivacySettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdatePrivacySettingsDtoCopyWith<$Res> {
  factory $UpdatePrivacySettingsDtoCopyWith(UpdatePrivacySettingsDto value,
          $Res Function(UpdatePrivacySettingsDto) then) =
      _$UpdatePrivacySettingsDtoCopyWithImpl<$Res, UpdatePrivacySettingsDto>;
  @useResult
  $Res call(
      {bool? isPrivateAccount,
      PrivacySettingsDto? privacy,
      AppSettingsDto? settings,
      String? defaultMessageTimer});

  $PrivacySettingsDtoCopyWith<$Res>? get privacy;
  $AppSettingsDtoCopyWith<$Res>? get settings;
}

/// @nodoc
class _$UpdatePrivacySettingsDtoCopyWithImpl<$Res,
        $Val extends UpdatePrivacySettingsDto>
    implements $UpdatePrivacySettingsDtoCopyWith<$Res> {
  _$UpdatePrivacySettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPrivateAccount = freezed,
    Object? privacy = freezed,
    Object? settings = freezed,
    Object? defaultMessageTimer = freezed,
  }) {
    return _then(_value.copyWith(
      isPrivateAccount: freezed == isPrivateAccount
          ? _value.isPrivateAccount
          : isPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool?,
      privacy: freezed == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as PrivacySettingsDto?,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as AppSettingsDto?,
      defaultMessageTimer: freezed == defaultMessageTimer
          ? _value.defaultMessageTimer
          : defaultMessageTimer // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PrivacySettingsDtoCopyWith<$Res>? get privacy {
    if (_value.privacy == null) {
      return null;
    }

    return $PrivacySettingsDtoCopyWith<$Res>(_value.privacy!, (value) {
      return _then(_value.copyWith(privacy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AppSettingsDtoCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $AppSettingsDtoCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdatePrivacySettingsDtoImplCopyWith<$Res>
    implements $UpdatePrivacySettingsDtoCopyWith<$Res> {
  factory _$$UpdatePrivacySettingsDtoImplCopyWith(
          _$UpdatePrivacySettingsDtoImpl value,
          $Res Function(_$UpdatePrivacySettingsDtoImpl) then) =
      __$$UpdatePrivacySettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? isPrivateAccount,
      PrivacySettingsDto? privacy,
      AppSettingsDto? settings,
      String? defaultMessageTimer});

  @override
  $PrivacySettingsDtoCopyWith<$Res>? get privacy;
  @override
  $AppSettingsDtoCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$UpdatePrivacySettingsDtoImplCopyWithImpl<$Res>
    extends _$UpdatePrivacySettingsDtoCopyWithImpl<$Res,
        _$UpdatePrivacySettingsDtoImpl>
    implements _$$UpdatePrivacySettingsDtoImplCopyWith<$Res> {
  __$$UpdatePrivacySettingsDtoImplCopyWithImpl(
      _$UpdatePrivacySettingsDtoImpl _value,
      $Res Function(_$UpdatePrivacySettingsDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPrivateAccount = freezed,
    Object? privacy = freezed,
    Object? settings = freezed,
    Object? defaultMessageTimer = freezed,
  }) {
    return _then(_$UpdatePrivacySettingsDtoImpl(
      isPrivateAccount: freezed == isPrivateAccount
          ? _value.isPrivateAccount
          : isPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool?,
      privacy: freezed == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as PrivacySettingsDto?,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as AppSettingsDto?,
      defaultMessageTimer: freezed == defaultMessageTimer
          ? _value.defaultMessageTimer
          : defaultMessageTimer // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$UpdatePrivacySettingsDtoImpl implements _UpdatePrivacySettingsDto {
  const _$UpdatePrivacySettingsDtoImpl(
      {this.isPrivateAccount,
      this.privacy,
      this.settings,
      this.defaultMessageTimer});

  factory _$UpdatePrivacySettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdatePrivacySettingsDtoImplFromJson(json);

  @override
  final bool? isPrivateAccount;
  @override
  final PrivacySettingsDto? privacy;
  @override
  final AppSettingsDto? settings;
  @override
  final String? defaultMessageTimer;

  @override
  String toString() {
    return 'UpdatePrivacySettingsDto(isPrivateAccount: $isPrivateAccount, privacy: $privacy, settings: $settings, defaultMessageTimer: $defaultMessageTimer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdatePrivacySettingsDtoImpl &&
            (identical(other.isPrivateAccount, isPrivateAccount) ||
                other.isPrivateAccount == isPrivateAccount) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.defaultMessageTimer, defaultMessageTimer) ||
                other.defaultMessageTimer == defaultMessageTimer));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, isPrivateAccount, privacy, settings, defaultMessageTimer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdatePrivacySettingsDtoImplCopyWith<_$UpdatePrivacySettingsDtoImpl>
      get copyWith => __$$UpdatePrivacySettingsDtoImplCopyWithImpl<
          _$UpdatePrivacySettingsDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdatePrivacySettingsDtoImplToJson(
      this,
    );
  }
}

abstract class _UpdatePrivacySettingsDto implements UpdatePrivacySettingsDto {
  const factory _UpdatePrivacySettingsDto(
      {final bool? isPrivateAccount,
      final PrivacySettingsDto? privacy,
      final AppSettingsDto? settings,
      final String? defaultMessageTimer}) = _$UpdatePrivacySettingsDtoImpl;

  factory _UpdatePrivacySettingsDto.fromJson(Map<String, dynamic> json) =
      _$UpdatePrivacySettingsDtoImpl.fromJson;

  @override
  bool? get isPrivateAccount;
  @override
  PrivacySettingsDto? get privacy;
  @override
  AppSettingsDto? get settings;
  @override
  String? get defaultMessageTimer;
  @override
  @JsonKey(ignore: true)
  _$$UpdatePrivacySettingsDtoImplCopyWith<_$UpdatePrivacySettingsDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PrivacySettingsDto _$PrivacySettingsDtoFromJson(Map<String, dynamic> json) {
  return _PrivacySettingsDto.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettingsDto {
  String? get statusVisibility => throw _privateConstructorUsedError;
  List<String>? get statusExceptions => throw _privateConstructorUsedError;
  List<String>? get statusIncluded => throw _privateConstructorUsedError;
  String? get likedVideosVisibility => throw _privateConstructorUsedError;
  String? get commentPermissions => throw _privateConstructorUsedError;
  String? get duetPermissions => throw _privateConstructorUsedError;
  String? get messagePermissions => throw _privateConstructorUsedError;
  String? get about => throw _privateConstructorUsedError;
  String? get groups => throw _privateConstructorUsedError;
  String? get lastSeen => throw _privateConstructorUsedError;
  String? get profilePhoto => throw _privateConstructorUsedError;
  bool? get readReceipts => throw _privateConstructorUsedError;
  List<String>? get lastSeenExceptions => throw _privateConstructorUsedError;
  List<String>? get profilePhotoExceptions =>
      throw _privateConstructorUsedError;
  List<String>? get aboutExceptions => throw _privateConstructorUsedError;
  List<String>? get groupExceptions => throw _privateConstructorUsedError;
  String? get videosVisibility => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrivacySettingsDtoCopyWith<PrivacySettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacySettingsDtoCopyWith<$Res> {
  factory $PrivacySettingsDtoCopyWith(
          PrivacySettingsDto value, $Res Function(PrivacySettingsDto) then) =
      _$PrivacySettingsDtoCopyWithImpl<$Res, PrivacySettingsDto>;
  @useResult
  $Res call(
      {String? statusVisibility,
      List<String>? statusExceptions,
      List<String>? statusIncluded,
      String? likedVideosVisibility,
      String? commentPermissions,
      String? duetPermissions,
      String? messagePermissions,
      String? about,
      String? groups,
      String? lastSeen,
      String? profilePhoto,
      bool? readReceipts,
      List<String>? lastSeenExceptions,
      List<String>? profilePhotoExceptions,
      List<String>? aboutExceptions,
      List<String>? groupExceptions,
      String? videosVisibility});
}

/// @nodoc
class _$PrivacySettingsDtoCopyWithImpl<$Res, $Val extends PrivacySettingsDto>
    implements $PrivacySettingsDtoCopyWith<$Res> {
  _$PrivacySettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? statusVisibility = freezed,
    Object? statusExceptions = freezed,
    Object? statusIncluded = freezed,
    Object? likedVideosVisibility = freezed,
    Object? commentPermissions = freezed,
    Object? duetPermissions = freezed,
    Object? messagePermissions = freezed,
    Object? about = freezed,
    Object? groups = freezed,
    Object? lastSeen = freezed,
    Object? profilePhoto = freezed,
    Object? readReceipts = freezed,
    Object? lastSeenExceptions = freezed,
    Object? profilePhotoExceptions = freezed,
    Object? aboutExceptions = freezed,
    Object? groupExceptions = freezed,
    Object? videosVisibility = freezed,
  }) {
    return _then(_value.copyWith(
      statusVisibility: freezed == statusVisibility
          ? _value.statusVisibility
          : statusVisibility // ignore: cast_nullable_to_non_nullable
              as String?,
      statusExceptions: freezed == statusExceptions
          ? _value.statusExceptions
          : statusExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      statusIncluded: freezed == statusIncluded
          ? _value.statusIncluded
          : statusIncluded // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      likedVideosVisibility: freezed == likedVideosVisibility
          ? _value.likedVideosVisibility
          : likedVideosVisibility // ignore: cast_nullable_to_non_nullable
              as String?,
      commentPermissions: freezed == commentPermissions
          ? _value.commentPermissions
          : commentPermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      duetPermissions: freezed == duetPermissions
          ? _value.duetPermissions
          : duetPermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      messagePermissions: freezed == messagePermissions
          ? _value.messagePermissions
          : messagePermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      about: freezed == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String?,
      groups: freezed == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      readReceipts: freezed == readReceipts
          ? _value.readReceipts
          : readReceipts // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastSeenExceptions: freezed == lastSeenExceptions
          ? _value.lastSeenExceptions
          : lastSeenExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      profilePhotoExceptions: freezed == profilePhotoExceptions
          ? _value.profilePhotoExceptions
          : profilePhotoExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      aboutExceptions: freezed == aboutExceptions
          ? _value.aboutExceptions
          : aboutExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      groupExceptions: freezed == groupExceptions
          ? _value.groupExceptions
          : groupExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      videosVisibility: freezed == videosVisibility
          ? _value.videosVisibility
          : videosVisibility // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrivacySettingsDtoImplCopyWith<$Res>
    implements $PrivacySettingsDtoCopyWith<$Res> {
  factory _$$PrivacySettingsDtoImplCopyWith(_$PrivacySettingsDtoImpl value,
          $Res Function(_$PrivacySettingsDtoImpl) then) =
      __$$PrivacySettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? statusVisibility,
      List<String>? statusExceptions,
      List<String>? statusIncluded,
      String? likedVideosVisibility,
      String? commentPermissions,
      String? duetPermissions,
      String? messagePermissions,
      String? about,
      String? groups,
      String? lastSeen,
      String? profilePhoto,
      bool? readReceipts,
      List<String>? lastSeenExceptions,
      List<String>? profilePhotoExceptions,
      List<String>? aboutExceptions,
      List<String>? groupExceptions,
      String? videosVisibility});
}

/// @nodoc
class __$$PrivacySettingsDtoImplCopyWithImpl<$Res>
    extends _$PrivacySettingsDtoCopyWithImpl<$Res, _$PrivacySettingsDtoImpl>
    implements _$$PrivacySettingsDtoImplCopyWith<$Res> {
  __$$PrivacySettingsDtoImplCopyWithImpl(_$PrivacySettingsDtoImpl _value,
      $Res Function(_$PrivacySettingsDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? statusVisibility = freezed,
    Object? statusExceptions = freezed,
    Object? statusIncluded = freezed,
    Object? likedVideosVisibility = freezed,
    Object? commentPermissions = freezed,
    Object? duetPermissions = freezed,
    Object? messagePermissions = freezed,
    Object? about = freezed,
    Object? groups = freezed,
    Object? lastSeen = freezed,
    Object? profilePhoto = freezed,
    Object? readReceipts = freezed,
    Object? lastSeenExceptions = freezed,
    Object? profilePhotoExceptions = freezed,
    Object? aboutExceptions = freezed,
    Object? groupExceptions = freezed,
    Object? videosVisibility = freezed,
  }) {
    return _then(_$PrivacySettingsDtoImpl(
      statusVisibility: freezed == statusVisibility
          ? _value.statusVisibility
          : statusVisibility // ignore: cast_nullable_to_non_nullable
              as String?,
      statusExceptions: freezed == statusExceptions
          ? _value._statusExceptions
          : statusExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      statusIncluded: freezed == statusIncluded
          ? _value._statusIncluded
          : statusIncluded // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      likedVideosVisibility: freezed == likedVideosVisibility
          ? _value.likedVideosVisibility
          : likedVideosVisibility // ignore: cast_nullable_to_non_nullable
              as String?,
      commentPermissions: freezed == commentPermissions
          ? _value.commentPermissions
          : commentPermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      duetPermissions: freezed == duetPermissions
          ? _value.duetPermissions
          : duetPermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      messagePermissions: freezed == messagePermissions
          ? _value.messagePermissions
          : messagePermissions // ignore: cast_nullable_to_non_nullable
              as String?,
      about: freezed == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String?,
      groups: freezed == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      readReceipts: freezed == readReceipts
          ? _value.readReceipts
          : readReceipts // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastSeenExceptions: freezed == lastSeenExceptions
          ? _value._lastSeenExceptions
          : lastSeenExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      profilePhotoExceptions: freezed == profilePhotoExceptions
          ? _value._profilePhotoExceptions
          : profilePhotoExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      aboutExceptions: freezed == aboutExceptions
          ? _value._aboutExceptions
          : aboutExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      groupExceptions: freezed == groupExceptions
          ? _value._groupExceptions
          : groupExceptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      videosVisibility: freezed == videosVisibility
          ? _value.videosVisibility
          : videosVisibility // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$PrivacySettingsDtoImpl implements _PrivacySettingsDto {
  const _$PrivacySettingsDtoImpl(
      {this.statusVisibility,
      final List<String>? statusExceptions,
      final List<String>? statusIncluded,
      this.likedVideosVisibility,
      this.commentPermissions,
      this.duetPermissions,
      this.messagePermissions,
      this.about,
      this.groups,
      this.lastSeen,
      this.profilePhoto,
      this.readReceipts,
      final List<String>? lastSeenExceptions,
      final List<String>? profilePhotoExceptions,
      final List<String>? aboutExceptions,
      final List<String>? groupExceptions,
      this.videosVisibility})
      : _statusExceptions = statusExceptions,
        _statusIncluded = statusIncluded,
        _lastSeenExceptions = lastSeenExceptions,
        _profilePhotoExceptions = profilePhotoExceptions,
        _aboutExceptions = aboutExceptions,
        _groupExceptions = groupExceptions;

  factory _$PrivacySettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacySettingsDtoImplFromJson(json);

  @override
  final String? statusVisibility;
  final List<String>? _statusExceptions;
  @override
  List<String>? get statusExceptions {
    final value = _statusExceptions;
    if (value == null) return null;
    if (_statusExceptions is EqualUnmodifiableListView)
      return _statusExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _statusIncluded;
  @override
  List<String>? get statusIncluded {
    final value = _statusIncluded;
    if (value == null) return null;
    if (_statusIncluded is EqualUnmodifiableListView) return _statusIncluded;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? likedVideosVisibility;
  @override
  final String? commentPermissions;
  @override
  final String? duetPermissions;
  @override
  final String? messagePermissions;
  @override
  final String? about;
  @override
  final String? groups;
  @override
  final String? lastSeen;
  @override
  final String? profilePhoto;
  @override
  final bool? readReceipts;
  final List<String>? _lastSeenExceptions;
  @override
  List<String>? get lastSeenExceptions {
    final value = _lastSeenExceptions;
    if (value == null) return null;
    if (_lastSeenExceptions is EqualUnmodifiableListView)
      return _lastSeenExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _profilePhotoExceptions;
  @override
  List<String>? get profilePhotoExceptions {
    final value = _profilePhotoExceptions;
    if (value == null) return null;
    if (_profilePhotoExceptions is EqualUnmodifiableListView)
      return _profilePhotoExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _aboutExceptions;
  @override
  List<String>? get aboutExceptions {
    final value = _aboutExceptions;
    if (value == null) return null;
    if (_aboutExceptions is EqualUnmodifiableListView) return _aboutExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _groupExceptions;
  @override
  List<String>? get groupExceptions {
    final value = _groupExceptions;
    if (value == null) return null;
    if (_groupExceptions is EqualUnmodifiableListView) return _groupExceptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? videosVisibility;

  @override
  String toString() {
    return 'PrivacySettingsDto(statusVisibility: $statusVisibility, statusExceptions: $statusExceptions, statusIncluded: $statusIncluded, likedVideosVisibility: $likedVideosVisibility, commentPermissions: $commentPermissions, duetPermissions: $duetPermissions, messagePermissions: $messagePermissions, about: $about, groups: $groups, lastSeen: $lastSeen, profilePhoto: $profilePhoto, readReceipts: $readReceipts, lastSeenExceptions: $lastSeenExceptions, profilePhotoExceptions: $profilePhotoExceptions, aboutExceptions: $aboutExceptions, groupExceptions: $groupExceptions, videosVisibility: $videosVisibility)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsDtoImpl &&
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
            const DeepCollectionEquality().equals(
                other._profilePhotoExceptions, _profilePhotoExceptions) &&
            const DeepCollectionEquality()
                .equals(other._aboutExceptions, _aboutExceptions) &&
            const DeepCollectionEquality()
                .equals(other._groupExceptions, _groupExceptions) &&
            (identical(other.videosVisibility, videosVisibility) ||
                other.videosVisibility == videosVisibility));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
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
      const DeepCollectionEquality().hash(_profilePhotoExceptions),
      const DeepCollectionEquality().hash(_aboutExceptions),
      const DeepCollectionEquality().hash(_groupExceptions),
      videosVisibility);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacySettingsDtoImplCopyWith<_$PrivacySettingsDtoImpl> get copyWith =>
      __$$PrivacySettingsDtoImplCopyWithImpl<_$PrivacySettingsDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacySettingsDtoImplToJson(
      this,
    );
  }
}

abstract class _PrivacySettingsDto implements PrivacySettingsDto {
  const factory _PrivacySettingsDto(
      {final String? statusVisibility,
      final List<String>? statusExceptions,
      final List<String>? statusIncluded,
      final String? likedVideosVisibility,
      final String? commentPermissions,
      final String? duetPermissions,
      final String? messagePermissions,
      final String? about,
      final String? groups,
      final String? lastSeen,
      final String? profilePhoto,
      final bool? readReceipts,
      final List<String>? lastSeenExceptions,
      final List<String>? profilePhotoExceptions,
      final List<String>? aboutExceptions,
      final List<String>? groupExceptions,
      final String? videosVisibility}) = _$PrivacySettingsDtoImpl;

  factory _PrivacySettingsDto.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsDtoImpl.fromJson;

  @override
  String? get statusVisibility;
  @override
  List<String>? get statusExceptions;
  @override
  List<String>? get statusIncluded;
  @override
  String? get likedVideosVisibility;
  @override
  String? get commentPermissions;
  @override
  String? get duetPermissions;
  @override
  String? get messagePermissions;
  @override
  String? get about;
  @override
  String? get groups;
  @override
  String? get lastSeen;
  @override
  String? get profilePhoto;
  @override
  bool? get readReceipts;
  @override
  List<String>? get lastSeenExceptions;
  @override
  List<String>? get profilePhotoExceptions;
  @override
  List<String>? get aboutExceptions;
  @override
  List<String>? get groupExceptions;
  @override
  String? get videosVisibility;
  @override
  @JsonKey(ignore: true)
  _$$PrivacySettingsDtoImplCopyWith<_$PrivacySettingsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppSettingsDto _$AppSettingsDtoFromJson(Map<String, dynamic> json) {
  return _AppSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$AppSettingsDto {
  NotificationSettingsDto? get notifications =>
      throw _privateConstructorUsedError;
  CommentFiltersDto? get commentFilters => throw _privateConstructorUsedError;
  bool? get allowScreenshots => throw _privateConstructorUsedError;
  String? get chatWallpaper => throw _privateConstructorUsedError;
  bool? get isAppLockEnabled => throw _privateConstructorUsedError;
  String? get themeMode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppSettingsDtoCopyWith<AppSettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsDtoCopyWith<$Res> {
  factory $AppSettingsDtoCopyWith(
          AppSettingsDto value, $Res Function(AppSettingsDto) then) =
      _$AppSettingsDtoCopyWithImpl<$Res, AppSettingsDto>;
  @useResult
  $Res call(
      {NotificationSettingsDto? notifications,
      CommentFiltersDto? commentFilters,
      bool? allowScreenshots,
      String? chatWallpaper,
      bool? isAppLockEnabled,
      String? themeMode});

  $NotificationSettingsDtoCopyWith<$Res>? get notifications;
  $CommentFiltersDtoCopyWith<$Res>? get commentFilters;
}

/// @nodoc
class _$AppSettingsDtoCopyWithImpl<$Res, $Val extends AppSettingsDto>
    implements $AppSettingsDtoCopyWith<$Res> {
  _$AppSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = freezed,
    Object? commentFilters = freezed,
    Object? allowScreenshots = freezed,
    Object? chatWallpaper = freezed,
    Object? isAppLockEnabled = freezed,
    Object? themeMode = freezed,
  }) {
    return _then(_value.copyWith(
      notifications: freezed == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as NotificationSettingsDto?,
      commentFilters: freezed == commentFilters
          ? _value.commentFilters
          : commentFilters // ignore: cast_nullable_to_non_nullable
              as CommentFiltersDto?,
      allowScreenshots: freezed == allowScreenshots
          ? _value.allowScreenshots
          : allowScreenshots // ignore: cast_nullable_to_non_nullable
              as bool?,
      chatWallpaper: freezed == chatWallpaper
          ? _value.chatWallpaper
          : chatWallpaper // ignore: cast_nullable_to_non_nullable
              as String?,
      isAppLockEnabled: freezed == isAppLockEnabled
          ? _value.isAppLockEnabled
          : isAppLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      themeMode: freezed == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationSettingsDtoCopyWith<$Res>? get notifications {
    if (_value.notifications == null) {
      return null;
    }

    return $NotificationSettingsDtoCopyWith<$Res>(_value.notifications!,
        (value) {
      return _then(_value.copyWith(notifications: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CommentFiltersDtoCopyWith<$Res>? get commentFilters {
    if (_value.commentFilters == null) {
      return null;
    }

    return $CommentFiltersDtoCopyWith<$Res>(_value.commentFilters!, (value) {
      return _then(_value.copyWith(commentFilters: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppSettingsDtoImplCopyWith<$Res>
    implements $AppSettingsDtoCopyWith<$Res> {
  factory _$$AppSettingsDtoImplCopyWith(_$AppSettingsDtoImpl value,
          $Res Function(_$AppSettingsDtoImpl) then) =
      __$$AppSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {NotificationSettingsDto? notifications,
      CommentFiltersDto? commentFilters,
      bool? allowScreenshots,
      String? chatWallpaper,
      bool? isAppLockEnabled,
      String? themeMode});

  @override
  $NotificationSettingsDtoCopyWith<$Res>? get notifications;
  @override
  $CommentFiltersDtoCopyWith<$Res>? get commentFilters;
}

/// @nodoc
class __$$AppSettingsDtoImplCopyWithImpl<$Res>
    extends _$AppSettingsDtoCopyWithImpl<$Res, _$AppSettingsDtoImpl>
    implements _$$AppSettingsDtoImplCopyWith<$Res> {
  __$$AppSettingsDtoImplCopyWithImpl(
      _$AppSettingsDtoImpl _value, $Res Function(_$AppSettingsDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = freezed,
    Object? commentFilters = freezed,
    Object? allowScreenshots = freezed,
    Object? chatWallpaper = freezed,
    Object? isAppLockEnabled = freezed,
    Object? themeMode = freezed,
  }) {
    return _then(_$AppSettingsDtoImpl(
      notifications: freezed == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as NotificationSettingsDto?,
      commentFilters: freezed == commentFilters
          ? _value.commentFilters
          : commentFilters // ignore: cast_nullable_to_non_nullable
              as CommentFiltersDto?,
      allowScreenshots: freezed == allowScreenshots
          ? _value.allowScreenshots
          : allowScreenshots // ignore: cast_nullable_to_non_nullable
              as bool?,
      chatWallpaper: freezed == chatWallpaper
          ? _value.chatWallpaper
          : chatWallpaper // ignore: cast_nullable_to_non_nullable
              as String?,
      isAppLockEnabled: freezed == isAppLockEnabled
          ? _value.isAppLockEnabled
          : isAppLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      themeMode: freezed == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$AppSettingsDtoImpl implements _AppSettingsDto {
  const _$AppSettingsDtoImpl(
      {this.notifications,
      this.commentFilters,
      this.allowScreenshots,
      this.chatWallpaper,
      this.isAppLockEnabled,
      this.themeMode});

  factory _$AppSettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsDtoImplFromJson(json);

  @override
  final NotificationSettingsDto? notifications;
  @override
  final CommentFiltersDto? commentFilters;
  @override
  final bool? allowScreenshots;
  @override
  final String? chatWallpaper;
  @override
  final bool? isAppLockEnabled;
  @override
  final String? themeMode;

  @override
  String toString() {
    return 'AppSettingsDto(notifications: $notifications, commentFilters: $commentFilters, allowScreenshots: $allowScreenshots, chatWallpaper: $chatWallpaper, isAppLockEnabled: $isAppLockEnabled, themeMode: $themeMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsDtoImpl &&
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
  _$$AppSettingsDtoImplCopyWith<_$AppSettingsDtoImpl> get copyWith =>
      __$$AppSettingsDtoImplCopyWithImpl<_$AppSettingsDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsDtoImplToJson(
      this,
    );
  }
}

abstract class _AppSettingsDto implements AppSettingsDto {
  const factory _AppSettingsDto(
      {final NotificationSettingsDto? notifications,
      final CommentFiltersDto? commentFilters,
      final bool? allowScreenshots,
      final String? chatWallpaper,
      final bool? isAppLockEnabled,
      final String? themeMode}) = _$AppSettingsDtoImpl;

  factory _AppSettingsDto.fromJson(Map<String, dynamic> json) =
      _$AppSettingsDtoImpl.fromJson;

  @override
  NotificationSettingsDto? get notifications;
  @override
  CommentFiltersDto? get commentFilters;
  @override
  bool? get allowScreenshots;
  @override
  String? get chatWallpaper;
  @override
  bool? get isAppLockEnabled;
  @override
  String? get themeMode;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsDtoImplCopyWith<_$AppSettingsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSettingsDto _$NotificationSettingsDtoFromJson(
    Map<String, dynamic> json) {
  return _NotificationSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettingsDto {
  bool? get calls => throw _privateConstructorUsedError;
  bool? get groups => throw _privateConstructorUsedError;
  bool? get messages => throw _privateConstructorUsedError;
  bool? get sound => throw _privateConstructorUsedError;
  bool? get vibrate => throw _privateConstructorUsedError;
  String? get messageTone => throw _privateConstructorUsedError;
  String? get groupTone => throw _privateConstructorUsedError;
  double? get notificationVolume => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationSettingsDtoCopyWith<NotificationSettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsDtoCopyWith<$Res> {
  factory $NotificationSettingsDtoCopyWith(NotificationSettingsDto value,
          $Res Function(NotificationSettingsDto) then) =
      _$NotificationSettingsDtoCopyWithImpl<$Res, NotificationSettingsDto>;
  @useResult
  $Res call(
      {bool? calls,
      bool? groups,
      bool? messages,
      bool? sound,
      bool? vibrate,
      String? messageTone,
      String? groupTone,
      double? notificationVolume});
}

/// @nodoc
class _$NotificationSettingsDtoCopyWithImpl<$Res,
        $Val extends NotificationSettingsDto>
    implements $NotificationSettingsDtoCopyWith<$Res> {
  _$NotificationSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calls = freezed,
    Object? groups = freezed,
    Object? messages = freezed,
    Object? sound = freezed,
    Object? vibrate = freezed,
    Object? messageTone = freezed,
    Object? groupTone = freezed,
    Object? notificationVolume = freezed,
  }) {
    return _then(_value.copyWith(
      calls: freezed == calls
          ? _value.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as bool?,
      groups: freezed == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as bool?,
      messages: freezed == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as bool?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool?,
      vibrate: freezed == vibrate
          ? _value.vibrate
          : vibrate // ignore: cast_nullable_to_non_nullable
              as bool?,
      messageTone: freezed == messageTone
          ? _value.messageTone
          : messageTone // ignore: cast_nullable_to_non_nullable
              as String?,
      groupTone: freezed == groupTone
          ? _value.groupTone
          : groupTone // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationVolume: freezed == notificationVolume
          ? _value.notificationVolume
          : notificationVolume // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsDtoImplCopyWith<$Res>
    implements $NotificationSettingsDtoCopyWith<$Res> {
  factory _$$NotificationSettingsDtoImplCopyWith(
          _$NotificationSettingsDtoImpl value,
          $Res Function(_$NotificationSettingsDtoImpl) then) =
      __$$NotificationSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? calls,
      bool? groups,
      bool? messages,
      bool? sound,
      bool? vibrate,
      String? messageTone,
      String? groupTone,
      double? notificationVolume});
}

/// @nodoc
class __$$NotificationSettingsDtoImplCopyWithImpl<$Res>
    extends _$NotificationSettingsDtoCopyWithImpl<$Res,
        _$NotificationSettingsDtoImpl>
    implements _$$NotificationSettingsDtoImplCopyWith<$Res> {
  __$$NotificationSettingsDtoImplCopyWithImpl(
      _$NotificationSettingsDtoImpl _value,
      $Res Function(_$NotificationSettingsDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calls = freezed,
    Object? groups = freezed,
    Object? messages = freezed,
    Object? sound = freezed,
    Object? vibrate = freezed,
    Object? messageTone = freezed,
    Object? groupTone = freezed,
    Object? notificationVolume = freezed,
  }) {
    return _then(_$NotificationSettingsDtoImpl(
      calls: freezed == calls
          ? _value.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as bool?,
      groups: freezed == groups
          ? _value.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as bool?,
      messages: freezed == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as bool?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool?,
      vibrate: freezed == vibrate
          ? _value.vibrate
          : vibrate // ignore: cast_nullable_to_non_nullable
              as bool?,
      messageTone: freezed == messageTone
          ? _value.messageTone
          : messageTone // ignore: cast_nullable_to_non_nullable
              as String?,
      groupTone: freezed == groupTone
          ? _value.groupTone
          : groupTone // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationVolume: freezed == notificationVolume
          ? _value.notificationVolume
          : notificationVolume // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$NotificationSettingsDtoImpl implements _NotificationSettingsDto {
  const _$NotificationSettingsDtoImpl(
      {this.calls,
      this.groups,
      this.messages,
      this.sound,
      this.vibrate,
      this.messageTone,
      this.groupTone,
      this.notificationVolume});

  factory _$NotificationSettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsDtoImplFromJson(json);

  @override
  final bool? calls;
  @override
  final bool? groups;
  @override
  final bool? messages;
  @override
  final bool? sound;
  @override
  final bool? vibrate;
  @override
  final String? messageTone;
  @override
  final String? groupTone;
  @override
  final double? notificationVolume;

  @override
  String toString() {
    return 'NotificationSettingsDto(calls: $calls, groups: $groups, messages: $messages, sound: $sound, vibrate: $vibrate, messageTone: $messageTone, groupTone: $groupTone, notificationVolume: $notificationVolume)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsDtoImpl &&
            (identical(other.calls, calls) || other.calls == calls) &&
            (identical(other.groups, groups) || other.groups == groups) &&
            (identical(other.messages, messages) ||
                other.messages == messages) &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.vibrate, vibrate) || other.vibrate == vibrate) &&
            (identical(other.messageTone, messageTone) ||
                other.messageTone == messageTone) &&
            (identical(other.groupTone, groupTone) ||
                other.groupTone == groupTone) &&
            (identical(other.notificationVolume, notificationVolume) ||
                other.notificationVolume == notificationVolume));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, calls, groups, messages, sound,
      vibrate, messageTone, groupTone, notificationVolume);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsDtoImplCopyWith<_$NotificationSettingsDtoImpl>
      get copyWith => __$$NotificationSettingsDtoImplCopyWithImpl<
          _$NotificationSettingsDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsDtoImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettingsDto implements NotificationSettingsDto {
  const factory _NotificationSettingsDto(
      {final bool? calls,
      final bool? groups,
      final bool? messages,
      final bool? sound,
      final bool? vibrate,
      final String? messageTone,
      final String? groupTone,
      final double? notificationVolume}) = _$NotificationSettingsDtoImpl;

  factory _NotificationSettingsDto.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsDtoImpl.fromJson;

  @override
  bool? get calls;
  @override
  bool? get groups;
  @override
  bool? get messages;
  @override
  bool? get sound;
  @override
  bool? get vibrate;
  @override
  String? get messageTone;
  @override
  String? get groupTone;
  @override
  double? get notificationVolume;
  @override
  @JsonKey(ignore: true)
  _$$NotificationSettingsDtoImplCopyWith<_$NotificationSettingsDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CommentFiltersDto _$CommentFiltersDtoFromJson(Map<String, dynamic> json) {
  return _CommentFiltersDto.fromJson(json);
}

/// @nodoc
mixin _$CommentFiltersDto {
  bool? get filterOffensiveWords => throw _privateConstructorUsedError;
  bool? get filterSpam => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommentFiltersDtoCopyWith<CommentFiltersDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentFiltersDtoCopyWith<$Res> {
  factory $CommentFiltersDtoCopyWith(
          CommentFiltersDto value, $Res Function(CommentFiltersDto) then) =
      _$CommentFiltersDtoCopyWithImpl<$Res, CommentFiltersDto>;
  @useResult
  $Res call({bool? filterOffensiveWords, bool? filterSpam});
}

/// @nodoc
class _$CommentFiltersDtoCopyWithImpl<$Res, $Val extends CommentFiltersDto>
    implements $CommentFiltersDtoCopyWith<$Res> {
  _$CommentFiltersDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filterOffensiveWords = freezed,
    Object? filterSpam = freezed,
  }) {
    return _then(_value.copyWith(
      filterOffensiveWords: freezed == filterOffensiveWords
          ? _value.filterOffensiveWords
          : filterOffensiveWords // ignore: cast_nullable_to_non_nullable
              as bool?,
      filterSpam: freezed == filterSpam
          ? _value.filterSpam
          : filterSpam // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentFiltersDtoImplCopyWith<$Res>
    implements $CommentFiltersDtoCopyWith<$Res> {
  factory _$$CommentFiltersDtoImplCopyWith(_$CommentFiltersDtoImpl value,
          $Res Function(_$CommentFiltersDtoImpl) then) =
      __$$CommentFiltersDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? filterOffensiveWords, bool? filterSpam});
}

/// @nodoc
class __$$CommentFiltersDtoImplCopyWithImpl<$Res>
    extends _$CommentFiltersDtoCopyWithImpl<$Res, _$CommentFiltersDtoImpl>
    implements _$$CommentFiltersDtoImplCopyWith<$Res> {
  __$$CommentFiltersDtoImplCopyWithImpl(_$CommentFiltersDtoImpl _value,
      $Res Function(_$CommentFiltersDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filterOffensiveWords = freezed,
    Object? filterSpam = freezed,
  }) {
    return _then(_$CommentFiltersDtoImpl(
      filterOffensiveWords: freezed == filterOffensiveWords
          ? _value.filterOffensiveWords
          : filterOffensiveWords // ignore: cast_nullable_to_non_nullable
              as bool?,
      filterSpam: freezed == filterSpam
          ? _value.filterSpam
          : filterSpam // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$CommentFiltersDtoImpl implements _CommentFiltersDto {
  const _$CommentFiltersDtoImpl({this.filterOffensiveWords, this.filterSpam});

  factory _$CommentFiltersDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentFiltersDtoImplFromJson(json);

  @override
  final bool? filterOffensiveWords;
  @override
  final bool? filterSpam;

  @override
  String toString() {
    return 'CommentFiltersDto(filterOffensiveWords: $filterOffensiveWords, filterSpam: $filterSpam)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentFiltersDtoImpl &&
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
  _$$CommentFiltersDtoImplCopyWith<_$CommentFiltersDtoImpl> get copyWith =>
      __$$CommentFiltersDtoImplCopyWithImpl<_$CommentFiltersDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentFiltersDtoImplToJson(
      this,
    );
  }
}

abstract class _CommentFiltersDto implements CommentFiltersDto {
  const factory _CommentFiltersDto(
      {final bool? filterOffensiveWords,
      final bool? filterSpam}) = _$CommentFiltersDtoImpl;

  factory _CommentFiltersDto.fromJson(Map<String, dynamic> json) =
      _$CommentFiltersDtoImpl.fromJson;

  @override
  bool? get filterOffensiveWords;
  @override
  bool? get filterSpam;
  @override
  @JsonKey(ignore: true)
  _$$CommentFiltersDtoImplCopyWith<_$CommentFiltersDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
