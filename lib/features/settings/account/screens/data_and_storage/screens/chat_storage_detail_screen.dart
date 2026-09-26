import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../../../theme/provider/theme_provider.dart';

// ── Chat storage entry model ───────────────────────────────────────────────
class ChatStorageEntry {
  final String id;
  final String name;
  final int sizeBytes;

  const ChatStorageEntry({
    required this.id,
    required this.name,
    required this.sizeBytes,
  });

  String get formattedSize {
    if (sizeBytes >= 1048576) return '${(sizeBytes / 1048576).toStringAsFixed(1)} MB';
    if (sizeBytes >= 1024) return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    return '$sizeBytes B';
  }
}

// ── Media item model ───────────────────────────────────────────────────────
enum MediaType { photo, video, audio, document }

class MediaItem {
  final String id;
  final MediaType type;
  final String? thumbnailUrl;
  final int sizeBytes;

  const MediaItem({
    required this.id,
    required this.type,
    this.thumbnailUrl,
    required this.sizeBytes,
  });

  String get formattedSize {
    if (sizeBytes >= 1048576) return '${(sizeBytes / 1048576).toStringAsFixed(1)} MB';
    if (sizeBytes >= 1024) return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    return '$sizeBytes B';
  }
}

// ── Filter tab model ───────────────────────────────────────────────────────
class _FilterTab {
  final String label;
  final IconData icon;
  final int itemCount;
  final int sizeBytes;
  final MediaType? type; // null = All

  const _FilterTab({
    required this.label,
    required this.icon,
    required this.itemCount,
    required this.sizeBytes,
    this.type,
  });

  String get formattedSize {
    if (sizeBytes >= 1048576) return '${(sizeBytes / 1048576).toStringAsFixed(0)} MB';
    if (sizeBytes >= 1024) return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    return '$sizeBytes B';
  }
}

// ── State ──────────────────────────────────────────────────────────────────
class _DetailState {
  final int selectedTabIndex;
  final Set<String> selectedIds;
  final List<MediaItem> items;

  const _DetailState({
    this.selectedTabIndex = 0,
    this.selectedIds = const {},
    required this.items,
  });

  bool get isSelecting => selectedIds.isNotEmpty;

  _DetailState copyWith({
    int? selectedTabIndex,
    Set<String>? selectedIds,
    List<MediaItem>? items,
  }) {
    return _DetailState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedIds: selectedIds ?? this.selectedIds,
      items: items ?? this.items,
    );
  }
}

class _DetailNotifier extends StateNotifier<_DetailState> {
  _DetailNotifier(List<MediaItem> items) : super(_DetailState(items: items));

  void selectTab(int index) {
    state = state.copyWith(selectedTabIndex: index, selectedIds: {});
  }

