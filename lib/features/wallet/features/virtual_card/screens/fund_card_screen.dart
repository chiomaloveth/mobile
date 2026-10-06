import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../../../../utilities/components/buttons/gradient_flow_button.dart';
import '../../../../../utilities/constants/app_colors.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class FundCardScreen extends ConsumerStatefulWidget {
  const FundCardScreen({super.key});

  @override
  ConsumerState<FundCardScreen> createState() => _FundCardScreenState();
}

class _FundCardScreenState extends ConsumerState<FundCardScreen> {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);

    final backgroundColor = isDark
        ? Color(AppColors.primaryBackgroundColor)
        : AppTheme.scaffoldBg(isDark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimary(isDark)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Fund Card',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              fontSize: 16,
            ),
          ),
          titleSpacing: 0,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const FundCardPreview(),
                const SizedBox(height: 32),

                const Text(
                  'Amount to Add',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const AmountInputField(),
                const SizedBox(height: 32),

                const Text(
                  'Quick Amounts',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                const QuickAmountsGrid(),

                const SizedBox(height: 60),

                GradientGlowButton(text: 'Fund Card', onClick: () {},),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class FundCardPreview extends StatelessWidget {
  const FundCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CenteredNotchClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.cardOrangeTop,
              AppColors.cardOrangeBottom,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'MASTERCARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            Text(
              '5399 8312 4567 8901',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '₦50,000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

class AmountInputField extends StatelessWidget {
  const AmountInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        style: const TextStyle(
          color: AppColors.orangeText,
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixText: '₦  ',
          prefixStyle: TextStyle(
            color: AppColors.orangeText,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          hintText: '0.00',
          hintStyle: TextStyle(
            color: AppColors.orangeText,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class QuickAmountsGrid extends StatelessWidget {
  const QuickAmountsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildChip('₦ 1,000')),
            const SizedBox(width: 12),
            Expanded(child: _buildChip('₦ 2,000')),
            const SizedBox(width: 12),
            Expanded(child: _buildChip('₦ 5,000')),
            const SizedBox(width: 12),
            Expanded(child: _buildChip('₦ 10,000')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildChip('₦ 20,000')),
            const SizedBox(width: 12),
            Expanded(child: _buildChip('₦ 50,000')),
            const SizedBox(width: 12),
            Expanded(child: _buildChip('₦ 70,000')),
            const SizedBox(width: 12),
            Expanded(child: _buildChip('₦ 100,000')),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String text) {
    return Builder(
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.chipBg : AppTheme.cardBg(isDark),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        );
      },
    );
  }
}



class CenteredNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double radius = 12.0;
    const double cutoutRadius = 8.0;
    final double cutoutY = size.height / 2;

    path.moveTo(0, radius);
    path.arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius));

    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));

    path.lineTo(size.width, cutoutY - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, cutoutY + cutoutRadius),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius));

    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius), radius: const Radius.circular(radius));

    path.lineTo(0, cutoutY + cutoutRadius);
    path.arcToPoint(
      Offset(0, cutoutY - cutoutRadius),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}