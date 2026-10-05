import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../utilities/constants/app_colors.dart';
import '../../../../../settings/theme/provider/theme_provider.dart';
import 'confirm_airtime_details_screen.dart';

class BuyAirtimeScreen extends ConsumerStatefulWidget {
  const BuyAirtimeScreen({super.key});

  @override
  ConsumerState<BuyAirtimeScreen> createState() => _BuyAirtimeScreenState();
}

class _BuyAirtimeScreenState extends ConsumerState<BuyAirtimeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();

  int _selectedNetworkIndex = 0;
  int? _selectedAmountIndex;

  final List<int> _presetAmounts = [100, 200, 500, 1000, 2000, 5000];

  final List<String> _netWorkServices = [
    "mtn",
    "airtel",
    "glo",
    "9mobile",
  ];

  String _selectedNetWorkService = "";

  @override
  void initState() {
    _selectedNetWorkService = "mtn";
    super.initState();
  }

  final List<Map<String, dynamic>> _networks = [
    {
      "name": "MTN",
      "icon": "assets/svgs/airtime.svg",
      "color": const Color(0xFFFFCC00),
    },
    {
      "name": "Airtel",
      "icon": "assets/svgs/airtime.svg",
      "color": const Color(0xFFFF0000),
    },
    {
      "name": "Glo",
      "icon": "assets/svgs/airtime.svg",
      "color": const Color(0xFF00FF00),
    },
    {
      "name": "9Mobile",
      "icon": "assets/svgs/airtime.svg",
      "color": const Color(0xFF006633),
    },
  ];


  @override
  void dispose() {
    _phoneController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _handlePresetTap(int index) {
    setState(() {
      _selectedAmountIndex = index;
      _customAmountController.text = _presetAmounts[index].toString();
      FocusScope.of(context).unfocus();
    });
  }

  void _handleCustomAmountChange(String value) {
    if (value.isNotEmpty && _selectedAmountIndex != null) {
      setState(() {
        _selectedAmountIndex = null;
      });
    }
  }

  void _processPurchase() {
    String phone = _phoneController.text;
    String amount = _selectedAmountIndex != null
        ? _presetAmounts[_selectedAmountIndex!].toString()
        : _customAmountController.text;
    String network = _selectedNetWorkService;

    if (phone.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid details.')),
      );
      return;
    }

    debugPrint("Processing Purchase: $amount ($network) for $phone");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmAirtimeDetailsScreen(
          phoneNumber: phone,
          amount: amount,
          networkName: network.toLowerCase(),
        ),
      ),
    );
  }

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
        : Colors.white;

    bool isActive =
        _selectedNetworkIndex >= 0 &&
        (_selectedAmountIndex != null ||
            _customAmountController.text.isNotEmpty) &&
        _phoneController.text.isNotEmpty;

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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                const _AppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Center(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 100,
                                sigmaY: 100,
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 500,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6900,
                                  ).withValues(alpha: 0.17),
                                  borderRadius: BorderRadius.circular(45845900),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel(
                              label: 'Select Network Provider',
                            ),
                            const SizedBox(height: 12),
                            _NetworkSelector(
                              networks: _networks,
                              selectedIndex: _selectedNetworkIndex,
                              onSelected: (index) {
                                setState(() {
                                  _selectedNetworkIndex = index;
                                  _selectedNetWorkService = _netWorkServices[_selectedNetworkIndex];
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            const _SectionLabel(label: 'Phone Number'),
                            const SizedBox(height: 8),
                            _PhoneInputField(controller: _phoneController),
                            const SizedBox(height: 24),
                            const _SectionLabel(label: 'Quick Select Amount'),
                            const SizedBox(height: 12),
                            _AmountGrid(
                              presetAmounts: _presetAmounts,
                              selectedIndex: _selectedAmountIndex,
                              onAmountSelected: _handlePresetTap,
                            ),
                            const SizedBox(height: 24),
                            const _SectionLabel(
                              label: 'Or Enter Custom Amount',
                            ),
                            const SizedBox(height: 8),
                            _CustomAmountField(
                              controller: _customAmountController,
                              onChanged: _handleCustomAmountChange,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomButton(isActive: isActive, onPressed: _processPurchase),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 17),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Airtime',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Top up your phone',
                style: GoogleFonts.inter(
                  color: const Color(0xB2FFD6A8),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _NetworkSelector extends StatelessWidget {
  final List<Map<String, dynamic>> networks;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _NetworkSelector({
    required this.networks,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(networks.length, (index) {
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            width: 77.87,
            height: 103.98,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFFF6900).withValues(alpha: 0.3),
                        const Color(0xFFFE9A00).withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.15),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              borderRadius: BorderRadius.circular(17.34),
              border: Border.all(
                color: isSelected
                    ? const Color(0xffFF6900)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF8904).withValues(alpha: 0.2),
                        blurRadius: 0,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    networks[index]["icon"] as String,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  networks[index]["name"],
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Enter phone number',
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _AmountGrid extends StatelessWidget {
  final List<int> presetAmounts;
  final int? selectedIndex;
  final ValueChanged<int> onAmountSelected;

  const _AmountGrid({
    required this.presetAmounts,
    required this.selectedIndex,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: presetAmounts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final amount = presetAmounts[index];
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onAmountSelected(index),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFFF6900).withValues(alpha: 0.2),
                        const Color(0xFFFE9A00).withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              borderRadius: BorderRadius.circular(15.17),
              border: Border.all(
                color: isSelected
                    ? const Color(0xffFF6900)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF8904).withValues(alpha: 0.2),
                        blurRadius: 0,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '₦$amount',
              style: GoogleFonts.inter(
                color: Colors.white,

                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomAmountField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CustomAmountField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 0),
            child: Text(
              '₦',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          hintText: '0',
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const _BottomButton({required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: GestureDetector(
        onTap: isActive ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF2E1A0B), Color(0xFF6A3710)],
                    //stops: [0.0, 0.3],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isActive ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            'Continue',
            style: GoogleFonts.inter(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
