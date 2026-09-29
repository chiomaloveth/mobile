import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

enum InteractionButtonMode { pill, raw }

class AnimatedInteractionButton extends StatefulWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;
  final InteractionButtonMode mode;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final String? svgAsset;
  final Color activeColor;
  final Color inactiveColor;
  final bool showBackground;
  final double? iconSize;

  const AnimatedInteractionButton({
    super.key,
    required this.isActive,
    required this.label,
    required this.onTap,
    this.activeIcon,
    this.inactiveIcon,
    this.svgAsset,
    required this.activeColor,
    required this.inactiveColor,
    this.mode = InteractionButtonMode.pill,
    this.showBackground = true,
    this.iconSize,
  }) : assert(svgAsset != null || (activeIcon != null && inactiveIcon != null));

  @override
  State<AnimatedInteractionButton> createState() =>
      _AnimatedInteractionButtonState();
}

class _AnimatedInteractionButtonState extends State<AnimatedInteractionButton> {
  double _scale = 1.0;

  @override
  void didUpdateWidget(AnimatedInteractionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulse();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Ensure we return to normal scale if unliked during pulse
      setState(() {
        _scale = 1.0;
      });
    }
  }

  void _pulse() {
    setState(() {
      _scale = 1.4;
    });
    // Return to original scale after a short burst
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? widget.activeColor : widget.inactiveColor;
    final icon = widget.isActive ? widget.activeIcon : widget.inactiveIcon;

    if (widget.mode == InteractionButtonMode.pill) {
      return GestureDetector(
        onTap: () {
          _pulse();
          widget.onTap();
        },
        child: Container(
          width: 82,
          height: 29,
          decoration: BoxDecoration(
            color: HexColor("#434141"),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedIcon(color, icon, isPill: true),
              if (widget.label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(color: color, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      // Raw mode for QikFlash-style sidebar
      return GestureDetector(
        onTap: () {
          _pulse();
          widget.onTap();
        },
        child: Column(
          children: [
            if (widget.showBackground)
              Center(child: _buildAnimatedIcon(color, icon))
            else
              _buildAnimatedIcon(color, icon),
            const SizedBox(height: 5),
            if (widget.label.isNotEmpty)
              Center(
                child: Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildAnimatedIcon(
    Color color,
    IconData? icon, {
    bool isPill = false,
  }) {
    final double defaultSize = isPill ? 25 : (widget.iconSize ?? 28);

    return AnimatedScale(
      scale: _scale,
      duration: Duration(milliseconds: _scale == 1.4 ? 100 : 250),
      curve: _scale == 1.4 ? Curves.easeOutBack : Curves.easeOutCubic,
      child: widget.svgAsset != null
          ? SvgPicture.asset(
              widget.svgAsset!,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: defaultSize,
              height: defaultSize,
            )
          : (icon != null
                ? Icon(icon, color: color, size: defaultSize)
                : const SizedBox.shrink()),
    );
  }
}
