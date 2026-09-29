import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/features/feed/data/models/create_post_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_story_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/features/feed/presentation/screens/widget/video_thumbnail_widget.dart';
import 'package:qik_talk/features/feed/data/models/text_overlay_model.dart';

class NewPostScreen extends ConsumerStatefulWidget {
  final List<File> selectedMedia;
  final String? initialCaption;
  final String? postType;
  final Map<int, List<TextOverlay>>? overlays;

  const NewPostScreen({
    super.key,
    this.selectedMedia = const [],
    this.initialCaption,
    this.postType,
    this.overlays,
  });

  @override
  ConsumerState<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends ConsumerState<NewPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  bool _showTagInput = false;

  List<String> _tags = [];
  PostMusic? _selectedMusic;
  bool isPosting = false;
  bool _allowComments = true;

  // @Mention state
  List<Map<String, dynamic>> _taggedUsers = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialCaption != null) {
      _captionController.text = widget.initialCaption!;
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    String cleanTag = tag.trim().replaceAll('#', '');
    if (cleanTag.isNotEmpty && !_tags.contains(cleanTag)) {
      setState(() {
        _tags.add(cleanTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addTaggedUser(Map<String, dynamic> user) {
    final id = user['_id'] as String? ?? '';
    if (id.isNotEmpty && !_taggedUsers.any((u) => u['_id'] == id)) {
      setState(() {
        _taggedUsers.add(user);
      });
    }
  }

  void _removeTaggedUser(String userId) {
    setState(() {
      _taggedUsers.removeWhere((u) => u['_id'] == userId);
    });
  }

  void _showMentionPicker() {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tag People',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Done',
                                style: GoogleFonts.poppins(
                                  color: HexColor('#FF2D55'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextField(
                          controller: searchController,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white24,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white54,
                            ),
                            filled: true,
                            fillColor: HexColor('#2A2A2D'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (query) async {
                            if (query.trim().isEmpty) {
                              setSheetState(() {
                                searchResults = [];
                                isSearching = false;
                              });
                              return;
                            }
                            setSheetState(() => isSearching = true);
                            final results = await ref
                                .read(feedProvider.notifier)
                                .searchUsers(query);
                            setSheetState(() {
                              searchResults = results;
                              isSearching = false;
                            });
                          },
                        ),
                      ),
                      // Show already tagged users
                      if (_taggedUsers.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _taggedUsers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final user = _taggedUsers[index];
                                return Chip(
                                  label: Text(
                                    '@${user['username'] ?? ''}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: HexColor(
                                    '#FF2D55',
                                  ).withValues(alpha: 0.3),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white54,
                                  ),
                                  onDeleted: () {
                                    _removeTaggedUser(
                                      user['_id'] as String? ?? '',
                                    );
                                    setSheetState(() {});
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (isSearching)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF2D55),
                            ),
                          ),
                        )
                      else if (searchResults.isEmpty &&
                          searchController.text.isNotEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_search_outlined,
                                  color: Colors.white24,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (searchResults.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.alternate_email,
                                  color: Colors.white24,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Search for users to tag',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final user = searchResults[index];
                              final userId = user['_id'] as String? ?? '';
                              final username =
                                  user['username'] as String? ?? '';
                              final profilePic =
                                  user['profilePicture'] as String? ?? '';
                              final isSelected = _taggedUsers.any(
                                (u) => u['_id'] == userId,
                              );

                              return ListTile(
                                onTap: () {
                                  if (isSelected) {
                                    _removeTaggedUser(userId);
                                  } else {
                                    _addTaggedUser(user);
                                  }
                                  setSheetState(() {});
                                },
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: HexColor('#2A2A2D'),
                                  backgroundImage: profilePic.isNotEmpty
                                      ? NetworkImage(profilePic)
                                      : null,
                                  child: profilePic.isEmpty
                                      ? Text(
                                          username.isNotEmpty
                                              ? username[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  '@$username',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: user['fullName'] != null
                                    ? Text(
                                        user['fullName'] as String,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.add_circle_outline,
                                  color: isSelected
                                      ? HexColor('#FF2D55')
                                      : Colors.white70,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMusicPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(feedProvider.notifier).searchMusic('');
        });
        return Consumer(
          builder: (context, ref, child) {
            final feedState = ref.watch(feedProvider);
            final musicResults = feedState.musicSearchResults;
            final isSearching = feedState.isMusicSearching;

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Music',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextField(
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search music...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white24,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white54,
                            ),
                            filled: true,
                            fillColor: HexColor('#2A2A2D'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (query) {
                            ref.read(feedProvider.notifier).searchMusic(query);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isSearching)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF2D55),
                            ),
                          ),
                        )
                      else if (musicResults.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.music_off_outlined,
                                  color: Colors.white24,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Search for your favorite songs',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: musicResults.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final music = musicResults[index];
                              return ListTile(
                                onTap: () {
                                  setState(() {
                                    _selectedMusic = PostMusic(
                                      thirdPartyId: music.thirdPartyId,
                                      title: music.title,
                                      artist: music.artist,
                                      audioUrl: music.audioUrl,
                                      coverImage: music.coverImage,
                                    );
                                  });
                                  Navigator.pop(context);
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    music.coverImage ?? " ",
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: HexColor('#2A2A2D'),
                                        child: const Icon(
                                          Icons.music_note,
                                          color: Colors.white54,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                title: Text(
                                  music.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  music.artist,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white70,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _sharePost() async {
    final content = _captionController.text.trim();

    if (content.isEmpty && widget.selectedMedia.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please add some content or media')),
      // );
      return;
    }

    setState(() {
      isPosting = true;
    });

    final dto = CreatePostDto(
      content: content,
      tags: _tags.isNotEmpty ? _tags : null,
      music: _selectedMusic,
      allowComment: _allowComments,
      taggedUsers: _taggedUsers.isNotEmpty
          ? _taggedUsers
                .map((u) => u['_id'] as String? ?? '')
                .where((id) => id.isNotEmpty)
                .toList()
          : null,
    );

    List<File> overlayVideoFiles = [];

    String? overlayTextJson;
    List<String>? overlayVideoTextJson;

    if (widget.postType == 'Story') {
      if (widget.selectedMedia.isNotEmpty) {
        final List<TextOverlay> storyOverlays = widget.overlays?[0] ?? [];

        // Combine all overlays (text, emoji, and video) into overlayText metadata
        // This ensures transforms (size/position) are preserved on the backend
        final allStoryOverlays = storyOverlays.map((e) => e.toJson()).toList();
        overlayTextJson = allStoryOverlays.isNotEmpty
            ? jsonEncode(allStoryOverlays)
            : null;

        // We do NOT send video overlay metadata in overlayVideoTextJson 
        // because the backend expects this field to only contain actual video URLs.
        // The metadata is already safely included in overlayTextJson above.
        overlayVideoTextJson = null;

        // Collect video overlay local paths
        for (var o in storyOverlays) {
          if (o.type == OverlayType.video && o.localVideoPath != null) {
            overlayVideoFiles.add(File(o.localVideoPath!));
          }
        }

        ref
            .read(feedProvider.notifier)
            .createStory(
              CreateStoryDto(
                caption: content,
                overlayText: overlayTextJson,
                overlayVideos: overlayVideoTextJson,
                music: _selectedMusic,
              ),
              mediaFile: widget.selectedMedia[0],
              overlayVideoFiles: overlayVideoFiles.isNotEmpty
                  ? overlayVideoFiles
                  : null,
            );
      }
    } else {
      // For Posts (multiple media)
      // Combine all overlays per media item
      List<List<Map<String, dynamic>>> allOverlaysPerMedia = [];
      List<List<Map<String, dynamic>>> videoOnlyOverlaysPerMedia = [];

      for (int i = 0; i < widget.selectedMedia.length; i++) {
        final mediaOverlays = widget.overlays?[i] ?? [];

        allOverlaysPerMedia.add(mediaOverlays.map((e) => e.toJson()).toList());

        videoOnlyOverlaysPerMedia.add(
          mediaOverlays
              .where((e) => e.type == OverlayType.video)
              .map((e) => e.toJson())
              .toList(),
        );

        // Collect all video files
        for (var o in mediaOverlays) {
          if (o.type == OverlayType.video && o.localVideoPath != null) {
            overlayVideoFiles.add(File(o.localVideoPath!));
          }
        }
      }

      overlayTextJson = allOverlaysPerMedia.any((l) => l.isNotEmpty)
          ? jsonEncode(allOverlaysPerMedia)
          : null;
      // We do NOT send video overlay metadata in overlayVideoTextJson 
      // because the backend expects this field to only contain actual video URLs.
      // The metadata is already safely included in overlayTextJson above.
      overlayVideoTextJson = null;

      ref
          .read(feedProvider.notifier)
          .createPost(
            dto.copyWith(
              overlayText: overlayTextJson,
              overlayVideos: overlayVideoTextJson,
            ),
            mediaFiles: widget.selectedMedia.isNotEmpty
                ? widget.selectedMedia
                : null,
            overlayVideoFiles: overlayVideoFiles.isNotEmpty
                ? overlayVideoFiles
                : null,
          );
    }

    // Navigate back to feed immediately
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Scaffold(
      backgroundColor: isDark ? HexColor('#1C1C1E') : AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: isDark ? HexColor('#1C1C1E') : AppTheme.scaffoldBg(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New post',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Media Preview
              if (widget.selectedMedia.isNotEmpty)
                Center(
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MediaUtils.isVideo(widget.selectedMedia[0].path)
                            ? VideoThumbnailWidget(
                                videoFile: widget.selectedMedia[0],
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.file(
                                widget.selectedMedia[0],
                                fit: BoxFit.cover,
                              ),
                        // Positioned(
                        //   bottom: 12,
                        //   right: 12,
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 12,
                        //       vertical: 6,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white.withValues(alpha: 0.8),
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //     child: Text(
                        //       'Edit',
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.black,
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Caption Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _captionController,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 14,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Add Caption...',
                      hintStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white54 : AppTheme.textHint(isDark),
                        fontSize: 14,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showTagInput = !_showTagInput;
                          });
                        },
                        child: Text(
                          '#Hashtags',
                          style: GoogleFonts.poppins(
                            color: _showTagInput || _tags.isNotEmpty
                                ? HexColor('#FF2D55')
                                : isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showMentionPicker,
                        child: Text(
                          '@Mention',
                          style: GoogleFonts.poppins(
                            color: _taggedUsers.isNotEmpty
                                ? HexColor('#FF2D55')
                                : isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Tagged users chips
                  if (_taggedUsers.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _taggedUsers.map((user) {
                        return Chip(
                          label: Text(
                            '@${user['username'] ?? ''}',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: HexColor('#FF2D55').withValues(alpha: 0.2),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 14,
                            color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                          ),
                          onDeleted: () =>
                              _removeTaggedUser(user['_id'] as String? ?? ''),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (_showTagInput) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tagController,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter tag and press enter...',
                        hintStyle: GoogleFonts.poppins(
                          color: isDark ? Colors.white24 : AppTheme.textHint(isDark),
                          fontSize: 14,
                        ),
                        isDense: true,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: HexColor('#FF2D55')),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: HexColor('#FF2D55'),
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          _addTag(val);
                        }
                      },
                    ),
                  ],
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(
                            '#$tag',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: isDark ? HexColor('#2A2A2D') : AppTheme.cardBg(isDark),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 14,
                            color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                          ),
                          onDeleted: () => _removeTag(tag),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildActionChip(
                        SvgPicture.asset('assets/svgs/poll.svg'),
                        'Poll',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildActionChip(
                        SvgPicture.asset(
                          'assets/svgs/search.svg',
                          width: 15,
                          height: 15,
                        ),
                        'Prompt',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: isDark ? Colors.white24 : AppTheme.divider(isDark), height: 1),

              // Menu Items
              _buildMenuItem(
                SvgPicture.asset(
                  'assets/svgs/music.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white70 : AppTheme.iconColor(isDark),
                    BlendMode.srcIn,
                  ),
                ),
                'Add audio',
                isDark: isDark,
                onTap: _showMusicPicker,
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                ),
              ),
              // For audio pill
              if (_selectedMusic != null)
                Padding(
                  padding: const EdgeInsets.only(left: 40, bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? HexColor('#2A2A2D') : AppTheme.cardBg(isDark),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white12 : AppTheme.divider(isDark),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note,
                          color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${_selectedMusic!.title} - ${_selectedMusic!.artist}',
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _selectedMusic = null),
                          child: Icon(
                            Icons.close,
                            color: isDark ? Colors.white38 : AppTheme.textHint(isDark),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Divider(color: isDark ? Colors.white24 : AppTheme.divider(isDark), height: 1),
              _buildMenuItem(
                SvgPicture.asset(
                  'assets/svgs/location.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white70 : AppTheme.iconColor(isDark),
                    BlendMode.srcIn,
                  ),
                ),
                'Add location',
                isDark: isDark,
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                ),
              ),
              Divider(color: isDark ? Colors.white24 : AppTheme.divider(isDark), height: 1),
              _buildMenuItem(
                SvgPicture.asset(
                  'assets/svgs/audience.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white70 : AppTheme.iconColor(isDark),
                    BlendMode.srcIn,
                  ),
                ),
                'Audience',
                isDark: isDark,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Everyone',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white54 : AppTheme.textSecondary(isDark),
                    ),
                  ],
                ),
              ),
              Divider(color: isDark ? Colors.white24 : AppTheme.divider(isDark), height: 1),
              if (widget.postType != 'Story') ...[
                _buildMenuItem(
                  Icon(
                    Icons.comment_outlined,
                    color: isDark ? Colors.white70 : AppTheme.iconColor(isDark),
                    size: 20,
                  ),
                  'Allow comments',
                  isDark: isDark,
                  trailing: Switch(
                    value: _allowComments,
                    onChanged: (val) {
                      setState(() {
                        _allowComments = val;
                      });
                    },
                    activeColor: HexColor('#FF2D55'),
                  ),
                ),
                Divider(color: isDark ? Colors.white24 : AppTheme.divider(isDark), height: 1),
              ],
              const SizedBox(height: 32),

              // Share Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPosting ? null : _sharePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('#FF2D55'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isPosting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Share',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(SvgPicture icon, String label, {bool isDark = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isDark ? Colors.white24 : AppTheme.divider(isDark),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    dynamic icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
    bool isDark = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            if (icon is Widget) icon else icon as Widget,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
