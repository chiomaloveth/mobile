import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../settings/theme/provider/theme_provider.dart';

class WalletAnimatedBalance extends ConsumerStatefulWidget {
  final double balance;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isVisible;

  const WalletAnimatedBalance({super.key, required this.balance, required this.isVisible, this.fontSize, this.fontWeight});

  @override
  ConsumerState<WalletAnimatedBalance> createState() => _WalletAnimatedBalanceState();
}

class _WalletAnimatedBalanceState extends ConsumerState<WalletAnimatedBalance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldBalance = 0;

  final NumberFormat _formatter = NumberFormat("#,##0.00");

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(
      begin: _oldBalance,
      end: widget.balance,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WalletAnimatedBalance oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.balance != widget.balance) {
      _oldBalance = oldWidget.balance;

      _animation = Tween<double>(
        begin: _oldBalance,
        end: widget.balance,
      ).animate(_controller);

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);
    return Text(
      widget.isVisible ? "₦${_formatter.format(_animation.value)}" : "****.**",
      style: TextStyle(
        fontSize: widget.fontSize ?? 25,
        color: isDark ? Colors.white : null,
        fontWeight: widget.fontWeight ?? null
      ),
    );
  }
}