import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/calls/ongoing_call_screen.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/calls/services/call_ringtone_service.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAccepting = false;
  bool _graceActive = true;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    CallRingtoneService().startRinging();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _graceActive = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isCallScreenVisibleProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    CallRingtoneService().stopRinging();
    
    // ✅ FIX: Use a safer check before accessing ref in dispose
    try {
      ref.read(isCallScreenVisibleProvider.notifier).state = false;
    } catch (e) {
      debugPrint('⚠️ Could not reset isCallScreenVisibleProvider in IncomingCallScreen dispose: $e');
    }
    
    super.dispose();
  }

  Future<void> _onAccept() async {
    if (_isAccepting) return;
    debugPrint('🔔 [IncomingCallScreen] _onAccept clicked');
    if (mounted) setState(() => _isAccepting = true);
    await CallRingtoneService().stopRinging();

    if (mounted) {
      debugPrint('🚀 [IncomingCallScreen] Navigating to OngoingCallScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OngoingCallScreen()),
      ).then((_) => debugPrint('✅ [IncomingCallScreen] pushReplacement finished'));
    }

    debugPrint('📞 [IncomingCallScreen] Calling acceptCall()');
    ref.read(callStateProvider.notifier).acceptCall().then((_) {
      debugPrint('✅ [IncomingCallScreen] acceptCall() completed');
    }).catchError((e) {
      debugPrint('❌ [IncomingCallScreen] acceptCall() failed: $e');
    });
  }

  Future<void> _onDecline() async {
    await CallRingtoneService().stopRinging();
    ref.read(callStateProvider.notifier).rejectCall();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use .select to avoid rebuilds on non-essential state changes
    // which can cause "defunct" assertion failures during transitions.
    final callState = ref.watch(callStateProvider.select((s) => s?.state));
    final callInfo = ref.read(callStateProvider);

    if (!_graceActive && !_isAccepting &&
        (callState == null || callState != CallState.ringing)) {
      debugPrint('📴 [IncomingCallScreen] Auto-dismissing (state: $callState)');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isAccepting) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white24)),
      );
    }

    final callerName = callInfo?.userName ?? '...';
    final callerPhoto = callInfo?.userPhoto ?? '';
    final isVideo = callInfo?.isVideo ?? false;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: HexColor('#141414'),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [HexColor('#3A1D07'), HexColor('#141414')],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        isVideo ? '📹 Incoming Video Call' : '📞 Incoming Call',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: HexColor('#FF6B00'), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: HexColor('#FF6B00').withOpacity(0.35),
                                blurRadius: 25,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 67,
                            backgroundColor: HexColor('#FB8830'),
                            backgroundImage: callerPhoto.isNotEmpty
                                ? NetworkImage(callerPhoto)
                                : null,
                            child: callerPhoto.isEmpty
                                ? Text(
                                    callerName.isNotEmpty
                                        ? callerName[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        callerName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) {
                          final dotCount = (_pulseController.value * 3).floor() + 1;
                          return Text(
                            'Ringing${'.' * dotCount}',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 15,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 60,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionButton(
                              icon: Icons.call_end,
                              label: 'Decline',
                              color: Colors.red,
                              onTap: _onDecline,
                            ),
                            _buildActionButton(
                              icon: _isAccepting ? Icons.hourglass_top : Icons.call,
                              label: _isAccepting ? 'Joining…' : 'Accept',
                              color: HexColor('#1A7F4B'),
                              onTap: _isAccepting ? () {} : _onAccept,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