  void toggleSelect(String id) {
    final newSet = Set<String>.from(state.selectedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    state = state.copyWith(selectedIds: newSet);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  void deleteSelected() {
    final remaining = state.items.where((i) => !state.selectedIds.contains(i.id)).toList();
    state = state.copyWith(items: remaining, selectedIds: {});
  }
}

final _detailProvider = StateNotifierProvider.family<_DetailNotifier, _DetailState, String>(
  (ref, chatId) {
    // Mock media items
    final items = List.generate(15, (i) {
      final type = i % 5 == 0
          ? MediaType.video
          : i % 7 == 0
              ? MediaType.audio
              : i % 9 == 0
                  ? MediaType.document
                  : MediaType.photo;
      return MediaItem(
        id: 'item_$i',
        type: type,
        thumbnailUrl: type == MediaType.photo || type == MediaType.video
            ? 'https://picsum.photos/seed/${chatId}_$i/200/200'
            : null,
        sizeBytes: (i + 1) * 1048576 + (i * 204800),
      );
    });
    return _DetailNotifier(items);
  },
);

// ── Screen ─────────────────────────────────────────────────────────────────
class ChatStorageDetailScreen extends ConsumerWidget {
  final ChatStorageEntry entry;

  const ChatStorageDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_detailProvider(entry.id));
    final notifier = ref.read(_detailProvider(entry.id).notifier);

    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    final Color bg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF5F0);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;
    final Color dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.07) : Colors.grey.withValues(alpha: 0.2);
    final Color tabBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0);
    final Color selectedTabBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    // Build filter tabs
    final allItems = state.items;
    final photos = allItems.where((i) => i.type == MediaType.photo).toList();
    final videos = allItems.where((i) => i.type == MediaType.video).toList();
    final audios = allItems.where((i) => i.type == MediaType.audio).toList();
    final docs = allItems.where((i) => i.type == MediaType.document).toList();

    int sumBytes(List<MediaItem> list) => list.fold(0, (s, i) => s + i.sizeBytes);

    final tabs = [
      _FilterTab(label: 'All', icon: Icons.description_outlined, itemCount: allItems.length, sizeBytes: sumBytes(allItems), type: null),
      _FilterTab(label: 'Photos', icon: Icons.image_outlined, itemCount: photos.length, sizeBytes: sumBytes(photos), type: MediaType.photo),
      _FilterTab(label: 'Videos', icon: Icons.videocam_outlined, itemCount: videos.length, sizeBytes: sumBytes(videos), type: MediaType.video),
      _FilterTab(label: 'Audio', icon: Icons.music_note_outlined, itemCount: audios.length, sizeBytes: sumBytes(audios), type: MediaType.audio),
      _FilterTab(label: 'Documents', icon: Icons.description_outlined, itemCount: docs.length, sizeBytes: sumBytes(docs), type: MediaType.document),
    ];

    // Filtered items for grid
    final activeTab = tabs[state.selectedTabIndex];
    final filteredItems = activeTab.type == null
        ? allItems
        : allItems.where((i) => i.type == activeTab.type).toList();

    // Visible items: show first 8 in collapsed, all in expanded
    const int previewCount = 8;
    final showMore = filteredItems.length > previewCount;
    final visibleItems = filteredItems.take(previewCount).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(AppColors.gradientColorsTwo),
                  Color(AppColors.gradientColorsOne),
                ],
              ) : null,
              color: isDark ? null : const Color(0xFFFAF5F0),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1A1008)),
                onPressed: () {
                  if (state.isSelecting) {
                    notifier.clearSelection();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.name,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.formattedSize,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                if (state.isSelecting)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 26),
                    onPressed: () => _showDeleteDialog(context, notifier),
                  ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  'REVIEW & FREE UP SPACE',
                  style: GoogleFonts.poppins(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Filter tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: tabBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(tabs.length, (i) {
                    final tab = tabs[i];
                    final isSelected = state.selectedTabIndex == i;
                    return _FilterTabRow(
                      tab: tab,
                      isSelected: isSelected,
                      isLast: i == tabs.length - 1,
                      selectedTabBg: selectedTabBg,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      dividerColor: dividerColor,
                      onTap: () => notifier.selectTab(i),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Media grid
              if (filteredItems.isNotEmpty)
                _MediaGrid(
                  items: visibleItems,
                  allItems: filteredItems,
                  showMore: showMore,
                  selectedIds: state.selectedIds,
                  isSelecting: state.isSelecting,
                  onToggle: notifier.toggleSelect,
                  onShowMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _FullMediaGridScreen(
                          entry: entry,
                          items: filteredItems,
                          isDark: isDark,
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, _DetailNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(
        onDelete: () {
          notifier.deleteSelected();
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

// ── Filter tab row ─────────────────────────────────────────────────────────
class _FilterTabRow extends StatelessWidget {
  final _FilterTab tab;
  final bool isSelected;
  final bool isLast;
  final Color selectedTabBg;
  final Color textColor;
  final Color subTextColor;
  final Color dividerColor;
  final VoidCallback onTap;

  const _FilterTabRow({
    required this.tab,
    required this.isSelected,
    required this.isLast,
    required this.selectedTabBg,
    required this.textColor,
    required this.subTextColor,
    required this.dividerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? selectedTabBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(tab.icon, color: textColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tab.label,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${tab.itemCount} items',
                        style: GoogleFonts.poppins(
                          color: subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  tab.formattedSize,
                  style: GoogleFonts.poppins(
                    color: subTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: subTextColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(height: 0.5, color: dividerColor, margin: const EdgeInsets.symmetric(horizontal: 14)),
      ],
    );
  }
}

// ── Media grid (preview, 3 columns, max 8 + "More") ───────────────────────
class _MediaGrid extends StatelessWidget {
  final List<MediaItem> items;
  final List<MediaItem> allItems;
  final bool showMore;
  final Set<String> selectedIds;
  final bool isSelecting;
  final void Function(String) onToggle;
  final VoidCallback onShowMore;

  const _MediaGrid({
    required this.items,
    required this.allItems,
    required this.showMore,
    required this.selectedIds,
    required this.isSelecting,
    required this.onToggle,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    final double itemSize = (MediaQuery.of(context).size.width - 6) / 3;

    // Build grid cells: items + optional "More" cell
    final cells = <Widget>[];
    for (final item in items) {
      cells.add(_MediaCell(
        item: item,
        size: itemSize,
        isSelected: selectedIds.contains(item.id),
        isSelecting: isSelecting,
        onTap: () => onToggle(item.id),
        onLongPress: () => onToggle(item.id),
      ));
    }
    if (showMore) {
      cells.add(_MoreCell(size: itemSize, onTap: onShowMore));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: cells,
      ),
    );
  }
}

class _MediaCell extends StatelessWidget {
  final MediaItem item;
  final double size;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _MediaCell({
    required this.item,
    required this.size,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail or placeholder
            _buildThumbnail(),

            // Video play icon overlay
            if (item.type == MediaType.video)
              Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
                ),
              ),

            // Size label
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.formattedSize,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Selection overlay
            if (isSelecting)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),

            // Dark overlay when selected
            if (isSelected)
              Container(color: Colors.black.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (item.thumbnailUrl != null) {
      return Image.network(
        item.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Icon(
        item.type == MediaType.audio
            ? Icons.music_note
            : item.type == MediaType.document
                ? Icons.description
                : Icons.image,
        color: Colors.white30,
        size: 32,
      ),
    );
  }
}

class _MoreCell extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const _MoreCell({required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Container(
          color: const Color(0xFF1E1E1E),
          child: Center(
            child: Text(
              'More',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Delete confirmation dialog ─────────────────────────────────────────────
class _DeleteDialog extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _DeleteDialog({required this.onDelete, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBg = AppTheme.cardBg(isDark);
    final Color textPrimary = AppTheme.textPrimary(isDark);
    final Color textSecondary = AppTheme.textSecondary(isDark);
    final Color cancelBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8DDD0);

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onCancel,
                child: Icon(Icons.close, color: textSecondary, size: 22),
              ),
            ),
            const SizedBox(height: 8),
            // Trash icon circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Item?',
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This item will be deleted from your QikTalk media, but it may still be saved on your device.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: cancelBg,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full media grid screen (when "More" is tapped) ─────────────────────────
class _FullMediaGridScreen extends StatelessWidget {
  final ChatStorageEntry entry;
  final List<MediaItem> items;
  final bool isDark;

  const _FullMediaGridScreen({
    required this.entry,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isDark ? const Color(0xFF141414) : const Color(0xFFFAF5F0);
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(AppColors.gradientColorsTwo),
                  Color(AppColors.gradientColorsOne),
                ],
              ) : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.name,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.formattedSize,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : AppTheme.textSecondary(isDark),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Text(
                'REVIEW & FREE UP SPACE',
                style: GoogleFonts.poppins(
                  color: subTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _MediaCell(
                    item: item,
                    size: (MediaQuery.of(context).size.width - 6) / 3,
                    isSelected: false,
                    isSelecting: false,
                    onTap: () {},
                    onLongPress: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
