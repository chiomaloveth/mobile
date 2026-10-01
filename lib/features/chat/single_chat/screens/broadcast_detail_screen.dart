import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:qik_talk/features/broadcast/screens/create_new_broadcast_list_screen.dart';
import 'package:qik_talk/features/chat/general/model/broadcast_model.dart';
import 'package:qik_talk/features/chat/general/services/broadcast_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/add_more_recipients_screen.dart';
import 'package:qik_talk/features/chat/single_chat/screens/reschedule_broadcast_screen.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class BroadcastDetailScreen extends StatefulWidget {
  final BroadcastList broadcast;

  const BroadcastDetailScreen({super.key, required this.broadcast});

  @override
  State<BroadcastDetailScreen> createState() => _BroadcastDetailScreenState();
}

class _BroadcastDetailScreenState extends State<BroadcastDetailScreen> {
  late BroadcastList _broadcast;
  bool _isLoading = false;
  final BroadcastService _service = BroadcastService();
  String _currentUserId = '';

  // ── Socket subscriptions ───────────────────────────────────────────
  // Typed as <dynamic>: broadcastUpdatedController is StreamController<dynamic>
  // so a strong-typed StreamSubscription<Map<...>> throws a cast error at runtime.
  StreamSubscription<dynamic>? _updatedSub;
  StreamSubscription<dynamic>? _deletedSub;
  StreamSubscription<dynamic>? _memberJoinedSub;
  StreamSubscription<dynamic>? _memberLeftSub;

  @override
  void initState() {
    super.initState();
    _broadcast = widget.broadcast;
    _loadCurrentUserId();
    _refreshBroadcast();
    _subscribeToSocket();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await SaveValues().getString(AppPreferenceHelper.ID) ?? '';
    if (mounted) {
      setState(() => _currentUserId = userId);
    }
  }

  // ── Socket ────────────────────────────────────────────────────────────────
  void _subscribeToSocket() {
    final gs = GlobalSocketService();

    // Real-time delivery count / status updates for THIS broadcast
    _updatedSub = gs.broadcastUpdatedController.stream.listen((rawData) {
      if (!mounted) return;
      if (rawData is! Map) return;
      final data = Map<String, dynamic>.from(rawData as Map);
      final id = (data['_id'] ?? data['broadcastId'] ?? '').toString().trim();
      if (id != _broadcast.id) return;
      debugPrint('📢 BroadcastDetail: socket update for ${_broadcast.id}');
      // Merge updated fields into the local broadcast object
      try {
        final updated = BroadcastList.fromJson({
          ..._broadcast.toJson(),
          ...Map<String, dynamic>.from(data)..remove('_socketEvent'),
        });
        setState(() => _broadcast = updated);
      } catch (_) {
        _refreshBroadcast();
      }
    });

    // If this broadcast is deleted by another device/admin — pop the screen
    _deletedSub = gs.broadcastDeletedController.stream.listen((rawData) {
      if (!mounted) return;
      final id = rawData?.toString() ?? '';
      if (id == _broadcast.id) {
        debugPrint('📢 BroadcastDetail: this broadcast was deleted — popping');
        Navigator.of(context).pop(true);
      }
    });

    // Member joined — update member list
    _memberJoinedSub = gs.broadcastMemberJoinedController.stream.listen((
      rawData,
    ) {
      if (!mounted) return;
      if (rawData is! Map) return;
      final data = Map<String, dynamic>.from(rawData as Map);
      final broadcastId = (data['broadcastId'] ?? '').toString();
      if (broadcastId != _broadcast.id) return;
      debugPrint('📢 BroadcastDetail: member joined');
      _refreshBroadcast();
    });

    // Member left — update member list
    _memberLeftSub = gs.broadcastMemberLeftController.stream.listen((rawData) {
      if (!mounted) return;
      if (rawData is! Map) return;
      final data = Map<String, dynamic>.from(rawData as Map);
      final broadcastId = (data['broadcastId'] ?? '').toString();
      if (broadcastId != _broadcast.id) return;
      debugPrint('📢 BroadcastDetail: member left');
      final userId = (data['userId'] ?? '').toString();
      if (userId.isNotEmpty) {
        setState(() {
          _broadcast = _broadcast.copyWith(
            members: _broadcast.members.where((m) => m.id != userId).toList(),
          );
        });
      } else {
        _refreshBroadcast();
      }
    });
  }

