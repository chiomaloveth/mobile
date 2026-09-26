import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:qik_talk/features/authentication/provider/user_provider.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../provider/change_phone_provider.dart';

class ChangePhoneNumberScreen extends ConsumerStatefulWidget {
  const ChangePhoneNumberScreen({super.key});

  @override
  ConsumerState<ChangePhoneNumberScreen> createState() =>
      _ChangePhoneNumberScreenState();
}

class _ChangePhoneNumberScreenState
    extends ConsumerState<ChangePhoneNumberScreen> {
  final _newPhoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _newPhoneController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  String get _otpValue =>
      _otpControllers.map((c) => c.text).join();

  void _clearOtp() {
    for (final c in _otpControllers) c.clear();
    if (_otpFocusNodes.isNotEmpty) {
      _otpFocusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePhoneProvider);
    final user = ref.watch(userProfileProvider);

    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);

    final Color bg = isDark
        ? const Color(0xFF0D0D0D)
        : const Color(0xFFFAF5F0);

    ref.listen<ChangePhoneState>(changePhoneProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      if (prev?.currentStep == ChangePhoneStep.enterPhone &&
          next.currentStep == ChangePhoneStep.enterOtp) {
        _startResendTimer();
      }
      if (next.currentStep == ChangePhoneStep.success) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            ref.read(changePhoneProvider.notifier).reset();
            Navigator.of(context).popUntil(
                (r) => r.isFirst || r.settings.name == '/settings');
          }
        });
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(AppColors.gradientColorsTwo),
                        Color(AppColors.gradientColorsOne),
                      ],
                    )
                  : null,
              color: isDark ? null : AppTheme.scaffoldBg(isDark),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark
                      ? Colors.white
                      : AppTheme.textPrimary(isDark),
                ),
                onPressed: () {
                  if (state.currentStep == ChangePhoneStep.enterOtp) {
                    ref
                        .read(changePhoneProvider.notifier)
                        .goBackToPhoneInput();
                    _clearOtp();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                state.currentStep == ChangePhoneStep.enterOtp
                    ? 'Verify Number'
                    : 'Change Number',
                style: GoogleFonts.poppins(
                  color: isDark
                      ? Colors.white
                      : AppTheme.textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(state, user, isDark),
        ),
      ),
    );
  }

  Widget _buildStep(
      ChangePhoneState state, UserProfile user, bool isDark) {
    switch (state.currentStep) {
      case ChangePhoneStep.enterPhone:
        return _EnterPhoneStep(
          key: const ValueKey('phone'),
          currentPhone: user.phoneNumber,
          newPhoneController: _newPhoneController,
          isLoading: state.isLoading,
          onContinue: () {
            final phone = _newPhoneController.text.trim();
            if (phone.isNotEmpty) {
              ref
                  .read(changePhoneProvider.notifier)
                  .requestOtp(phone);
            }
          },
          isDark: isDark,
          country: state.country,
          onCountrySelect: ref.read(changePhoneProvider.notifier).changeCountry,
        );
      case ChangePhoneStep.enterOtp:
        return _OtpStep(
          key: const ValueKey('otp'),
          phoneNumber: state.tempPhoneNumber ?? '',
          controllers: _otpControllers,
          focusNodes: _otpFocusNodes,
          isLoading: state.isLoading,
          resendSeconds: _resendSeconds,
          onVerify: () {
            final otp = _otpValue;
            if (otp.length == 6) {
              ref
                  .read(changePhoneProvider.notifier)
                  .verifyOtp(otp);
            }
          },
          onResend: _resendSeconds == 0
              ? () {
                  final phone = _newPhoneController.text.trim();
                  if (phone.isNotEmpty) {
                    ref
                        .read(changePhoneProvider.notifier)
                        .requestOtp(phone);
                    _clearOtp();
                  }
                }
              : null,
          isDark: isDark,
        );
      case ChangePhoneStep.success:
        return _SuccessStep(
            key: const ValueKey('success'), isDark: isDark);
    }
  }
}

