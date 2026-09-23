import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/services/biometric_auth_service.dart';

class AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground from background
        ref.read(biometricAuthProvider.notifier).onAppResumed();
        break;
      case AppLifecycleState.paused:
        // App went to background (home button, app switcher, etc.)
        // This is when we should require authentication on return
        ref.read(biometricAuthProvider.notifier).onAppPaused();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (notification panel, control center, etc.)
        // Don't lock for inactive state - it's too aggressive and causes repeated prompts
        // User is still "using" the app, just temporarily interrupted
        ref.read(biometricAuthProvider.notifier).onAppInactive();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Do nothing — hidden is a transient state on Android (e.g. opening
        // a picker or camera). Treating it as paused breaks picker detection.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}