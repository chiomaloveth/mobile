import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  String _pin = "";
  static const int _pinLength = 5;
  bool _isKeypadVisible = false;

  void _onKeyPress(String key) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += key;
      });
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.4), // Dim background
        body: Stack(
          children: [
            // Dismissible background area
            GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            // Bottom Sheet Content
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212).withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom + 20,
                    ),
                    child: Stack(
                      children: [
                        // Inner Background Glow (16% opacity, 200 blur)
                        Positioned.fill(
                          child: Center(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 200,
                                sigmaY: 200,
                              ),
                              child: Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6900,
                                  ).withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Content
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Header(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Enter your security pin',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'We use state-of-the-art security measures to protect your information at all times',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    // PIN Indicator
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isKeypadVisible = true;
                                        });
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: _PinIndicator(
                                        pinLength: _pinLength,
                                        currentPin: _pin,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    // Confirm Button
                                    _ConfirmButton(
                                      isActive: _pin.length == _pinLength,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                              if (_isKeypadVisible)
                                _NumericKeypad(
                                  onKeyPress: _onKeyPress,
                                  onDelete: _onDelete,
                                ),
                            ],
                          ),
                        ),
                      ],
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
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _PinIndicator extends StatelessWidget {
  final int pinLength;
  final String currentPin;

  const _PinIndicator({required this.pinLength, required this.currentPin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(pinLength, (index) {
        final hasPin = index < currentPin.length;
        final isFocused = index == currentPin.length;

        return Container(
          width: 50,
          height: 60,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox.expand(),
              // Bottom underline (The "Dash")
              Positioned(
                bottom: 12,
                child: Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1A0B), Color(0xFF6A3710)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // PIN Dot
              if (hasPin)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              // Focused cursor bar
              if (isFocused)
                Container(
                  width: 2,
                  height: 24,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDelete;

  const _NumericKeypad({required this.onKeyPress, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', 'delete'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((key) {
                if (key == 'delete') {
                  return _KeyItem(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                }
                return _KeyItem(onTap: () => onKeyPress(key), text: key);
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyItem extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback onTap;

  const _KeyItem({this.text, this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        height: 50,
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool isActive;
  const _ConfirmButton({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isActive ? null : Colors.white.withValues(alpha: 0.1),
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFF2E1A0B), Color(0xFF6A3710)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        'Confirm PIN',
        style: GoogleFonts.inter(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
