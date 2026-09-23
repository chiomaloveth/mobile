import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

// ── Biometric Auth State ──────────────────────────────────────────────────

class BiometricAuthState {
  final bool isEnabled;
  final bool isAuthenticated;
  final bool isLoading;
  final bool shouldShowLockScreen;

  const BiometricAuthState({
    this.isEnabled = false,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.shouldShowLockScreen = false,
  });

  BiometricAuthState copyWith({
    bool? isEnabled,
    bool? isAuthenticated,
    bool? isLoading,
    bool? shouldShowLockScreen,
  }) {
    return BiometricAuthState(
      isEnabled: isEnabled ?? this.isEnabled,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      shouldShowLockScreen: shouldShowLockScreen ?? this.shouldShowLockScreen,
    );
  }
}

// ── Biometric Auth Service ────────────────────────────────────────────────

class BiometricAuthService extends StateNotifier<BiometricAuthState> {
  BiometricAuthService() : super(const BiometricAuthState(isLoading: true)) {
    _initialize();
  }

  final LocalAuthentication _auth = LocalAuthentication();
  final SaveValues _saveValues = SaveValues();
  
  // Cache keys
  static const _kBiometricEnabled = 'biometric_enabled';
  static const _kLastAuthTime = 'last_auth_time';
  static const _kAppWasInBackground = 'app_was_in_background';

  // Set this to true before opening camera/file picker so the
  // resulting paused lifecycle event does not trigger a lock.
  bool isPickerActive = false;
  int _pauseCountDuringPicker = 0;
  DateTime? _pickerPausedAt;

  Future<void> _initialize() async {
    // ── PHASE 1: synchronous pre-check ──────────────────────────────────────
    // Read the persisted enabled flag BEFORE any async gap so the initial
    // state already reflects whether a lock is needed.  This closes the
    // window where isEnabled==false lets the app render unprotected.
    final cachedEnabled = await _saveValues.getString(_kBiometricEnabled);
    final isEnabled = cachedEnabled == 'true';

    if (isEnabled) {
      // Immediately lock — don't wait for anything else.
      // The app will stay behind the lock screen until authenticate() succeeds.
      final wasInBackground = await _saveValues.getString(_kAppWasInBackground);
      final needsAuth = wasInBackground == 'true';

      state = state.copyWith(
        isEnabled: true,
        // If the app was freshly launched (not from background) we still
        // require auth on first open when biometric is enabled.
        isAuthenticated: false,
        shouldShowLockScreen: true,
        isLoading: false,
      );

      // Clear the background flag now that we've acted on it.
      await _saveValues.clearPrefValue(_kAppWasInBackground);
    } else {
      state = state.copyWith(
        isEnabled: false,
        isAuthenticated: true,
        shouldShowLockScreen: false,
        isLoading: false,
      );
    }

    // Sync with backend (non-blocking, does not affect lock state).
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token == null) return;
      
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
          final isAppLockEnabled = body['data']['isAppLockEnabled'] as bool? ?? false;
          
