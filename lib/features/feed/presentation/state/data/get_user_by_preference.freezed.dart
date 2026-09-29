// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_user_by_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetUserByPreference _$GetUserByPreferenceFromJson(Map<String, dynamic> json) {
  return _GetUserByPreference.fromJson(json);
}

/// @nodoc
mixin _$GetUserByPreference {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  MatchingUsersData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetUserByPreferenceCopyWith<GetUserByPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetUserByPreferenceCopyWith<$Res> {
  factory $GetUserByPreferenceCopyWith(
          GetUserByPreference value, $Res Function(GetUserByPreference) then) =
      _$GetUserByPreferenceCopyWithImpl<$Res, GetUserByPreference>;
  @useResult
  $Res call({bool success, String message, MatchingUsersData data});

  $MatchingUsersDataCopyWith<$Res> get data;
}

/// @nodoc
class _$GetUserByPreferenceCopyWithImpl<$Res, $Val extends GetUserByPreference>
    implements $GetUserByPreferenceCopyWith<$Res> {
  _$GetUserByPreferenceCopyWithImpl(this._value, this._then);

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
              as MatchingUsersData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MatchingUsersDataCopyWith<$Res> get data {
    return $MatchingUsersDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetUserByPreferenceImplCopyWith<$Res>
    implements $GetUserByPreferenceCopyWith<$Res> {
  factory _$$GetUserByPreferenceImplCopyWith(_$GetUserByPreferenceImpl value,
          $Res Function(_$GetUserByPreferenceImpl) then) =
      __$$GetUserByPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, MatchingUsersData data});

  @override
  $MatchingUsersDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$GetUserByPreferenceImplCopyWithImpl<$Res>
    extends _$GetUserByPreferenceCopyWithImpl<$Res, _$GetUserByPreferenceImpl>
    implements _$$GetUserByPreferenceImplCopyWith<$Res> {
  __$$GetUserByPreferenceImplCopyWithImpl(_$GetUserByPreferenceImpl _value,
      $Res Function(_$GetUserByPreferenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$GetUserByPreferenceImpl(
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
              as MatchingUsersData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetUserByPreferenceImpl implements _GetUserByPreference {
  const _$GetUserByPreferenceImpl(
      {required this.success, required this.message, required this.data});

  factory _$GetUserByPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetUserByPreferenceImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final MatchingUsersData data;

  @override
  String toString() {
    return 'GetUserByPreference(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetUserByPreferenceImpl &&
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
  _$$GetUserByPreferenceImplCopyWith<_$GetUserByPreferenceImpl> get copyWith =>
      __$$GetUserByPreferenceImplCopyWithImpl<_$GetUserByPreferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetUserByPreferenceImplToJson(
      this,
    );
  }
}

abstract class _GetUserByPreference implements GetUserByPreference {
  const factory _GetUserByPreference(
      {required final bool success,
      required final String message,
      required final MatchingUsersData data}) = _$GetUserByPreferenceImpl;

  factory _GetUserByPreference.fromJson(Map<String, dynamic> json) =
      _$GetUserByPreferenceImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  MatchingUsersData get data;
  @override
  @JsonKey(ignore: true)
  _$$GetUserByPreferenceImplCopyWith<_$GetUserByPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchingUsersData _$MatchingUsersDataFromJson(Map<String, dynamic> json) {
  return _MatchingUsersData.fromJson(json);
}

/// @nodoc
mixin _$MatchingUsersData {
  Preferences get myPreferences => throw _privateConstructorUsedError;
  List<MatchingUser> get matchingUsers => throw _privateConstructorUsedError;
  int get totalMatches => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MatchingUsersDataCopyWith<MatchingUsersData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchingUsersDataCopyWith<$Res> {
  factory $MatchingUsersDataCopyWith(
          MatchingUsersData value, $Res Function(MatchingUsersData) then) =
      _$MatchingUsersDataCopyWithImpl<$Res, MatchingUsersData>;
  @useResult
  $Res call(
      {Preferences myPreferences,
      List<MatchingUser> matchingUsers,
      int totalMatches});

  $PreferencesCopyWith<$Res> get myPreferences;
}

/// @nodoc
class _$MatchingUsersDataCopyWithImpl<$Res, $Val extends MatchingUsersData>
    implements $MatchingUsersDataCopyWith<$Res> {
  _$MatchingUsersDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? myPreferences = null,
    Object? matchingUsers = null,
    Object? totalMatches = null,
  }) {
    return _then(_value.copyWith(
      myPreferences: null == myPreferences
          ? _value.myPreferences
          : myPreferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
      matchingUsers: null == matchingUsers
          ? _value.matchingUsers
          : matchingUsers // ignore: cast_nullable_to_non_nullable
              as List<MatchingUser>,
      totalMatches: null == totalMatches
          ? _value.totalMatches
          : totalMatches // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PreferencesCopyWith<$Res> get myPreferences {
    return $PreferencesCopyWith<$Res>(_value.myPreferences, (value) {
      return _then(_value.copyWith(myPreferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchingUsersDataImplCopyWith<$Res>
    implements $MatchingUsersDataCopyWith<$Res> {
  factory _$$MatchingUsersDataImplCopyWith(_$MatchingUsersDataImpl value,
          $Res Function(_$MatchingUsersDataImpl) then) =
      __$$MatchingUsersDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Preferences myPreferences,
      List<MatchingUser> matchingUsers,
      int totalMatches});

  @override
  $PreferencesCopyWith<$Res> get myPreferences;
}

/// @nodoc
class __$$MatchingUsersDataImplCopyWithImpl<$Res>
    extends _$MatchingUsersDataCopyWithImpl<$Res, _$MatchingUsersDataImpl>
    implements _$$MatchingUsersDataImplCopyWith<$Res> {
  __$$MatchingUsersDataImplCopyWithImpl(_$MatchingUsersDataImpl _value,
      $Res Function(_$MatchingUsersDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? myPreferences = null,
    Object? matchingUsers = null,
    Object? totalMatches = null,
  }) {
    return _then(_$MatchingUsersDataImpl(
      myPreferences: null == myPreferences
          ? _value.myPreferences
          : myPreferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
      matchingUsers: null == matchingUsers
          ? _value._matchingUsers
          : matchingUsers // ignore: cast_nullable_to_non_nullable
              as List<MatchingUser>,
      totalMatches: null == totalMatches
          ? _value.totalMatches
          : totalMatches // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchingUsersDataImpl implements _MatchingUsersData {
  const _$MatchingUsersDataImpl(
      {required this.myPreferences,
      required final List<MatchingUser> matchingUsers,
      required this.totalMatches})
      : _matchingUsers = matchingUsers;

  factory _$MatchingUsersDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchingUsersDataImplFromJson(json);

  @override
  final Preferences myPreferences;
  final List<MatchingUser> _matchingUsers;
  @override
  List<MatchingUser> get matchingUsers {
    if (_matchingUsers is EqualUnmodifiableListView) return _matchingUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchingUsers);
  }

  @override
  final int totalMatches;

  @override
  String toString() {
    return 'MatchingUsersData(myPreferences: $myPreferences, matchingUsers: $matchingUsers, totalMatches: $totalMatches)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchingUsersDataImpl &&
            (identical(other.myPreferences, myPreferences) ||
                other.myPreferences == myPreferences) &&
            const DeepCollectionEquality()
                .equals(other._matchingUsers, _matchingUsers) &&
            (identical(other.totalMatches, totalMatches) ||
                other.totalMatches == totalMatches));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, myPreferences,
      const DeepCollectionEquality().hash(_matchingUsers), totalMatches);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchingUsersDataImplCopyWith<_$MatchingUsersDataImpl> get copyWith =>
      __$$MatchingUsersDataImplCopyWithImpl<_$MatchingUsersDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchingUsersDataImplToJson(
      this,
    );
  }
}

abstract class _MatchingUsersData implements MatchingUsersData {
  const factory _MatchingUsersData(
      {required final Preferences myPreferences,
      required final List<MatchingUser> matchingUsers,
      required final int totalMatches}) = _$MatchingUsersDataImpl;

  factory _MatchingUsersData.fromJson(Map<String, dynamic> json) =
      _$MatchingUsersDataImpl.fromJson;

  @override
  Preferences get myPreferences;
  @override
  List<MatchingUser> get matchingUsers;
  @override
  int get totalMatches;
  @override
  @JsonKey(ignore: true)
  _$$MatchingUsersDataImplCopyWith<_$MatchingUsersDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchingUser _$MatchingUserFromJson(Map<String, dynamic> json) {
  return _MatchingUser.fromJson(json);
}

/// @nodoc
mixin _$MatchingUser {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int get v => throw _privateConstructorUsedError;
  String get about => throw _privateConstructorUsedError;
  AccountInfoRequest get accountInfoRequest =>
      throw _privateConstructorUsedError;
  String get accountStatus => throw _privateConstructorUsedError;
  AdminFlags get adminFlags => throw _privateConstructorUsedError;
  List<String> get blockedUsers => throw _privateConstructorUsedError;
  List<String> get contacts => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  DataSettings get dataSettings => throw _privateConstructorUsedError;
  List<String> get fcmTokens => throw _privateConstructorUsedError;
  bool get hasPassword => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  bool get isProfileComplete => throw _privateConstructorUsedError;
  String get lastActive => throw _privateConstructorUsedError;
  Privacy get privacy => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;
  int get reportCount => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  Security get security => throw _privateConstructorUsedError;
  Settings get settings => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  Preferences get preferences => throw _privateConstructorUsedError;
  Preferences get matchedPreferences => throw _privateConstructorUsedError;
  int get matchCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MatchingUserCopyWith<MatchingUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchingUserCopyWith<$Res> {
  factory $MatchingUserCopyWith(
          MatchingUser value, $Res Function(MatchingUser) then) =
      _$MatchingUserCopyWithImpl<$Res, MatchingUser>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String phone,
      @JsonKey(name: '__v') int v,
      String about,
      AccountInfoRequest accountInfoRequest,
      String accountStatus,
      AdminFlags adminFlags,
      List<String> blockedUsers,
      List<String> contacts,
      String createdAt,
      DataSettings dataSettings,
      List<String> fcmTokens,
      bool hasPassword,
      bool isOnline,
      bool isProfileComplete,
      String lastActive,
      Privacy privacy,
      String profilePicture,
      int reportCount,
      String role,
      Security security,
      Settings settings,
      String updatedAt,
      String? username,
      String? email,
      Preferences preferences,
      Preferences matchedPreferences,
      int matchCount});

  $AccountInfoRequestCopyWith<$Res> get accountInfoRequest;
  $AdminFlagsCopyWith<$Res> get adminFlags;
  $DataSettingsCopyWith<$Res> get dataSettings;
  $PrivacyCopyWith<$Res> get privacy;
  $SecurityCopyWith<$Res> get security;
  $SettingsCopyWith<$Res> get settings;
  $PreferencesCopyWith<$Res> get preferences;
  $PreferencesCopyWith<$Res> get matchedPreferences;
}

/// @nodoc
class _$MatchingUserCopyWithImpl<$Res, $Val extends MatchingUser>
    implements $MatchingUserCopyWith<$Res> {
  _$MatchingUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? v = null,
    Object? about = null,
    Object? accountInfoRequest = null,
    Object? accountStatus = null,
    Object? adminFlags = null,
    Object? blockedUsers = null,
    Object? contacts = null,
    Object? createdAt = null,
    Object? dataSettings = null,
    Object? fcmTokens = null,
    Object? hasPassword = null,
    Object? isOnline = null,
    Object? isProfileComplete = null,
    Object? lastActive = null,
    Object? privacy = null,
    Object? profilePicture = null,
    Object? reportCount = null,
    Object? role = null,
    Object? security = null,
    Object? settings = null,
    Object? updatedAt = null,
    Object? username = freezed,
    Object? email = freezed,
    Object? preferences = null,
    Object? matchedPreferences = null,
    Object? matchCount = null,
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
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int,
      about: null == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String,
      accountInfoRequest: null == accountInfoRequest
          ? _value.accountInfoRequest
          : accountInfoRequest // ignore: cast_nullable_to_non_nullable
              as AccountInfoRequest,
      accountStatus: null == accountStatus
          ? _value.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      adminFlags: null == adminFlags
          ? _value.adminFlags
          : adminFlags // ignore: cast_nullable_to_non_nullable
              as AdminFlags,
      blockedUsers: null == blockedUsers
          ? _value.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contacts: null == contacts
          ? _value.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      dataSettings: null == dataSettings
          ? _value.dataSettings
          : dataSettings // ignore: cast_nullable_to_non_nullable
              as DataSettings,
      fcmTokens: null == fcmTokens
          ? _value.fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasPassword: null == hasPassword
          ? _value.hasPassword
          : hasPassword // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isProfileComplete: null == isProfileComplete
          ? _value.isProfileComplete
          : isProfileComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as String,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as Privacy,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      security: null == security
          ? _value.security
          : security // ignore: cast_nullable_to_non_nullable
              as Security,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Settings,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
      matchedPreferences: null == matchedPreferences
          ? _value.matchedPreferences
          : matchedPreferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
      matchCount: null == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AccountInfoRequestCopyWith<$Res> get accountInfoRequest {
    return $AccountInfoRequestCopyWith<$Res>(_value.accountInfoRequest,
        (value) {
      return _then(_value.copyWith(accountInfoRequest: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AdminFlagsCopyWith<$Res> get adminFlags {
    return $AdminFlagsCopyWith<$Res>(_value.adminFlags, (value) {
      return _then(_value.copyWith(adminFlags: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DataSettingsCopyWith<$Res> get dataSettings {
    return $DataSettingsCopyWith<$Res>(_value.dataSettings, (value) {
      return _then(_value.copyWith(dataSettings: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PrivacyCopyWith<$Res> get privacy {
    return $PrivacyCopyWith<$Res>(_value.privacy, (value) {
      return _then(_value.copyWith(privacy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SecurityCopyWith<$Res> get security {
    return $SecurityCopyWith<$Res>(_value.security, (value) {
      return _then(_value.copyWith(security: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SettingsCopyWith<$Res> get settings {
    return $SettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PreferencesCopyWith<$Res> get preferences {
    return $PreferencesCopyWith<$Res>(_value.preferences, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PreferencesCopyWith<$Res> get matchedPreferences {
    return $PreferencesCopyWith<$Res>(_value.matchedPreferences, (value) {
      return _then(_value.copyWith(matchedPreferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchingUserImplCopyWith<$Res>
    implements $MatchingUserCopyWith<$Res> {
  factory _$$MatchingUserImplCopyWith(
          _$MatchingUserImpl value, $Res Function(_$MatchingUserImpl) then) =
      __$$MatchingUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String phone,
      @JsonKey(name: '__v') int v,
      String about,
      AccountInfoRequest accountInfoRequest,
      String accountStatus,
      AdminFlags adminFlags,
      List<String> blockedUsers,
      List<String> contacts,
      String createdAt,
      DataSettings dataSettings,
      List<String> fcmTokens,
      bool hasPassword,
      bool isOnline,
      bool isProfileComplete,
      String lastActive,
      Privacy privacy,
      String profilePicture,
      int reportCount,
      String role,
      Security security,
      Settings settings,
      String updatedAt,
      String? username,
      String? email,
      Preferences preferences,
      Preferences matchedPreferences,
      int matchCount});

  @override
  $AccountInfoRequestCopyWith<$Res> get accountInfoRequest;
  @override
  $AdminFlagsCopyWith<$Res> get adminFlags;
  @override
  $DataSettingsCopyWith<$Res> get dataSettings;
  @override
  $PrivacyCopyWith<$Res> get privacy;
  @override
  $SecurityCopyWith<$Res> get security;
  @override
  $SettingsCopyWith<$Res> get settings;
  @override
  $PreferencesCopyWith<$Res> get preferences;
  @override
  $PreferencesCopyWith<$Res> get matchedPreferences;
}

/// @nodoc
class __$$MatchingUserImplCopyWithImpl<$Res>
    extends _$MatchingUserCopyWithImpl<$Res, _$MatchingUserImpl>
    implements _$$MatchingUserImplCopyWith<$Res> {
  __$$MatchingUserImplCopyWithImpl(
      _$MatchingUserImpl _value, $Res Function(_$MatchingUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phone = null,
    Object? v = null,
    Object? about = null,
    Object? accountInfoRequest = null,
    Object? accountStatus = null,
    Object? adminFlags = null,
    Object? blockedUsers = null,
    Object? contacts = null,
    Object? createdAt = null,
    Object? dataSettings = null,
    Object? fcmTokens = null,
    Object? hasPassword = null,
    Object? isOnline = null,
    Object? isProfileComplete = null,
    Object? lastActive = null,
    Object? privacy = null,
    Object? profilePicture = null,
    Object? reportCount = null,
    Object? role = null,
    Object? security = null,
    Object? settings = null,
    Object? updatedAt = null,
    Object? username = freezed,
    Object? email = freezed,
    Object? preferences = null,
    Object? matchedPreferences = null,
    Object? matchCount = null,
  }) {
    return _then(_$MatchingUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      v: null == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as int,
      about: null == about
          ? _value.about
          : about // ignore: cast_nullable_to_non_nullable
              as String,
      accountInfoRequest: null == accountInfoRequest
          ? _value.accountInfoRequest
          : accountInfoRequest // ignore: cast_nullable_to_non_nullable
              as AccountInfoRequest,
      accountStatus: null == accountStatus
          ? _value.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      adminFlags: null == adminFlags
          ? _value.adminFlags
          : adminFlags // ignore: cast_nullable_to_non_nullable
              as AdminFlags,
      blockedUsers: null == blockedUsers
          ? _value._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contacts: null == contacts
          ? _value._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      dataSettings: null == dataSettings
          ? _value.dataSettings
          : dataSettings // ignore: cast_nullable_to_non_nullable
              as DataSettings,
      fcmTokens: null == fcmTokens
          ? _value._fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasPassword: null == hasPassword
          ? _value.hasPassword
          : hasPassword // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isProfileComplete: null == isProfileComplete
          ? _value.isProfileComplete
          : isProfileComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActive: null == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as String,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as Privacy,
      profilePicture: null == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      security: null == security
          ? _value.security
          : security // ignore: cast_nullable_to_non_nullable
              as Security,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Settings,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
      matchedPreferences: null == matchedPreferences
          ? _value.matchedPreferences
          : matchedPreferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
      matchCount: null == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchingUserImpl implements _MatchingUser {
  const _$MatchingUserImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.phone,
      @JsonKey(name: '__v') required this.v,
      required this.about,
      required this.accountInfoRequest,
      required this.accountStatus,
      required this.adminFlags,
      required final List<String> blockedUsers,
      required final List<String> contacts,
      required this.createdAt,
      required this.dataSettings,
      required final List<String> fcmTokens,
      required this.hasPassword,
      required this.isOnline,
      required this.isProfileComplete,
      required this.lastActive,
      required this.privacy,
      required this.profilePicture,
      required this.reportCount,
      required this.role,
      required this.security,
      required this.settings,
      required this.updatedAt,
      this.username,
      this.email,
      required this.preferences,
      required this.matchedPreferences,
      required this.matchCount})
      : _blockedUsers = blockedUsers,
        _contacts = contacts,
        _fcmTokens = fcmTokens;

  factory _$MatchingUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchingUserImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String phone;
  @override
  @JsonKey(name: '__v')
  final int v;
  @override
  final String about;
  @override
  final AccountInfoRequest accountInfoRequest;
  @override
  final String accountStatus;
  @override
  final AdminFlags adminFlags;
  final List<String> _blockedUsers;
  @override
  List<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  final List<String> _contacts;
  @override
  List<String> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  @override
  final String createdAt;
  @override
  final DataSettings dataSettings;
  final List<String> _fcmTokens;
  @override
  List<String> get fcmTokens {
    if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fcmTokens);
  }

  @override
  final bool hasPassword;
  @override
  final bool isOnline;
  @override
  final bool isProfileComplete;
  @override
  final String lastActive;
  @override
  final Privacy privacy;
  @override
  final String profilePicture;
  @override
  final int reportCount;
  @override
  final String role;
  @override
  final Security security;
  @override
  final Settings settings;
  @override
  final String updatedAt;
  @override
  final String? username;
  @override
  final String? email;
  @override
  final Preferences preferences;
  @override
  final Preferences matchedPreferences;
  @override
  final int matchCount;

  @override
  String toString() {
    return 'MatchingUser(id: $id, phone: $phone, v: $v, about: $about, accountInfoRequest: $accountInfoRequest, accountStatus: $accountStatus, adminFlags: $adminFlags, blockedUsers: $blockedUsers, contacts: $contacts, createdAt: $createdAt, dataSettings: $dataSettings, fcmTokens: $fcmTokens, hasPassword: $hasPassword, isOnline: $isOnline, isProfileComplete: $isProfileComplete, lastActive: $lastActive, privacy: $privacy, profilePicture: $profilePicture, reportCount: $reportCount, role: $role, security: $security, settings: $settings, updatedAt: $updatedAt, username: $username, email: $email, preferences: $preferences, matchedPreferences: $matchedPreferences, matchCount: $matchCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchingUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.about, about) || other.about == about) &&
            (identical(other.accountInfoRequest, accountInfoRequest) ||
                other.accountInfoRequest == accountInfoRequest) &&
            (identical(other.accountStatus, accountStatus) ||
                other.accountStatus == accountStatus) &&
            (identical(other.adminFlags, adminFlags) ||
                other.adminFlags == adminFlags) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.dataSettings, dataSettings) ||
                other.dataSettings == dataSettings) &&
            const DeepCollectionEquality()
                .equals(other._fcmTokens, _fcmTokens) &&
            (identical(other.hasPassword, hasPassword) ||
                other.hasPassword == hasPassword) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isProfileComplete, isProfileComplete) ||
                other.isProfileComplete == isProfileComplete) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.reportCount, reportCount) ||
                other.reportCount == reportCount) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.security, security) ||
                other.security == security) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.matchedPreferences, matchedPreferences) ||
                other.matchedPreferences == matchedPreferences) &&
            (identical(other.matchCount, matchCount) ||
                other.matchCount == matchCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        phone,
        v,
        about,
        accountInfoRequest,
        accountStatus,
        adminFlags,
        const DeepCollectionEquality().hash(_blockedUsers),
        const DeepCollectionEquality().hash(_contacts),
        createdAt,
        dataSettings,
        const DeepCollectionEquality().hash(_fcmTokens),
        hasPassword,
        isOnline,
        isProfileComplete,
        lastActive,
        privacy,
        profilePicture,
        reportCount,
        role,
        security,
        settings,
        updatedAt,
        username,
        email,
        preferences,
        matchedPreferences,
        matchCount
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchingUserImplCopyWith<_$MatchingUserImpl> get copyWith =>
      __$$MatchingUserImplCopyWithImpl<_$MatchingUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchingUserImplToJson(
      this,
    );
  }
}

abstract class _MatchingUser implements MatchingUser {
  const factory _MatchingUser(
      {@JsonKey(name: '_id') required final String id,
      required final String phone,
      @JsonKey(name: '__v') required final int v,
      required final String about,
      required final AccountInfoRequest accountInfoRequest,
      required final String accountStatus,
      required final AdminFlags adminFlags,
      required final List<String> blockedUsers,
      required final List<String> contacts,
      required final String createdAt,
      required final DataSettings dataSettings,
      required final List<String> fcmTokens,
      required final bool hasPassword,
      required final bool isOnline,
      required final bool isProfileComplete,
      required final String lastActive,
      required final Privacy privacy,
      required final String profilePicture,
      required final int reportCount,
      required final String role,
      required final Security security,
      required final Settings settings,
      required final String updatedAt,
      final String? username,
      final String? email,
      required final Preferences preferences,
      required final Preferences matchedPreferences,
      required final int matchCount}) = _$MatchingUserImpl;

  factory _MatchingUser.fromJson(Map<String, dynamic> json) =
      _$MatchingUserImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get phone;
  @override
  @JsonKey(name: '__v')
  int get v;
  @override
  String get about;
  @override
  AccountInfoRequest get accountInfoRequest;
  @override
  String get accountStatus;
  @override
  AdminFlags get adminFlags;
  @override
  List<String> get blockedUsers;
  @override
  List<String> get contacts;
  @override
  String get createdAt;
  @override
  DataSettings get dataSettings;
  @override
  List<String> get fcmTokens;
  @override
  bool get hasPassword;
  @override
  bool get isOnline;
  @override
  bool get isProfileComplete;
  @override
  String get lastActive;
  @override
  Privacy get privacy;
  @override
  String get profilePicture;
  @override
  int get reportCount;
  @override
  String get role;
  @override
  Security get security;
  @override
  Settings get settings;
  @override
  String get updatedAt;
  @override
  String? get username;
  @override
  String? get email;
  @override
  Preferences get preferences;
  @override
  Preferences get matchedPreferences;
  @override
  int get matchCount;
  @override
  @JsonKey(ignore: true)
  _$$MatchingUserImplCopyWith<_$MatchingUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
