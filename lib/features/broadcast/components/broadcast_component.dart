import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/chat/general/model/broadcast_model.dart';
import 'package:qik_talk/features/chat/general/services/broadcast_service.dart';
import 'package:qik_talk/features/chat/single_chat/screens/broadcast_detail_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BroadcastComponent extends StatefulWidget {
  const BroadcastComponent({super.key});

  @override
  State<BroadcastComponent> createState() => _BroadcastComponentState();
}

class _BroadcastComponentState extends State<BroadcastComponent>
    with AutomaticKeepAliveClientMixin {
  List<BroadcastList> _broadcasts = [];
  bool _isLoading = true;
  bool _hasError = false;

  // ── Socket subscriptions ────────────────────────────────────────────────────
  // NOTE: broadcastUpdatedController is StreamController<dynamic> so we must
  // type the subscription as dynamic to avoid a runtime type cast error.
  StreamSubscription<dynamic>? _updatedSub;
  StreamSubscription<dynamic>? _deletedSub;

  static const String _prefKey = 'cached_broadcasts_json_v2';

  @override
  void initState() {
    super.initState();
    _loadFromPrefs().then((_) => _fetchBroadcasts());
    _subscribeToSocket();
  }

  // ── Socket subscriptions ───────────────────────────────────────────────────
  void _subscribeToSocket() {
    final gs = GlobalSocketService();

    // Real-time: broadcast created or updated
    _updatedSub = gs.broadcastUpdatedController.stream.listen((data) {
      if (!mounted) return;
      // data is dynamic — normalise to Map before processing
      if (data is Map) {
        _handleSocketUpdate(Map<String, dynamic>.from(data));
      } else {
        debugPrint(
          '⚠️ BroadcastComponent: unexpected socket data type ${data.runtimeType}',
        );
        _fetchBroadcasts();
      }
    });

    // Real-time: broadcast deleted (broadcastDeletedController is StreamController<String>)
    _deletedSub = gs.broadcastDeletedController.stream.listen((data) {
      if (!mounted) return;
      // data arrives as dynamic — coerce to String
      final id = data?.toString() ?? '';
      if (id.isEmpty) return;
      debugPrint('📢 BroadcastComponent: broadcast deleted — $id');
      setState(() => _broadcasts.removeWhere((b) => b.id == id));
      _saveToPrefs(_broadcasts);
    });
  }

  void _handleSocketUpdate(Map<String, dynamic> data) {
    final event = data['_socketEvent']?.toString(); // 'created' | 'updated'
    debugPrint('📢 BroadcastComponent: socket event "$event" — $data');

    // Remove our internal marker before parsing
    final payload = Map<String, dynamic>.from(data)..remove('_socketEvent');

    // Resolve broadcast id
    final broadcastId = (payload['_id'] ?? payload['broadcastId'] ?? '')
        .toString()
        .trim();

    if (broadcastId.isEmpty) {
      // No ID — do a full refresh as a fallback
      _fetchBroadcasts();
      return;
    }

    try {
      final updated = BroadcastList.fromJson(payload);
      setState(() {
        final idx = _broadcasts.indexWhere((b) => b.id == broadcastId);
        if (idx != -1) {
          _broadcasts[idx] = updated;
        } else {
          // Brand-new broadcast for this user — insert at top
          _broadcasts.insert(0, updated);
        }
      });
      _saveToPrefs(_broadcasts);
    } catch (e) {
      debugPrint('⚠️ BroadcastComponent: could not parse socket data — $e');
      // Fallback: full refresh
      _fetchBroadcasts();
    }
  }

  // ── SharedPrefs cache ──────────────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null || raw.isEmpty) return;
      final List decoded = jsonDecode(raw) as List;
      final items = decoded
          .map((e) => BroadcastList.fromJson(e as Map<String, dynamic>))
          .toList();
      if (items.isNotEmpty && mounted) {
        setState(() {
          _broadcasts = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ BroadcastComponent _loadFromPrefs: $e');
    }
  }

  Future<void> _saveToPrefs(List<BroadcastList> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(items.map((b) => b.toJson()).toList());
      await prefs.setString(_prefKey, encoded);
    } catch (e) {
      debugPrint('⚠️ BroadcastComponent _saveToPrefs: $e');
    }
  }

  // ── API fetch ──────────────────────────────────────────────────────────────
  // Uses BroadcastService which calls GET /api/v1/chat/broadcast and correctly
  // unwraps the { success, count, data: [...] } response envelope.
  Future<void> _fetchBroadcasts() async {
    if (!mounted) return;
    if (_broadcasts.isEmpty) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final broadcasts = await BroadcastService().getAllBroadcasts();
      final userId = await SaveValues().getString(AppPreferenceHelper.ID) ?? '';

      // Only show broadcasts THIS user created — recipients see messages in their DMs only
      final userBroadcasts = broadcasts.where((b) {
        if (b.creatorId == null) return true; // legacy: show if no creatorId
        return b.creatorId == userId;
      }).toList();

      if (!mounted) return;
      await _saveToPrefs(userBroadcasts);
      setState(() {
        _broadcasts = userBroadcasts;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      debugPrint('⚠️ Broadcasts offline/failed: $e');
      if (mounted) {
        setState(() {
          _hasError = _broadcasts.isEmpty;
          _isLoading = false;
        });
      }
    }
  }

  // ── Time helpers ───────────────────────────────────────────────────────────
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }

  String _timeUntil(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inMinutes < 60) return 'in ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'in ${diff.inHours} hours';
    return 'in ${diff.inDays} days';
  }

  @override
  void dispose() {
    _updatedSub?.cancel();
    _deletedSub?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: HexColor("#FB8830")),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: AppTheme.textHint(isDark), size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load broadcasts',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary(isDark)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _fetchBroadcasts,
              child: Text(
                'Retry',
                style: TextStyle(color: HexColor("#FB8830")),
              ),
            ),
          ],
        ),
      );
    }

    if (_broadcasts.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      color: HexColor("#FB8830"),
      onRefresh: _fetchBroadcasts,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _broadcasts.length,
        itemBuilder: (context, index) =>
            _buildBroadcastTile(_broadcasts[index], isDark),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.cardBg(isDark),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.campaign_outlined,
              color: AppTheme.textHint(isDark),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No broadcasts yet',
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to create your first broadcast',
            style: GoogleFonts.poppins(
              color: AppTheme.textHint(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastTile(BroadcastList broadcast, bool isDark) {
    final Color cardColor = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);

    Widget statusBadge;
    Widget timeRow;

    switch (broadcast.status) {
      case BroadcastStatus.sent:
        statusBadge = _badge('Sent', HexColor("#1A7F4B"));
        timeRow = _timeRowWidget(
          Icons.access_time,
          _timeAgo(broadcast.scheduledAt ?? broadcast.updatedAt),
          textSecondary,
        );
        break;
      case BroadcastStatus.scheduled:
        statusBadge = _badge('Scheduled', HexColor("#2B4A8F"));
        timeRow = _timeRowWidget(
          Icons.access_time,
          broadcast.scheduledAt != null
              ? _timeUntil(broadcast.scheduledAt!)
              : 'Scheduled',
          textSecondary,
        );
        break;
      case BroadcastStatus.draft:
        statusBadge = _badge('Draft', HexColor("#3A3A3C"));
        timeRow = _timeRowWidget(
          Icons.access_time,
          _timeAgo(broadcast.updatedAt),
          textSecondary,
        );
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BroadcastDetailScreen(broadcast: broadcast),
          ),
        ).then((_) => _fetchBroadcasts());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.campaign_outlined,
                color: AppTheme.textSecondary(isDark),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          broadcast.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.textHint(isDark),
                        size: 20,
                      ),
                    ],
                  ),
                  if (broadcast.latestMessage != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      broadcast.latestMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      statusBadge,
                      const SizedBox(width: 8),
                      if (broadcast.totalRecipients != null ||
                          broadcast.members.isNotEmpty) ...[
                        Icon(
                          Icons.people_outline,
                          color: textSecondary,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${broadcast.totalRecipients ?? broadcast.members.length} recipients',
                          style: GoogleFonts.poppins(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  timeRow,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _timeRowWidget(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(color: color, fontSize: 11)),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
