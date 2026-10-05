import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../../../../../settings/theme/provider/theme_provider.dart';
import '../../../../temporary/core_components.dart';

class CableTVScreen extends ConsumerStatefulWidget {
  const CableTVScreen({super.key});

  @override
  ConsumerState<CableTVScreen> createState() => _CableTVScreenState();
}

class _CableTVScreenState extends ConsumerState<CableTVScreen> {
  bool providerSelected = false;
  int? _selectedPackageIndex = 2;

  final List<Map<String, String>> _packages = [
    {'name': 'Dstv Padi', 'price': '₦2,500'},
    {'name': 'Dstv Yanga', 'price': '₦3,500'},
    {'name': 'Dstv Compact', 'price': '₦10,500'},
    {'name': 'Dstv Premium', 'price': '₦24,500'},
  ];

  void _handleSubscribe() {
    FocusScope.of(context).unfocus();

    if (!providerSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a provider first.')),
      );
      return;
    }

    if (_selectedPackageIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a package.')),
      );
      return;
    }

    final selectedPackage = _packages[_selectedPackageIndex!];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscribing to ${selectedPackage['name']} for ${selectedPackage['price']}...'),
        backgroundColor: successGreen,
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
        : AppTheme.scaffoldBg(isDark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark
            ? Color(AppColors.primaryBackgroundColor)
            : AppTheme.scaffoldBg(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
              'Cable TV Subscription',
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary(isDark), fontSize: 15),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provider',
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary(isDark), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        providerSelected = true;
                      });
                    },
                    child: CustomInputField(
                      hintText: providerSelected ? 'DSTV' : 'Select provider',
                      isDropdown: !providerSelected,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Smart Card Number',
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary(isDark), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const CustomInputField(hintText: 'Enter Smart Card Number'),

                  if (providerSelected) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Select Package',
                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary(isDark), fontSize: 13),
                    ),
                    const SizedBox(height: 15),

                    ...List.generate(_packages.length, (index) {
                      final isSelected = _selectedPackageIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildTvPackage(
                          _packages[index]['name']!,
                          _packages[index]['price']!,
                          isSelected,
                          isDark,
                          () {
                            setState(() {
                              _selectedPackageIndex = index;
                            });
                          },
                        ),
                      );
                    }),
                  ],

                  SizedBox(height: providerSelected ? 40 : 250),

                  GestureDetector(
                    onTap: _handleSubscribe,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? cardColor : AppTheme.cardBg(isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? errorRed.withOpacity(0.3) : AppTheme.border(isDark)),
                      ),
                      child: Text(
                        'Subscribe',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTvPackage(String name, String price, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? cardColor : AppTheme.cardBg(isDark),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.orange)
              : Border.all(color: isDark ? Colors.transparent : AppTheme.border(isDark)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.tv, color: isDark ? Colors.white : AppTheme.textPrimary(isDark), size: 18),
                const SizedBox(width: 10),
                Text(name, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary(isDark))),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}