import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qik_talk/features/feed/presentation/state/provider/feed_provider.dart';
import 'package:qik_talk/features/feed/presentation/screens/friends_feed_screen.dart';
import 'package:qik_talk/features/feed/presentation/screens/qik_flash_screen.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:qik_talk/utilities/widgets/offline_media_widgets.dart';
import 'package:qik_talk/utilities/database/save_values.dart';

class SearchOverlay extends ConsumerStatefulWidget {
  final String tab;

  const SearchOverlay({super.key, this.tab = 'following'});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final SaveValues _saveValues = SaveValues();
  static const String _historyKey = 'feed_search_history';
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _saveValues.getStringList(_historyKey);
    setState(() {
      _history = history;
    });
  }

  Future<void> _saveHistory(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    setState(() {
      _history.remove(trimmedQuery);
      _history.insert(0, trimmedQuery);
      if (_history.length > 20) {
        _history = _history.sublist(0, 20);
      }
    });
    await _saveValues.saveStringList(_historyKey, _history);
  }

  Future<void> _removeFromHistory(int index) async {
    setState(() {
      _history.removeAt(index);
    });
    await _saveValues.saveStringList(_historyKey, _history);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(feedProvider.notifier).searchFeedPosts(query);
    });
    setState(() {}); // Trigger rebuild to show/hide history vs search results
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.8, sigmaY: 8.8),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: HexColor('#1C1C1E'),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white10,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  onSubmitted: (value) {
                                    _saveHistory(value);
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'What are you looking for?..',
                                    hintStyle: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: HexColor('#EA4359'),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // History List / Search Results
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final feedState = ref.watch(feedProvider);
                      final isSearching = _searchController.text.isNotEmpty;

                      if (isSearching) {
                        if (feedState.isSearchLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (feedState.searchError != null) {
                          return Center(
                            child: Text(
                              'Error: ${feedState.searchError}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (feedState.searchResults.isEmpty) {
                          return const Center(
                            child: Text(
                              'No posts found.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: feedState.searchResults.length,
                          itemBuilder: (context, index) {
                            final post = feedState.searchResults[index];
                            final imageUrl = post.media.isNotEmpty
                                ? MediaUtils.getThumbnailUrl(post.media.first)
                                : null;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? OfflineCachedImage(
                                        imageUrl: imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade800,
                                        child: const Icon(
                                          Icons.text_snippet,
                                          color: Colors.white54,
                                        ),
                                      ),
                              ),
                              title: Text(
                                post.user.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                post.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () {
                                if (widget.tab == 'qikFlash') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QikFlashScreen(
                                        posts: feedState.searchResults,
                                        initialPostIndex: index,
                                        usePassedPostsOnly: true,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FriendsFeedScreen(
                                        posts: feedState.searchResults,
                                        initialPostIndex: index,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }

                      // Default History List
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _searchController.text = _history[index];
                                      _saveHistory(_history[index]);
                                      _onSearchChanged(_history[index]);
                                    },
                                    child: Text(
                                      _history[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeFromHistory(index),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white38,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showSearchOverlay(BuildContext context, {String tab = 'following'}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) => SearchOverlay(tab: tab),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
