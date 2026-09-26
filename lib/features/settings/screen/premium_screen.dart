import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_colors.dart';
import 'package:qik_talk/utilities/constants/app_icons.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import '../../../utilities/components/buttons/custom_button_two.dart';
import '../theme/provider/theme_provider.dart';

// ── Models ─────────────────────────────────────────────────────────────────

class _PremiumPlan {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String interval;
  final List<String> features;
  final String? savings;

  const _PremiumPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.interval,
    required this.features,
    this.savings,
  });

  factory _PremiumPlan.fromJson(Map<String, dynamic> json) {
    return _PremiumPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      interval: json['interval'] as String? ?? 'month',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      savings: json['savings'] as String?,
    );
  }
}

class _PremiumStatus {
  final bool isPremium;
  final String plan;
  final String renewsAt;
  final List<String> features;

  const _PremiumStatus({
    this.isPremium = false,
    this.plan = '',
    this.renewsAt = '',
    this.features = const [],
  });

  factory _PremiumStatus.fromJson(Map<String, dynamic> json) {
    return _PremiumStatus(
      isPremium: json['isPremium'] == true,
      plan: json['plan'] as String? ?? '',
      renewsAt: json['renewsAt'] as String? ?? '',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isSubscribing = false;
  bool _isCancelling = false;

  _PremiumStatus _status = const _PremiumStatus();
  List<_PremiumPlan> _plans = [];
  int _selectedPlanIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _fetchPlans();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await SaveValues().getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _fetchStatus() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(ApiStrings.getPremiumStatus),
        headers: headers,
      );
      print('Premium status ${response.statusCode}: ${response.body}');
      if (mounted && (response.statusCode == 200 || response.statusCode == 201)) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>? ?? {};
        setState(() => _status = _PremiumStatus.fromJson(data));
      }
    } catch (e) {
      print('Premium status error: $e');
    }
  }

  Future<void> _fetchPlans() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(ApiStrings.getPremiumPlans),
        headers: headers,
      );
      print('Premium plans ${response.statusCode}: ${response.body}');
      if (mounted && (response.statusCode == 200 || response.statusCode == 201)) {
        final body = jsonDecode(response.body);
        final List<dynamic> list = body['data'] as List<dynamic>? ?? [];
        setState(() {
          _plans = list
              .map((e) => _PremiumPlan.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      print('Premium plans error: $e');
    }
  }

  Future<void> _subscribe() async {
    if (_plans.isEmpty) return;
    final plan = _plans[_selectedPlanIndex];

    setState(() => _isSubscribing = true);
    try {
      final headers = await _authHeaders();
      // POST /api/v1/settings/premium/subscribe
      final response = await http.post(
        Uri.parse(ApiStrings.subscribePremium),
        headers: headers,
        body: jsonEncode({
          'plan': plan.interval == 'year' ? 'annual' : 'monthly',
          'paymentMethod': 'card',
        }),
      );
      print('Subscribe ${response.statusCode}: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium subscription activated!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchStatus();
      } else {
        String message = 'Failed to subscribe';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubscribing = false);
    }
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Subscription',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to cancel your premium subscription? You will retain access until the end of your billing period.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep Premium', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      final headers = await _authHeaders();
      // POST /api/v1/settings/premium/cancel
      final response = await http.post(
        Uri.parse(ApiStrings.cancelPremium),
        headers: headers,
        body: jsonEncode({'reason': 'User requested cancellation'}),
      );
      print('Cancel premium ${response.statusCode}: ${response.body}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled. Access continues until renewal date.'),
            backgroundColor: Colors.orange,
          ),
        );
        _fetchStatus();
      } else {
        String message = 'Failed to cancel subscription';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppColors.lightBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor:
                isDark ? HexColor("#3A1D07") : AppTheme.scaffoldBg(isDark),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: isDark
                    ? const DecorationImage(
                        image: AssetImage("images/app_bar_gredient.png"),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: isDark ? null : AppTheme.scaffoldBg(isDark),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: topPadding, left: 16.0, right: 40.0),
                          child: Icon(Icons.arrow_back,
                              size: 22.0,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary(isDark)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topPadding, left: 10.0),
                        child: Text(
                          'Premium',
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary(isDark),
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Badge icon
                SizedBox(
                  height: 70,
                  width: 70,
                  child: Image.asset(AppIcons.premiumBadgeIcon),
                ),
                const SizedBox(height: 15),

                // ── Active subscription banner ──────────────────────────────
                if (_status.isPremium) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A2A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF34C759).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFF34C759), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Premium Active',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF34C759),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_status.renewsAt.isNotEmpty)
                                  Text(
                                    'Renews ${_formatDate(_status.renewsAt)}',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF34C759)
                                          .withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _cancelSubscription,
                            child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFFF3B30),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Text(
                    'Unlock Premium',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : null,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Get exclusive features and enhanced experience',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : null,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Premium Features ────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'PREMIUM FEATURES',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _breakDownCard(
                        icon: AppIcons.adFreeIcon,
                        title: 'Ad-Free Experience',
                        message: 'No ads, ever'),
                    const SizedBox(height: 10),
                    _breakDownCard(
                        icon: AppIcons.badgeIcon,
                        title: 'Verified Badge',
                        message: 'Get the verified checkmark'),
                    const SizedBox(height: 10),
                    _breakDownCard(
                        icon: AppIcons.largerGroupIcon,
                        title: 'Larger Groups',
                        message: 'Create groups up to 500 members'),
                    const SizedBox(height: 10),
                    _breakDownCard(
                        icon: AppIcons.priorityIcon,
                        title: 'Priority Support',
                        message: '24/7 premium support'),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Plans ───────────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'CHOOSE YOUR PLAN',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_plans.isNotEmpty)
                      ..._plans.asMap().entries.map((e) {
                        final i = e.key;
                        final plan = e.value;
                        return _planOptionCard(
                          period: plan.name,
                          price: plan.price.toStringAsFixed(2),
                          interval: plan.interval,
                          savings: plan.savings,
                          isMostPopular: plan.interval == 'year',
                          isBestValue: plan.id.contains('lifetime') ||
                              plan.interval == 'lifetime',
                          index: i,
                          currentIndex: _selectedPlanIndex,
                          onClick: () =>
                              setState(() => _selectedPlanIndex = i),
                          isDark: isDark,
                        );
                      })
                    else ...[
                      // Fallback static plans if API returns nothing
                      _planOptionCard(
                          period: 'Monthly',
                          price: '4.99',
                          interval: 'month',
                          isMostPopular: false,
                          isBestValue: false,
                          index: 0,
                          currentIndex: _selectedPlanIndex,
                          onClick: () => setState(() => _selectedPlanIndex = 0),
                          isDark: isDark),
                      _planOptionCard(
                          period: 'Yearly',
                          price: '39.99',
                          interval: 'year',
                          savings: '33%',
                          isMostPopular: true,
                          isBestValue: false,
                          index: 1,
                          currentIndex: _selectedPlanIndex,
                          onClick: () => setState(() => _selectedPlanIndex = 1),
                          isDark: isDark),
                      _planOptionCard(
                          period: 'Lifetime',
                          price: '99.99',
                          interval: 'lifetime',
                          isMostPopular: false,
                          isBestValue: true,
                          index: 2,
                          currentIndex: _selectedPlanIndex,
                          onClick: () => setState(() => _selectedPlanIndex = 2),
                          isDark: isDark),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // ── Subscribe button ────────────────────────────────────────
                if (!_status.isPremium)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CustomButtonTwo(
                      title: _isSubscribing
                          ? 'Processing...'
                          : 'Subscribe to Premium',
                      onClick: _isSubscribing ? () {} : _subscribe,
                      isLoading: _isSubscribing,
                    ),
                  ),

                const SizedBox(height: 10),
                Text(
                  'Cancel anytime. Terms and conditions apply.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white : null,
                  ),
                ),

                const SizedBox(height: 20),

                // ── FAQ ─────────────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'FREQUENTLY ASKED',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _frequentlyAskedCard(
                        title: 'Can I cancel anytime?', isDark: isDark),
                    const SizedBox(height: 10),
                    _frequentlyAskedCard(
                        title: 'What payment methods are accepted?',
                        isDark: isDark),
                    const SizedBox(height: 10),
                    _frequentlyAskedCard(
                        title: 'Is there a free trial?', isDark: isDark),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _breakDownCard({
    required String icon,
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              SizedBox(
                  height: 24, width: 24, child: Image.asset(icon)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(message,
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w400)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.check, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _frequentlyAskedCard(
      {required String title, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : null,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _planOptionCard({
    required String period,
    required String price,
    required String interval,
    String? savings,
    required bool isMostPopular,
    required bool isBestValue,
    required int index,
    required int currentIndex,
    required VoidCallback onClick,
    required bool isDark,
  }) {
    final bool isSelected = index == currentIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          height: 120,
          width: double.infinity,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 1.5,
                      color: isSelected
                          ? const Color(0xFFFF00A8)
                          : Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              period,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : null,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\$$price',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: interval == 'lifetime'
                                        ? ' one-time'
                                        : '/$interval',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (savings != null) ...[
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 3),
                                child: Text(
                                  'Save $savings',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.green),
                                ),
                              ),
                            ] else if (isBestValue) ...[
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 3),
                                child: const Text(
                                  'Best Value',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.green),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: const Color(0xFFFF00A8)),
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFFF00A8)
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isMostPopular)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF00A8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Text(
                        'Most Popular',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
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
