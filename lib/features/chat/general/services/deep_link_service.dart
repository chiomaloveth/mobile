import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:qik_talk/features/chat/group_chat/screens/join_group_screen.dart';

/// Listens for deep links of the form:
///   https://qiktalk.app/join?code=<groupId>
///
/// When intercepted, opens JoinGroupScreen which shows the group preview,
/// handles "already a member", and calls POST /chat/group/join.
///
/// Setup:
///   1. Call DeepLinkService.init(navigatorKey) once in main.dart after runApp
///   2. Pass your app's GlobalKey<NavigatorState> so the service can navigate
///
/// Android: add intent-filter in AndroidManifest.xml (see README below)
/// iOS:     add Associated Domains + url types in Info.plist (see README below)
class DeepLinkService {
  DeepLinkService._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  /// Call once from main.dart:
  ///   await DeepLinkService.init(navigatorKey);
  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // Handle link that launched the app from a cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, navigatorKey);
      }
    } catch (_) {}

    // Handle links while app is already running
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, navigatorKey),
      onError: (_) {},
    );
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  static void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    // Only handle: https://qiktalk.app/join?code=<groupId>
    if (uri.host != 'qiktalk.app') return;
    if (uri.path != '/join') return;

    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) return;

    print('🔗 Deep link: join group with code=$code');

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => JoinGroupScreen(inviteCode: code)),
    );
  }
}
