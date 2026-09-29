import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'add_link_screen.dart';
import 'edit_link_screen.dart';

class LinksScreen extends ConsumerStatefulWidget {
  final List<Map<String, String>> initialLinks;

  const LinksScreen({super.key, this.initialLinks = const []});

  @override
  ConsumerState<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends ConsumerState<LinksScreen> {
  late List<Map<String, String>> _links;

  @override
  void initState() {
    super.initState();
    _links = List.from(widget.initialLinks);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
          onPressed: () => Navigator.pop(context, _links),
        ),
        title: Text(
          'Links',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _links.isEmpty ? _buildEmptyState() : _buildLinksList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          _buildAddLinkButton(),
          const SizedBox(height: 20),
          Text(
            'Your links are visible to everyone on and off QikTalk.',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Learn more',
              style: GoogleFonts.poppins(
                color: const Color(0xFFA26743),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          if (_links.length < 3) _buildAddLinkButton(),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.separated(
              itemCount: _links.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final link = _links[index];
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditLinkScreenV2(
                          index: index,
                          initialUrl: link['url'],
                          initialTitle: link['title'],
                        ),
                      ),
                    );
                    if (result != null) {
                      if (result is Map<String, String>) {
                        // Check if changing platform to one that already exists (other than itself)
                        final newTitle = result['title'];
                        final isDuplicate = _links.asMap().entries.any(
                          (entry) =>
                              entry.key != index &&
                              entry.value['title'] == newTitle,
                        );

                        if (isDuplicate) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'You already have a $newTitle link.',
                                ),
                              ),
                            );
                          }
                          return;
                        }

                        setState(() {
                          _links[index] = result;
                        });
                      } else if (result == 'remove') {
                        setState(() {
                          _links.removeAt(index);
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.white70, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                link['title'] ?? 'No Title',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                link['url'] ?? '',
                                style: GoogleFonts.poppins(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your links are visible to everyone on and off QikTalk.',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Learn more',
              style: GoogleFonts.poppins(
                color: const Color(0xFFA26743),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddLinkButton() {
    final themeMode = ref.watch(themeProvider);
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);
        
    return GestureDetector(
      onTap: () async {
        if (_links.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can add a maximum of 3 links.')),
          );
          return;
        }

        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddLinkScreen()),
        );

        if (result != null && result is Map<String, String>) {
          final newTitle = result['title'];
          final isDuplicate = _links.any((l) => l['title'] == newTitle);

          if (isDuplicate) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You already have a $newTitle link.')),
              );
            }
            return;
          }

          setState(() {
            _links.add(result);
          });
        }
      },
      child: Row(
        children: [
          Icon(Icons.add, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 24),
          const SizedBox(width: 12),
          Text(
            'Add Link',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
