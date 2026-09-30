import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/calls/call_permission_handler.dart';
import 'package:qik_talk/features/calls/ongoing_call_screen.dart';
import 'package:qik_talk/features/calls/providers/call_state_provider.dart';
import 'package:qik_talk/features/chat/general/components/tabs/documents_tab.dart';
import 'package:qik_talk/features/chat/general/components/tabs/links_tab.dart';
import 'package:qik_talk/features/chat/general/components/tabs/media_tab.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';

class ChatMediaTabScreen extends ConsumerWidget {
  final String userId;
  final String username;
  final bool isOnline;
  final int initialTabIndex;
  final String? chatId;
  final String? userPhoto; // optional — used for call avatar

  const ChatMediaTabScreen({
    Key? key,
    required this.userId,
    required this.username,
    required this.isOnline,
    this.initialTabIndex = 0,
    this.chatId,
    this.userPhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBg(isDark),
        body: Column(
          children: [
            // ── HEADER ────────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.only(
                top: topPadding + 16,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _circleButton(context, isDark, Icons.arrow_back),
                      ),
                      Column(
                        children: [
                          Text(
                            username,
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: GoogleFonts.poppins(
                              color: isOnline
                                  ? const Color(0xFF34C759)
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _circleButton(
                            context,
                            isDark,
                            Icons.videocam_outlined,
                            onTap: () => _initiateCall(
                              context: context,
                              ref: ref,
                              isVideo: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _circleButton(
                            context,
                            isDark,
                            Icons.call_outlined,
                            onTap: () => _initiateCall(
                              context: context,
                              ref: ref,
                              isVideo: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    indicatorColor: AppTheme.accent(isDark),
                    labelColor: AppTheme.textPrimary(isDark),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Media'),
                      Tab(text: 'Links'),
                      Tab(text: 'Documents'),
                    ],
                  ),
                ],
              ),
            ),

            // ── TAB CONTENT ───────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  MediaTab(userId: chatId ?? userId),
                  LinksTab(userId: chatId ?? userId),
                  DocumentsTab(userId: chatId ?? userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(BuildContext context, bool isDark, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.cardBgAlt(isDark),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.iconColor(isDark), size: 22),
      ),
    );
  }

  Future<void> _initiateCall({
    required BuildContext context,
    required WidgetRef ref,
    required bool isVideo,
  }) async {
    try {
      // Check permissions first
      final hasPermission = isVideo
          ? await CallPermissionHandler.requestVideoPermissions(context)
          : await CallPermissionHandler.requestAudioPermissions(context);
      if (!hasPermission) return;

      // Ensure global socket is connected
      final globalSocket = GlobalSocketService();
      if (!globalSocket.isConnected) await globalSocket.connect();

      final socket = globalSocket.socket;
      if (socket == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Load user credentials
      final saveValues = SaveValues();
      final myUserId = await saveValues.getString(AppPreferenceHelper.ID) ?? '';
      final myUsername =
          await saveValues.getString(AppPreferenceHelper.USER_NAME) ?? '';
      final authToken =
          await saveValues.getString(AppPreferenceHelper.AUTH_TOKEN) ?? '';

      // FIX: Use callStateProvider (LiveKit) instead of old callProvider (WebRTC).
      // callStateProvider.startCall() handles the full LiveKit flow:
      //   POST /call/start → get token → connect to LiveKit room → emit socket signal.
      final callNotifier = ref.read(callStateProvider.notifier);
      callNotifier.initializeWithSocket(
        socket,
        myUserId: myUserId,
        myUsername: myUsername,
        authToken: authToken,
      );

      await callNotifier.startCall(
        userId: userId,
        userName: username,
        userPhoto: userPhoto ?? '',
        isVideo: isVideo,
      );

      // Navigate to OngoingCallScreen (replaces old ActiveCallScreen dialog)
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OngoingCallScreen()),
        );
      }
    } catch (e) {
      debugPrint('❌ _initiateCall error: $e');
      ref.read(callStateProvider.notifier).endCall();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
