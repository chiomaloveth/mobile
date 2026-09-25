import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';

// SharedPreferences key for the picture version counter.
const _kPicVersion = 'profile_picture_version';

class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String email;

  /// Raw URL as stored on the backend / SharedPreferences.
  final String profilePicture;

  final String phoneNumber;
  final String about;

  /// Monotonically-increasing counter that is bumped every time the user
  /// successfully uploads a new profile picture.  Used by [profilePictureUrl]
  /// to append a cache-busting query parameter so that every Image.network /
  /// CircleAvatar(backgroundImage: NetworkImage(...)) widget across the whole
  /// app treats the new picture as a brand-new URL — even widgets that have
  /// no ValueKey and would otherwise reuse the cached bitmap.
  final int pictureVersion;

  UserProfile({
    this.id = '',
    this.username = '',
    this.email = '',
    this.profilePicture = '',
    this.fullName = '',
    this.phoneNumber = '',
    this.about = '',
    this.pictureVersion = 0,
  });

  /// URL to use in Image.network / NetworkImage calls.
  /// Appends ?v=<pictureVersion> so Flutter treats each new upload as a
  /// distinct URL, bypassing both its in-memory image cache and any HTTP
  /// cache layer — without requiring a ValueKey on every widget.
  String get profilePictureUrl {
    if (profilePicture.isEmpty) return '';
    // Avoid double-appending if the URL already has a query string.
    final separator = profilePicture.contains('?') ? '&' : '?';
    return '$profilePicture${separator}v=$pictureVersion';
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    String? about,
    int? pictureVersion,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      about: about ?? this.about,
      pictureVersion: pictureVersion ?? this.pictureVersion,
    );
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile()) {
    loadUser();
  }

  final SaveValues _saveValues = SaveValues();

  Future<void> loadUser() async {
    final id = await _saveValues.getString(AppPreferenceHelper.ID) ?? '';
    final username =
        await _saveValues.getString(AppPreferenceHelper.USER_NAME) ?? 'User';
    final email =
        await _saveValues.getString(AppPreferenceHelper.EMAIL_ADDRESS) ?? '';
    final profilePicture =
        await _saveValues.getString(AppPreferenceHelper.PROFILE_IMAGE) ?? '';
    final phoneNumber =
        await _saveValues.getString(AppPreferenceHelper.PHONE_NUMBER) ?? '';
    final about =
        await _saveValues.getString(AppPreferenceHelper.ABOUT) ?? '';
    final fullName =
        await _saveValues.getString(AppPreferenceHelper.FULL_NAME) ?? '';
    final version = await _saveValues.getInt(_kPicVersion) ?? 0;

    state = UserProfile(
      id: id,
      username: username,
      email: email,
      profilePicture: profilePicture,
      phoneNumber: phoneNumber,
      about: about,
      fullName: fullName,
      pictureVersion: version,
    );
  }

  Future<void> updateEmail(String newEmail) async {
    await _saveValues.saveString(AppPreferenceHelper.EMAIL_ADDRESS, newEmail);
    state = state.copyWith(email: newEmail);
  }

  /// Called only after the user taps Update and the upload succeeds.
  /// Evicts the old bitmap from Flutter's image cache AND bumps the version
  /// counter so every CachedNetworkImage widget gets a new URL string.
  Future<void> updateProfilePicture(String newProfilePictureUrl) async {
    // 1. Evict old bitmap from Flutter's in-memory image cache.
    final oldUrl = state.profilePicture;
    if (oldUrl.isNotEmpty) {
      PaintingBinding.instance.imageCache.evict(NetworkImage(oldUrl));
      // Also evict the versioned URL that was previously in use.
      if (state.pictureVersion > 0) {
        final sep = oldUrl.contains('?') ? '&' : '?';
        PaintingBinding.instance.imageCache
            .evict(NetworkImage('$oldUrl${sep}v=${state.pictureVersion}'));
      }
      // 2. Also evict from CachedNetworkImage's disk cache.
      await CachedNetworkImage.evictFromCache(oldUrl);
      if (state.pictureVersion > 0) {
        final sep = oldUrl.contains('?') ? '&' : '?';
        await CachedNetworkImage.evictFromCache(
            '$oldUrl${sep}v=${state.pictureVersion}');
      }
    }

    // 3. Bump the version counter and persist everything.
    final newVersion = state.pictureVersion + 1;
    await _saveValues.saveString(
        AppPreferenceHelper.PROFILE_IMAGE, newProfilePictureUrl);
    await _saveValues.saveInt(_kPicVersion, newVersion);

    state = state.copyWith(
      profilePicture: newProfilePictureUrl,
      pictureVersion: newVersion,
    );
  }

  /// Syncs text fields from the backend response.
  /// Never overwrites the profile picture — the caller is responsible for
  /// passing the already-correct local URL so we don't regress to a
  /// potentially-stale backend value.
  Future<void> updateFromUserInfo({
    required String username,
    required String about,
    required String fullName,
    required String profilePicture,
  }) async {
    // Only evict + bump version when the URL genuinely changes (e.g. first
    // load after a fresh install where the backend has a newer URL).
    final oldUrl = state.profilePicture;
    int newVersion = state.pictureVersion;

    if (oldUrl.isNotEmpty && oldUrl != profilePicture) {
      PaintingBinding.instance.imageCache.evict(NetworkImage(oldUrl));
      newVersion = state.pictureVersion + 1;
      await _saveValues.saveInt(_kPicVersion, newVersion);
    }

    await _saveValues.saveString(AppPreferenceHelper.USER_NAME, username);
    await _saveValues.saveString(AppPreferenceHelper.ABOUT, about);
    await _saveValues.saveString(AppPreferenceHelper.FULL_NAME, fullName);
    await _saveValues.saveString(
        AppPreferenceHelper.PROFILE_IMAGE, profilePicture);

    state = state.copyWith(
      username: username,
      about: about,
      fullName: fullName,
      profilePicture: profilePicture,
      pictureVersion: newVersion,
    );
  }
}
