import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/calls/incoming_call_screen.dart';
import 'package:qik_talk/features/calls/ongoing_call_screen.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/authentication/provider/user_provider.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

class GlobalCallListener extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  const GlobalCallListener({
    required this.child,
    required this.navigatorKey,
    super.key,
  });

  @override
  ConsumerState<GlobalCallListener> createState() => _GlobalCallListenerState();
}

class _GlobalCallListenerState extends ConsumerState<GlobalCallListener> {
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAttach();

      _statusSub = GlobalSocketService().connectionStatus.listen((status) {
        if (status == ConnectionStatus.connected) {
          debugPrint('[GlobalCallListener] Socket reconnected — re-attaching');
          _tryAttach();
        }
      });
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _tryAttach() async {
    final userProfile = ref.read(userProfileProvider);
    if (userProfile.id.isEmpty) {
      debugPrint('[GlobalCallListener] User profile empty, loading from prefs...');
      await ref.read(userProfileProvider.notifier).loadUser();
    }
    
    final updatedProfile = ref.read(userProfileProvider);
    if (updatedProfile.id.isEmpty) {
      debugPrint('[GlobalCallListener] User not logged in, cannot attach calling socket');
      return;
    }

    final socket = GlobalSocketService().socket;
    if (socket == null || !socket.connected) {
      debugPrint('[GlobalCallListener] Global socket not connected, cannot attach calling socket');
      return;
    }

    final authToken = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN) ?? '';

    debugPrint('🔌 [GlobalCallListener] Attaching calling socket for user=${updatedProfile.id}');
    ref.read(callStateProvider.notifier).initializeWithSocket(
      socket,
      myUserId: updatedProfile.id,
      myUsername: updatedProfile.username,
      authToken: authToken,
    );
  }

  void _showIncomingCallScreen() {
    if (!mounted) return;
    widget.navigatorKey.currentState!.push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: true,
        pageBuilder: (_, __, ___) => const IncomingCallScreen(),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserProfile>(userProfileProvider, (previous, next) {
      if (next.id.isNotEmpty && (previous == null || previous.id != next.id)) {
        debugPrint('[GlobalCallListener] User profile ID became active, calling _tryAttach()');
        _tryAttach();
      }
    });

    ref.listen<CallInfo?>(callStateProvider, (previous, next) {
      if (next != null &&
          next.state == CallState.ringing &&
          next.direction == CallDirection.incoming) {
        final isVisible = ref.read(isCallScreenVisibleProvider);
        if (!isVisible) {
          debugPrint('[GlobalCallListener] Automatic incoming call pop up triggered');
          _showIncomingCallScreen();
        }
      }
    });

    final callState = ref.watch(callStateProvider);
    final isVisible = ref.watch(isCallScreenVisibleProvider);

    final showBanner = callState != null &&
        !isVisible &&
        (callState.state == CallState.inProgress ||
            callState.state == CallState.ringing ||
            callState.state == CallState.connecting);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (showBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: GestureDetector(
                  onTap: () {
                    if (callState.state == CallState.ringing &&
                        callState.direction == CallDirection.incoming) {
                      _showIncomingCallScreen();
                    } else {
                      widget.navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (_) => const OngoingCallScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#FB8830'),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _PulsingCallIcon(isVideo: callState.isVideo),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                callState.state == CallState.inProgress
                                    ? 'Ongoing Call'
                                    : 'Call in Progress...',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Tap to return to call with ${callState.userName}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulsingCallIcon extends StatefulWidget {
  final bool isVideo;
  const _PulsingCallIcon({required this.isVideo});

  @override
  State<_PulsingCallIcon> createState() => _PulsingCallIconState();
}

class _PulsingCallIconState extends State<_PulsingCallIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.isVideo ? Icons.videocam : Icons.call,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
