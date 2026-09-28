import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

const _kGiphyKey = 'cc5oWSwdtVAs7tWUQMTZALah9ZIaPLkA';

class EmojiGifPicker extends StatefulWidget {
  final bool showGif;
  final ValueChanged<bool> onTabChanged;
  final ValueChanged<String> onEmojiSelected;
  final ValueChanged<String> onGifSelected;
  final FocusNode? textFieldFocusNode;

  const EmojiGifPicker({
    super.key,
    required this.showGif,
    required this.onTabChanged,
    required this.onEmojiSelected,
    required this.onGifSelected,
    this.textFieldFocusNode,
  });

  static bool isGifUrl(String text) {
    final t = text.trim().toLowerCase();
    return (t.startsWith('https://media') || t.startsWith('http://media')) &&
        (t.contains('giphy.com') || t.contains('tenor.com')) &&
        (t.endsWith('.gif') || t.contains('.gif?'));
  }

  @override
  State<EmojiGifPicker> createState() => _EmojiGifPickerState();
}

class _EmojiGifPickerState extends State<EmojiGifPicker> {
  final _emojiSearchCtrl = TextEditingController();
  String _emojiSearch = '';
  int _selectedCategory = 0;

  final _gifSearchCtrl = TextEditingController();
  List<_GifItem> _gifs = [];
  bool _gifLoading = false;
  Timer? _gifDebounce;

