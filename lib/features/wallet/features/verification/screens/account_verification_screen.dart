import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qik_talk/features/wallet/features/verification/screens/tier_one/screens/basic_information_screen.dart';
import 'package:qik_talk/features/wallet/features/verification/screens/tier_three/screens/tier_three_verification_screen.dart';
import 'package:qik_talk/features/wallet/features/verification/screens/tier_two/screens/choose_verification_screen.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

class VerificationTier {
  final String id;
  final String title;
  final String limit;
  final IconData icon;
  final List<String> requirements;
  final String buttonText;

  VerificationTier({
    required this.id,
    required this.title,
    required this.limit,
    required this.icon,
    required this.requirements,
    required this.buttonText,
  });
}

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  String _currentTierId = 'Tier 1';

  final List<VerificationTier> _tiers =[
    VerificationTier(
      id: 'Tier 1',
      title: 'Tier 1 - Basic',
      limit: '₦10,000 - ₦50,000',
      icon: Icons.check_circle_outline_rounded,
      requirements:[
        'Verified phone',
        'Verified email',
      ],
      buttonText: 'Start Basic Verification',
    ),
    VerificationTier(
      id: 'Tier 2',
      title: 'Tier 2 - Verified',
      limit: '₦100,000 - ₦500,000',
      icon: Icons.lock_outline_rounded,
      requirements:[
        'BVN verification OR',
        'NIN verification',
        'Face capture (Optional)',
      ],
      buttonText: 'Upgrade to Tier 2',
    ),
    VerificationTier(
      id: 'Tier 3',
      title: 'Tier 3 - Business',
      limit: 'Unlimited',
      icon: Icons.workspace_premium_outlined,
      requirements:[
        'BVN + NIN verification',
        'Government-issued ID',
        'Residential address',
        'Face capture',
        'Bank account(s) linked to BVN/NIN',
        'Video verification (Optional)',
      ],
      buttonText: 'Upgrade to Tier 3',
    ),
  ];

  void _handleUpgrade(String newTierId) {
    setState(() {
      _currentTierId = newTierId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification process initiated for $newTierId...'),
        backgroundColor: const Color(0xFF6B330C),
        duration: const Duration(seconds: 2),
      ),
    );
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
        title: Text(
          'Account Verification',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark),
          ),
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(
                                'Current Verification Level',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentTierId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._tiers.map((tier) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TierCardWidget(
                          tier: tier,
                          onActionTap: () {
                            if (tier.id == 'Tier 1') {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                  const BasicInformationScreen()));
                            } else if (tier.id == 'Tier 2') {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                  const ChooseVerificationScreen()));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                  const VerificationScreen()));
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TierCardWidget extends StatelessWidget {
  final VerificationTier tier;
  final VoidCallback onActionTap;

  const TierCardWidget({
    super.key,
    required this.tier,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Icon(
                    tier.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          tier.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Limit: ${tier.limit}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...tier.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 10),
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        req,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E2E0D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    tier.buttonText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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