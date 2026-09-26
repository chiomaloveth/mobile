import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconly/iconly.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../utilities/components/buttons/custom_button_two.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/constants/app_theme.dart';
import '../../../theme/provider/theme_provider.dart';
import '../services/support_service.dart';

class ReportABugScreen extends ConsumerStatefulWidget {
  const ReportABugScreen({super.key});

  @override
  ConsumerState<ReportABugScreen> createState() => _ReportABugScreenState();
}

class _ReportABugScreenState extends ConsumerState<ReportABugScreen> {
  final _bugTitleController = TextEditingController();
  final _expectedController = TextEditingController();
  final _actualController = TextEditingController();
  final SupportService _supportService = SupportService();

  String _selectedSeverity = 'Low - minor inconvenience';
  bool _isLoading = false;
  bool _isSeverityDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  
  String _deviceInfo = 'Loading device info...';
  String _appVersion = 'Loading app version...';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  static const List<String> _severityOptions = [
    'Low - minor inconvenience',
    'Medium - Affect functionality',
    'High - Major feature broken',
    'Critical - App crashes / data loss',
  ];

  @override
  void dispose() {
    _removeOverlay();
    _bugTitleController.dispose();
    _expectedController.dispose();
    _actualController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      String deviceDetails = '';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceDetails = 'Android ${androidInfo.version.release} (${androidInfo.model})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceDetails = 'iOS ${iosInfo.systemVersion} (${iosInfo.model})';
      }
      
      setState(() {
        _deviceInfo = deviceDetails;
        _appVersion = '${packageInfo.version} (Build ${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _deviceInfo = 'Unable to get device info';
        _appVersion = 'Unable to get app version';
      });
    }
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

  Future<void> _submitBugReport() async {
    if (_bugTitleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a bug title', isError: true);
      return;
    }
    
    if (_expectedController.text.trim().isEmpty) {
      _showSnackBar('Please describe the expected behavior', isError: true);
      return;
    }
    
    if (_actualController.text.trim().isEmpty) {
      _showSnackBar('Please describe the actual behavior', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _supportService.submitBugReport(
        title: _bugTitleController.text.trim(),
        description: 'Severity: $_selectedSeverity',
        stepsToReproduce: 'User reported bug via mobile app',
        expectedBehavior: _expectedController.text.trim(),
        actualBehavior: _actualController.text.trim(),
        deviceInfo: _deviceInfo,
        appVersion: _appVersion,
      );
      
      _showSnackBar(message, isError: false);
      
      // Clear form on success
      _bugTitleController.clear();
      _expectedController.clear();
      _actualController.clear();
      setState(() => _selectedSeverity = 'Low - minor inconvenience');
      
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isSeverityDropdownOpen = false;
  }

  void _toggleSeverityDropdown(bool isDark, Color borderColor) {
    if (_isSeverityDropdownOpen) {
      _removeOverlay();
    } else {
      _overlayEntry = _createOverlayEntry(isDark, borderColor);
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isSeverityDropdownOpen = true);
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
                    constraints: const BoxConstraints(maxHeight: 200),
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
                      itemCount: _severityOptions.length,
                      itemBuilder: (context, index) {
                        final option = _severityOptions[index];
                        final isSelected = option == _selectedSeverity;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSeverity = option;
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
                              option,
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
                          'Report a Bug',
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
                            color: Colors.red.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              height: 44,
                              width: 44,
                              child: Image.asset(
                                'images/icons/bug_icon.png',
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Help Us Fix It',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Provide details about the bug you encountered',
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

                  // ── Bug Title ───────────────────────────────────────────
                  _fieldLabel('Bug Title', isDark, required: true),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _bugTitleController,
                    hintText: 'Brief description of the bug',
                    isDark: isDark,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 20),

                  // ── Severity dropdown ───────────────────────────────────
                  _fieldLabel('Severity', isDark, required: true),
                  const SizedBox(height: 8),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: _severityDropdown(isDark: isDark, borderColor: borderColor),
                  ),
                  const SizedBox(height: 20),

                  // ── Expected Behavior ───────────────────────────────────
                  _fieldLabel('Expected Behavior', isDark, required: true),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _expectedController,
                    hintText: 'What should happen ?',
                    isDark: isDark,
                    borderColor: borderColor,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // ── Actual Behavior ─────────────────────────────────────
                  _fieldLabel('Actual Behavior', isDark, required: true),
                  const SizedBox(height: 8),
                  _textField(
                    controller: _actualController,
                    hintText: 'What actually happens ?',
                    isDark: isDark,
                    borderColor: borderColor,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // ── Screenshots ─────────────────────────────────────────
                  _fieldLabel('Screenshots (Optional)', isDark),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Image/video picker functionality coming soon
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('File attachment feature coming soon'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: borderColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconlyLight.upload,
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.grey,
                            size: 22,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload screenshot or screen recording',
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
                  ),
                  const SizedBox(height: 20),

                  // ── Device Information ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF313C42),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'images/icons/phone_icon.png',
                              color: Colors.white,
                              height: 18,
                              width: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Device Information',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _deviceInfoRow('Device: $_deviceInfo'),
                        _deviceInfoRow('App Version: $_appVersion'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Submit ──────────────────────────────────────────────
                  CustomButtonTwo(
                    title: 'Submit Bug Report',
                    onClick: _submitBugReport,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Your report helps us improve Qikchat for everyone. Thank you!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.grey,
                      ),
                    ),
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

  Widget _fieldLabel(String text, bool isDark, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    required Color borderColor,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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

  Widget _severityDropdown({
    required bool isDark,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: () => _toggleSeverityDropdown(isDark, borderColor),
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
                _selectedSeverity,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              _isSeverityDropdownOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.85),
        ),
      ),
    );
  }
}