  static const _categories = <(String, String, List<String>)>[
    ('😀', 'SMILES & PEOPLES', _smileys),
    ('👋', 'PEOPLE', _people),
    ('🐶', 'ANIMALS', _animals),
    ('🍕', 'FOOD', _food),
    ('✈️', 'TRAVEL', _travel),
    ('⚽', 'ACTIVITY', _activity),
    ('💡', 'OBJECTS', _objects),
    ('❤️', 'SYMBOLS', _symbols),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showGif) _fetchGifs('');
  }

  @override
  void didUpdateWidget(EmojiGifPicker old) {
    super.didUpdateWidget(old);
    if (widget.showGif && !old.showGif && _gifs.isEmpty) _fetchGifs('');
  }

  @override
  void dispose() {
    _emojiSearchCtrl.dispose();
    _gifSearchCtrl.dispose();
    _gifDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchGifs(String query) async {
    if (!mounted) return;
    setState(() => _gifLoading = true);
    try {
      final url = query.trim().isEmpty
          ? 'https://api.giphy.com/v1/gifs/trending?api_key=$_kGiphyKey&limit=20&rating=g'
          : 'https://api.giphy.com/v1/gifs/search?api_key=$_kGiphyKey&q=${Uri.encodeComponent(query)}&limit=20&rating=g';
      final res = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List results = data['data'] ?? [];
        final items = results
            .map((g) {
              final images = g['images'] as Map? ?? {};
              final full = images['downsized'] as Map? ?? {};
              final preview = images['preview_gif'] as Map? ?? {};
              final fixed = images['fixed_width_small'] as Map? ?? {};
              return _GifItem(
                url: full['url'] ?? fixed['url'] ?? '',
                preview: preview['url'] ?? fixed['url'] ?? full['url'] ?? '',
              );
            })
            .where((g) => g.url.isNotEmpty)
            .toList();
        setState(() {
          _gifs = items;
          _gifLoading = false;
        });
      } else {
        if (mounted) setState(() => _gifLoading = false);
      }
    } catch (e) {
      debugPrint('Giphy error: $e');
      if (mounted) setState(() => _gifLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarH = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentH = (constraints.maxHeight - 36).clamp(100.0, 800.0);
        return Column(
          children: [
            _buildTabRow(isDark),
            SizedBox(
              height: contentH,
              child: widget.showGif
                  ? _buildGifPanel(contentH, navBarH, isDark)
                  : _buildEmojiPanel(contentH, navBarH, isDark),
            ),
          ],
        );
      },
    );
  }

  // ── Tab row ───────────────────────────────────
  Widget _buildTabRow(bool isDark) {
    return Container(
      height: 36,
      color: isDark ? const Color(0xFF111111) : const Color(0xFFF5EEE4),
      child: Row(
        children: [
          _tabBtn(
            child: const Text('😊', style: TextStyle(fontSize: 18)),
            selected: !widget.showGif,
            onTap: () => widget.onTabChanged(false),
            isDark: isDark,
          ),
          _tabBtn(
            child: Icon(
              Icons.gif_box_outlined,
              size: 24,
              color: widget.showGif ? const Color(0xFF1A7F4B) : (isDark ? Colors.white54 : Colors.black45),
            ),
            selected: widget.showGif,
            onTap: () {
              widget.onTabChanged(true);
              if (_gifs.isEmpty) _fetchGifs('');
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _tabBtn({
    required Widget child,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF1A7F4B) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  // ── Emoji panel ───────────────────────────────
  Widget _buildEmojiPanel(double totalH, double navBarH, bool isDark) {
    final searching = _emojiSearch.isNotEmpty;

    const searchBarH = 38.0;
    const labelH = 16.0;
    final chipsH = 44.0 + navBarH;

    final gridH = searching
        ? (totalH - searchBarH - chipsH - 8).clamp(50.0, 800.0)
        : (totalH - searchBarH - labelH - chipsH - 8).clamp(50.0, 800.0);
    final emojis = searching
        ? _categories
              .expand((c) => c.$3)
              .where((e) => e.contains(_emojiSearch))
              .toList()
        : _categories[_selectedCategory].$3;

    return Container(
      color: isDark ? const Color(0xFF1B1B1B) : const Color(0xFFFAF5F0),
      child: Column(
        children: [
          _searchBar(
            controller: _emojiSearchCtrl,
            hint: 'Search Emoji',
            autofocus: false,
            onChanged: (v) => setState(() => _emojiSearch = v),
            isDark: isDark,
            suffixIcon: _emojiSearch.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _emojiSearchCtrl.clear();
                      setState(() => _emojiSearch = '');
                    },
                    child: Icon(
                      Icons.close,
                      color: isDark ? Colors.white38 : Colors.black38,
                      size: 16,
                    ),
                  )
                : null,
          ),

          if (!searching)
            SizedBox(
              height: labelH,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _categories[_selectedCategory].$2,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black45,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ),

          SizedBox(
            height: gridH,
            child: searching
                ? (emojis.isEmpty
                      ? Center(
                          child: Text(
                            'No results',
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          itemCount: emojis.length,
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => widget.onEmojiSelected(emojis[i]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(emojis[i], style: const TextStyle(fontSize: 26)),
                            ),
                          ),
                        ))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => widget.onEmojiSelected(emojis[i]),
                      child: Center(
                        child: Text(emojis[i], style: const TextStyle(fontSize: 23)),
                      ),
                    ),
                  ),
          ),

          SizedBox(
            height: chipsH,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: 6,
                right: 6,
                top: 4,
                bottom: navBarH > 0 ? navBarH : 4,
              ),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final sel = i == _selectedCategory && !searching;
                return GestureDetector(
                  onTap: () {
                    _emojiSearchCtrl.clear();
                    setState(() {
                      _emojiSearch = '';
                      _selectedCategory = i;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF1A7F4B).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: sel
                          ? Border.all(color: const Color(0xFF1A7F4B), width: 1.2)
                          : null,
                    ),
                    child: Text(_categories[i].$1, style: const TextStyle(fontSize: 17)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── GIF panel ─────────────────────────────────
  Widget _buildGifPanel(double totalH, double navBarH, bool isDark) {
    final gridH = (totalH - 38 - navBarH).clamp(80.0, 800.0);
    return Container(
      color: isDark ? const Color(0xFF1B1B1B) : const Color(0xFFFAF5F0),
      child: Column(
        children: [
          _searchBar(
            controller: _gifSearchCtrl,
            hint: 'Search GIFs',
            isDark: isDark,
            onChanged: (v) {
              setState(() {});
              _gifDebounce?.cancel();
              _gifDebounce = Timer(
                const Duration(milliseconds: 600),
                () => _fetchGifs(v),
              );
            },
            suffixIcon: _gifSearchCtrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _gifSearchCtrl.clear();
                      _fetchGifs('');
                      setState(() {});
                    },
                    child: Icon(
                      Icons.close,
                      color: isDark ? Colors.white38 : Colors.black38,
                      size: 16,
                    ),
                  )
                : null,
          ),
          SizedBox(
            height: gridH,
            child: _gifLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A7F4B),
                      strokeWidth: 2,
                    ),
                  )
                : _gifs.isEmpty
                ? Center(
                    child: Text(
                      'No GIFs found',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 13,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: _gifs.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => widget.onGifSelected(_gifs[i].url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _gifs[i].preview,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, p) {
                            if (p == null) return child;
                            return Container(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5EEE4),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  color: Color(0xFF1A7F4B),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5EEE4),
                            child: Icon(
                              Icons.gif,
                              color: isDark ? Colors.white38 : Colors.black38,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          SizedBox(height: navBarH),
        ],
      ),
    );
  }

  // ── Shared search bar ──────────────────────────
  Widget _searchBar({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required bool isDark,
    Widget? suffixIcon,
    bool autofocus = false,
  }) {
    return SizedBox(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 18,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5EEE4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ),
    );
  }
}

class _GifItem {
  final String url;
  final String preview;
  _GifItem({required this.url, required this.preview});
}

// ─────────────────────────────────────────────
// EMOJI DATA
// ─────────────────────────────────────────────
const _smileys = [
  '😀',
  '😃',
  '😄',
  '😁',
  '😆',
  '😅',
  '😂',
  '🤣',
  '🥲',
  '😊',
  '😇',
  '🙂',
  '🙃',
  '😉',
  '😌',
  '😍',
  '🥰',
  '😘',
  '😗',
  '😙',
  '😚',
  '😋',
  '😛',
  '😝',
  '😜',
  '🤪',
  '🤨',
  '🧐',
  '🤓',
  '😎',
  '🥸',
  '🤩',
  '🥳',
  '😏',
  '😒',
  '😞',
  '😔',
  '😟',
  '😕',
  '🙁',
  '☹️',
  '😣',
  '😖',
  '😫',
  '😩',
  '🥺',
  '😢',
  '😭',
  '😤',
  '😠',
  '😡',
  '🤬',
  '🤯',
  '😳',
  '🥵',
  '🥶',
  '😱',
  '😨',
  '😰',
  '😥',
  '😓',
  '🤗',
  '🤔',
  '🤭',
  '🤫',
  '🤥',
  '😶',
  '😐',
  '😑',
  '😬',
  '🙄',
  '😯',
  '😦',
  '😧',
  '😮',
  '😲',
  '🥱',
  '😴',
  '🤤',
  '😪',
  '😵',
  '🤐',
  '🥴',
  '🤢',
  '🤮',
  '🤧',
  '😷',
  '🤒',
  '🤕',
  '🤑',
  '🤠',
  '😈',
  '👿',
  '👹',
  '👺',
  '🤡',
  '💩',
  '👻',
  '💀',
  '☠️',
  '👽',
  '👾',
  '🤖',
  '🎃',
  '😺',
  '😸',
  '😹',
  '😻',
  '😼',
  '😽',
  '🙀',
  '😿',
  '😾',
];

const _people = [
  '👋',
  '🤚',
  '🖐️',
  '✋',
  '🖖',
  '👌',
  '🤌',
  '🤏',
  '✌️',
  '🤞',
  '🤟',
  '🤘',
  '🤙',
  '👈',
  '👉',
  '👆',
  '🖕',
  '👇',
  '☝️',
  '👍',
  '👎',
  '✊',
  '👊',
  '🤛',
  '🤜',
  '👏',
  '🙌',
  '👐',
  '🤲',
  '🤝',
  '🙏',
  '✍️',
  '💅',
  '🤳',
  '💪',
  '🦾',
  '🦿',
  '🦵',
  '🦶',
  '👂',
  '🦻',
  '👃',
  '🫀',
  '🫁',
  '🧠',
  '🦷',
  '🦴',
  '👀',
  '👁️',
  '👅',
  '👄',
  '💋',
  '👶',
  '🧒',
  '👦',
  '👧',
  '🧑',
  '👱',
  '👨',
  '🧔',
  '👩',
  '🧓',
  '👴',
  '👵',
  '🙍',
  '🙎',
  '🙅',
  '🙆',
  '💁',
  '🙋',
  '🧏',
  '🙇',
  '🤦',
  '🤷',
  '👮',
  '🕵️',
  '💂',
  '🥷',
  '👷',
  '🤴',
  '👸',
  '👳',
  '👲',
];

const _animals = [
  '🐶',
  '🐱',
  '🐭',
  '🐹',
  '🐰',
  '🦊',
  '🐻',
  '🐼',
  '🐨',
  '🐯',
  '🦁',
  '🐮',
  '🐷',
  '🐸',
  '🐵',
  '🙈',
  '🙉',
  '🙊',
  '🐔',
  '🐧',
  '🐦',
  '🐤',
  '🦆',
  '🦅',
  '🦉',
  '🦇',
  '🐺',
  '🐗',
  '🐴',
  '🦄',
  '🐝',
  '🐛',
  '🦋',
  '🐌',
  '🐞',
  '🐜',
  '🦟',
  '🦗',
  '🕷️',
  '🦂',
  '🐢',
  '🐍',
  '🦎',
  '🦖',
  '🦕',
  '🐙',
  '🦑',
  '🦐',
  '🦞',
  '🦀',
  '🐡',
  '🐠',
  '🐟',
  '🐬',
  '🐳',
  '🐋',
  '🦈',
  '🐊',
  '🐅',
  '🐆',
  '🦓',
  '🦍',
  '🦣',
  '🐘',
  '🦛',
  '🦏',
  '🐪',
  '🐫',
  '🦒',
];

const _food = [
  '🍎',
  '🍊',
  '🍋',
  '🍌',
  '🍍',
  '🥭',
  '🍓',
  '🫐',
  '🍈',
  '🍒',
  '🍑',
  '🥝',
  '🍅',
  '🥑',
  '🍆',
  '🥔',
  '🥕',
  '🌽',
  '🌶️',
  '🥒',
  '🥬',
  '🥦',
  '🧄',
  '🧅',
  '🍄',
  '🥜',
  '🌰',
  '🍞',
  '🥐',
  '🥖',
  '🫓',
  '🥨',
  '🥯',
  '🧀',
  '🥚',
  '🍳',
  '🧈',
  '🥞',
  '🧇',
  '🥓',
  '🥩',
  '🍗',
  '🍖',
  '🌭',
  '🍔',
  '🍟',
  '🍕',
  '🌮',
  '🌯',
  '🍜',
  '🍝',
  '🍛',
  '🍲',
  '🍣',
  '🍱',
  '🥟',
  '🍤',
  '🍙',
  '🍚',
  '🍘',
  '🍥',
  '🥮',
  '🍢',
  '🧁',
  '🍰',
  '🎂',
  '🍮',
  '🍭',
  '🍬',
  '🍫',
  '🍿',
  '🍩',
  '🍪',
  '☕',
  '🍵',
  '🧋',
  '🍺',
  '🍻',
  '🥂',
  '🍷',
  '🥤',
];

const _travel = [
  '🚗',
  '🚕',
  '🚙',
  '🚌',
  '🚎',
  '🏎️',
  '🚓',
  '🚑',
  '🚒',
  '🚐',
  '🛻',
  '🚚',
  '🚛',
  '🚜',
  '🛵',
  '🏍️',
  '🚲',
  '🛴',
  '🛹',
  '⛵',
  '🚤',
  '🛥️',
  '🛳️',
  '🚢',
  '✈️',
  '🛩️',
  '🛫',
  '🛬',
  '🪂',
  '💺',
  '🚁',
  '🚀',
  '🛸',
  '🏖️',
  '🏝️',
  '🏜️',
  '🏔️',
  '🗻',
  '🏕️',
  '🏟️',
  '🏛️',
  '🏗️',
  '🏘️',
  '🏠',
  '🏡',
  '🏢',
  '🏣',
  '🏤',
  '🏥',
  '🏦',
  '🏨',
  '🏩',
  '🏪',
  '🏫',
  '🏬',
  '🏭',
  '🏯',
  '🏰',
  '💒',
  '🗼',
  '🗽',
  '⛪',
  '🕌',
  '🛕',
  '🕍',
  '⛩️',
  '🕋',
  '⛲',
];

const _activity = [
  '⚽',
  '🏀',
  '🏈',
  '⚾',
  '🥎',
  '🎾',
  '🏐',
  '🏉',
  '🥏',
  '🎱',
  '🪀',
  '🏓',
  '🏸',
  '🏒',
  '⛳',
  '🪁',
  '🏹',
  '🎣',
  '🤿',
  '🎽',
  '🎿',
  '🛷',
  '🥌',
  '🎯',
  '🪃',
  '🎮',
  '🎲',
  '♟️',
  '🎭',
  '🎨',
  '🎬',
  '🎤',
  '🎧',
  '🎼',
  '🎹',
  '🥁',
  '🎷',
  '🎺',
  '🎸',
  '🎻',
  '🏋️',
  '🤸',
  '🤼',
  '🤺',
  '🏇',
  '⛷️',
  '🏂',
  '🏊',
  '🤽',
  '🚣',
  '🧗',
  '🚴',
  '🏄',
  '🤾',
  '🏌️',
  '⛹️',
];

const _objects = [
  '📱',
  '💻',
  '⌨️',
  '🖥️',
  '🖨️',
  '🖱️',
  '💾',
  '💿',
  '📀',
  '📷',
  '📸',
  '📹',
  '🎥',
  '📽️',
  '📞',
  '☎️',
  '📺',
  '📻',
  '🧭',
  '⏱️',
  '⏰',
  '🕰️',
  '⌚',
  '⏳',
  '📡',
  '🔋',
  '🔌',
  '💡',
  '🔦',
  '🕯️',
  '🧯',
  '💸',
  '💵',
  '💰',
  '💳',
  '🔑',
  '🗝️',
  '🔐',
  '🔒',
  '🔓',
  '🔩',
  '🔧',
  '🔨',
  '⚒️',
  '🛠️',
  '🔗',
  '⛓️',
  '🧲',
  '🪜',
  '🧪',
  '🧫',
  '🧬',
  '🔭',
  '🔬',
  '🩺',
  '💊',
  '💉',
  '🩹',
  '🧴',
  '🧹',
  '🧺',
  '🪣',
  '🧻',
  '🚿',
  '🛁',
];

const _symbols = [
  '❤️',
  '🧡',
  '💛',
  '💚',
  '💙',
  '💜',
  '🖤',
  '🤍',
  '🤎',
  '💔',
  '❤️‍🔥',
  '❣️',
  '💕',
  '💞',
  '💓',
  '💗',
  '💖',
  '💘',
  '💝',
  '💟',
  '☮️',
  '✝️',
  '☪️',
  '🕉️',
  '✡️',
  '🔯',
  '☸️',
  '☯️',
  '🛐',
  '⛎',
  '♈',
  '♉',
  '♊',
  '♋',
  '♌',
  '♍',
  '♎',
  '♏',
  '♐',
  '♑',
  '♒',
  '♓',
  '🆔',
  '⚛️',
  '🉑',
  '☢️',
  '☣️',
  '📴',
  '📳',
  '🈶',
  '🈚',
  '🈸',
  '🈺',
  '🈷️',
  '✴️',
  '🆚',
  '💮',
  '🉐',
  '㊙️',
  '㊗️',
  '🈴',
  '🈵',
  '🈹',
  '🈲',
  '🅰️',
  '🅱️',
  '🆎',
  '🆑',
  '🅾️',
  '🆘',
  '❌',
  '⭕',
  '🛑',
  '⛔',
  '📛',
  '🚫',
  '💯',
  '✅',
  '❗',
  '❕',
  '❓',
  '❔',
  '‼️',
  '⁉️',
  '💤',
  '🔱',
  '⚜️',
  '🔰',
  '♻️',
  '🌐',
  '💠',
  '🌀',
  '🏧',
  '💹',
  '❎',
];
