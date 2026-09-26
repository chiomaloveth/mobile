import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class PrivacySettingsState {
  final String lastSeen;
  final String profilePhoto;
  final String about;
  final String groups;
  final String statusVisibility;
  final bool readReceipts;
  final String defaultMessageTimer;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  // NEW
  final Set<String> lastSeenExcludedIds;
  final Set<String> profilePhotoExcludedIds;
  final Set<String> groupsExcludedIds;

  const PrivacySettingsState({
    this.lastSeen = 'everyone',
    this.profilePhoto = 'everyone',
    this.about = 'everyone',
    this.groups = 'everyone',
    this.statusVisibility = 'contacts',
    this.readReceipts = true,
    this.defaultMessageTimer = 'off',
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    // NEW
    this.lastSeenExcludedIds = const {},
    this.profilePhotoExcludedIds = const {},
    this.groupsExcludedIds = const {},
  });

  PrivacySettingsState copyWith({
    String? lastSeen,
    String? profilePhoto,
    String? about,
    String? groups,
    String? statusVisibility,
    bool? readReceipts,
    String? defaultMessageTimer,
    bool? isLoading,
    bool? isSaving,
    String? error,
    // NEW
    Set<String>? lastSeenExcludedIds,
    Set<String>? profilePhotoExcludedIds,
    Set<String>? groupsExcludedIds,
  }) {
    return PrivacySettingsState(
      lastSeen: lastSeen ?? this.lastSeen,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      about: about ?? this.about,
      groups: groups ?? this.groups,
      statusVisibility: statusVisibility ?? this.statusVisibility,
      readReceipts: readReceipts ?? this.readReceipts,
      defaultMessageTimer: defaultMessageTimer ?? this.defaultMessageTimer,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      // NEW
      lastSeenExcludedIds: lastSeenExcludedIds ?? this.lastSeenExcludedIds,
      profilePhotoExcludedIds: profilePhotoExcludedIds ?? this.profilePhotoExcludedIds,
      groupsExcludedIds: groupsExcludedIds ?? this.groupsExcludedIds,
    );
  }
}

final privacySettingsProvider =
    StateNotifierProvider<PrivacySettingsNotifier, PrivacySettingsState>(
  (ref) => PrivacySettingsNotifier(),
);

class PrivacySettingsNotifier extends StateNotifier<PrivacySettingsState> {
  PrivacySettingsNotifier() : super(const PrivacySettingsState()) {
    _loadFromCacheThenBackend();
  }

  final SaveValues _saveValues = SaveValues();

  static const _kLastSeen       = 'privacy_lastSeen';
  static const _kProfilePhoto   = 'privacy_profilePhoto';
  static const _kAbout          = 'privacy_about';
  static const _kGroups         = 'privacy_groups';
  static const _kStatusVis      = 'privacy_statusVisibility';
  static const _kReadReceipts   = 'privacy_readReceipts';
  static const _kMsgTimer       = 'privacy_msgTimer';
  static const _kLastSeenExcluded      = 'privacy_lastSeenExcluded';
  static const _kProfilePhotoExcluded  = 'privacy_profilePhotoExcluded';
  static const _kGroupsExcluded        = 'privacy_groupsExcluded';

  Future<void> _loadFromCacheThenBackend() async {
    final lastSeen         = await _saveValues.getString(_kLastSeen)     ?? 'everyone';
    final profilePhoto     = await _saveValues.getString(_kProfilePhoto) ?? 'everyone';
    final about            = await _saveValues.getString(_kAbout)        ?? 'everyone';
    final groups           = await _saveValues.getString(_kGroups)       ?? 'everyone';
    final statusVisibility = await _saveValues.getString(_kStatusVis)    ?? 'contacts';
    final readReceiptsStr  = await _saveValues.getString(_kReadReceipts);
    final readReceipts     = readReceiptsStr == null ? true : readReceiptsStr == 'true';
    final msgTimer         = await _saveValues.getString(_kMsgTimer)     ?? 'off';
    // NEW
    final lastSeenExcluded     = _parseIds(await _saveValues.getString(_kLastSeenExcluded));
    final profilePhotoExcluded = _parseIds(await _saveValues.getString(_kProfilePhotoExcluded));
    final groupsExcluded       = _parseIds(await _saveValues.getString(_kGroupsExcluded));

    state = state.copyWith(
      lastSeen: lastSeen,
      profilePhoto: profilePhoto,
      about: about,
      groups: groups,
      statusVisibility: statusVisibility,
      readReceipts: readReceipts,
      defaultMessageTimer: msgTimer,
      // NEW
      lastSeenExcludedIds: lastSeenExcluded,
      profilePhotoExcludedIds: profilePhotoExcluded,
      groupsExcludedIds: groupsExcluded,
    );

    await loadPrivacySettings();
  }

