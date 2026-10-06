import 'package:flutter/material.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../components/group_savings_glowing_button.dart';
import 'group_savings_setup_wizard_screen.dart';

class FinanceTermsSheet extends StatefulWidget {
  const FinanceTermsSheet({Key? key}) : super(key: key);

  @override
  State<FinanceTermsSheet> createState() => _FinanceTermsSheetState();
}

class _FinanceTermsSheetState extends State<FinanceTermsSheet> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.primaryOrange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Important: Read Before Continuing\nFinance groups involve real money transactions. Please review the following carefully.',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  _buildInfoCard(
                    Icons.account_balance_wallet,
                    'Wallet Connection Required',
                    'Your wallet will be linked to this group. This connection is permanent and cannot be undone or changed later.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.swap_vert,
                    'Automatic Deductions',
                    'Contributions will be automatically deducted from your wallet based on the agreed schedule. Make sure you have sufficient balance.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.calendar_today,
                    'Structured Payout System',
                    'Members receive payouts in a predetermined order. Each member gets their turn to receive the pooled contributions. Once the cycle starts, the payout order cannot be changed.',
                    iconColor: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Note: Finance groups require wallet connection and cannot be converted to other types. Family & Friends groups can be upgraded to Games groups later.',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (v) => setState(() => isChecked = v!),
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                              side: const BorderSide(color: AppColors.textGray),
                            ),
                            const Text(
                              'I understand and agree to the terms.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
            ),
            GlowingButton(
              text: 'Continue to Group',
              isEnabled: isChecked,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GroupSavingsSetupWizardScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String desc, {
    Color iconColor = Colors.blue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
