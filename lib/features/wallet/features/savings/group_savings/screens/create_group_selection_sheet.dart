import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/constants/app_colors.dart';

import 'group_finance_terms_sheet.dart';

class CreateGroupSelectionSheet extends StatelessWidget {
  const CreateGroupSelectionSheet({super.key});

  void _onFinanceSelected(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FinanceTermsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _onFinanceSelected(context),
              child: _buildOptionCard(
                icon: Icons.attach_money,
                color: AppColors.primaryOrange,
                title: 'Finance',
                subtitle: 'Savings & contribution group\nfor managing collective funds',
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              icon: Icons.people_outline,
              color: AppColors.primaryGreen,
              title: 'Family & Friends',
              subtitle: 'Social group for staying\nconnected with loved ones',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textGray),
        ],
      ),
    );
  }
}