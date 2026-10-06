import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// --- CONSTANTS & THEME ---
class AppColors {
  static const Color background = Color(0xFF0A0A0A);
  static const Color cardBg = Color(0xFF1C140D);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xFFA0A0A0);
  static const Color accentOrange = Color(0xFFD97706);
  static const Color accentBrown = Color(0xFF5C3317);
  static const Color successGreen = Color(0xFF10B981);
  static const Color borderSubtle = Color(0xFF333333);
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter', // Defaulting to standard sans-serif
        useMaterial3: true,
      ),
      home: const WalletDashboardScreen(),
    );
  }
}

// --- SCREEN 1: MAIN DASHBOARD ---

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  bool _autoDeposit = true;

  void _showFundWalletBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FundWalletBottomSheet(),
    );
  }

  void _navigateToAddPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Subtle background glow
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentBrown.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                  const Text(
                    'WALLET SETTINGS',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.accentBrown,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'OH',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              Text(
                'Odogwu Hilary',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceLight.withOpacity(0.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'NGN',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.secondaryText, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '₦23,932,543.02',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '↑+2.3% income this week',
            style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star,
                    color: AppColors.accentOrange, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coin Earned',
                    style:
                    TextStyle(color: AppColors.secondaryText, fontSize: 13),
                  ),
                  Text(
                    '1,247',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _CustomButton(
            title: 'Fund via Wallet',
            onTap: _showFundWalletBottomSheet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _CustomButton(
            title: 'Fund via Card',
            onTap: _navigateToAddPayment,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.credit_card,
            title: 'Payment Methods',
            onTap: _navigateToAddPayment,
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          _buildSettingsTile(
            icon: Icons.auto_graph,
            title: 'Auto-deposit Stars',
            subtitle: 'Convert stars to wallet balance',
            trailing: Switch(
              value: _autoDeposit,
              activeColor: Colors.white,
              activeTrackColor: AppColors.successGreen,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: AppColors.surfaceLight,
              onChanged: (val) => setState(() => _autoDeposit = val),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Security Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.secondaryText, size: 24),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
          style: const TextStyle(
              color: AppColors.secondaryText, fontSize: 13))
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBrown.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentOrange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_border,
                  color: AppColors.accentOrange, size: 16),
              const SizedBox(width: 8),
              Text(
                'Earn Stars on Discover',
                style: TextStyle(
                  color: AppColors.accentOrange.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Like, comment, and share posts in the Discover feed to earn stars. Each star converts to \$0.01 in your wallet!',
            style: TextStyle(
              color: AppColors.accentOrange.withOpacity(0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CustomButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 2: BOTTOM SHEET ---

class FundWalletBottomSheet extends StatelessWidget {
  const FundWalletBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fund via Wallet',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.secondaryText),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Amount of coins',
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '1000000',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.circle,
                            color: AppColors.accentBrown, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          'Available Coin Balance: 200',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: const Text(
                        '₦ 23,932,543',
                        style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 22), // Align with left column
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232D3F), // Dark blueish tint
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () {}, // Implement fund logic
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accentBrown,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Fund',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
    );
  }
}

// --- SCREEN 3: ADD PAYMENT METHOD ---

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  bool _isDefault = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Payment Method',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentBrown.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  radius: 1.0,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMiniBalanceCard(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 24),
                _buildSecurityNotice(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'NGN',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.secondaryText, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '₦23,932,543.02',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '↑+2.3% income this week',
            style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Card Number',
          initialValue: '1234  4567  8643  3222',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Cardholder Name',
          initialValue: 'HILARY ODOGWU',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Expiry Date',
                initialValue: '08/28',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'CVV',
                initialValue: '123',
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _isDefault,
                onChanged: (val) {
                  setState(() {
                    _isDefault = val ?? false;
                  });
                },
                activeColor: Colors.blue,
                side: const BorderSide(color: AppColors.secondaryText),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Set as default payment method',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, letterSpacing: 1.0),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceDark,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F13), // Dark green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B4028)), // Green border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline,
              color: AppColors.successGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your card is secure',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We use bank-level encryption to protect your card information. Your CVV is never stored.',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Implement Add Card Logic
          Navigator.pop(context);
        },
        icon: const Icon(Icons.credit_card, color: Colors.white, size: 18),
        label: const Text(
          'Add Card',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBrown,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}