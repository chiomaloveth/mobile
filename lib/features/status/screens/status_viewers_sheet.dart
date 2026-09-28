import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../model/my_status_model.dart';

class StatusViewersSheet extends StatefulWidget {
  final List<Viewer> viewers;
  final int totalUpdates;
  final String statusId;
  final IO.Socket? socket;

  const StatusViewersSheet({
    super.key,
    required this.viewers,
    required this.totalUpdates,
    required this.statusId,
    this.socket,
  });

  static void show(
    BuildContext context,
    List<Viewer> viewers,
    int totalUpdates,
    String statusId, {
    IO.Socket? socket,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? HexColor("#1E1E1E")
          : AppTheme.scaffoldBg(
              Theme.of(context).brightness == Brightness.dark,
            ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => StatusViewersSheet(
        viewers: viewers,
        totalUpdates: totalUpdates,
        statusId: statusId,
        socket: socket,
      ),
    );
  }

  @override
  State<StatusViewersSheet> createState() => _StatusViewersSheetState();
}

class _StatusViewersSheetState extends State<StatusViewersSheet> {
  late List<Viewer> _viewers;

  @override
  void initState() {
    super.initState();
    _viewers = List.from(widget.viewers);
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    if (widget.socket == null || !widget.socket!.connected) return;

    // ✅ Remove any existing listener first to avoid duplicates
    widget.socket!.off('status viewed');

    // ✅ Listen for new views in real-time
    widget.socket!.on('status viewed', (data) {
      debugPrint('📺 New status view received: $data');

      final incomingStatusId =
          data['statusId']?.toString() ?? data['status']?.toString() ?? '';
      if (incomingStatusId != widget.statusId) return;
      final viewerId =
          data['viewerId']?.toString() ?? data['userId']?.toString();
      final viewerName = data['viewerUsername']?.toString() ?? 'Unknown';
      final profilePic = data['viewerProfilePicture']?.toString() ?? '';

      if (viewerId == null) return;

      if (mounted) {
        setState(() {
          // ✅ Check if viewer already in list
          final existingIndex = _viewers.indexWhere((v) => v.id == viewerId);
          if (existingIndex == -1) {
            // New viewer — add to top
            _viewers.insert(
              0,
              Viewer(
                id: viewerId,
                username: viewerName,
                profilePicture: profilePic,
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // ✅ Remove listener to prevent memory leaks and duplicate callbacks
    widget.socket?.off('status viewed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : AppTheme.divider(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    color: isDark
                        ? Colors.white70
                        : AppTheme.textSecondary(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${_viewers.length} ${_viewers.length == 1 ? 'view' : 'views'}",
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: isDark ? Colors.white12 : AppTheme.divider(isDark),
              height: 1,
            ),

            // Viewers list
            Expanded(
              child: _viewers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            color: isDark
                                ? Colors.white30
                                : AppTheme.textHint(isDark),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No views yet",
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white38
                                  : AppTheme.textSecondary(isDark),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "When someone views your status,\nthey'll appear here",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white24
                                  : AppTheme.textHint(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      itemCount: _viewers.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final viewer = _viewers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: isDark
                                ? HexColor("#2E2E2E")
                                : AppTheme.iconBg(isDark),
                            backgroundImage: viewer.profilePicture.isNotEmpty
                                ? NetworkImage(viewer.profilePicture)
                                : null,
                            child: viewer.profilePicture.isEmpty
                                ? Text(
                                    viewer.username.isNotEmpty
                                        ? viewer.username[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.textPrimary(isDark),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            viewer.username.isNotEmpty
                                ? viewer.username
                                : 'Unknown',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textPrimary(isDark),
                              fontSize: 15,
                            ),
                          ),
                          trailing: Icon(
                            Icons.check_circle_outline,
                            color: isDark
                                ? Colors.greenAccent
                                : AppTheme.successGreen(isDark),
                            size: 18,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