          // Only update local cache if we don't have a local setting yet
          final localSetting = await _saveValues.getString(_kBiometricEnabled);
          if (localSetting == null) {
            await _saveValues.saveString(_kBiometricEnabled, isAppLockEnabled.toString());
            
            // Update state to match backend only if no local preference exists
            if (isAppLockEnabled != state.isEnabled) {
              if (isAppLockEnabled) {
                state = state.copyWith(
                  isEnabled: true,
                  isAuthenticated: false,
                  shouldShowLockScreen: true,
                );
              } else {
                state = state.copyWith(
                  isEnabled: false,
                  isAuthenticated: true,
                  shouldShowLockScreen: false,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore sync errors - local functionality should work independently
      print('Backend sync failed (this is okay): $e');
    }
  }

  Future<bool> authenticate({String? reason}) async {
    if (!state.isEnabled) {
      // If biometric is disabled, consider as authenticated
      state = state.copyWith(isAuthenticated: true, shouldShowLockScreen: false);
      return true;
    }

    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isAvailable = await _auth.isDeviceSupported();
      
      if (!canCheck || !isAvailable) {
        // Biometric not available, just allow access
        state = state.copyWith(isAuthenticated: true, shouldShowLockScreen: false);
        return true;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Unlock to use QikTalk',
        options: const AuthenticationOptions(
          biometricOnly: true, // Only fingerprint/face ID, no PIN/pattern
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Save authentication time and clear background flag
        await _saveValues.saveString(_kLastAuthTime, DateTime.now().toIso8601String());
        await _saveValues.clearPrefValue(_kAppWasInBackground);
        
        // Immediately update state to hide lock screen
        state = state.copyWith(
          isAuthenticated: true,
          shouldShowLockScreen: false,
          isLoading: false,
        );
        return true;
      } else {
        // Authentication failed, keep showing lock screen
        state = state.copyWith(
          isAuthenticated: false,
          shouldShowLockScreen: true,
          isLoading: false,
        );
        return false;
      }
    } on PlatformException catch (e) {
      print('Fingerprint authentication error: $e');
      // On error, keep showing lock screen
      state = state.copyWith(
        isAuthenticated: false,
        shouldShowLockScreen: true,
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> enableBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isAvailable = await _auth.isDeviceSupported();
      
      if (!canCheck || !isAvailable) {
        throw Exception('Fingerprint authentication is not available on this device');
      }

      // First authenticate to enable (fingerprint only)
      final authenticated = await _auth.authenticate(
        localizedReason: 'Unlock to use QikTalk',
        options: const AuthenticationOptions(
          biometricOnly: true, // Only fingerprint/face ID, no PIN/pattern
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        throw Exception('Fingerprint authentication failed');
      }

      // Update local state first (this is the primary functionality)
      await _saveValues.saveString(_kBiometricEnabled, 'true');
      await _saveValues.saveString(_kLastAuthTime, DateTime.now().toIso8601String());
      
      state = state.copyWith(
        isEnabled: true,
        isAuthenticated: true,
        shouldShowLockScreen: false,
      );

      // Try to update backend (optional - don't fail if this doesn't work)
      _updateBackend(true).catchError((e) {
        print('Warning: Failed to sync biometric setting to backend: $e');
        // Continue anyway - local functionality is what matters
        return false;
      });
      
    } catch (e) {
      rethrow;
    }
  }

  /// Check if biometric authentication is available on this device
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isAvailable = await _auth.isDeviceSupported();
      return canCheck && isAvailable;
    } catch (_) {
      return false;
    }
  }

  Future<void> disableBiometric() async {
    // Update local state first (this is the primary functionality)
    await _saveValues.saveString(_kBiometricEnabled, 'false');
    await _saveValues.clearPrefValue(_kLastAuthTime);
    
    state = state.copyWith(
      isEnabled: false,
      isAuthenticated: true,
      shouldShowLockScreen: false,
    );

    // Try to update backend (optional - don't fail if this doesn't work)
    _updateBackend(false).catchError((e) {
      print('Warning: Failed to sync biometric setting to backend: $e');
      // Continue anyway - local functionality is what matters
      return false;
    });
  }

  Future<bool> _updateBackend(bool enabled) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      if (token == null) return false;
      
      final response = await http.post(
        Uri.parse('${ApiStrings.baseUri}user/biometric-lock'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'isAppLockEnabled': enabled}),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  void onAppResumed() {
    isPickerActive = false;
    if (state.isEnabled) {
      _checkIfNeedsAuthentication();
    }
  }

  void onAppPaused() {
    if (isPickerActive) {
      _pauseCountDuringPicker++;
      _pickerPausedAt = DateTime.now();
    }
    if (state.isEnabled) {
      _saveValues.saveString(_kAppWasInBackground, 'true');
    }
  }

  Future<void> onPickerReturned() async {
    isPickerActive = false;
    final pausedAt = _pickerPausedAt;
    _pauseCountDuringPicker = 0;
    _pickerPausedAt = null;

    if (pausedAt == null) {
      await _saveValues.clearPrefValue(_kAppWasInBackground);
      return;
    }

    final pauseDuration = DateTime.now().difference(pausedAt);
    if (pauseDuration.inSeconds < 4) {
      await _saveValues.clearPrefValue(_kAppWasInBackground);
    }
  }

  void onAppInactive() {
    // App is inactive (notification panel, control center, etc.)
    // Don't require authentication for this - this is just temporary
    // Don't change any state here
  }

  Future<void> _checkIfNeedsAuthentication() async {
    if (!state.isEnabled) return;
    
    final wasInBackground = await _saveValues.getString(_kAppWasInBackground);
    
    if (wasInBackground == 'true') {
      // App was in background, require authentication
      state = state.copyWith(
        isAuthenticated: false,
        shouldShowLockScreen: true,
        isLoading: false,
      );
    } else {
      // App wasn't in background (just inactive), no authentication needed
      state = state.copyWith(
        isAuthenticated: true,
        shouldShowLockScreen: false,
        isLoading: false,
      );
    }
  }

  void logout() {
    // Clear authentication state on logout
    state = state.copyWith(
      isAuthenticated: false,
      shouldShowLockScreen: state.isEnabled,
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final biometricAuthProvider = StateNotifierProvider<BiometricAuthService, BiometricAuthState>(
  (ref) => BiometricAuthService(),
);