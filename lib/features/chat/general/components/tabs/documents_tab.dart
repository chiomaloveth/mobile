import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsTab extends StatefulWidget {
  final String userId;

  const DocumentsTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  List<DocumentItem> documentItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocumentsFromMessages();
  }

  Future<void> _loadDocumentsFromMessages() async {
    try {
      final chatBox = Hive.box<List>('chat_messages');
      final List<DocumentItem> extractedDocs = [];

      // ✅ FIX: Only read messages from THIS chat
      final messages = chatBox.get(widget.userId) as List?;
      if (messages != null) {
        for (var msgData in messages) {
          if (msgData is! ChatMessageHive) continue;

          final msg = msgData;
          // ✅ Defensive chatId guard
          if (msg.chatId.isNotEmpty && msg.chatId != widget.userId) continue;

          // Extract documents
          if (msg.isDocument && msg.documentUrl != null) {
            extractedDocs.add(
              DocumentItem(
                name: msg.documentName ?? 'Document',
                url: _getFullUrl(msg.documentUrl!),
                timestamp: DateTime.parse(msg.timestamp),
                chatId: msg.chatId,
                size: 'Unknown', // Backend doesn't provide size
              ),
            );
          }
        }
      }

      // Sort by timestamp (newest first)
      extractedDocs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          documentItems = extractedDocs;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading documents: $e');
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

  Map<String, List<DocumentItem>> _groupDocumentsByDate() {
    final Map<String, List<DocumentItem>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    for (var item in documentItems) {
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

  Color _getDocumentColor(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Color(0xFFFF3B30);
      case 'doc':
      case 'docx':
        return Color(0xFF4A90E2);
      case 'xls':
      case 'xlsx':
        return Color(0xFF34C759);
      case 'ppt':
      case 'pptx':
        return Color(0xFFFF9500);
      case 'txt':
        return Color(0xFF888888);
      case 'zip':
      case 'rar':
        return Color(0xFFAF52DE);
      default:
        return Color(0xFF5AC8FA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
    }

    if (documentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No documents shared yet',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final groupedDocs = _groupDocumentsByDate();

    return Container(
      color: AppTheme.scaffoldBg(isDark),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: groupedDocs.entries.map((entry) {
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
              ...entry.value.map((doc) => _buildDocumentItem(context, doc)),
              SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, DocumentItem doc) {
    final color = _getDocumentColor(doc.name);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.insert_drive_file, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  doc.size,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _downloadDocument(context, doc),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.cardBg(isDark),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download, color: Color(0xFF1A7F4B), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadDocument(BuildContext context, DocumentItem doc) async {
    try {
      final Uri uri = Uri.parse(doc.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${doc.name}...'),
              backgroundColor: HexColor("#1A7F4B"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class DocumentItem {
  final String name;
  final String url;
  final DateTime timestamp;
  final String chatId;
  final String size;

  DocumentItem({
    required this.name,
    required this.url,
    required this.timestamp,
    required this.chatId,
    required this.size,
  });
}
