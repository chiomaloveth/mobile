import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

class AddLinkScreen extends StatefulWidget {
  const AddLinkScreen({super.key});

  @override
  State<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedPlatform = 'Website';
  final List<String> _platforms = ['Instagram', 'YouTube', 'Website'];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.iconColor(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Link',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_urlController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'url': _urlController.text,
                  'title': _selectedPlatform,
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                color: const Color(0xFFA26743),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildPlatformSelector(),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'URL',
              controller: _urlController,
              hintText: 'Enter URL',
              showClearButton: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformSelector() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform',
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border(isDark)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPlatform,
              dropdownColor: AppTheme.popupBg(isDark),
              icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.iconColorSubtle(isDark)),
              isExpanded: true,
              style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark)),
              items: _platforms.map((String platform) {
                return DropdownMenuItem<String>(
                  value: platform,
                  child: Text(platform),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPlatform = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool showClearButton = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border(isDark)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary(isDark)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(color: AppTheme.textHint(isDark)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              suffixIcon: (showClearButton && controller.text.isNotEmpty)
                  ? IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: AppTheme.iconColorSubtle(isDark),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              if (showClearButton) setState(() {});
            },
          ),
        ),
      ],
    );
  }
}
