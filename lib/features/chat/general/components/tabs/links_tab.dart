import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksTab extends StatefulWidget {
  final String userId;

  const LinksTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<LinksTab> createState() => _LinksTabState();
}

class _LinksTabState extends State<LinksTab> {
  List<LinkItem> linkItems = [];
  bool isLoading = true;

  // Regex to extract URLs
  final RegExp urlRegex = RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    _loadLinksFromMessages();
  }

  Future<void> _loadLinksFromMessages() async {
    try {
      final chatBox = Hive.box<List>('chat_messages');
      final List<LinkItem> extractedLinks = [];

      // ✅ FIX: Only read messages from THIS chat
      final messages = chatBox.get(widget.userId) as List?;
      if (messages != null) {
        for (var msgData in messages) {
          if (msgData is! ChatMessageHive) continue;

          final msg = msgData;
          // ✅ Defensive chatId guard
          if (msg.chatId.isNotEmpty && msg.chatId != widget.userId) continue;
          if (msg.text.isEmpty) continue;

          final matches = urlRegex.allMatches(msg.text);
          for (var match in matches) {
            final url = match.group(0);
            if (url != null) {
              extractedLinks.add(
                LinkItem(
                  url: url,
                  title: _extractTitleFromUrl(url),
                  timestamp: DateTime.parse(msg.timestamp),
                  chatId: msg.chatId,
                ),
              );
            }
          }
        }
      }

      // Sort by timestamp (newest first)
      extractedLinks.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          linkItems = extractedLinks;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading links: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _extractTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.replaceAll('www.', '');
      final path = uri.path.split('/').where((e) => e.isNotEmpty).join(' > ');
      return path.isNotEmpty ? '$domain: $path' : domain;
    } catch (_) {
      return url;
    }
  }

  Map<String, List<LinkItem>> _groupLinksByDate() {
    final Map<String, List<LinkItem>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    for (var item in linkItems) {
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
      } else if (now.difference(itemDate).inDays < 30) {
        dateKey = 'This Month';
      } else {
        dateKey = '${itemDate.month}/${itemDate.year}';
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
    }

    if (linkItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No links shared yet',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final groupedLinks = _groupLinksByDate();

    return Container(
      color: AppTheme.scaffoldBg(isDark),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: groupedLinks.entries.map((entry) {
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
              ...entry.value.map((link) => _buildLinkItem(context, link)),
              SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, LinkItem link) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(link.url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open link'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onLongPress: () => _showLinkOptions(context, link),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBgAlt(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.link, color: Color(0xFF1A7F4B), size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    link.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkOptions(BuildContext context, LinkItem link) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBg(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.open_in_browser, color: AppTheme.iconColor(isDark)),
                title: Text('Open link', style: TextStyle(color: AppTheme.popupText(isDark))),
                onTap: () {
                  Navigator.pop(context);
                  _launchURL(context, link.url);
                },
              ),
              ListTile(
                leading: Icon(Icons.copy, color: AppTheme.iconColor(isDark)),
                title: Text('Copy link', style: TextStyle(color: AppTheme.popupText(isDark))),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: link.url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class LinkItem {
  final String url;
  final String title;
  final DateTime timestamp;
  final String chatId;

  LinkItem({
    required this.url,
    required this.title,
    required this.timestamp,
    required this.chatId,
  });
}
