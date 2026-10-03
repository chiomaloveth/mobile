import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

const List<Color> _kBgColors = [
  Colors.black,
  Color(0xFF1A1A2E), // deep navy
  Color(0xFF0D3B2E), // deep green
  Color(0xFF2E0D1A), // deep wine
  Color(0xFF1A0D2E), // deep purple
  Color(0xFF2E2A0D), // deep gold
  Color(0xFF0D1A2E), // deep blue
  Color(0xFF2E1A0D), // deep amber
];

class OngoingCallScreen extends ConsumerStatefulWidget {
  const OngoingCallScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OngoingCallScreen> createState() => _OngoingCallScreenState();
}

class _OngoingCallScreenState extends ConsumerState<OngoingCallScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  StreamSubscription<int>? _proximitySub;
  ProviderSubscription<CallInfo?>? _callStateSub;

  bool _isEnding = false;
  bool _hasNavigatedAway = false;
  bool _isTogglingVideo = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  String _myPhoto = '';
  String _myUsername = '';

  int _bgColorIndex = 0;
  Color get _bgColor => _kBgColors[_bgColorIndex];

  Offset _circlesOffset = Offset.zero;
  bool _localIsFullscreen = false;
  bool _controlsVisible = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableProximityWakeLock();
    WakelockPlus.enable();
    _loadMyProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(isCallScreenVisibleProvider.notifier).state = true;
      ref.read(callStateProvider.notifier).webrtcService.onRemoteStreamReady = () {
        if (mounted) {
          debugPrint('📺 [OngoingCallScreen] Rebuilding due to remote stream update');
          setState(() {});
        }
      };
    });

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _callStateSub = ref.listenManual<CallInfo?>(callStateProvider, (
        previous,
        next,
      ) {
        if (_hasNavigatedAway) return;
        if (next == null || next.state == CallState.ended) {
          _hasNavigatedAway = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
        }
      });
      _resetControlsTimer();
    });
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  Future<void> _loadMyProfile() async {
    final photo =
        await SaveValues().getString(AppPreferenceHelper.PROFILE_IMAGE) ?? '';
    String username =
        await SaveValues().getString(AppPreferenceHelper.USER_NAME) ?? '';
    if (username.isEmpty) {
      username =
          await SaveValues().getString(AppPreferenceHelper.FIRST_NAME) ?? '';
    }
    if (mounted) {
      setState(() {
        _myPhoto = photo;
        _myUsername = username;
      });
    }
  }

  @override
  void dispose() {
    _callStateSub?.close();
    _controlsTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _glowController.dispose();
    _disableProximityWakeLock();
    WakelockPlus.disable();
    try {
      ref.read(callStateProvider.notifier).webrtcService.onRemoteStreamReady = null;
    } catch (_) {}
    try {
      ref.read(isCallScreenVisibleProvider.notifier).state = false;
    } catch (_) {}
    super.dispose();
  }

  Future<void> _enableProximityWakeLock() async {
    try {
      _proximitySub = ProximitySensor.events.listen((_) {});
    } catch (_) {}
  }

  void _disableProximityWakeLock() => _proximitySub?.cancel();

  Future<void> _handleEndCall() async {
    if (_isEnding) return;
    _isEnding = true;
    await ref.read(callStateProvider.notifier).endCall();
    if (mounted) Navigator.of(context).pop();
  }

  void _handleBack() {
    if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
  }

  Future<void> _handleToggleVideo() async {
    if (_isTogglingVideo) return;
    setState(() => _isTogglingVideo = true);
    try {
      final notifier = ref.read(callStateProvider.notifier);
      await notifier.toggleCamera();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video toggle failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingVideo = false);
    }
  }

  Future<void> _handleSendMessage(CallInfo callInfo) async {
    try {
      String? chatId;
      String about = '';
      try {
        final chatBox = await Hive.openBox<ChatListItemHive>('chats');
        for (final chat in chatBox.values) {
          if (chat.userId == callInfo.userId) {
            chatId = chat.id;
            about = chat.about;
            break;
          }
        }
      } catch (_) {}
      chatId ??= await ref
          .read(callStateProvider.notifier)
          .getOrCreateChatId(callInfo.userId);
      if (chatId == null || chatId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open chat.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MessageScreen(
              chatId: chatId!,
              userId: callInfo.userId,
              username: callInfo.userName,
              lastSeenActive: '',
              profilePicture: callInfo.userPhoto,
              about: about,
              isGroupChat: false,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ _handleSendMessage: $e');
    }
  }

  void _showMoreOptions(CallInfo callInfo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A7F4B).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    color: Color(0xFF1A7F4B),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Send Message',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Open chat with ${callInfo.userName}',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _handleSendMessage(callInfo);
                },
              ),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add, color: Colors.white, size: 20),
                ),
                title: Text(
                  'Add Participant',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Coming soon',
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 12,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callStateProvider.select((s) => s?.state));
    final callInfo = ref.read(callStateProvider);
    final notifier = ref.read(callStateProvider.notifier);

    if (callInfo == null || callState == CallState.ended) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.call_end, color: Colors.white24, size: 64),
              const SizedBox(height: 16),
              Text(
                'Call Ended',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (callInfo.state == CallState.failed) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Failed',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your internet connection',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                ),
                onPressed: _handleEndCall,
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _resetControlsTimer,
          child: callInfo.isVideo
              ? _buildVideoUI(callInfo, notifier)
              : _buildVoiceUI(callInfo, notifier),
        ),
      ),
    );
  }

  Widget _buildVoiceUI(CallInfo callInfo, CallStateNotifier notifier) {
    final isVideo = callInfo.isVideo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: _bgColor,
      child: SafeArea(
        child: Column(
          children: [
            _TopBar(
              callInfo: callInfo,
              onBack: _handleBack,
              onFlipCamera: () => notifier.switchCamera(),
            ),
            const Spacer(),
            if (!isVideo) ...[
              GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _circlesOffset += d.delta;
                    const maxX = 110.0;
                    const maxY = 180.0;
                    _circlesOffset = Offset(
                      _circlesOffset.dx.clamp(-maxX, maxX),
                      _circlesOffset.dy.clamp(-maxY, maxY),
                    );
                  });
                },
                child: Transform.translate(
                  offset: _circlesOffset,
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (_, __) {
                      const double sz = 140.0;
                      const double overlap = 40.0;
                      return SizedBox(
                        width: sz * 2 - overlap,
                        height: sz,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _ProfileCircle(
                                imageUrl: callInfo.userPhoto,
                                name: callInfo.userName,
                                size: sz,
                                glowOpacity: _glowAnimation.value,
                                isRight: false,
                              ),
                            ),
                            Positioned(
                              left: sz - overlap,
                              child: _ProfileCircle(
                                imageUrl: _myPhoto,
                                name: _myUsername,
                                size: sz,
                                glowOpacity: _glowAnimation.value * 0.8,
                                isRight: true,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (callInfo.state == CallState.inProgress) const _DurationPill(),
            const SizedBox(height: 20),
            _ControlBar(
              callInfo: callInfo,
              notifier: notifier,
              onEndCall: _handleEndCall,
              onToggleVideo: _handleToggleVideo,
              onMoreOptions: () => _showMoreOptions(callInfo),
              isTogglingVideo: _isTogglingVideo,
              isVideoMode: false,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamView({
    required bool isLocal,
    required bool compact,
    required CallStateNotifier notifier,
    required CallInfo callInfo,
  }) {
    if (isLocal) {
      if (notifier.isCameraOn) {
        return RTCVideoView(
          notifier.webrtcService.localRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          mirror: true,
        );
      } else {
        return _VideoFallback(
          photoUrl: _myPhoto,
          name: _myUsername,
          compact: compact,
        );
      }
    } else {
      final remoteStream = notifier.webrtcService.remoteRenderer.srcObject;
      final hasVideo = remoteStream != null &&
          remoteStream.getVideoTracks().any((track) => track.enabled);
      if (hasVideo) {
        return RTCVideoView(
          notifier.webrtcService.remoteRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        );
      } else {
        return _VideoFallback(
          photoUrl: callInfo.userPhoto,
          name: callInfo.userName,
          compact: compact,
        );
      }
    }
  }

  Widget _buildVideoUI(CallInfo callInfo, CallStateNotifier notifier) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fullscreen stream or fallback
        GestureDetector(
          onTap: _resetControlsTimer,
          child: _buildStreamView(
            isLocal: _localIsFullscreen,
            compact: false,
            notifier: notifier,
            callInfo: callInfo,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 180,
          child: _gradientOverlay(fromTop: true),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 340,
          child: _gradientOverlay(fromTop: false),
        ),
        // Local PIP stream or fallback
        Positioned(
          right: 20,
          bottom: 160,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _localIsFullscreen = !_localIsFullscreen;
              });
            },
            child: _RectangularPip(
              child: _buildStreamView(
                isLocal: !_localIsFullscreen,
                compact: true,
                notifier: notifier,
                callInfo: callInfo,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _TopBar(
                    callInfo: callInfo,
                    onBack: _handleBack,
                    onFlipCamera: () => notifier.switchCamera(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: SafeArea(
            top: false,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _ControlBar(
                callInfo: callInfo,
                notifier: notifier,
                onEndCall: _handleEndCall,
                onToggleVideo: _handleToggleVideo,
                onMoreOptions: () => _showMoreOptions(callInfo),
                isTogglingVideo: _isTogglingVideo,
                isVideoMode: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradientOverlay({required bool fromTop}) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
            end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.72), Colors.transparent],
          ),
        ),
      );
}

class _VideoFallback extends StatelessWidget {
  final String photoUrl;
  final String name;
  final bool compact;
  const _VideoFallback({
    required this.photoUrl,
    required this.name,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final sz = compact ? 52.0 : 120.0;
    return SizedBox.expand(
      child: Container(
        color: const Color(0xFF111111),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProfileCircle(
                imageUrl: photoUrl,
                name: name,
                size: sz,
                glowOpacity: 0.5,
              ),
              if (!compact) ...[
                const SizedBox(height: 14),
                Text(
                  'Camera is off',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RectangularPip extends StatelessWidget {
  final Widget child;
  const _RectangularPip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(15), child: child),
    );
  }
}

class _TopBar extends StatefulWidget {
  final CallInfo callInfo;
  final VoidCallback onBack;
  final VoidCallback onFlipCamera;

  const _TopBar({
    required this.callInfo,
    required this.onBack,
    required this.onFlipCamera,
  });

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  bool _showEncryption = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showEncryption = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleBtn(
                svgPath: 'images/icons/minimize.svg',
                onTap: widget.onBack,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleBtn(
                    svgPath: 'images/icons/add_friends.svg',
                    onTap: () {},
                  ),
                  if (widget.callInfo.isVideo) ...[
                    const SizedBox(width: 10),
                    _CircleBtn(
                      svgPath: 'images/icons/flip_camera.svg',
                      onTap: widget.onFlipCamera,
                    ),
                  ],
                ],
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.callInfo.userName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _buildSubtitle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    if (widget.callInfo.state == CallState.inProgress) {
      return const SizedBox.shrink();
    }

    if (_showEncryption && widget.callInfo.state == CallState.connecting) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, color: Colors.white54, size: 10),
          const SizedBox(width: 4),
          Text(
            'End-to-end encryption',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
          ),
        ],
      );
    }

    String text = 'Calling...';
    if (widget.callInfo.state == CallState.ringing) {
      text = 'Ringing...';
    } else if (widget.callInfo.state == CallState.reconnecting) {
      text = 'Reconnecting...';
    }

    return Text(
      text,
      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
    );
  }
}

class _DurationPill extends ConsumerWidget {
  const _DurationPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(callTimerProvider).value ?? 0;
    final m = duration ~/ 60;
    final s = duration % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ControlBar extends ConsumerWidget {
  final CallInfo callInfo;
  final CallStateNotifier notifier;
  final VoidCallback onEndCall;
  final VoidCallback onToggleVideo;
  final VoidCallback onMoreOptions;
  final bool isTogglingVideo;
  final bool isVideoMode;

  const _ControlBar({
    required this.callInfo,
    required this.notifier,
    required this.onEndCall,
    required this.onToggleVideo,
    required this.onMoreOptions,
    required this.isTogglingVideo,
    required this.isVideoMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(callStateProvider);
    final isMuted = notifier.isMuted;
    final isSpeakerOn = notifier.isSpeakerOn;
    final isCameraOn = notifier.isCameraOn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CallBtn(
            icon: Icons.more_horiz,
            bg: const Color(0xFF141414),
            iconColor: Colors.white,
            onTap: onMoreOptions,
          ),
          isTogglingVideo
              ? const _SpinnerBtn()
              : _CallBtn(
                  svgPath: 'images/icons/video.svg',
                  bg: isCameraOn ? Colors.white : const Color(0xFF141414),
                  iconColor: isCameraOn ? Colors.black : Colors.white,
                  onTap: onToggleVideo,
                ),
          _CallBtn(
            svgPath: 'images/icons/mdi_headset.svg',
            bg: isSpeakerOn ? Colors.white : const Color(0xFF141414),
            iconColor: isSpeakerOn ? Colors.black : Colors.white,
            onTap: () => notifier.toggleSpeaker(),
          ),
          _CallBtn(
            svgPath: isMuted ? 'images/icons/mute.svg' : 'images/icons/mic.svg',
            bg: isMuted ? Colors.white : const Color(0xFF141414),
            iconColor: isMuted ? Colors.black : Colors.white,
            onTap: () => notifier.toggleMute(),
          ),
          _CallBtn(
            icon: Icons.call_end,
            bg: const Color(0xFFFF0000),
            iconColor: Colors.white,
            onTap: onEndCall,
            size: 54,
          ),
        ],
      ),
    );
  }
}

class _ProfileCircle extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;
  final double glowOpacity;
  final bool isRight;
  const _ProfileCircle({
    required this.imageUrl,
    required this.name,
    required this.size,
    required this.glowOpacity,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B00).withOpacity(0.55 * glowOpacity),
            blurRadius: 28,
            spreadRadius: isRight ? 10 : 6,
          ),
          if (isRight)
            const BoxShadow(
              color: Colors.black,
              spreadRadius: 4,
              blurRadius: 0,
            ),
        ],
        border: Border.all(
          color: const Color(0xFFFF6B00).withOpacity(0.7 + 0.3 * glowOpacity),
          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(name: name, size: size),
              )
            : _Initials(name: name, size: size),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final double size;
  const _Initials({required this.name, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFFF6B00),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(
              fontSize: size * 0.38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
}

class _CallBtn extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;
  final double size;

  const _CallBtn({
    this.icon,
    this.svgPath,
    required this.bg,
    required this.iconColor,
    required this.onTap,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: svgPath != null
                ? SvgPicture.asset(
                    svgPath!,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    width: size * 0.44,
                  )
                : Icon(icon, color: iconColor, size: size * 0.44),
          ),
        ),
      );
}

class _SpinnerBtn extends StatelessWidget {
  const _SpinnerBtn();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 58,
        height: 58,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
          ),
        ),
      );
}

class _CircleBtn extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final VoidCallback onTap;

  const _CircleBtn({this.icon, this.svgPath, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: svgPath != null
                ? SvgPicture.asset(
                    svgPath!,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                  )
                : Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      );
}