  //helper to convert comma-separated string back to Set<String>
  static Set<String> _parseIds(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  Future<void> _persistToCache(PrivacySettingsState s) async {
    await _saveValues.saveString(_kLastSeen,     s.lastSeen);
    await _saveValues.saveString(_kProfilePhoto, s.profilePhoto);
    await _saveValues.saveString(_kAbout,        s.about);
    await _saveValues.saveString(_kGroups,       s.groups);
    await _saveValues.saveString(_kStatusVis,    s.statusVisibility);
    await _saveValues.saveString(_kReadReceipts, s.readReceipts.toString());
    await _saveValues.saveString(_kMsgTimer,     s.defaultMessageTimer);
    await _saveValues.saveString(_kLastSeenExcluded,     s.lastSeenExcludedIds.join(','));
    await _saveValues.saveString(_kProfilePhotoExcluded, s.profilePhotoExcludedIds.join(','));
    await _saveValues.saveString(_kGroupsExcluded,       s.groupsExcludedIds.join(','));
  }

  Future<void> loadPrivacySettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token =
          await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse(ApiStrings.getUserInfo),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map) {
          final privacy = body['data']['privacy'] as Map<String, dynamic>?;
          final timer   = body['data']['defaultMessageTimer'] as String?;

          final next = state.copyWith(
            isLoading:           false,
            lastSeen:            privacy?['lastSeen']         ?? 'everyone',
            profilePhoto:        privacy?['profilePhoto']     ?? 'everyone',
            about:               privacy?['about']            ?? 'everyone',
            groups:              privacy?['groups']           ?? 'everyone',
            statusVisibility:    privacy?['statusVisibility'] ?? 'contacts',
            readReceipts:        privacy?['readReceipts']     ?? true,
            defaultMessageTimer: timer ?? 'off',
          );
          state = next;
          await _persistToCache(next);
          return;
        }
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

 Future<bool> updatePrivacy({
    String? lastSeen,
    String? profilePhoto,
    String? about,
    String? groups,
    String? statusVisibility,
    bool? readReceipts,
    // NEW
    Set<String>? lastSeenExcludedIds,
    Set<String>? profilePhotoExcludedIds,
    Set<String>? groupsExcludedIds,
  }) async {
    final previousState = state;

    // Optimistic update — include new fields
    state = state.copyWith(
      isSaving:               true,
      error:                  null,
      lastSeen:               lastSeen               ?? state.lastSeen,
      profilePhoto:           profilePhoto           ?? state.profilePhoto,
      about:                  about                  ?? state.about,
      groups:                 groups                 ?? state.groups,
      statusVisibility:       statusVisibility       ?? state.statusVisibility,
      readReceipts:           readReceipts           ?? state.readReceipts,
      // NEW
      lastSeenExcludedIds:     lastSeenExcludedIds     ?? state.lastSeenExcludedIds,
      profilePhotoExcludedIds: profilePhotoExcludedIds ?? state.profilePhotoExcludedIds,
      groupsExcludedIds:       groupsExcludedIds       ?? state.groupsExcludedIds,
    );

    // HTTP payload — unchanged, backend only knows about the string fields
    final Map<String, dynamic> privacyPayload = {};
    if (lastSeen         != null) privacyPayload['lastSeen']         = lastSeen;
    if (profilePhoto     != null) privacyPayload['profilePhoto']     = profilePhoto;
    if (about            != null) privacyPayload['about']            = about;
    if (groups           != null) privacyPayload['groups']           = groups;
    if (statusVisibility != null) privacyPayload['statusVisibility'] = statusVisibility;
    if (readReceipts     != null) privacyPayload['readReceipts']     = readReceipts;

    final body = {'privacy': privacyPayload};

    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.patch(
        Uri.parse(ApiStrings.updatePrivacy),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = jsonDecode(response.body);
        final updated = resBody['data']?['privacy'] as Map<String, dynamic>?;

        final next = state.copyWith(
          isSaving:         false,
          lastSeen:         updated?['lastSeen']         ?? lastSeen         ?? state.lastSeen,
          profilePhoto:     updated?['profilePhoto']     ?? profilePhoto     ?? state.profilePhoto,
          about:            updated?['about']            ?? about            ?? state.about,
          groups:           updated?['groups']           ?? groups           ?? state.groups,
          statusVisibility: updated?['statusVisibility'] ?? statusVisibility ?? state.statusVisibility,
          readReceipts:     updated?['readReceipts']     ?? readReceipts     ?? state.readReceipts,
          // excluded IDs come from local state (backend doesn't return them)
          lastSeenExcludedIds:     lastSeenExcludedIds     ?? state.lastSeenExcludedIds,
          profilePhotoExcludedIds: profilePhotoExcludedIds ?? state.profilePhotoExcludedIds,
          groupsExcludedIds:       groupsExcludedIds       ?? state.groupsExcludedIds,
        );
        state = next;
        await _persistToCache(next);
        return true;
      } else {
        final resBody = jsonDecode(response.body);
        state = previousState.copyWith(
          isSaving: false,
          error: resBody['message'] ?? 'Failed to update privacy settings',
        );
        return false;
      }
    } catch (e) {
      state = previousState.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateMessageTimer(String timer) async {
    final previousState = state;

    state = state.copyWith(
      isSaving:            true,
      error:               null,
      defaultMessageTimer: timer,
    );

    try {
      final token =
          await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.patch(
        Uri.parse(ApiStrings.updatePrivacy),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'defaultMessageTimer': timer}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody      = jsonDecode(response.body);
        final updatedTimer =
            resBody['data']?['defaultMessageTimer'] as String?;
        final next = state.copyWith(
          isSaving:            false,
          defaultMessageTimer: updatedTimer ?? timer,
        );
        state = next;
        await _persistToCache(next);
        return true;
      } else {
        final resBody = jsonDecode(response.body);
        state = previousState.copyWith(
          isSaving: false,
          error: resBody['message'] ?? 'Failed to update timer',
        );
        return false;
      }
    } catch (e) {
      state =
          previousState.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}