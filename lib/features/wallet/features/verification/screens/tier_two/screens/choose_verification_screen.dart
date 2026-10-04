import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qik_talk/features/wallet/features/verification/screens/tier_two/screens/bvn_verification_screen.dart';

import '../../../../../../../utilities/constants/app_colors.dart';

class VerificationMethod {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  VerificationMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class ChooseVerificationScreen extends StatefulWidget {
  const ChooseVerificationScreen({super.key});

  @override
  State<ChooseVerificationScreen> createState() =>
      _ChooseVerificationScreenState();
}

class _ChooseVerificationScreenState extends State<ChooseVerificationScreen> {
  final List<VerificationMethod> _methods =[
    VerificationMethod(
      id: 'bvn',
      title: 'Verify with BVN',
      subtitle: 'Bank Verification Number',
      icon: Icons.credit_card_outlined,
    ),
    VerificationMethod(
      id: 'nin',
      title: 'Verify with NIN',
      subtitle: 'National Identification Number',
      icon: Icons.fingerprint_rounded,
    ),
  ];

  void _handleMethodSelection({required VerificationMethod method, required BuildContext context}) {
    if (method.id.toLowerCase() == "bvn") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BVNVerificationScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text(
              'Choose Verification Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tier 2 - Verified',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Stack(
        children:[
          Positioned(
            top: 100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF96D15).withOpacity(0.35),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF96D15).withOpacity(0.25),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:[
                  ..._methods.map((method) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: MethodCardWidget(
                        method: method,
                        onTap: () => _handleMethodSelection(method: method, context: context),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Choose one verification method to proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
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

class MethodCardWidget extends StatelessWidget {
  final VerificationMethod method;
  final VoidCallback onTap;

  const MethodCardWidget({
    super.key,
    required this.method,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Material(
          color: Colors.white.withOpacity(0.05),
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              child: Row(
                children:[
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      method.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          method.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}