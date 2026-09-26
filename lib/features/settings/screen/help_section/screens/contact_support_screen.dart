import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../../../utilities/components/buttons/custom_button_two.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';
import '../services/support_service.dart';

class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState
    extends ConsumerState<ContactSupportScreen> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final SupportService _supportService = SupportService();

  String _selectedCategory = 'Technical Issue';
  bool _isLoading = false;
  bool _isCategoryDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  static const List<String> _categories = [
    'Technical Issue',
    'Account Problem',
    'Billing & Payments',
    'Feature Request',
    'Privacy & Security',
    'Other',
  ];

  @override
  void dispose() {
    _removeOverlay();
    _subjectController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitSupport() async {
    if (_subjectController.text.trim().isEmpty) {
      _showSnackBar('Please enter a subject', isError: true);
      return;
    }
    
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackBar('Please enter a description', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _supportService.submitContactSupport(
        subject: _subjectController.text.trim(),
        message: _descriptionController.text.trim(),
        category: _selectedCategory,
      );
      
      _showSnackBar(message, isError: false);
      
      // Clear form on success
      _subjectController.clear();
      _descriptionController.clear();
      _emailController.clear();
      setState(() => _selectedCategory = 'Technical Issue');
      
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isCategoryDropdownOpen = false;
  }

  void _toggleCategoryDropdown(bool isDark, Color borderColor) {
    if (_isCategoryDropdownOpen) {
      _removeOverlay();
    } else {
      _overlayEntry = _createOverlayEntry(isDark, borderColor);
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isCategoryDropdownOpen = true);
    }
  }

  OverlayEntry _createOverlayEntry(bool isDark, Color borderColor) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          setState(() => _removeOverlay());
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: size.width - 32,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 56),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? const Color(0xFF2A2A2A) : AppTheme.scaffoldBg(isDark),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : AppTheme.scaffoldBg(isDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: borderColor,
                      ),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _removeOverlay();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.shade100)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final double topPadding = MediaQuery.of(context).padding.top + 10;

    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.25)
        : Colors.grey.shade300;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? HexColor('#3A1D07') : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark ? const DecorationImage(
                  image: AssetImage('images/app_bar_gredient.png'),
                  fit: BoxFit.cover,
                ) : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 22.0,
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Text(
                          'Contact Support',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Hero icon + heading ─────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              height: 44,
                              width: 44,
                              child: Image.asset(
                                'images/icons/streamline-flex_customer-support-5.png',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "We're Here to Help",
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Describe your issue and we'll get back to you",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.white.withOpacity(0.45)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Subject ─────────────────────────────────────────────
                  _fieldLabel('Subject', isDark),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _subjectController,
                    hintText: 'Brief description of your issue',
                    isDark: isDark,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 20),

                  // ── Category dropdown ───────────────────────────────────
                  _fieldLabel('Category', isDark),
                  const SizedBox(height: 8),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: _categoryDropdown(isDark: isDark, borderColor: borderColor),
                  ),
                  const SizedBox(height: 20),

                  // ── Description ─────────────────────────────────────────
                  _fieldLabel('Description', isDark),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _descriptionController,
                    hintText: 'Describe your issue in details.....',
                    isDark: isDark,
                    borderColor: borderColor,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),

                  // ── Email ───────────────────────────────────────────────
                  _fieldLabel('Email (Optional)', isDark),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _emailController,
                    hintText: 'your@email.com',
                    isDark: isDark,
                    borderColor: borderColor,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 28),

                  // ── Submit ──────────────────────────────────────────────
                  CustomButtonTwo(
                    title: 'Submit',
                    onClick: _submitSupport,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    required Color borderColor,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 1,
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
          ),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _categoryDropdown({required bool isDark, required Color borderColor}) {
    return GestureDetector(
      onTap: () => _toggleCategoryDropdown(isDark, borderColor),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCategory,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              _isCategoryDropdownOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
