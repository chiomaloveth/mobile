import 'dart:async';
import 'package:flutter/material.dart';

class IncomingVehicleBanner extends StatefulWidget {
  const IncomingVehicleBanner({super.key});

  @override
  State<IncomingVehicleBanner> createState() => _IncomingVehicleBannerState();
}

class _IncomingVehicleBannerState extends State<IncomingVehicleBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    ));

    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    if (!mounted) return;
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    _controller.duration = const Duration(milliseconds: 800);
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1612),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white10, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Incoming Vehicle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Your container has landed',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '₦100,000',
                        style: TextStyle(
                          color: Color(0xFFF38A1D),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'From: ',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          children: const [
                            TextSpan(
                              text: 'Odogwu Hilary',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  "images/garage_arrival.png",
                  height: 60,
                  errorBuilder: (context, _, __) => const Icon(
                    Icons.local_shipping,
                    color: Color(0xFFF38A1D),
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}