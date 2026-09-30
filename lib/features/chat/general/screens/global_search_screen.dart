import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_ce/hive.dart';
import 'package:just_audio/just_audio.dart';
// ROBOT DISABLED: AI chat screen import temporarily hidden
// import 'package:qik_talk/features/ai/screens/ai_chat_screen.dart'
//     hide ChatMessage;
import 'package:qik_talk/features/ai/screens/ai_chat_screen.dart'
    hide ChatMessage, AIChatScreen;
import 'package:url_launcher/url_launcher.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:qik_talk/features/chat/group_chat/screens/group_chat_screen.dart';
import 'package:qik_talk/features/chat/group_chat/widgets/group_composite_avatar.dart';
import 'package:qik_talk/features/chat/single_chat/screens/message_screen.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';

// ── Video player ──────────────────────────────────────────────
// Uses the video_player package already in your pubspec.yaml
import 'package:video_player/video_player.dart';

enum SearchFilter {
  all,
  contacts,
  photos,
  videos,
  audio,
  documents,
  links,
  gifs,
}

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  SearchFilter _activeFilter = SearchFilter.all;
  List<_SearchResult> _allResults = [];
  List<_ContactResult> _allContacts = [];
  bool _loaded = false;
  bool _hasQuery = false;

  // ROBOT DISABLED: _robotShouldBeSmall getter temporarily hidden
  // bool get _robotShouldBeSmall =>
  //     _hasQuery || _activeFilter != SearchFilter.all;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _searchController.addListener(() {
      final text = _searchController.text;
      setState(() {
        _query = text.toLowerCase();
        _hasQuery = text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // DATA LOADING
  // ─────────────────────────────────────────────────────────────

  Future<void> _loadAllData() async {
    final msgBox = Hive.box<List>('chat_messages');
    final List<_SearchResult> results = [];

    for (final chatId in msgBox.keys) {
      final raw = msgBox.get(chatId);
      if (raw == null) continue;
      for (final item in raw) {
        if (item is! ChatMessageHive) continue;
        final msg = item.toChat();
        // Skip internal messages
        if (msg.text.startsWith('__TRANSACTION__') ||
            msg.text.startsWith('__SCHEDULED__'))
          continue;
        results.add(_SearchResult(chatId: chatId.toString(), message: msg));
      }
    }

    final List<_ContactResult> contacts = [];
    try {
      final chatBox = Hive.box<ChatListItemHive>('chats');
      for (final chat in chatBox.values) {
        if (chat.isBroadcast || chat.isCommunity) continue;
        contacts.add(
          _ContactResult(
            id: chat.id,
            title: chat.title,
            profilePicture: chat.profilePicture,
            isGroup: chat.isGroupChat,
            memberCount: chat.memberCount,
            membersAvatarUrls: chat.membersAvatarUrls,
            memberUserIds: chat.memberUserIds,
            about: chat.about,
            userId: chat.userId,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
    }

    if (mounted) {
      setState(() {
        _allResults = results;
        _allContacts = contacts;
        _loaded = true;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FILTERING
  // ─────────────────────────────────────────────────────────────

  List<_SearchResult> get _filtered {
    return _allResults.where((r) {
      final msg = r.message;
      switch (_activeFilter) {
        case SearchFilter.photos:
          if (!msg.isImage) return false;
          break;
        case SearchFilter.videos:
          if (!msg.isVideo) return false;
          break;
        case SearchFilter.audio:
          if (!msg.isVoiceNote && !msg.isAudioFile) return false;
          break;
        case SearchFilter.documents:
          if (!msg.isDocument) return false;
          break;
        case SearchFilter.links:
          if (!_isLink(msg.text)) return false;
          break;
        case SearchFilter.gifs:
          if (!_isGif(msg.text)) return false;
          break;
        case SearchFilter.all:
        case SearchFilter.contacts:
          break;
      }
      if (_query.isEmpty) return true;
      return msg.text.toLowerCase().contains(_query) ||
          (msg.documentName ?? '').toLowerCase().contains(_query);
    }).toList();
  }

  List<_ContactResult> get _filteredContacts {
    if (_query.isEmpty) return _allContacts;
    return _allContacts
        .where((c) => c.title.toLowerCase().contains(_query))
        .toList();
  }

  bool _isLink(String text) =>
      text.startsWith('http://') ||
      text.startsWith('https://') ||
      text.contains('www.');

  bool _isGif(String text) =>
      text.trim().endsWith('.gif') ||
      text.contains('tenor.com') ||
      text.contains('giphy.com');

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      body: Stack(
        fit: StackFit.expand, // ← forces Stack to fill the whole screen
        children: [
          // ── Main content ────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(child: _loaded ? _buildResults() : _buildLoading()),
              ],
            ),
          ),

          // ROBOT DISABLED: Robot mascot widget temporarily hidden
          // AnimatedPositioned(
          //   duration: const Duration(milliseconds: 450),
          //   curve: Curves.easeInOut,
          //   bottom: _robotShouldBeSmall ? 24 : null,
          //   top: _robotShouldBeSmall ? null : 96,
          //   left: _robotShouldBeSmall ? null : 0,
          //   right: _robotShouldBeSmall ? 16 : null,
          //   child: IgnorePointer(
          //     ignoring: false,
          //     child: GestureDetector(
          //       onTap: () {
          //         Navigator.pop(context);
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (_) => AIChatScreen(initialMessage: ""),
          //           ),
          //         );
          //       },
          //       child: _robotShouldBeSmall
          //           ? AnimatedOpacity(
          //               duration: const Duration(milliseconds: 300),
          //               opacity: 1.0,
          //               child: _RobotBounce(
          //                 child: Image.asset(
          //                   "images/robot.png",
          //                   width: 60,
          //                   height: 60,
          //                   fit: BoxFit.contain,
          //                 ),
          //               ),
          //             )
          //           : LayoutBuilder(
          //               builder: (context, constraints) => SizedBox(
          //                 width: MediaQuery.of(context).size.width,
          //                 child: Column(
          //                   mainAxisSize: MainAxisSize.min,
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     const SizedBox(height: 80),
          //                     _RobotBounce(
          //                       child: Image.asset(
          //                         "images/robot.png",
          //                         width: 200,
          //                         height: 200,
          //                         fit: BoxFit.contain,
          //                       ),
          //                     ),
          //                     const SizedBox(height: 20),
          //                     Text(
          //                       "Say hello to Qik AI",
          //                       style: GoogleFonts.poppins(
          //                         color: isDark
          //                             ? Colors.white
          //                             : const Color(0xFF1A1008),
          //                         fontSize: 18,
          //                         fontWeight: FontWeight.w700,
          //                       ),
          //                     ),
          //                     const SizedBox(height: 6),
          //                     Text(
          //                       "Your AI assistant is ready to help",
          //                       style: GoogleFonts.poppins(
          //                         color: isDark
          //                             ? Colors.white54
          //                             : const Color(0xFF6B6B6B),
          //                         fontSize: 13,
          //                       ),
          //                     ),
          //                     const SizedBox(height: 20),
          //                     GestureDetector(
          //                       onTap: () {
          //                         Navigator.pop(context);
          //                         Navigator.push(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (_) =>
          //                                 AIChatScreen(initialMessage: ""),
          //                           ),
          //                         );
          //                       },
          //                       child: Container(
          //                         width: 180,
          //                         height: 42,
          //                         decoration: BoxDecoration(
          //                           gradient: const LinearGradient(
          //                             colors: [
          //                               Color(0xFFFF00A8),
          //                               Color(0xFF00D1FF),
          //                             ],
          //                           ),
          //                           borderRadius: BorderRadius.circular(21),
          //                           boxShadow: [
          //                             BoxShadow(
          //                               color: const Color(
          //                                 0xFFFF00A8,
          //                               ).withOpacity(0.35),
          //                               blurRadius: 12,
          //                               offset: const Offset(0, 4),
          //                             ),
          //                           ],
          //                         ),
          //                         child: Center(
          //                           child: Text(
          //                             "Say Hello!",
          //                             style: GoogleFonts.poppins(
          //                               color: Colors.white,
          //                               fontSize: 14,
          //                               fontWeight: FontWeight.w600,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3A1D07), Color(0xFF171516)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFAF5F0), Color(0xFFFAF5F0)],
              ),
        color: isDark ? null : const Color(0xFFFAF5F0),
        image: isDark
            ? const DecorationImage(
                image: AssetImage('images/app_bar_gredient.png'),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFF1A1008),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: isDark
                    ? null
                    : Border.all(color: const Color(0xFFCFC4B5), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : const Color(0xFF1A1008),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search contacts, messages, media...',
                  hintStyle: GoogleFonts.poppins(
                    color: isDark ? Colors.white54 : const Color(0xFF4A4A4A),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : const Color(0xFF4A4A4A),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = [
      (SearchFilter.all, 'All', Icons.apps),
      (SearchFilter.contacts, 'Contacts', Icons.people_outline),
      (SearchFilter.photos, 'Photos', Icons.image_outlined),
      (SearchFilter.videos, 'Videos', Icons.videocam_outlined),
      (SearchFilter.links, 'Links', Icons.link),
      (SearchFilter.gifs, 'Gifs', Icons.gif),
      (SearchFilter.audio, 'Audio', Icons.headphones_outlined),
      (SearchFilter.documents, 'Documents', Icons.insert_drive_file_outlined),
    ];

    return Container(
      height: 48,
      color: AppTheme.cardBg(isDark),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (filter, label, icon) = filters[i];
          final isActive = _activeFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? HexColor('#1A7F4B')
                    : AppTheme.cardBgAlt(isDark),
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFCFC4B5),
                      ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isActive
                        ? Colors.white
                        : (isDark
                              ? AppTheme.iconColorSubtle(isDark)
                              : const Color(0xFF4A4A4A)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: isActive
                          ? Colors.white
                          : (isDark
                                ? AppTheme.textSecondary(isDark)
                                : const Color(0xFF4A4A4A)),
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // RESULTS ROUTER
  // ─────────────────────────────────────────────────────────────

  Widget _buildResults() {
    switch (_activeFilter) {
      case SearchFilter.contacts:
        return _buildContactResults();

      case SearchFilter.photos:
        return _buildPhotoGrid();

      case SearchFilter.videos:
        return _buildVideoList();

      case SearchFilter.links:
        return _buildLinkList();

      case SearchFilter.documents:
        return _buildDocumentList();

      case SearchFilter.audio:
        return _buildAudioList();

      case SearchFilter.gifs:
        return _buildGifGrid();

      case SearchFilter.all:
        if (_query.isEmpty) {
          return _buildEmptyState('Search for messages, contacts, or media');
        }
        return _buildAllTabWithQuery();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PHOTOS — grid with fullscreen viewer
  // ─────────────────────────────────────────────────────────────

  Widget _buildPhotoGrid() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Flatten all image URLs with their source message
    final List<_FlatImage> images = [];
    for (final r in _allResults) {
      final msg = r.message;
      if (!msg.isImage || msg.imageUrls == null) continue;
      for (final url in msg.imageUrls!) {
        if (_query.isEmpty || url.toLowerCase().contains(_query)) {
          images.add(_FlatImage(url: url, result: r));
        }
      }
    }

    if (images.isEmpty) return _buildEmptyState('No photos yet');

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (context, i) {
        final img = images[i];
        return GestureDetector(
          onTap: () => _openPhotoViewer(context, images: images, startIndex: i),
          child: Hero(
            tag: 'photo_$i',
            child: img.url.startsWith('http')
                ? OfflineCachedImage(
                    imageUrl: img.url,
                    fit: BoxFit.cover,
                    placeholder: Container(color: AppTheme.cardBgAlt(isDark)),
                    errorWidget: Container(
                      color: AppTheme.cardBgAlt(isDark),
                      child: Icon(
                        Icons.broken_image,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                  )
                : Image.file(File(img.url), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  /// Full-screen image viewer with left/right swipe
  void _openPhotoViewer(
    BuildContext context, {
    required List<_FlatImage> images,
    required int startIndex,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _PhotoViewerScreen(images: images, startIndex: startIndex),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // VIDEOS — list with thumbnail + play
  // ─────────────────────────────────────────────────────────────

  Widget _buildVideoList() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final videos = _allResults.where((r) {
      final msg = r.message;
      if (!msg.isVideo) return false;
      if (_query.isNotEmpty && !msg.text.toLowerCase().contains(_query))
        return false;
      return true;
    }).toList();

    if (videos.isEmpty) return _buildEmptyState('No videos yet');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: videos.length,
      itemBuilder: (context, i) {
        final msg = videos[i].message;
        return GestureDetector(
          onTap: () => _openVideoPlayer(context, msg),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardBgAlt(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 90,
                    height: 70,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (msg.videoThumbnail != null &&
                            msg.videoThumbnail!.isNotEmpty)
                          msg.videoThumbnail!.startsWith('http')
                              ? OfflineCachedImage(
                                  imageUrl: msg.videoThumbnail!,
                                  fit: BoxFit.cover,
                                  placeholder: Container(
                                    color: AppTheme.scaffoldBg(isDark),
                                  ),
                                  errorWidget: Container(
                                    color: AppTheme.scaffoldBg(isDark),
                                  ),
                                )
                              : Image.file(
                                  File(msg.videoThumbnail!),
                                  fit: BoxFit.cover,
                                )
                        else
                          Container(
                            color: AppTheme.scaffoldBg(isDark),
                            child: Icon(
                              Icons.videocam,
                              color: isDark ? Colors.white24 : Colors.black26,
                              size: 32,
                            ),
                          ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text.isNotEmpty ? msg.text : 'Video',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(msg.timestamp),
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppTheme.iconColorSubtle(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openVideoPlayer(BuildContext context, ChatMessage msg) {
    final url = msg.videoUrl ?? '';
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _VideoPlayerScreen(videoUrl: url)),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LINKS — list, tap opens browser
  // ─────────────────────────────────────────────────────────────

  Widget _buildLinkList() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final links = _allResults.where((r) {
      if (!_isLink(r.message.text)) return false;
      if (_query.isNotEmpty && !r.message.text.toLowerCase().contains(_query))
        return false;
      return true;
    }).toList();

    if (links.isEmpty) return _buildEmptyState('No links shared yet');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: links.length,
      itemBuilder: (context, i) {
        final url = links[i].message.text.trim();
        final domain = _extractDomain(url);
        return GestureDetector(
          onTap: () => _launchUrl(url),
          onLongPress: () => _showLinkOptions(context, url),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBgAlt(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppTheme.border(isDark),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: HexColor('#1A7F4B').withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.link, color: HexColor('#1A7F4B'), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        domain,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new, color: HexColor('#1A7F4B'), size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (_) {
      return url;
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLinkOptions(BuildContext context, String url) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBg(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.open_in_browser,
                color: AppTheme.iconColor(isDark),
              ),
              title: Text(
                'Open in browser',
                style: GoogleFonts.poppins(color: AppTheme.popupText(isDark)),
              ),
              onTap: () {
                Navigator.pop(context);
                _launchUrl(url);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: AppTheme.iconColor(isDark)),
              title: Text(
                'Copy link',
                style: GoogleFonts.poppins(color: AppTheme.popupText(isDark)),
              ),
              onTap: () async {
                Navigator.pop(context);
                // Using clipboard
                final data = ClipboardData(text: url);
                await Clipboard.setData(data);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link copied'),
                      backgroundColor: HexColor('#1A7F4B'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DOCUMENTS — list, tap opens/downloads
  // ─────────────────────────────────────────────────────────────

  Widget _buildDocumentList() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final docs = _allResults.where((r) {
      final msg = r.message;
      if (!msg.isDocument) return false;
      if (_query.isNotEmpty) {
        final nameMatch = (msg.documentName ?? '').toLowerCase().contains(
          _query,
        );
        final textMatch = msg.text.toLowerCase().contains(_query);
        if (!nameMatch && !textMatch) return false;
      }
      return true;
    }).toList();

    if (docs.isEmpty) return _buildEmptyState('No documents shared yet');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final msg = docs[i].message;
        final name = msg.documentName ?? 'Document';
        final ext = name.contains('.')
            ? name.split('.').last.toUpperCase()
            : 'FILE';
        final color = _docColor(ext);

        return GestureDetector(
          onTap: () => _openDocument(context, msg),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      ext.length > 4 ? ext.substring(0, 4) : ext,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(msg.timestamp),
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download,
                    color: HexColor('#1A7F4B'),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _docColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFFF3B30);
      case 'doc':
      case 'docx':
        return const Color(0xFF4A90E2);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF34C759);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF9500);
      case 'zip':
      case 'rar':
        return const Color(0xFFAF52DE);
      default:
        return const Color(0xFF5AC8FA);
    }
  }

  Future<void> _openDocument(BuildContext context, ChatMessage msg) async {
    final url = msg.documentUrl ?? '';
    if (url.isEmpty) return;
    final fullUrl = url.startsWith('http') ? url : url;
    try {
      final uri = Uri.parse(fullUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // AUDIO — list with waveform placeholder + play
  // ─────────────────────────────────────────────────────────────

  Widget _buildAudioList() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final audios = _allResults.where((r) {
      final msg = r.message;
      if (!msg.isVoiceNote && !msg.isAudioFile) return false;
      if (_query.isNotEmpty &&
          !(msg.audioName ?? '').toLowerCase().contains(_query))
        return false;
      return true;
    }).toList();

    if (audios.isEmpty) return _buildEmptyState('No audio files yet');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: audios.length,
      itemBuilder: (context, i) {
        final msg = audios[i].message;
        final isVoice = msg.isVoiceNote;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _AudioPlayerScreen(message: msg)),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBgAlt(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVoice ? Icons.mic : Icons.headphones,
                    color: Colors.purple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVoice
                            ? 'Voice message'
                            : (msg.audioName ?? 'Audio file'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Waveform placeholder bars
                      Row(
                        children: List.generate(
                          20,
                          (j) => Container(
                            width: 3,
                            height: (4 + (j % 5) * 4).toDouble(),
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(msg.timestamp),
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  msg.isMe ? 'You' : 'Them',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GIFS — grid view
  // ─────────────────────────────────────────────────────────────

  Widget _buildGifGrid() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final gifs = _allResults.where((r) {
      if (!_isGif(r.message.text)) return false;
      if (_query.isNotEmpty && !r.message.text.toLowerCase().contains(_query))
        return false;
      return true;
    }).toList();

    if (gifs.isEmpty) return _buildEmptyState('No GIFs shared yet');

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: gifs.length,
      itemBuilder: (context, i) {
        final url = gifs[i].message.text.trim();
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _GifViewerScreen(url: url)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: url.startsWith('http')
                ? OfflineCachedImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: Container(color: AppTheme.cardBgAlt(isDark)),
                    errorWidget: Container(
                      color: AppTheme.cardBgAlt(isDark),
                      child: Center(
                        child: Icon(
                          Icons.gif,
                          color: isDark ? Colors.white24 : Colors.black26,
                          size: 40,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: AppTheme.cardBgAlt(isDark),
                    child: Center(
                      child: Icon(
                        Icons.gif,
                        color: isDark ? Colors.white24 : Colors.black26,
                        size: 40,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CONTACTS
  // ─────────────────────────────────────────────────────────────

  Widget _buildContactResults() {
    final contacts = _filteredContacts;
    if (contacts.isEmpty) {
      return _buildEmptyState(
        _query.isEmpty
            ? 'Your contacts and groups appear here'
            : 'No contacts found',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: contacts.length,
      itemBuilder: (context, i) => _buildContactTile(contacts[i]),
    );
  }

  Widget _buildContactTile(_ContactResult contact) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        if (contact.isGroup) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupChatScreen(
                groupId: contact.id,
                groupName: contact.title,
                communityName: contact.title,
                memberCount: contact.memberCount,
                groupImage: contact.profilePicture,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MessageScreen(
                chatId: contact.id,
                username: contact.title,
                lastSeenActive: '',
                profilePicture: contact.profilePicture,
                about: contact.about,
                userId: contact.userId,
                isGroupChat: false,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            contact.isGroup && contact.membersAvatarUrls.isNotEmpty
                ? GroupCompositeAvatar(
                    imageUrls: contact.membersAvatarUrls,
                    userIds: contact.memberUserIds,
                    totalMemberCount: contact.memberCount,
                    size: 50,
                    statusRings: const {},
                  )
                : CachedProfileAvatar(
                    imageUrl: contact.profilePicture.isNotEmpty
                        ? contact.profilePicture
                        : null,
                    displayName: contact.title,
                    radius: 25,
                    backgroundColor: const Color(0xFFFB8830),
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.isGroup
                        ? '${contact.memberCount} members'
                        : (contact.about.isNotEmpty
                              ? contact.about
                              : 'Tap to open chat'),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: contact.isGroup
                    ? HexColor('#1A7F4B').withOpacity(0.2)
                    : HexColor('#FB8830').withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    contact.isGroup ? Icons.group : Icons.person,
                    size: 12,
                    color: contact.isGroup
                        ? HexColor('#1A7F4B')
                        : HexColor('#FB8830'),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    contact.isGroup ? 'Group' : 'Contact',
                    style: GoogleFonts.poppins(
                      color: contact.isGroup
                          ? HexColor('#1A7F4B')
                          : HexColor('#FB8830'),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

  // ─────────────────────────────────────────────────────────────
  // ALL TAB WITH QUERY
  // ─────────────────────────────────────────────────────────────

  Widget _buildAllTabWithQuery() {
    final contactMatches = _filteredContacts;
    final messageMatches = _filtered;

    if (contactMatches.isEmpty && messageMatches.isEmpty) {
      return _buildEmptyState('No results found');
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 180), // leave room for robot
      children: [
        if (contactMatches.isNotEmpty) ...[
          _sectionHeader('Contacts & Groups'),
          ...contactMatches.map((c) => _buildContactTile(c)),
        ],
        if (messageMatches.isNotEmpty) ...[
          _sectionHeader('Messages'),
          ...messageMatches.map((r) => _buildMessageSearchTile(r)),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: HexColor('#1A7F4B'),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGenericMessageTile(ChatMessage msg) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    IconData icon;
    String subtitle;
    Color iconColor = HexColor('#1A7F4B');

    if (msg.isDocument) {
      icon = Icons.insert_drive_file_outlined;
      subtitle = msg.documentName ?? 'Document';
      iconColor = Colors.blue;
    } else if (msg.isVoiceNote || msg.isAudioFile) {
      icon = Icons.headphones;
      subtitle = msg.audioName ?? 'Audio';
      iconColor = Colors.purple;
    } else if (_isLink(msg.text)) {
      icon = Icons.link;
      subtitle = msg.text;
      iconColor = Colors.orange;
    } else if (msg.isImage) {
      icon = Icons.image_outlined;
      subtitle = 'Photo';
      iconColor = Colors.teal;
    } else if (msg.isVideo) {
      icon = Icons.videocam_outlined;
      subtitle = msg.text.isNotEmpty ? msg.text : 'Video';
      iconColor = Colors.red;
    } else {
      icon = Icons.message_outlined;
      subtitle = msg.text;
    }

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary(isDark),
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        msg.isMe ? 'You' : 'Them',
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 11,
        ),
      ),
      trailing: Text(
        _formatDate(msg.timestamp),
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 10,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MESSAGE SEARCH TILE — with chat name, preview, tap to jump
  // ─────────────────────────────────────────────────────────────

  Widget _buildMessageSearchTile(_SearchResult result) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final msg = result.message;

    // Find the chat info from Hive so we can show chat name
    final chatBox = Hive.box<ChatListItemHive>('chats');
    final chat = chatBox.get(result.chatId);
    final chatName = chat?.title ?? 'Unknown Chat';
    final chatProfilePic = chat?.profilePicture ?? '';
    final isGroup = chat?.isGroupChat ?? false;
    final chatUserId = chat?.userId ?? '';
    final chatAbout = chat?.about ?? '';

    // Build preview text with highlighted query
    String previewText;
    if (msg.isImage) {
      previewText = '📷 Photo';
    } else if (msg.isVoiceNote) {
      previewText = '🎙️ Voice message';
    } else if (msg.isAudioFile) {
      previewText = '🎵 Audio';
    } else if (msg.isVideo) {
      previewText = '🎥 Video';
    } else if (msg.isDocument) {
      previewText = '📄 ${msg.documentName ?? "Document"}';
    } else {
      previewText = msg.text;
    }

    final String capitalize = chatName.isNotEmpty
        ? '${chatName[0].toUpperCase()}${chatName.substring(1)}'
        : chatName;

    return InkWell(
      onTap: () {
        // Navigate to the chat and jump to this specific message
        if (isGroup) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupChatScreen(
                groupId: result.chatId,
                groupName: capitalize,
                communityName: capitalize,
                memberCount: chat?.memberCount ?? 0,
                groupImage: chatProfilePic,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MessageScreen(
                chatId: result.chatId,
                username: capitalize,
                lastSeenActive: '',
                profilePicture: chatProfilePic,
                about: chatAbout,
                userId: chatUserId,
                isGroupChat: false,
                highlightMessageId: msg.id, // ← jump to this message
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBgAlt(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CachedProfileAvatar(
              imageUrl: chatProfilePic.isNotEmpty ? chatProfilePic : null,
              displayName: chatName,
              radius: 22,
              backgroundColor: HexColor('#FB8830'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chat name + time row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          capitalize,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(msg.timestamp),
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Highlighted message preview
                  _buildHighlightedText(previewText, _query, isDark: isDark),
                  const SizedBox(height: 4),
                  // Sent by label
                  Text(
                    msg.isMe ? '✔ You' : '← ${capitalize}',
                    style: GoogleFonts.poppins(
                      color: msg.isMe
                          ? HexColor('#1A7F4B')
                          : HexColor('#FB8830'),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: AppTheme.iconColorSubtle(isDark),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Renders text with the search query highlighted in orange
  Widget _buildHighlightedText(
    String text,
    String query, {
    required bool isDark,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 13,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final idx = lowerText.indexOf(lowerQuery);

    if (idx == -1) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 13,
        ),
      );
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: GoogleFonts.poppins(
          color: AppTheme.textSecondary(isDark),
          fontSize: 13,
        ),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: GoogleFonts.poppins(
              color: HexColor('#FF6900'),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              backgroundColor: HexColor('#FF6900').withOpacity(0.12),
            ),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState(String message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF1A7F4B)),
    );
  }

  String _formatDate(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final m = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour < 12 ? 'AM' : 'PM';
        return '$h:$m $ampm';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// FULL-SCREEN PHOTO VIEWER (swipe left/right)
// ─────────────────────────────────────────────────────────────

class _PhotoViewerScreen extends StatefulWidget {
  final List<_FlatImage> images;
  final int startIndex;

  const _PhotoViewerScreen({required this.images, required this.startIndex});

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _pageController = PageController(initialPage: widget.startIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, i) {
          final img = widget.images[i];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'photo_$i',
                child: img.url.startsWith('http')
                    ? OfflineCachedImage(
                        imageUrl: img.url,
                        fit: BoxFit.contain,
                        placeholder: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A7F4B),
                          ),
                        ),
                        errorWidget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 64,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Could not load image',
                              style: GoogleFonts.poppins(color: Colors.white38),
                            ),
                          ],
                        ),
                      )
                    : Image.file(
                        File(img.url),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white24,
                          size: 64,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
      // Left/right navigation arrows
      bottomNavigationBar: widget.images.length > 1
          ? Container(
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _currentIndex > 0
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : null,
                  ),
                  // Dot indicators (max 10 shown)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.images.length > 10 ? 10 : widget.images.length,
                      (i) {
                        final dotIndex = widget.images.length > 10
                            ? (i * widget.images.length ~/ 10)
                            : i;
                        return Container(
                          width: _currentIndex == dotIndex ? 10 : 6,
                          height: _currentIndex == dotIndex ? 10 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _currentIndex == dotIndex
                                ? const Color(0xFF1A7F4B)
                                : Colors.white38,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _currentIndex < widget.images.length - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// VIDEO PLAYER SCREEN
// ─────────────────────────────────────────────────────────────

class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerScreen({required this.videoUrl});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        _controller = VideoPlayerController.file(File(widget.videoUrl));
      }
      await _controller.initialize();
      if (mounted) {
        setState(() => _initialized = true);
        _controller.play();
      }
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Center(
          child: !_initialized
              ? const CircularProgressIndicator(color: Color(0xFF1A7F4B))
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (_showControls)
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Progress bar
                              ValueListenableBuilder(
                                valueListenable: _controller,
                                builder: (_, value, __) {
                                  final pos = value.position;
                                  final dur = value.duration;
                                  return Column(
                                    children: [
                                      Slider(
                                        value: pos.inMilliseconds.toDouble(),
                                        min: 0,
                                        max: dur.inMilliseconds.toDouble() > 0
                                            ? dur.inMilliseconds.toDouble()
                                            : 1,
                                        activeColor: const Color(0xFF1A7F4B),
                                        inactiveColor: Colors.white24,
                                        onChanged: (v) {
                                          _controller.seekTo(
                                            Duration(milliseconds: v.toInt()),
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDuration(pos),
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(dur),
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                },
                              ),
                              // Play/pause + rewind/forward
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      final pos = _controller.value.position;
                                      _controller.seekTo(
                                        pos - const Duration(seconds: 10),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  ValueListenableBuilder(
                                    valueListenable: _controller,
                                    builder: (_, value, __) {
                                      return GestureDetector(
                                        onTap: () {
                                          value.isPlaying
                                              ? _controller.pause()
                                              : _controller.play();
                                        },
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1A7F4B),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.forward_10,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      final pos = _controller.value.position;
                                      _controller.seekTo(
                                        pos + const Duration(seconds: 10),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────
// GIF VIEWER SCREEN — fullscreen animated GIF
// ─────────────────────────────────────────────────────────────

class _GifViewerScreen extends StatelessWidget {
  final String url;
  const _GifViewerScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'GIF',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: url.startsWith('http')
              ? Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A7F4B),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        color: Colors.white24,
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Could not load GIF',
                        style: GoogleFonts.poppins(color: Colors.white38),
                      ),
                    ],
                  ),
                )
              : const Icon(Icons.gif, color: Colors.white24, size: 80),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AUDIO PLAYER SCREEN — plays voice notes and audio files
// ─────────────────────────────────────────────────────────────

class _AudioPlayerScreen extends StatefulWidget {
  final ChatMessage message;
  const _AudioPlayerScreen({required this.message});

  @override
  State<_AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<_AudioPlayerScreen> {
  late final AudioPlayer _player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final url = widget.message.audioUrl ?? '';
      if (url.startsWith('http')) {
        await _player.setUrl(url);
      } else {
        await _player.setFilePath(url);
      }
      setState(() {
        _duration = _player.duration ?? Duration.zero;
        _isLoading = false;
      });
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
          if (state.processingState == ProcessingState.completed) {
            _player.seek(Duration.zero);
            _player.pause();
          }
        }
      });
      _player.play();
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isVoice = widget.message.isVoiceNote;
    final title = isVoice
        ? 'Voice Message'
        : (widget.message.audioName ?? 'Audio File');

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Color(0xFF1A7F4B))
            : _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'Could not play audio',
                    style: GoogleFonts.poppins(color: Colors.white54),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isVoice ? Icons.mic : Icons.headphones,
                        color: Colors.purple,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Waveform placeholder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(30, (i) {
                        final filled = _duration.inMilliseconds > 0
                            ? (i / 30) <=
                                  (_position.inMilliseconds /
                                      _duration.inMilliseconds)
                            : false;
                        return Container(
                          width: 4,
                          height: (8 + (i % 7) * 5).toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: filled
                                ? Colors.purple
                                : Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Slider
                    Slider(
                      value: _position.inMilliseconds.toDouble().clamp(
                        0,
                        _duration.inMilliseconds.toDouble().clamp(
                          1,
                          double.infinity,
                        ),
                      ),
                      min: 0,
                      max: _duration.inMilliseconds.toDouble().clamp(
                        1,
                        double.infinity,
                      ),
                      activeColor: Colors.purple,
                      inactiveColor: Colors.purple.withOpacity(0.2),
                      onChanged: (v) {
                        _player.seek(Duration(milliseconds: v.toInt()));
                      },
                    ),

                    // Time labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fmt(_position),
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _fmt(_duration),
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () => _player.seek(
                            _position - const Duration(seconds: 10),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () =>
                              _isPlaying ? _player.pause() : _player.play(),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () => _player.seek(
                            _position + const Duration(seconds: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────

class _SearchResult {
  final String chatId;
  final ChatMessage message;
  _SearchResult({required this.chatId, required this.message});
}

class _FlatImage {
  final String url;
  final _SearchResult result;
  _FlatImage({required this.url, required this.result});
}

class _MediaItem {
  final String url;
  final bool isVideo;
  final _SearchResult result;
  _MediaItem({required this.url, required this.isVideo, required this.result});
}

// ROBOT DISABLED: _RobotBounce widget class temporarily hidden
// class _RobotBounce extends StatefulWidget {
//   final Widget child;
//   const _RobotBounce({required this.child});
//
//   @override
//   State<_RobotBounce> createState() => _RobotBounceState();
// }
//
// class _RobotBounceState extends State<_RobotBounce>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//     _anim = Tween<double>(
//       begin: 0,
//       end: 12,
//     ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _anim,
//       builder: (_, child) =>
//           Transform.translate(offset: Offset(0, _anim.value), child: child),
//       child: widget.child,
//     );
//   }
// }

class _ContactResult {
  final String id;
  final String title;
  final String profilePicture;
  final bool isGroup;
  final int memberCount;
  final List<String> membersAvatarUrls;
  final List<String> memberUserIds;
  final String about;
  final String userId;

  _ContactResult({
    required this.id,
    required this.title,
    required this.profilePicture,
    required this.isGroup,
    required this.memberCount,
    required this.membersAvatarUrls,
    required this.memberUserIds,
    required this.about,
    required this.userId,
  });
}
