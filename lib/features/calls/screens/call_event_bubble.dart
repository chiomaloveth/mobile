import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class CallEventBubble extends StatelessWidget {
  final String callType; // 'audio' or 'video'
  final String callStatus; // 'missed', 'answered', 'cancelled', 'declined'
  final bool isOutgoing;
  final int duration; // seconds
  final String timestamp;
  final VoidCallback? onTap;
  final Function(DismissDirection)? onSwipe; // ← swipe to reply

  const CallEventBubble({
    Key? key,
    required this.callType,
    required this.callStatus,
    required this.isOutgoing,
    required this.duration,
    required this.timestamp,
    this.onTap,
    this.onSwipe,
  }) : super(key: key);

  bool get _isMissed =>
      callStatus == 'missed' ||
      callStatus == 'cancelled' ||
      callStatus == 'declined';
  bool get _isAnswered => callStatus == 'answered' && duration > 0;
  bool get _isVideo => callType == 'video';

  Color get _accentColor =>
      _isMissed ? const Color(0xFFE05252) : const Color(0xFF1A7F4B);

  IconData get _callIcon =>
      _isVideo ? Icons.videocam_rounded : Icons.call_rounded;

  String get _label {
    if (callStatus == 'cancelled')
      return isOutgoing ? 'Cancelled call' : 'Missed call';
    if (callStatus == 'missed') return isOutgoing ? 'No answer' : 'Missed call';
    if (callStatus == 'declined')
      return isOutgoing ? 'Call declined' : 'Declined call';
    if (_isAnswered) return isOutgoing ? 'Outgoing call' : 'Incoming call';
    return isOutgoing ? 'Outgoing call' : 'Incoming call';
  }

  String get _sublabel {
    if (_isAnswered) return _formatDuration(duration);
    if (_isMissed && !isOutgoing) return 'Tap to call back';
    return _isVideo ? 'Video call' : 'Voice call';
  }

  @override
  Widget build(BuildContext context) {
    final bubble = GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: HexColor('#1C1C1C'),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accentColor.withOpacity(0.25), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon circle ──────────────────────────────────────────────
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_callIcon, color: _accentColor, size: 19),
              ),
              const SizedBox(width: 10),

              // ── Label + sublabel ─────────────────────────────────────────
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOutgoing
                              ? Icons.north_east_rounded
                              : Icons.south_west_rounded,
                          color: _accentColor,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _label,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _sublabel,
                      style: GoogleFonts.poppins(
                        color: _isMissed && !isOutgoing
                            ? _accentColor.withOpacity(0.8)
                            : Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Time ────────────────────────────────────────────────────
              Text(
                _formatTime(timestamp),
                style: GoogleFonts.poppins(color: Colors.white24, fontSize: 10),
              ),

              // No call-back button — tapping the whole bubble calls back
            ],
          ),
        ),
      ),
    );

    // ── Swipe-to-reply wrapper ───────────────────────────────────────────────
    final swipeable = onSwipe != null
        ? Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) async {
              onSwipe!(direction);
              return false; // don't actually dismiss
            },
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.reply, color: Colors.white54, size: 22),
            ),
            child: bubble,
          )
        : bubble;

    // ── Align left (incoming) or right (outgoing) ────────────────────────────
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Align(
        alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
        child: swipeable,
      ),
    );
  }

  String _formatDuration(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) return '${h}h ${m}m ${sec}s';
    if (m > 0) return '${m}m ${sec}s';
    return '${sec}s';
  }

  String _formatTime(String ts) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(ts).toLocal());
    } catch (_) {
      return '';
    }
  }

  /// Parses plain-text call messages like "Cancelled Voice call",
  /// "Incoming Video call - 2m 3s" saved as contentType:'text'.
  static CallEventBubble? fromPlainText({
    required String text,
    required String timestamp,
    required bool isMe,
    VoidCallback? onTap,
    Function(DismissDirection)? onSwipe,
  }) {
    final t = text.trim().toLowerCase();

    String? callType;
    if (t.contains('video')) callType = 'video';
    if (t.contains('voice') || t.contains('audio')) callType = 'audio';
    if (callType == null) return null;
    if (!t.contains('call')) return null;

    String callStatus;
    if (t.contains('cancelled')) {
      callStatus = 'cancelled';
    } else if (t.contains('missed')) {
      callStatus = 'missed';
    } else if (t.contains('incoming') || t.contains('outgoing')) {
      callStatus = 'answered';
    } else {
      return null;
    }

    int duration = 0;
    final mSec = RegExp(r'(\d+)m\s*(\d+)s').firstMatch(text);
    if (mSec != null) {
      duration = int.parse(mSec.group(1)!) * 60 + int.parse(mSec.group(2)!);
    }

    return CallEventBubble(
      callType: callType,
      callStatus: callStatus,
      isOutgoing: isMe,
      duration: duration,
      timestamp: timestamp,
      onTap: onTap,
      onSwipe: onSwipe,
    );
  }
}