  Future<void> _refreshBroadcast() async {
    if (_broadcast.id.isEmpty) return;
    try {
      final fresh = await _service.getBroadcast(_broadcast.id);
      if (mounted) setState(() => _broadcast = fresh);
    } catch (e) {
      // Endpoint may not exist yet — silently use data passed from list
      debugPrint(
        '⚠️ Could not refresh broadcast (endpoint may be unavailable): $e',
      );
    }
  }

  // ── 3-dot menu actions ───────────────────────────────────────
  void _showMenu() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textHint(isDark).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _menuItem(
                icon: Icons.person_add_outlined,
                label: 'Add More Recipients',
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMoreRecipientsScreen(
                        broadcastId: _broadcast.id,
                        existingMemberIds: _broadcast.members
                            .map((m) => m.id)
                            .toList(),
                      ),
                    ),
                  );
                  if (result == true) _refreshBroadcast();
                },
              ),
              _divider(isDark),
              _menuItem(
                icon: Icons.edit_outlined,
                label: 'Edit broadcast',
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateBroadcastScreen(
                        existing: _broadcast,
                        preSelectedUsers: _broadcast.members,
                        listName: _broadcast.name,
                      ),
                    ),
                  );
                  if (result == true) _refreshBroadcast();
                },
              ),
              _divider(isDark),
              _menuItem(
                icon: Icons.schedule_outlined,
                label: 'Reschedule broadcast',
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RescheduleBroadcastScreen(broadcast: _broadcast),
                    ),
                  );
                  if (result == true) _refreshBroadcast();
                },
              ),
              _divider(isDark),
              _menuItem(
                icon: Icons.delete_outline,
                label: 'Delete broadcast',
                isDark: isDark,
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    Color? color,
  }) {
    final textColor = color ?? AppTheme.textPrimary(isDark);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
    height: 1,
    indent: 20,
    endIndent: 20,
    color: AppTheme.textHint(isDark).withOpacity(0.15),
  );

  // ── Delete confirmation ──────────────────────────────────────
  void _confirmDelete() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Broadcast',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_broadcast.name}"? This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(isDark),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBroadcast();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBroadcast() async {
    setState(() => _isLoading = true);
    try {
      await _service.deleteBroadcast(_broadcast.id);
      if (mounted) {
        _showSnack('Broadcast deleted');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to delete: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.red : HexColor("#1A7F4B"),
      ),
    );
  }

  @override
  void dispose() {
    _updatedSub?.cancel();
    _deletedSub?.cancel();
    _memberJoinedSub?.cancel();
    _memberLeftSub?.cancel();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────
  String _formatDateTime(DateTime dt) {
    return DateFormat('d MMMM yyyy \'at\' HH:mm').format(dt.toLocal());
  }

  Color _statusColor(BroadcastStatus status) {
    switch (status) {
      case BroadcastStatus.sent:
        return HexColor("#1A7F4B");
      case BroadcastStatus.scheduled:
        return HexColor("#2B4A8F");
      case BroadcastStatus.draft:
        return const Color(0xFF3A3A3C);
    }
  }

  String _statusLabel(BroadcastStatus status) {
    switch (status) {
      case BroadcastStatus.sent:
        return 'Sent';
      case BroadcastStatus.scheduled:
        return 'Scheduled';
      case BroadcastStatus.draft:
        return 'Draft';
    }
  }

  // ── BUILD ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int delivered = _broadcast.deliveredCount ?? 0;
    final int pending = _broadcast.pendingCount ?? 0;
    final int total = _broadcast.totalRecipients ?? _broadcast.members.length;
    final double successRate = total > 0 ? (delivered / total * 100) : 0;
    final double pendingRate = total > 0 ? (pending / total * 100) : 0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/app_bar_gredient.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Broadcasts',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showMenu,
                ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: HexColor("#FB8830"),
        onRefresh: _refreshBroadcast,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status badge + icon ──────────────────────
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.campaign_outlined,
                      color: AppTheme.textSecondary(isDark),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(_broadcast.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(_broadcast.status),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Title + Creator badge ───────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _broadcast.name,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Always show creator badge — either "You" or the creator's name
                      if (_currentUserId.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (_broadcast.creatorId == _currentUserId
                                        ? HexColor("#FB8830")
                                        : AppTheme.cardBg(isDark))
                                    .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _broadcast.creatorId == _currentUserId
                                  ? HexColor("#FB8830").withOpacity(0.4)
                                  : AppTheme.textHint(isDark).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _broadcast.creatorId == _currentUserId
                                ? 'You (Creator)'
                                : 'Created by ${_broadcast.creatorUsername ?? 'Unknown'}',
                            style: GoogleFonts.poppins(
                              color: _broadcast.creatorId == _currentUserId
                                  ? HexColor("#FB8830")
                                  : AppTheme.textSecondary(isDark),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Message body ─────────────────────────────
              if (_broadcast.latestMessage != null &&
                  _broadcast.latestMessage!.isNotEmpty) ...[
                Text(
                  _broadcast.latestMessage!,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: AppTheme.textHint(isDark).withOpacity(0.15),
                  height: 1,
                ),
                const SizedBox(height: 16),
              ],

              // ── Recipients row ───────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: AppTheme.textSecondary(isDark),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$total recipients',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Date/Time ────────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppTheme.textSecondary(isDark),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _broadcast.scheduledAt != null
                        ? _formatDateTime(_broadcast.scheduledAt!)
                        : _formatDateTime(_broadcast.updatedAt),
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Delivery Status ──────────────────────────
              Text(
                'Delivery Status',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  // Delivered card
                  Expanded(
                    child: _deliveryCard(
                      icon: Icons.check_circle_outline,
                      iconColor: HexColor("#1A7F4B"),
                      label: 'Delivered',
                      count: delivered,
                      subtitle:
                          '${successRate.toStringAsFixed(0)}% success rate',
                      bgColor: HexColor("#1A7F4B").withOpacity(0.15),
                      textColor: HexColor("#1A7F4B"),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Pending card
                  Expanded(
                    child: _deliveryCard(
                      icon: Icons.access_time,
                      iconColor: AppTheme.textSecondary(isDark),
                      label: 'Pending',
                      count: pending,
                      subtitle: '${pendingRate.toStringAsFixed(0)}% pending',
                      bgColor: AppTheme.cardBg(isDark),
                      textColor: AppTheme.textPrimary(isDark),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              // ── Members list preview ─────────────────────
              if (_broadcast.members.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Recipients (${_broadcast.members.length})',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ..._broadcast.members
                    .take(5)
                    .map((m) => _memberTile(m, isDark)),
                if (_broadcast.members.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${_broadcast.members.length - 5} more recipients',
                      style: GoogleFonts.poppins(
                        color: HexColor("#FB8830"),
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required int count,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: iconColor.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberTile(BroadcastMember member, bool isDark) {
    final String imgUrl = _fullImageUrl(member.profilePicture);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: HexColor("#FB8830"),
            backgroundImage: imgUrl.isNotEmpty ? NetworkImage(imgUrl) : null,
            child: imgUrl.isEmpty
                ? Text(
                    member.username.isNotEmpty
                        ? member.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.username.isNotEmpty ? member.username : member.id,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(isDark),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fullImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }
}
