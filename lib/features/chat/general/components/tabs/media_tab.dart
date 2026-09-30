import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class MediaTab extends StatefulWidget {
  final String userId;

  const MediaTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<MediaTab> createState() => _MediaTabState();
}

class _MediaTabState extends State<MediaTab> {
  List<MediaItem> mediaItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMediaFromMessages();
  }

  Future<void> _loadMediaFromMessages() async {
    try {
      final chatBox = Hive.box<List>('chat_messages');
      final List<MediaItem> extractedMedia = [];

      // ✅ FIX: Only read messages from THIS chat, not all chats
      final messages = chatBox.get(widget.userId) as List?;
      if (messages != null) {
        for (var msgData in messages) {
          if (msgData is! ChatMessageHive) continue;

          final msg = msgData;
          // ✅ Double-check chatId matches (defensive guard)
          if (msg.chatId.isNotEmpty && msg.chatId != widget.userId) continue;

          final timestamp = DateTime.parse(msg.timestamp);

          // Extract images
          if (msg.isImage && msg.imageUrls != null) {
            for (var imageUrl in msg.imageUrls!) {
              extractedMedia.add(
                MediaItem(
                  url: _getFullUrl(imageUrl),
                  type: MediaType.image,
                  timestamp: timestamp,
                  chatId: msg.chatId,
                ),
              );
            }
          }

          // Extract videos
          if (msg.isVideo && msg.videoUrl != null) {
            extractedMedia.add(
              MediaItem(
                url: _getFullUrl(msg.videoUrl!),
                type: MediaType.video,
                timestamp: timestamp,
                chatId: msg.chatId,
                thumbnail: msg.videoThumbnail != null
                    ? _getFullUrl(msg.videoThumbnail!)
                    : null,
              ),
            );
          }
        }
      }

      // Sort by timestamp (newest first)
      extractedMedia.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          mediaItems = extractedMedia;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading media: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getFullUrl(String url) {
    if (url.startsWith('http')) return url;
    return ApiStrings.baseUriImage + url;
  }

  Map<String, List<MediaItem>> _groupMediaByDate() {
    final Map<String, List<MediaItem>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    for (var item in mediaItems) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );

      String dateKey;
      if (itemDate == today) {
        dateKey = 'Today';
      } else if (itemDate == yesterday) {
        dateKey = 'Yesterday';
      } else if (now.difference(itemDate).inDays < 7) {
        dateKey = _getWeekdayName(itemDate.weekday);
      } else {
        dateKey = '${itemDate.day}/${itemDate.month}/${itemDate.year}';
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(item);
    }

    return grouped;
  }

  String _getWeekdayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
    }

    if (mediaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No media shared yet',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final groupedMedia = _groupMediaByDate();

    return Container(
      color: AppTheme.scaffoldBg(isDark),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: groupedMedia.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) {
                  final item = entry.value[index];
                  return GestureDetector(
                    onTap: () => _openFullScreen(context, item),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.type == MediaType.video
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                item.thumbnail != null
                                    ? Image.network(
                                        item.thumbnail!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildPlaceholder(Icons.videocam),
                                      )
                                    : _buildPlaceholder(Icons.videocam),
                                Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            )
                          : Image.network(
                              item.url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(Icons.image),
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Builder(
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: AppTheme.cardBgAlt(isDark),
          child: Icon(icon, color: Colors.grey, size: 32),
        );
      },
    );
  }

  void _openFullScreen(BuildContext context, MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: item.type == MediaType.video
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Video playback not implemented',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ],
                  )
                : InteractiveViewer(
                    child: Image.network(item.url, fit: BoxFit.contain),
                  ),
          ),
        ),
      ),
    );
  }
}

enum MediaType { image, video }

class MediaItem {
  final String url;
  final MediaType type;
  final DateTime timestamp;
  final String chatId;
  final String? thumbnail;

  MediaItem({
    required this.url,
    required this.type,
    required this.timestamp,
    required this.chatId,
    this.thumbnail,
  });
}
