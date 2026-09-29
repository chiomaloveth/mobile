// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_preference_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreatePreferenceList _$CreatePreferenceListFromJson(Map<String, dynamic> json) {
  return _CreatePreferenceList.fromJson(json);
}

/// @nodoc
mixin _$CreatePreferenceList {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  UserPreferencesData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreatePreferenceListCopyWith<CreatePreferenceList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePreferenceListCopyWith<$Res> {
  factory $CreatePreferenceListCopyWith(CreatePreferenceList value,
          $Res Function(CreatePreferenceList) then) =
      _$CreatePreferenceListCopyWithImpl<$Res, CreatePreferenceList>;
  @useResult
  $Res call({bool success, String message, UserPreferencesData data});

  $UserPreferencesDataCopyWith<$Res> get data;
}

/// @nodoc
class _$CreatePreferenceListCopyWithImpl<$Res,
        $Val extends CreatePreferenceList>
    implements $CreatePreferenceListCopyWith<$Res> {
  _$CreatePreferenceListCopyWithImpl(this._value, this._then);

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
              as UserPreferencesData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesDataCopyWith<$Res> get data {
    return $UserPreferencesDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreatePreferenceListImplCopyWith<$Res>
    implements $CreatePreferenceListCopyWith<$Res> {
  factory _$$CreatePreferenceListImplCopyWith(_$CreatePreferenceListImpl value,
          $Res Function(_$CreatePreferenceListImpl) then) =
      __$$CreatePreferenceListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, UserPreferencesData data});

  @override
  $UserPreferencesDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$CreatePreferenceListImplCopyWithImpl<$Res>
    extends _$CreatePreferenceListCopyWithImpl<$Res, _$CreatePreferenceListImpl>
    implements _$$CreatePreferenceListImplCopyWith<$Res> {
  __$$CreatePreferenceListImplCopyWithImpl(_$CreatePreferenceListImpl _value,
      $Res Function(_$CreatePreferenceListImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$CreatePreferenceListImpl(
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
              as UserPreferencesData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatePreferenceListImpl implements _CreatePreferenceList {
  const _$CreatePreferenceListImpl(
      {required this.success, required this.message, required this.data});

  factory _$CreatePreferenceListImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatePreferenceListImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final UserPreferencesData data;

  @override
  String toString() {
    return 'CreatePreferenceList(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePreferenceListImpl &&
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
  _$$CreatePreferenceListImplCopyWith<_$CreatePreferenceListImpl>
      get copyWith =>
          __$$CreatePreferenceListImplCopyWithImpl<_$CreatePreferenceListImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatePreferenceListImplToJson(
      this,
    );
  }
}

abstract class _CreatePreferenceList implements CreatePreferenceList {
  const factory _CreatePreferenceList(
      {required final bool success,
      required final String message,
      required final UserPreferencesData data}) = _$CreatePreferenceListImpl;

  factory _CreatePreferenceList.fromJson(Map<String, dynamic> json) =
      _$CreatePreferenceListImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  UserPreferencesData get data;
  @override
  @JsonKey(ignore: true)
  _$$CreatePreferenceListImplCopyWith<_$CreatePreferenceListImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UserPreferencesData _$UserPreferencesDataFromJson(Map<String, dynamic> json) {
  return _UserPreferencesData.fromJson(json);
}

/// @nodoc
mixin _$UserPreferencesData {
  Security get security => throw _privateConstructorUsedError;
  AdminFlags get adminFlags => throw _privateConstructorUsedError;
  Privacy get privacy => throw _privateConstructorUsedError;
  DataSettings get dataSettings => throw _privateConstructorUsedError;
  AccountInfoRequest get accountInfoRequest =>
      throw _privateConstructorUsedError;
  Settings get settings => throw _privateConstructorUsedError;
  Preferences get preferences => throw _privateConstructorUsedError;
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int get v => throw _privateConstructorUsedError;
  String get about => throw _privateConstructorUsedError;
  String get accountStatus => throw _privateConstructorUsedError;
  List<dynamic> get blockedUsers => throw _privateConstructorUsedError;
  List<dynamic> get contacts => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  List<String> get fcmTokens => throw _privateConstructorUsedError;
  bool get hasPassword => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  bool get isProfileComplete => throw _privateConstructorUsedError;
  String get lastActive => throw _privateConstructorUsedError;
  List<dynamic> get profileImages => throw _privateConstructorUsedError;
  String get profilePicture => throw _privateConstructorUsedError;
  int get reportCount => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  int get postsCount => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  int get followersCount => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  int get followingCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserPreferencesDataCopyWith<UserPreferencesData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesDataCopyWith<$Res> {
  factory $UserPreferencesDataCopyWith(
          UserPreferencesData value, $Res Function(UserPreferencesData) then) =
      _$UserPreferencesDataCopyWithImpl<$Res, UserPreferencesData>;
  @useResult
  $Res call(
      {Security security,
      AdminFlags adminFlags,
      Privacy privacy,
      DataSettings dataSettings,
      AccountInfoRequest accountInfoRequest,
      Settings settings,
      Preferences preferences,
      @JsonKey(name: '_id') String id,
      String phone,
      @JsonKey(name: '__v') int v,
      String about,
      String accountStatus,
      List<dynamic> blockedUsers,
      List<dynamic> contacts,
      String createdAt,
      List<String> fcmTokens,
      bool hasPassword,
      bool isOnline,
      bool isProfileComplete,
      String lastActive,
      List<dynamic> profileImages,
      String profilePicture,
      int reportCount,
      String role,
      String updatedAt,
      String? email,
      String? username,
      @JsonKey(defaultValue: 0) int postsCount,
      @JsonKey(defaultValue: 0) int followersCount,
      @JsonKey(defaultValue: 0) int followingCount});

  $SecurityCopyWith<$Res> get security;
  $AdminFlagsCopyWith<$Res> get adminFlags;
  $PrivacyCopyWith<$Res> get privacy;
  $DataSettingsCopyWith<$Res> get dataSettings;
  $AccountInfoRequestCopyWith<$Res> get accountInfoRequest;
  $SettingsCopyWith<$Res> get settings;
  $PreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class _$UserPreferencesDataCopyWithImpl<$Res, $Val extends UserPreferencesData>
    implements $UserPreferencesDataCopyWith<$Res> {
  _$UserPreferencesDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? security = null,
    Object? adminFlags = null,
    Object? privacy = null,
    Object? dataSettings = null,
    Object? accountInfoRequest = null,
    Object? settings = null,
    Object? preferences = null,
    Object? id = null,
    Object? phone = null,
    Object? v = null,
    Object? about = null,
    Object? accountStatus = null,
    Object? blockedUsers = null,
    Object? contacts = null,
    Object? createdAt = null,
    Object? fcmTokens = null,
    Object? hasPassword = null,
    Object? isOnline = null,
    Object? isProfileComplete = null,
    Object? lastActive = null,
    Object? profileImages = null,
    Object? profilePicture = null,
    Object? reportCount = null,
    Object? role = null,
    Object? updatedAt = null,
    Object? email = freezed,
    Object? username = freezed,
    Object? postsCount = null,
    Object? followersCount = null,
    Object? followingCount = null,
  }) {
    return _then(_value.copyWith(
      security: null == security
          ? _value.security
          : security // ignore: cast_nullable_to_non_nullable
              as Security,
      adminFlags: null == adminFlags
          ? _value.adminFlags
          : adminFlags // ignore: cast_nullable_to_non_nullable
              as AdminFlags,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as Privacy,
      dataSettings: null == dataSettings
          ? _value.dataSettings
          : dataSettings // ignore: cast_nullable_to_non_nullable
              as DataSettings,
      accountInfoRequest: null == accountInfoRequest
          ? _value.accountInfoRequest
          : accountInfoRequest // ignore: cast_nullable_to_non_nullable
              as AccountInfoRequest,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Settings,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
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
      accountStatus: null == accountStatus
          ? _value.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      blockedUsers: null == blockedUsers
          ? _value.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      contacts: null == contacts
          ? _value.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
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
      profileImages: null == profileImages
          ? _value.profileImages
          : profileImages // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
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
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      postsCount: null == postsCount
          ? _value.postsCount
          : postsCount // ignore: cast_nullable_to_non_nullable
              as int,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
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
  $AdminFlagsCopyWith<$Res> get adminFlags {
    return $AdminFlagsCopyWith<$Res>(_value.adminFlags, (value) {
      return _then(_value.copyWith(adminFlags: value) as $Val);
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
  $DataSettingsCopyWith<$Res> get dataSettings {
    return $DataSettingsCopyWith<$Res>(_value.dataSettings, (value) {
      return _then(_value.copyWith(dataSettings: value) as $Val);
    });
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
}

/// @nodoc
abstract class _$$UserPreferencesDataImplCopyWith<$Res>
    implements $UserPreferencesDataCopyWith<$Res> {
  factory _$$UserPreferencesDataImplCopyWith(_$UserPreferencesDataImpl value,
          $Res Function(_$UserPreferencesDataImpl) then) =
      __$$UserPreferencesDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Security security,
      AdminFlags adminFlags,
      Privacy privacy,
      DataSettings dataSettings,
      AccountInfoRequest accountInfoRequest,
      Settings settings,
      Preferences preferences,
      @JsonKey(name: '_id') String id,
      String phone,
      @JsonKey(name: '__v') int v,
      String about,
      String accountStatus,
      List<dynamic> blockedUsers,
      List<dynamic> contacts,
      String createdAt,
      List<String> fcmTokens,
      bool hasPassword,
      bool isOnline,
      bool isProfileComplete,
      String lastActive,
      List<dynamic> profileImages,
      String profilePicture,
      int reportCount,
      String role,
      String updatedAt,
      String? email,
      String? username,
      @JsonKey(defaultValue: 0) int postsCount,
      @JsonKey(defaultValue: 0) int followersCount,
      @JsonKey(defaultValue: 0) int followingCount});

  @override
  $SecurityCopyWith<$Res> get security;
  @override
  $AdminFlagsCopyWith<$Res> get adminFlags;
  @override
  $PrivacyCopyWith<$Res> get privacy;
  @override
  $DataSettingsCopyWith<$Res> get dataSettings;
  @override
  $AccountInfoRequestCopyWith<$Res> get accountInfoRequest;
  @override
  $SettingsCopyWith<$Res> get settings;
  @override
  $PreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class __$$UserPreferencesDataImplCopyWithImpl<$Res>
    extends _$UserPreferencesDataCopyWithImpl<$Res, _$UserPreferencesDataImpl>
    implements _$$UserPreferencesDataImplCopyWith<$Res> {
  __$$UserPreferencesDataImplCopyWithImpl(_$UserPreferencesDataImpl _value,
      $Res Function(_$UserPreferencesDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? security = null,
    Object? adminFlags = null,
    Object? privacy = null,
    Object? dataSettings = null,
    Object? accountInfoRequest = null,
    Object? settings = null,
    Object? preferences = null,
    Object? id = null,
    Object? phone = null,
    Object? v = null,
    Object? about = null,
    Object? accountStatus = null,
    Object? blockedUsers = null,
    Object? contacts = null,
    Object? createdAt = null,
    Object? fcmTokens = null,
    Object? hasPassword = null,
    Object? isOnline = null,
    Object? isProfileComplete = null,
    Object? lastActive = null,
    Object? profileImages = null,
    Object? profilePicture = null,
    Object? reportCount = null,
    Object? role = null,
    Object? updatedAt = null,
    Object? email = freezed,
    Object? username = freezed,
    Object? postsCount = null,
    Object? followersCount = null,
    Object? followingCount = null,
  }) {
    return _then(_$UserPreferencesDataImpl(
      security: null == security
          ? _value.security
          : security // ignore: cast_nullable_to_non_nullable
              as Security,
      adminFlags: null == adminFlags
          ? _value.adminFlags
          : adminFlags // ignore: cast_nullable_to_non_nullable
              as AdminFlags,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as Privacy,
      dataSettings: null == dataSettings
          ? _value.dataSettings
          : dataSettings // ignore: cast_nullable_to_non_nullable
              as DataSettings,
      accountInfoRequest: null == accountInfoRequest
          ? _value.accountInfoRequest
          : accountInfoRequest // ignore: cast_nullable_to_non_nullable
              as AccountInfoRequest,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Settings,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Preferences,
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
      accountStatus: null == accountStatus
          ? _value.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      blockedUsers: null == blockedUsers
          ? _value._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      contacts: null == contacts
          ? _value._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
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
      profileImages: null == profileImages
          ? _value._profileImages
          : profileImages // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
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
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      postsCount: null == postsCount
          ? _value.postsCount
          : postsCount // ignore: cast_nullable_to_non_nullable
              as int,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesDataImpl implements _UserPreferencesData {
  const _$UserPreferencesDataImpl(
      {required this.security,
      required this.adminFlags,
      required this.privacy,
      required this.dataSettings,
      required this.accountInfoRequest,
      required this.settings,
      required this.preferences,
      @JsonKey(name: '_id') required this.id,
      required this.phone,
      @JsonKey(name: '__v') required this.v,
      required this.about,
      required this.accountStatus,
      required final List<dynamic> blockedUsers,
      required final List<dynamic> contacts,
      required this.createdAt,
      required final List<String> fcmTokens,
      required this.hasPassword,
      required this.isOnline,
      required this.isProfileComplete,
      required this.lastActive,
      required final List<dynamic> profileImages,
      required this.profilePicture,
      required this.reportCount,
      required this.role,
      required this.updatedAt,
      this.email,
      this.username,
      @JsonKey(defaultValue: 0) required this.postsCount,
      @JsonKey(defaultValue: 0) required this.followersCount,
      @JsonKey(defaultValue: 0) required this.followingCount})
      : _blockedUsers = blockedUsers,
        _contacts = contacts,
        _fcmTokens = fcmTokens,
        _profileImages = profileImages;

  factory _$UserPreferencesDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesDataImplFromJson(json);

  @override
  final Security security;
  @override
  final AdminFlags adminFlags;
  @override
  final Privacy privacy;
  @override
  final DataSettings dataSettings;
  @override
  final AccountInfoRequest accountInfoRequest;
  @override
  final Settings settings;
  @override
  final Preferences preferences;
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
  final String accountStatus;
  final List<dynamic> _blockedUsers;
  @override
  List<dynamic> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  final List<dynamic> _contacts;
  @override
  List<dynamic> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  @override
  final String createdAt;
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
  final List<dynamic> _profileImages;
  @override
  List<dynamic> get profileImages {
    if (_profileImages is EqualUnmodifiableListView) return _profileImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profileImages);
  }

  @override
  final String profilePicture;
  @override
  final int reportCount;
  @override
  final String role;
  @override
  final String updatedAt;
  @override
  final String? email;
  @override
  final String? username;
  @override
  @JsonKey(defaultValue: 0)
  final int postsCount;
  @override
  @JsonKey(defaultValue: 0)
  final int followersCount;
  @override
  @JsonKey(defaultValue: 0)
  final int followingCount;

  @override
  String toString() {
    return 'UserPreferencesData(security: $security, adminFlags: $adminFlags, privacy: $privacy, dataSettings: $dataSettings, accountInfoRequest: $accountInfoRequest, settings: $settings, preferences: $preferences, id: $id, phone: $phone, v: $v, about: $about, accountStatus: $accountStatus, blockedUsers: $blockedUsers, contacts: $contacts, createdAt: $createdAt, fcmTokens: $fcmTokens, hasPassword: $hasPassword, isOnline: $isOnline, isProfileComplete: $isProfileComplete, lastActive: $lastActive, profileImages: $profileImages, profilePicture: $profilePicture, reportCount: $reportCount, role: $role, updatedAt: $updatedAt, email: $email, username: $username, postsCount: $postsCount, followersCount: $followersCount, followingCount: $followingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesDataImpl &&
            (identical(other.security, security) ||
                other.security == security) &&
            (identical(other.adminFlags, adminFlags) ||
                other.adminFlags == adminFlags) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.dataSettings, dataSettings) ||
                other.dataSettings == dataSettings) &&
            (identical(other.accountInfoRequest, accountInfoRequest) ||
                other.accountInfoRequest == accountInfoRequest) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.about, about) || other.about == about) &&
            (identical(other.accountStatus, accountStatus) ||
                other.accountStatus == accountStatus) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
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
            const DeepCollectionEquality()
                .equals(other._profileImages, _profileImages) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.reportCount, reportCount) ||
                other.reportCount == reportCount) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.postsCount, postsCount) ||
                other.postsCount == postsCount) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        security,
        adminFlags,
        privacy,
        dataSettings,
        accountInfoRequest,
        settings,
        preferences,
        id,
        phone,
        v,
        about,
        accountStatus,
        const DeepCollectionEquality().hash(_blockedUsers),
        const DeepCollectionEquality().hash(_contacts),
        createdAt,
        const DeepCollectionEquality().hash(_fcmTokens),
        hasPassword,
        isOnline,
        isProfileComplete,
        lastActive,
        const DeepCollectionEquality().hash(_profileImages),
        profilePicture,
        reportCount,
        role,
        updatedAt,
        email,
        username,
        postsCount,
        followersCount,
        followingCount
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesDataImplCopyWith<_$UserPreferencesDataImpl> get copyWith =>
      __$$UserPreferencesDataImplCopyWithImpl<_$UserPreferencesDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesDataImplToJson(
      this,
    );
  }
}

abstract class _UserPreferencesData implements UserPreferencesData {
  const factory _UserPreferencesData(
          {required final Security security,
          required final AdminFlags adminFlags,
          required final Privacy privacy,
          required final DataSettings dataSettings,
          required final AccountInfoRequest accountInfoRequest,
          required final Settings settings,
          required final Preferences preferences,
          @JsonKey(name: '_id') required final String id,
          required final String phone,
          @JsonKey(name: '__v') required final int v,
          required final String about,
          required final String accountStatus,
          required final List<dynamic> blockedUsers,
          required final List<dynamic> contacts,
          required final String createdAt,
          required final List<String> fcmTokens,
          required final bool hasPassword,
          required final bool isOnline,
          required final bool isProfileComplete,
          required final String lastActive,
          required final List<dynamic> profileImages,
          required final String profilePicture,
          required final int reportCount,
          required final String role,
          required final String updatedAt,
          final String? email,
          final String? username,
          @JsonKey(defaultValue: 0) required final int postsCount,
          @JsonKey(defaultValue: 0) required final int followersCount,
          @JsonKey(defaultValue: 0) required final int followingCount}) =
      _$UserPreferencesDataImpl;

  factory _UserPreferencesData.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesDataImpl.fromJson;

  @override
  Security get security;
  @override
  AdminFlags get adminFlags;
  @override
  Privacy get privacy;
  @override
  DataSettings get dataSettings;
  @override
  AccountInfoRequest get accountInfoRequest;
  @override
  Settings get settings;
  @override
  Preferences get preferences;
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
  String get accountStatus;
  @override
  List<dynamic> get blockedUsers;
  @override
  List<dynamic> get contacts;
  @override
  String get createdAt;
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
  List<dynamic> get profileImages;
  @override
  String get profilePicture;
  @override
  int get reportCount;
  @override
  String get role;
  @override
  String get updatedAt;
  @override
  String? get email;
  @override
  String? get username;
  @override
  @JsonKey(defaultValue: 0)
  int get postsCount;
  @override
  @JsonKey(defaultValue: 0)
  int get followersCount;
  @override
  @JsonKey(defaultValue: 0)
  int get followingCount;
  @override
  @JsonKey(ignore: true)
  _$$UserPreferencesDataImplCopyWith<_$UserPreferencesDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Security _$SecurityFromJson(Map<String, dynamic> json) {
  return _Security.fromJson(json);
}

/// @nodoc
mixin _$Security {
  bool get twoFactorEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SecurityCopyWith<Security> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityCopyWith<$Res> {
  factory $SecurityCopyWith(Security value, $Res Function(Security) then) =
      _$SecurityCopyWithImpl<$Res, Security>;
  @useResult
  $Res call({bool twoFactorEnabled});
}

/// @nodoc
class _$SecurityCopyWithImpl<$Res, $Val extends Security>
    implements $SecurityCopyWith<$Res> {
  _$SecurityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? twoFactorEnabled = null,
  }) {
    return _then(_value.copyWith(
      twoFactorEnabled: null == twoFactorEnabled
          ? _value.twoFactorEnabled
          : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SecurityImplCopyWith<$Res>
    implements $SecurityCopyWith<$Res> {
  factory _$$SecurityImplCopyWith(
          _$SecurityImpl value, $Res Function(_$SecurityImpl) then) =
      __$$SecurityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool twoFactorEnabled});
}

/// @nodoc
class __$$SecurityImplCopyWithImpl<$Res>
    extends _$SecurityCopyWithImpl<$Res, _$SecurityImpl>
    implements _$$SecurityImplCopyWith<$Res> {
  __$$SecurityImplCopyWithImpl(
      _$SecurityImpl _value, $Res Function(_$SecurityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? twoFactorEnabled = null,
  }) {
    return _then(_$SecurityImpl(
      twoFactorEnabled: null == twoFactorEnabled
          ? _value.twoFactorEnabled
          : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityImpl implements _Security {
  const _$SecurityImpl({required this.twoFactorEnabled});

  factory _$SecurityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityImplFromJson(json);

  @override
  final bool twoFactorEnabled;

  @override
  String toString() {
    return 'Security(twoFactorEnabled: $twoFactorEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityImpl &&
            (identical(other.twoFactorEnabled, twoFactorEnabled) ||
                other.twoFactorEnabled == twoFactorEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, twoFactorEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityImplCopyWith<_$SecurityImpl> get copyWith =>
      __$$SecurityImplCopyWithImpl<_$SecurityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityImplToJson(
      this,
    );
  }
}

abstract class _Security implements Security {
  const factory _Security({required final bool twoFactorEnabled}) =
      _$SecurityImpl;

  factory _Security.fromJson(Map<String, dynamic> json) =
      _$SecurityImpl.fromJson;

  @override
  bool get twoFactorEnabled;
  @override
  @JsonKey(ignore: true)
  _$$SecurityImplCopyWith<_$SecurityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdminFlags _$AdminFlagsFromJson(Map<String, dynamic> json) {
  return _AdminFlags.fromJson(json);
}

/// @nodoc
mixin _$AdminFlags {
  bool get isFlagged => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdminFlagsCopyWith<AdminFlags> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminFlagsCopyWith<$Res> {
  factory $AdminFlagsCopyWith(
          AdminFlags value, $Res Function(AdminFlags) then) =
      _$AdminFlagsCopyWithImpl<$Res, AdminFlags>;
  @useResult
  $Res call({bool isFlagged, String reason});
}

/// @nodoc
class _$AdminFlagsCopyWithImpl<$Res, $Val extends AdminFlags>
    implements $AdminFlagsCopyWith<$Res> {
  _$AdminFlagsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFlagged = null,
    Object? reason = null,
  }) {
    return _then(_value.copyWith(
      isFlagged: null == isFlagged
          ? _value.isFlagged
          : isFlagged // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminFlagsImplCopyWith<$Res>
    implements $AdminFlagsCopyWith<$Res> {
  factory _$$AdminFlagsImplCopyWith(
          _$AdminFlagsImpl value, $Res Function(_$AdminFlagsImpl) then) =
      __$$AdminFlagsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isFlagged, String reason});
}

/// @nodoc
class __$$AdminFlagsImplCopyWithImpl<$Res>
    extends _$AdminFlagsCopyWithImpl<$Res, _$AdminFlagsImpl>
    implements _$$AdminFlagsImplCopyWith<$Res> {
  __$$AdminFlagsImplCopyWithImpl(
      _$AdminFlagsImpl _value, $Res Function(_$AdminFlagsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFlagged = null,
    Object? reason = null,
  }) {
    return _then(_$AdminFlagsImpl(
      isFlagged: null == isFlagged
          ? _value.isFlagged
          : isFlagged // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminFlagsImpl implements _AdminFlags {
  const _$AdminFlagsImpl({required this.isFlagged, required this.reason});

  factory _$AdminFlagsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminFlagsImplFromJson(json);

  @override
  final bool isFlagged;
  @override
  final String reason;

  @override
  String toString() {
    return 'AdminFlags(isFlagged: $isFlagged, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminFlagsImpl &&
            (identical(other.isFlagged, isFlagged) ||
                other.isFlagged == isFlagged) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, isFlagged, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminFlagsImplCopyWith<_$AdminFlagsImpl> get copyWith =>
      __$$AdminFlagsImplCopyWithImpl<_$AdminFlagsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminFlagsImplToJson(
      this,
    );
  }
}

abstract class _AdminFlags implements AdminFlags {
  const factory _AdminFlags(
      {required final bool isFlagged,
      required final String reason}) = _$AdminFlagsImpl;

  factory _AdminFlags.fromJson(Map<String, dynamic> json) =
      _$AdminFlagsImpl.fromJson;

  @override
  bool get isFlagged;
  @override
  String get reason;
  @override
  @JsonKey(ignore: true)
  _$$AdminFlagsImplCopyWith<_$AdminFlagsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Privacy _$PrivacyFromJson(Map<String, dynamic> json) {
  return _Privacy.fromJson(json);
}

/// @nodoc
mixin _$Privacy {
  String get about => throw _privateConstructorUsedError;
  String get groups => throw _privateConstructorUsedError;
  String get lastSeen => throw _privateConstructorUsedError;
  String get profilePhoto => throw _privateConstructorUsedError;
  bool get readReceipts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrivacyCopyWith<Privacy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacyCopyWith<$Res> {
  factory $PrivacyCopyWith(Privacy value, $Res Function(Privacy) then) =
      _$PrivacyCopyWithImpl<$Res, Privacy>;
  @useResult
  $Res call(
      {String about,
      String groups,
      String lastSeen,
      String profilePhoto,
      bool readReceipts});
}

/// @nodoc
class _$PrivacyCopyWithImpl<$Res, $Val extends Privacy>
    implements $PrivacyCopyWith<$Res> {
  _$PrivacyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? about = null,
    Object? groups = null,
    Object? lastSeen = null,
    Object? profilePhoto = null,
    Object? readReceipts = null,
  }) {
    return _then(_value.copyWith(
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrivacyImplCopyWith<$Res> implements $PrivacyCopyWith<$Res> {
  factory _$$PrivacyImplCopyWith(
          _$PrivacyImpl value, $Res Function(_$PrivacyImpl) then) =
      __$$PrivacyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String about,
      String groups,
      String lastSeen,
      String profilePhoto,
      bool readReceipts});
}

/// @nodoc
class __$$PrivacyImplCopyWithImpl<$Res>
    extends _$PrivacyCopyWithImpl<$Res, _$PrivacyImpl>
    implements _$$PrivacyImplCopyWith<$Res> {
  __$$PrivacyImplCopyWithImpl(
      _$PrivacyImpl _value, $Res Function(_$PrivacyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? about = null,
    Object? groups = null,
    Object? lastSeen = null,
    Object? profilePhoto = null,
    Object? readReceipts = null,
  }) {
    return _then(_$PrivacyImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacyImpl implements _Privacy {
  const _$PrivacyImpl(
      {required this.about,
      required this.groups,
      required this.lastSeen,
      required this.profilePhoto,
      required this.readReceipts});

  factory _$PrivacyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacyImplFromJson(json);

  @override
  final String about;
  @override
  final String groups;
  @override
  final String lastSeen;
  @override
  final String profilePhoto;
  @override
  final bool readReceipts;

  @override
  String toString() {
    return 'Privacy(about: $about, groups: $groups, lastSeen: $lastSeen, profilePhoto: $profilePhoto, readReceipts: $readReceipts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacyImpl &&
            (identical(other.about, about) || other.about == about) &&
            (identical(other.groups, groups) || other.groups == groups) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.profilePhoto, profilePhoto) ||
                other.profilePhoto == profilePhoto) &&
            (identical(other.readReceipts, readReceipts) ||
                other.readReceipts == readReceipts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, about, groups, lastSeen, profilePhoto, readReceipts);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacyImplCopyWith<_$PrivacyImpl> get copyWith =>
      __$$PrivacyImplCopyWithImpl<_$PrivacyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacyImplToJson(
      this,
    );
  }
}

abstract class _Privacy implements Privacy {
  const factory _Privacy(
      {required final String about,
      required final String groups,
      required final String lastSeen,
      required final String profilePhoto,
      required final bool readReceipts}) = _$PrivacyImpl;

  factory _Privacy.fromJson(Map<String, dynamic> json) = _$PrivacyImpl.fromJson;

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
  @JsonKey(ignore: true)
  _$$PrivacyImplCopyWith<_$PrivacyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadConfig _$DownloadConfigFromJson(Map<String, dynamic> json) {
  return _DownloadConfig.fromJson(json);
}

/// @nodoc
mixin _$DownloadConfig {
  bool get documents => throw _privateConstructorUsedError;
  bool get photos => throw _privateConstructorUsedError;
  bool get videos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DownloadConfigCopyWith<DownloadConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadConfigCopyWith<$Res> {
  factory $DownloadConfigCopyWith(
          DownloadConfig value, $Res Function(DownloadConfig) then) =
      _$DownloadConfigCopyWithImpl<$Res, DownloadConfig>;
  @useResult
  $Res call({bool documents, bool photos, bool videos});
}

/// @nodoc
class _$DownloadConfigCopyWithImpl<$Res, $Val extends DownloadConfig>
    implements $DownloadConfigCopyWith<$Res> {
  _$DownloadConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documents = null,
    Object? photos = null,
    Object? videos = null,
  }) {
    return _then(_value.copyWith(
      documents: null == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as bool,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as bool,
      videos: null == videos
          ? _value.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadConfigImplCopyWith<$Res>
    implements $DownloadConfigCopyWith<$Res> {
  factory _$$DownloadConfigImplCopyWith(_$DownloadConfigImpl value,
          $Res Function(_$DownloadConfigImpl) then) =
      __$$DownloadConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool documents, bool photos, bool videos});
}

/// @nodoc
class __$$DownloadConfigImplCopyWithImpl<$Res>
    extends _$DownloadConfigCopyWithImpl<$Res, _$DownloadConfigImpl>
    implements _$$DownloadConfigImplCopyWith<$Res> {
  __$$DownloadConfigImplCopyWithImpl(
      _$DownloadConfigImpl _value, $Res Function(_$DownloadConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documents = null,
    Object? photos = null,
    Object? videos = null,
  }) {
    return _then(_$DownloadConfigImpl(
      documents: null == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as bool,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as bool,
      videos: null == videos
          ? _value.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadConfigImpl implements _DownloadConfig {
  const _$DownloadConfigImpl(
      {required this.documents, required this.photos, required this.videos});

  factory _$DownloadConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadConfigImplFromJson(json);

  @override
  final bool documents;
  @override
  final bool photos;
  @override
  final bool videos;

  @override
  String toString() {
    return 'DownloadConfig(documents: $documents, photos: $photos, videos: $videos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadConfigImpl &&
            (identical(other.documents, documents) ||
                other.documents == documents) &&
            (identical(other.photos, photos) || other.photos == photos) &&
            (identical(other.videos, videos) || other.videos == videos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, documents, photos, videos);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadConfigImplCopyWith<_$DownloadConfigImpl> get copyWith =>
      __$$DownloadConfigImplCopyWithImpl<_$DownloadConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadConfigImplToJson(
      this,
    );
  }
}

abstract class _DownloadConfig implements DownloadConfig {
  const factory _DownloadConfig(
      {required final bool documents,
      required final bool photos,
      required final bool videos}) = _$DownloadConfigImpl;

  factory _DownloadConfig.fromJson(Map<String, dynamic> json) =
      _$DownloadConfigImpl.fromJson;

  @override
  bool get documents;
  @override
  bool get photos;
  @override
  bool get videos;
  @override
  @JsonKey(ignore: true)
  _$$DownloadConfigImplCopyWith<_$DownloadConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AutoDownload _$AutoDownloadFromJson(Map<String, dynamic> json) {
  return _AutoDownload.fromJson(json);
}

/// @nodoc
mixin _$AutoDownload {
  DownloadConfig get wifi => throw _privateConstructorUsedError;
  DownloadConfig get cellular => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AutoDownloadCopyWith<AutoDownload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoDownloadCopyWith<$Res> {
  factory $AutoDownloadCopyWith(
          AutoDownload value, $Res Function(AutoDownload) then) =
      _$AutoDownloadCopyWithImpl<$Res, AutoDownload>;
  @useResult
  $Res call({DownloadConfig wifi, DownloadConfig cellular});

  $DownloadConfigCopyWith<$Res> get wifi;
  $DownloadConfigCopyWith<$Res> get cellular;
}

/// @nodoc
class _$AutoDownloadCopyWithImpl<$Res, $Val extends AutoDownload>
    implements $AutoDownloadCopyWith<$Res> {
  _$AutoDownloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wifi = null,
    Object? cellular = null,
  }) {
    return _then(_value.copyWith(
      wifi: null == wifi
          ? _value.wifi
          : wifi // ignore: cast_nullable_to_non_nullable
              as DownloadConfig,
      cellular: null == cellular
          ? _value.cellular
          : cellular // ignore: cast_nullable_to_non_nullable
              as DownloadConfig,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DownloadConfigCopyWith<$Res> get wifi {
    return $DownloadConfigCopyWith<$Res>(_value.wifi, (value) {
      return _then(_value.copyWith(wifi: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DownloadConfigCopyWith<$Res> get cellular {
    return $DownloadConfigCopyWith<$Res>(_value.cellular, (value) {
      return _then(_value.copyWith(cellular: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AutoDownloadImplCopyWith<$Res>
    implements $AutoDownloadCopyWith<$Res> {
  factory _$$AutoDownloadImplCopyWith(
          _$AutoDownloadImpl value, $Res Function(_$AutoDownloadImpl) then) =
      __$$AutoDownloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DownloadConfig wifi, DownloadConfig cellular});

  @override
  $DownloadConfigCopyWith<$Res> get wifi;
  @override
  $DownloadConfigCopyWith<$Res> get cellular;
}

/// @nodoc
class __$$AutoDownloadImplCopyWithImpl<$Res>
    extends _$AutoDownloadCopyWithImpl<$Res, _$AutoDownloadImpl>
    implements _$$AutoDownloadImplCopyWith<$Res> {
  __$$AutoDownloadImplCopyWithImpl(
      _$AutoDownloadImpl _value, $Res Function(_$AutoDownloadImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wifi = null,
    Object? cellular = null,
  }) {
    return _then(_$AutoDownloadImpl(
      wifi: null == wifi
          ? _value.wifi
          : wifi // ignore: cast_nullable_to_non_nullable
              as DownloadConfig,
      cellular: null == cellular
          ? _value.cellular
          : cellular // ignore: cast_nullable_to_non_nullable
              as DownloadConfig,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutoDownloadImpl implements _AutoDownload {
  const _$AutoDownloadImpl({required this.wifi, required this.cellular});

  factory _$AutoDownloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutoDownloadImplFromJson(json);

  @override
  final DownloadConfig wifi;
  @override
  final DownloadConfig cellular;

  @override
  String toString() {
    return 'AutoDownload(wifi: $wifi, cellular: $cellular)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoDownloadImpl &&
            (identical(other.wifi, wifi) || other.wifi == wifi) &&
            (identical(other.cellular, cellular) ||
                other.cellular == cellular));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, wifi, cellular);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoDownloadImplCopyWith<_$AutoDownloadImpl> get copyWith =>
      __$$AutoDownloadImplCopyWithImpl<_$AutoDownloadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutoDownloadImplToJson(
      this,
    );
  }
}

abstract class _AutoDownload implements AutoDownload {
  const factory _AutoDownload(
      {required final DownloadConfig wifi,
      required final DownloadConfig cellular}) = _$AutoDownloadImpl;

  factory _AutoDownload.fromJson(Map<String, dynamic> json) =
      _$AutoDownloadImpl.fromJson;

  @override
  DownloadConfig get wifi;
  @override
  DownloadConfig get cellular;
  @override
  @JsonKey(ignore: true)
  _$$AutoDownloadImplCopyWith<_$AutoDownloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DataSettings _$DataSettingsFromJson(Map<String, dynamic> json) {
  return _DataSettings.fromJson(json);
}

/// @nodoc
mixin _$DataSettings {
  AutoDownload get autoDownload => throw _privateConstructorUsedError;
  int get networkUsage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DataSettingsCopyWith<DataSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataSettingsCopyWith<$Res> {
  factory $DataSettingsCopyWith(
          DataSettings value, $Res Function(DataSettings) then) =
      _$DataSettingsCopyWithImpl<$Res, DataSettings>;
  @useResult
  $Res call({AutoDownload autoDownload, int networkUsage});

  $AutoDownloadCopyWith<$Res> get autoDownload;
}

/// @nodoc
class _$DataSettingsCopyWithImpl<$Res, $Val extends DataSettings>
    implements $DataSettingsCopyWith<$Res> {
  _$DataSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoDownload = null,
    Object? networkUsage = null,
  }) {
    return _then(_value.copyWith(
      autoDownload: null == autoDownload
          ? _value.autoDownload
          : autoDownload // ignore: cast_nullable_to_non_nullable
              as AutoDownload,
      networkUsage: null == networkUsage
          ? _value.networkUsage
          : networkUsage // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AutoDownloadCopyWith<$Res> get autoDownload {
    return $AutoDownloadCopyWith<$Res>(_value.autoDownload, (value) {
      return _then(_value.copyWith(autoDownload: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DataSettingsImplCopyWith<$Res>
    implements $DataSettingsCopyWith<$Res> {
  factory _$$DataSettingsImplCopyWith(
          _$DataSettingsImpl value, $Res Function(_$DataSettingsImpl) then) =
      __$$DataSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AutoDownload autoDownload, int networkUsage});

  @override
  $AutoDownloadCopyWith<$Res> get autoDownload;
}

/// @nodoc
class __$$DataSettingsImplCopyWithImpl<$Res>
    extends _$DataSettingsCopyWithImpl<$Res, _$DataSettingsImpl>
    implements _$$DataSettingsImplCopyWith<$Res> {
  __$$DataSettingsImplCopyWithImpl(
      _$DataSettingsImpl _value, $Res Function(_$DataSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoDownload = null,
    Object? networkUsage = null,
  }) {
    return _then(_$DataSettingsImpl(
      autoDownload: null == autoDownload
          ? _value.autoDownload
          : autoDownload // ignore: cast_nullable_to_non_nullable
              as AutoDownload,
      networkUsage: null == networkUsage
          ? _value.networkUsage
          : networkUsage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DataSettingsImpl implements _DataSettings {
  const _$DataSettingsImpl(
      {required this.autoDownload, required this.networkUsage});

  factory _$DataSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataSettingsImplFromJson(json);

  @override
  final AutoDownload autoDownload;
  @override
  final int networkUsage;

  @override
  String toString() {
    return 'DataSettings(autoDownload: $autoDownload, networkUsage: $networkUsage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataSettingsImpl &&
            (identical(other.autoDownload, autoDownload) ||
                other.autoDownload == autoDownload) &&
            (identical(other.networkUsage, networkUsage) ||
                other.networkUsage == networkUsage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, autoDownload, networkUsage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataSettingsImplCopyWith<_$DataSettingsImpl> get copyWith =>
      __$$DataSettingsImplCopyWithImpl<_$DataSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataSettingsImplToJson(
      this,
    );
  }
}

abstract class _DataSettings implements DataSettings {
  const factory _DataSettings(
      {required final AutoDownload autoDownload,
      required final int networkUsage}) = _$DataSettingsImpl;

  factory _DataSettings.fromJson(Map<String, dynamic> json) =
      _$DataSettingsImpl.fromJson;

  @override
  AutoDownload get autoDownload;
  @override
  int get networkUsage;
  @override
  @JsonKey(ignore: true)
  _$$DataSettingsImplCopyWith<_$DataSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccountInfoRequest _$AccountInfoRequestFromJson(Map<String, dynamic> json) {
  return _AccountInfoRequest.fromJson(json);
}

/// @nodoc
mixin _$AccountInfoRequest {
  String get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountInfoRequestCopyWith<AccountInfoRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountInfoRequestCopyWith<$Res> {
  factory $AccountInfoRequestCopyWith(
          AccountInfoRequest value, $Res Function(AccountInfoRequest) then) =
      _$AccountInfoRequestCopyWithImpl<$Res, AccountInfoRequest>;
  @useResult
  $Res call({String status});
}

/// @nodoc
class _$AccountInfoRequestCopyWithImpl<$Res, $Val extends AccountInfoRequest>
    implements $AccountInfoRequestCopyWith<$Res> {
  _$AccountInfoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountInfoRequestImplCopyWith<$Res>
    implements $AccountInfoRequestCopyWith<$Res> {
  factory _$$AccountInfoRequestImplCopyWith(_$AccountInfoRequestImpl value,
          $Res Function(_$AccountInfoRequestImpl) then) =
      __$$AccountInfoRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status});
}

/// @nodoc
class __$$AccountInfoRequestImplCopyWithImpl<$Res>
    extends _$AccountInfoRequestCopyWithImpl<$Res, _$AccountInfoRequestImpl>
    implements _$$AccountInfoRequestImplCopyWith<$Res> {
  __$$AccountInfoRequestImplCopyWithImpl(_$AccountInfoRequestImpl _value,
      $Res Function(_$AccountInfoRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_$AccountInfoRequestImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountInfoRequestImpl implements _AccountInfoRequest {
  const _$AccountInfoRequestImpl({required this.status});

  factory _$AccountInfoRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountInfoRequestImplFromJson(json);

  @override
  final String status;

  @override
  String toString() {
    return 'AccountInfoRequest(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountInfoRequestImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountInfoRequestImplCopyWith<_$AccountInfoRequestImpl> get copyWith =>
      __$$AccountInfoRequestImplCopyWithImpl<_$AccountInfoRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountInfoRequestImplToJson(
      this,
    );
  }
}

abstract class _AccountInfoRequest implements AccountInfoRequest {
  const factory _AccountInfoRequest({required final String status}) =
      _$AccountInfoRequestImpl;

  factory _AccountInfoRequest.fromJson(Map<String, dynamic> json) =
      _$AccountInfoRequestImpl.fromJson;

  @override
  String get status;
  @override
  @JsonKey(ignore: true)
  _$$AccountInfoRequestImplCopyWith<_$AccountInfoRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Notifications _$NotificationsFromJson(Map<String, dynamic> json) {
  return _Notifications.fromJson(json);
}

/// @nodoc
mixin _$Notifications {
  bool get calls => throw _privateConstructorUsedError;
  bool get groups => throw _privateConstructorUsedError;
  bool get messages => throw _privateConstructorUsedError;
  bool get sound => throw _privateConstructorUsedError;
  bool get vibrate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationsCopyWith<Notifications> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationsCopyWith<$Res> {
  factory $NotificationsCopyWith(
          Notifications value, $Res Function(Notifications) then) =
      _$NotificationsCopyWithImpl<$Res, Notifications>;
  @useResult
  $Res call({bool calls, bool groups, bool messages, bool sound, bool vibrate});
}

/// @nodoc
class _$NotificationsCopyWithImpl<$Res, $Val extends Notifications>
    implements $NotificationsCopyWith<$Res> {
  _$NotificationsCopyWithImpl(this._value, this._then);

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
abstract class _$$NotificationsImplCopyWith<$Res>
    implements $NotificationsCopyWith<$Res> {
  factory _$$NotificationsImplCopyWith(
          _$NotificationsImpl value, $Res Function(_$NotificationsImpl) then) =
      __$$NotificationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool calls, bool groups, bool messages, bool sound, bool vibrate});
}

/// @nodoc
class __$$NotificationsImplCopyWithImpl<$Res>
    extends _$NotificationsCopyWithImpl<$Res, _$NotificationsImpl>
    implements _$$NotificationsImplCopyWith<$Res> {
  __$$NotificationsImplCopyWithImpl(
      _$NotificationsImpl _value, $Res Function(_$NotificationsImpl) _then)
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
    return _then(_$NotificationsImpl(
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
class _$NotificationsImpl implements _Notifications {
  const _$NotificationsImpl(
      {required this.calls,
      required this.groups,
      required this.messages,
      required this.sound,
      required this.vibrate});

  factory _$NotificationsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationsImplFromJson(json);

  @override
  final bool calls;
  @override
  final bool groups;
  @override
  final bool messages;
  @override
  final bool sound;
  @override
  final bool vibrate;

  @override
  String toString() {
    return 'Notifications(calls: $calls, groups: $groups, messages: $messages, sound: $sound, vibrate: $vibrate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationsImpl &&
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
  _$$NotificationsImplCopyWith<_$NotificationsImpl> get copyWith =>
      __$$NotificationsImplCopyWithImpl<_$NotificationsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationsImplToJson(
      this,
    );
  }
}

abstract class _Notifications implements Notifications {
  const factory _Notifications(
      {required final bool calls,
      required final bool groups,
      required final bool messages,
      required final bool sound,
      required final bool vibrate}) = _$NotificationsImpl;

  factory _Notifications.fromJson(Map<String, dynamic> json) =
      _$NotificationsImpl.fromJson;

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
  _$$NotificationsImplCopyWith<_$NotificationsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Settings _$SettingsFromJson(Map<String, dynamic> json) {
  return _Settings.fromJson(json);
}

/// @nodoc
mixin _$Settings {
  Notifications get notifications => throw _privateConstructorUsedError;
  bool get allowScreenshots => throw _privateConstructorUsedError;
  String get chatWallpaper => throw _privateConstructorUsedError;
  bool get isAppLockEnabled => throw _privateConstructorUsedError;
  String get themeMode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettingsCopyWith<Settings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsCopyWith<$Res> {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) then) =
      _$SettingsCopyWithImpl<$Res, Settings>;
  @useResult
  $Res call(
      {Notifications notifications,
      bool allowScreenshots,
      String chatWallpaper,
      bool isAppLockEnabled,
      String themeMode});

  $NotificationsCopyWith<$Res> get notifications;
}

/// @nodoc
class _$SettingsCopyWithImpl<$Res, $Val extends Settings>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? allowScreenshots = null,
    Object? chatWallpaper = null,
    Object? isAppLockEnabled = null,
    Object? themeMode = null,
  }) {
    return _then(_value.copyWith(
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as Notifications,
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
  $NotificationsCopyWith<$Res> get notifications {
    return $NotificationsCopyWith<$Res>(_value.notifications, (value) {
      return _then(_value.copyWith(notifications: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SettingsImplCopyWith<$Res>
    implements $SettingsCopyWith<$Res> {
  factory _$$SettingsImplCopyWith(
          _$SettingsImpl value, $Res Function(_$SettingsImpl) then) =
      __$$SettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Notifications notifications,
      bool allowScreenshots,
      String chatWallpaper,
      bool isAppLockEnabled,
      String themeMode});

  @override
  $NotificationsCopyWith<$Res> get notifications;
}

/// @nodoc
class __$$SettingsImplCopyWithImpl<$Res>
    extends _$SettingsCopyWithImpl<$Res, _$SettingsImpl>
    implements _$$SettingsImplCopyWith<$Res> {
  __$$SettingsImplCopyWithImpl(
      _$SettingsImpl _value, $Res Function(_$SettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? allowScreenshots = null,
    Object? chatWallpaper = null,
    Object? isAppLockEnabled = null,
    Object? themeMode = null,
  }) {
    return _then(_$SettingsImpl(
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as Notifications,
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
class _$SettingsImpl implements _Settings {
  const _$SettingsImpl(
      {required this.notifications,
      required this.allowScreenshots,
      required this.chatWallpaper,
      required this.isAppLockEnabled,
      required this.themeMode});

  factory _$SettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsImplFromJson(json);

  @override
  final Notifications notifications;
  @override
  final bool allowScreenshots;
  @override
  final String chatWallpaper;
  @override
  final bool isAppLockEnabled;
  @override
  final String themeMode;

  @override
  String toString() {
    return 'Settings(notifications: $notifications, allowScreenshots: $allowScreenshots, chatWallpaper: $chatWallpaper, isAppLockEnabled: $isAppLockEnabled, themeMode: $themeMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsImpl &&
            (identical(other.notifications, notifications) ||
                other.notifications == notifications) &&
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
  int get hashCode => Object.hash(runtimeType, notifications, allowScreenshots,
      chatWallpaper, isAppLockEnabled, themeMode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      __$$SettingsImplCopyWithImpl<_$SettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsImplToJson(
      this,
    );
  }
}

abstract class _Settings implements Settings {
  const factory _Settings(
      {required final Notifications notifications,
      required final bool allowScreenshots,
      required final String chatWallpaper,
      required final bool isAppLockEnabled,
      required final String themeMode}) = _$SettingsImpl;

  factory _Settings.fromJson(Map<String, dynamic> json) =
      _$SettingsImpl.fromJson;

  @override
  Notifications get notifications;
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
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Preferences _$PreferencesFromJson(Map<String, dynamic> json) {
  return _Preferences.fromJson(json);
}

/// @nodoc
mixin _$Preferences {
  List<String>? get entertainment => throw _privateConstructorUsedError;
  List<String>? get homeFamily => throw _privateConstructorUsedError;
  List<String>? get fashionBeauty => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreferencesCopyWith<Preferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreferencesCopyWith<$Res> {
  factory $PreferencesCopyWith(
          Preferences value, $Res Function(Preferences) then) =
      _$PreferencesCopyWithImpl<$Res, Preferences>;
  @useResult
  $Res call(
      {List<String>? entertainment,
      List<String>? homeFamily,
      List<String>? fashionBeauty});
}

/// @nodoc
class _$PreferencesCopyWithImpl<$Res, $Val extends Preferences>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entertainment = freezed,
    Object? homeFamily = freezed,
    Object? fashionBeauty = freezed,
  }) {
    return _then(_value.copyWith(
      entertainment: freezed == entertainment
          ? _value.entertainment
          : entertainment // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      homeFamily: freezed == homeFamily
          ? _value.homeFamily
          : homeFamily // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      fashionBeauty: freezed == fashionBeauty
          ? _value.fashionBeauty
          : fashionBeauty // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreferencesImplCopyWith<$Res>
    implements $PreferencesCopyWith<$Res> {
  factory _$$PreferencesImplCopyWith(
          _$PreferencesImpl value, $Res Function(_$PreferencesImpl) then) =
      __$$PreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? entertainment,
      List<String>? homeFamily,
      List<String>? fashionBeauty});
}

/// @nodoc
class __$$PreferencesImplCopyWithImpl<$Res>
    extends _$PreferencesCopyWithImpl<$Res, _$PreferencesImpl>
    implements _$$PreferencesImplCopyWith<$Res> {
  __$$PreferencesImplCopyWithImpl(
      _$PreferencesImpl _value, $Res Function(_$PreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entertainment = freezed,
    Object? homeFamily = freezed,
    Object? fashionBeauty = freezed,
  }) {
    return _then(_$PreferencesImpl(
      entertainment: freezed == entertainment
          ? _value._entertainment
          : entertainment // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      homeFamily: freezed == homeFamily
          ? _value._homeFamily
          : homeFamily // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      fashionBeauty: freezed == fashionBeauty
          ? _value._fashionBeauty
          : fashionBeauty // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferencesImpl implements _Preferences {
  const _$PreferencesImpl(
      {final List<String>? entertainment,
      final List<String>? homeFamily,
      final List<String>? fashionBeauty})
      : _entertainment = entertainment,
        _homeFamily = homeFamily,
        _fashionBeauty = fashionBeauty;

  factory _$PreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferencesImplFromJson(json);

  final List<String>? _entertainment;
  @override
  List<String>? get entertainment {
    final value = _entertainment;
    if (value == null) return null;
    if (_entertainment is EqualUnmodifiableListView) return _entertainment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _homeFamily;
  @override
  List<String>? get homeFamily {
    final value = _homeFamily;
    if (value == null) return null;
    if (_homeFamily is EqualUnmodifiableListView) return _homeFamily;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _fashionBeauty;
  @override
  List<String>? get fashionBeauty {
    final value = _fashionBeauty;
    if (value == null) return null;
    if (_fashionBeauty is EqualUnmodifiableListView) return _fashionBeauty;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Preferences(entertainment: $entertainment, homeFamily: $homeFamily, fashionBeauty: $fashionBeauty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferencesImpl &&
            const DeepCollectionEquality()
                .equals(other._entertainment, _entertainment) &&
            const DeepCollectionEquality()
                .equals(other._homeFamily, _homeFamily) &&
            const DeepCollectionEquality()
                .equals(other._fashionBeauty, _fashionBeauty));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_entertainment),
      const DeepCollectionEquality().hash(_homeFamily),
      const DeepCollectionEquality().hash(_fashionBeauty));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      __$$PreferencesImplCopyWithImpl<_$PreferencesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferencesImplToJson(
      this,
    );
  }
}

abstract class _Preferences implements Preferences {
  const factory _Preferences(
      {final List<String>? entertainment,
      final List<String>? homeFamily,
      final List<String>? fashionBeauty}) = _$PreferencesImpl;

  factory _Preferences.fromJson(Map<String, dynamic> json) =
      _$PreferencesImpl.fromJson;

  @override
  List<String>? get entertainment;
  @override
  List<String>? get homeFamily;
  @override
  List<String>? get fashionBeauty;
  @override
  @JsonKey(ignore: true)
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
