import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/auth/screens/app_lock_screen.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

class AppLockWrapper extends ConsumerWidget {
  final Widget child;

  const AppLockWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricState = ref.watch(biometricAuthProvider);

    // ── Block access while the service is still initialising ──────────────
    // This prevents the brief window where isEnabled==false lets the app
    // render before _initialize() has finished reading persisted settings.
    if (biometricState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    // Only show lock screen if biometric is enabled and user is not authenticated
    if (biometricState.isEnabled &&
        biometricState.shouldShowLockScreen &&
        !biometricState.isAuthenticated) {
      return Stack(
        children: [
          // Keep the original app in the background (preserves navigation)
          child,
          // Overlay the lock screen on top — blocks all interaction
          const AppLockScreen(),
        ],
      );
    }

    // Show main app if authenticated or biometric is disabled
    return child;
  }
}