// ── Step 1: Enter phone numbers ────────────────────────────────────────────
class _EnterPhoneStep extends StatefulWidget {
  final String currentPhone;
  final TextEditingController newPhoneController;
  final bool isLoading;
  final VoidCallback onContinue;
  final bool isDark;
  final Country country;
  final ValueChanged<Country> onCountrySelect;

  const _EnterPhoneStep({
    super.key,
    required this.currentPhone,
    required this.newPhoneController,
    required this.isLoading,
    required this.onContinue,
    required this.isDark,
    required this.country,
    required this.onCountrySelect,
  });

  @override
  State<_EnterPhoneStep> createState() => _EnterPhoneStepState();
}

class _EnterPhoneStepState extends State<_EnterPhoneStep> {
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    widget.newPhoneController.addListener(() {
      final has = widget.newPhoneController.text.trim().isNotEmpty;
      if (has != _hasInput) setState(() => _hasInput = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color fieldBg = widget.isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF5EEE4);
    final Color hintColor = widget.isDark
        ? const Color(0xFF636366)
        : const Color(0xFF6B6B6B);
    final Color labelColor = widget.isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF4A4A4A);
    final Color infoBg = widget.isDark
        ? const Color(0xFF0F1E2E)
        : const Color(0xFFE8DDD0);
    final Color infoTitle = widget.isDark
        ? const Color(0xFF4A9EFF)
        : const Color(0xFFFF8C00);
    final Color infoText = widget.isDark
        ? const Color(0xFF8BB8E8)
        : const Color(0xFF4A4A4A);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before you continue',
                  style: GoogleFonts.poppins(
                    color: infoTitle,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _bulletText(
                    'Your account info, groups, and settings will be transferred',
                    infoText),
                const SizedBox(height: 6),
                _bulletText(
                    'Your contacts will be notified about your new number',
                    infoText),
                const SizedBox(height: 6),
                _bulletText(
                    "You'll need to verify both numbers", infoText),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Current phone
          Text('Current Phone Number',
              style: GoogleFonts.poppins(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_outlined,
                    color: hintColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  widget.currentPhone.isNotEmpty
                      ? widget.currentPhone
                      : '+1 234 567 8900',
                  style: GoogleFonts.poppins(
                    color: widget.currentPhone.isNotEmpty
                        ? (widget.isDark
                            ? Colors.white
                            : const Color(0xFF1A1008))
                        : hintColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // New phone
          Text('New Phone Number',
              style: GoogleFonts.poppins(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: widget.onCountrySelect,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.country.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: widget.isDark ? Colors.white70 : Colors.black87,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${widget.country.phoneCode}',
                          style: GoogleFonts.poppins(
                            color: widget.isDark ? Colors.white70 : Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: widget.isDark ? Colors.white24 : Colors.black12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.newPhoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1A1008),
                        fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '803 348 9436',
                      hintStyle: GoogleFonts.poppins(
                          color: hintColor, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: _hasInput
                    ? LinearGradient(
                        colors: [
                          Color(AppColors.gradientColorsOne),
                          const Color(0xFF7A3A10),
                        ],
                      )
                    : null,
                color: _hasInput ? null : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _hasInput ? widget.onContinue : null,
                  child: Center(
                    child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              color: _hasInput
                                  ? Colors.white
                                  : (widget.isDark
                                      ? const Color(0xFF636366)
                                      : const Color(0xFF6B6B6B)),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletText(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ',
            style: GoogleFonts.poppins(color: color, fontSize: 13)),
        Expanded(
          child: Text(text,
              style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w400)),
        ),
      ],
    );
  }
}

// ── Step 2: OTP verification ───────────────────────────────────────────────
class _OtpStep extends StatefulWidget {
  final String phoneNumber;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isLoading;
  final int resendSeconds;
  final VoidCallback onVerify;
  final VoidCallback? onResend;
  final bool isDark;

  const _OtpStep({
    super.key,
    required this.phoneNumber,
    required this.controllers,
    required this.focusNodes,
    required this.isLoading,
    required this.resendSeconds,
    required this.onVerify,
    required this.onResend,
    required this.isDark,
  });

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  bool get _isFilled =>
      widget.controllers.every((c) => c.text.isNotEmpty);

  @override
  void initState() {
    super.initState();
    for (final c in widget.controllers) {
      c.addListener(_onOtpChanged);
    }
  }

  void _onOtpChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in widget.controllers) {
      c.removeListener(_onOtpChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color cardBg = widget.isDark
        ? const Color(0xFF141820)
        : const Color(0xFFF5EEE4);
    final Color boxBg = widget.isDark
        ? const Color(0xFF0F1520)
        : const Color(0xFFE8DDD0);
    final Color boxBorder = widget.isDark
        ? const Color(0xFF2A3550)
        : const Color(0xFFCFC4B5);
    final Color titleColor =
        widget.isDark ? Colors.white : const Color(0xFF1A1008);
    final Color subtitleColor = widget.isDark
        ? const Color(0xFF8A8A8E)
        : const Color(0xFF4A4A4A);
    final Color resendActiveColor = widget.isDark
        ? const Color(0xFFE8A020)
        : const Color(0xFFFF8C00);
    final Color resendInactiveColor = widget.isDark
        ? const Color(0xFF636366)
        : const Color(0xFF6B6B6B);

    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Verification Code',
                style: GoogleFonts.poppins(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: subtitleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // ── OTP boxes — responsive layout fix ─────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize =
                      (constraints.maxWidth - 60) / 6;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5),
                        child: SizedBox(
                          width: cellSize,
                          height: cellSize * 1.13,
                          child: _OtpBox(
                            controller: widget.controllers[i],
                            focusNode: widget.focusNodes[i],
                            boxBg: boxBg,
                            boxBorder: boxBorder,
                            isDark: widget.isDark,
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 5) {
                                widget.focusNodes[i + 1]
                                    .requestFocus();
                              }
                              if (val.isEmpty && i > 0) {
                                widget.focusNodes[i - 1]
                                    .requestFocus();
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: _isFilled
                        ? LinearGradient(
                            colors: [
                              Color(AppColors.gradientColorsOne),
                              const Color(0xFF7A3A10),
                            ],
                          )
                        : null,
                    color: _isFilled
                        ? null
                        : const Color(0xFF2C3550),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _isFilled ? widget.onVerify : null,
                      child: Center(
                        child: Text(
                                'Verify',
                                style: GoogleFonts.poppins(
                                  color: _isFilled
                                      ? Colors.white
                                      : (widget.isDark
                                          ? const Color(0xFF636366)
                                          : const Color(0xFF6B6B6B)),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Resend
              GestureDetector(
                onTap: widget.onResend,
                child: Text(
                  widget.resendSeconds > 0
                      ? 'Resend Code (${widget.resendSeconds}s)'
                      : 'Resend Code',
                  style: GoogleFonts.poppins(
                    color: widget.resendSeconds > 0
                        ? resendInactiveColor
                        : resendActiveColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

// ── Single OTP input box ───────────────────────────────────────────────────
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color boxBg;
  final Color boxBorder;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.boxBg,
    required this.boxBorder,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = widget.focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        color: widget.boxBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF4A7AFF)
              : widget.boxBorder,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.poppins(
          color: widget.isDark
              ? Colors.white
              : const Color(0xFF1A1008),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          setState(() {});
          widget.onChanged(val);
        },
      ),
    );
  }
}

// ── Step 3: Success ────────────────────────────────────────────────────────
class _SuccessStep extends StatefulWidget {
  final bool isDark;

  const _SuccessStep({super.key, required this.isDark});

  @override
  State<_SuccessStep> createState() => _SuccessStepState();
}

class _SuccessStepState extends State<_SuccessStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(
        parent: _animCtrl, curve: Curves.elasticOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(AppColors.gradientColorsOne),
                    const Color(0xFF7A3A10),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 46,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Number Changed!',
            style: GoogleFonts.poppins(
              color: widget.isDark
                  ? Colors.white
                  : const Color(0xFF1A1008),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your phone number has been updated\nsuccessfully',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: widget.isDark
                  ? Colors.white70
                  : const Color(0xFF4A4A4A),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Redirecting to settings...',
            style: GoogleFonts.poppins(
              color: widget.isDark
                  ? const Color(0xFF636366)
                  : const Color(0xFF6B6B6B),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}