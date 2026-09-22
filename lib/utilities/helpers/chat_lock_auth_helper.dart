import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Shared authentication helper for the Chat Lock (Protected Chats) feature.
///
/// Triggers biometric or device-credential auth.
/// Falls back to device PIN/pattern/password when biometrics are unavailable
/// by using [biometricOnly: false].
///
/// Returns `true` on successful authentication, `false` otherwise.
class ChatLockAuthHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Authenticate the user before locking / unlocking / entering a protected chat.
  ///
  /// [context]  – used to show an error snackbar on hard failure.
  /// [reason]   – message shown in the system auth prompt.
  static Future<bool> authenticate(
    BuildContext context, {
    String reason = 'Authenticate to access your protected chats',
  }) async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      if (!isSupported) {
        // Device has no lock screen at all — allow access gracefully.
        return true;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // false = also allow PIN/pattern/password when biometric unavailable
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('ChatLockAuth error: $e');
      // NotAvailable / PasscodeNotSet — let user through gracefully so they
      // are never permanently locked out.
      if (e.code == 'NotAvailable' ||
          e.code == 'PasscodeNotSet' ||
          e.code == 'notAvailable' ||
          e.code == 'no_fragment_activity') {
        return true;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('ChatLockAuth unknown error: $e');
      return false;
    }
  }
}
