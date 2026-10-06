import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../settings/theme/provider/theme_provider.dart';

class CreateVirtualCardScreen extends ConsumerStatefulWidget {
  const CreateVirtualCardScreen({super.key});

  @override
  ConsumerState<CreateVirtualCardScreen> createState() => _CreateVirtualCardScreenState();
}

class _CreateVirtualCardScreenState extends ConsumerState<CreateVirtualCardScreen> {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;

    final bool isDark =
        currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);

    final backgroundColor =  isDark
        ? Color(AppColors.primaryBackgroundColor)
        : Colors.white;

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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {},
          ),
          title: const Text(
            'Create Virtual Card',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          titleSpacing: 0,
        ),
        body: const SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  VirtualCardPreview(),
                  SizedBox(height: 32),

                  Text(
                    'Card Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  CardTypeSelector(),
                  SizedBox(height: 24),

                  Text(
                    'Initial Funding Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  FundingInput(),
                  SizedBox(height: 32),

                  CardBenefitsBox(),
                  SizedBox(height: 48),

                  CreateCardButton(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VirtualCardPreview extends StatelessWidget {
  const VirtualCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CenteredNotchClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.cardOrangeTop, AppColors.cardOrangeBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
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
            const SizedBox(height: 32),

            const Row(
              children: [
                _DotGroup(),
                SizedBox(width: 16),
                _DotGroup(),
                SizedBox(width: 16),
                _DotGroup(),
                SizedBox(width: 16),
                _DotGroup(),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDataColumn('Balance', '₦0.00'),
                _buildDataColumn(
                  'Expires',
                  '12/28',
                  alignment: CrossAxisAlignment.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataColumn(
    String label,
    String value, {
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DotGroup extends StatelessWidget {
  const _DotGroup();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '••••',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        letterSpacing: 2.0,
        height: 0.5,
      ),
    );
  }
}

class CardTypeSelector extends StatelessWidget {
  const CardTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD94A00).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD94A00).withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Mastercard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Visa',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FundingInput extends StatelessWidget {
  const FundingInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 18),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '₦',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: '0.00',
              hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Minimum ₦ 1,000',
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class CardBenefitsBox extends StatelessWidget {
  const CardBenefitsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderPink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Benefits:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Shop online worldwide'),
          const SizedBox(height: 8),
          _buildBulletPoint('Secure and disposable'),
          const SizedBox(height: 8),
          _buildBulletPoint('Instant creation'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4.0, right: 8.0),
          child: Icon(Icons.circle, color: Colors.white, size: 4),
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class CreateCardButton extends StatelessWidget {
  const CreateCardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.btnGradStart, AppColors.btnGradEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),

        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.btnGradStart, AppColors.btnGradEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(1.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(
                14.5,
              ),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.5),
                ),
              ),
              child: const Text(
                'Create Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
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
    path.arcToPoint(
      const Offset(radius, 0),
      radius: const Radius.circular(radius),
    );

    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );

    path.lineTo(size.width, cutoutY - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, cutoutY + cutoutRadius),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
    );
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
