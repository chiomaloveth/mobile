import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/wallet/features/virtual_card/screens/fund_card_screen.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../settings/theme/provider/theme_provider.dart';
import 'create_virtual_card_screen.dart';


class VirtualCardsScreen extends ConsumerStatefulWidget {
  const VirtualCardsScreen({super.key});

  @override
  ConsumerState<VirtualCardsScreen> createState() => _VirtualCardsScreenState();
}

class _VirtualCardsScreenState extends ConsumerState<VirtualCardsScreen> {
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
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Virtual Cards',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          titleSpacing: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateVirtualCardScreen()));
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.appBarButtonBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const VirtualCardWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class VirtualCardWidget extends StatelessWidget {
  const VirtualCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: VirtualCardClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
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
                  const SizedBox(height: 28),

                  const Text(
                    '5399 8312 4567 8901',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDataColumn('Balance', '₦50,000'),
                      _buildDataColumn('Expires', '12/28', alignment: CrossAxisAlignment.end),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: const BoxDecoration(
                color: AppColors.cardDarkBottom,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionItem(Icons.visibility_outlined, 'Show', (){}),
                  _buildActionItem(Icons.add, 'Fund', (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FundCardScreen()));
                  }),
                  _buildActionItem(Icons.lock_outline, 'Freeze', (){}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataColumn(String label, String value, {CrossAxisAlignment alignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textFaint,
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
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

  Widget _buildActionItem(IconData icon, String label, VoidCallback onClick) {
    return InkWell(
      onTap: onClick,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class VirtualCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double radius = 12.0;
    const double cutoutRadius = 8.0;

    final double cutoutY = size.height * 0.45;

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