import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/components/string_utilities/string_utilities.dart';

import '../../../../../../utilities/constants/app_colors.dart';
import '../components/group_savings_glowing_button.dart';
import '../models/group_savings_data_model.dart';

class StepFourReview extends StatelessWidget {
  final GroupData data;
  final VoidCallback onNext;
  final VoidCallback onEdit;

  const StepFourReview({
    super.key,
    required this.data,
    required this.onNext,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCol(
                              'Contribution',
                              StringUtilities.formatNaira(data.amount),
                              Icons.attach_money,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoCol(
                              'Frequency',
                              data.frequency,
                              Icons.access_time,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCol(
                              'Members',
                              '${data.memberCount}',
                              Icons.people,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoCol(
                              'Start Date',
                              StringUtilities.formatDate(data.startDate),
                              Icons.calendar_today,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total pool per cycle',
                            style: TextStyle(color: AppColors.textGray),
                          ),
                          Text(
                            StringUtilities.formatNaira(data.totalPool),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payout Order',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...data.payoutOrder
                    .asMap()
                    .entries
                    .map(
                      (e) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: e.key == 0
                                  ? AppColors.primaryOrange
                                  : const Color(0xFF333333),
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(e.value),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191E2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What happens next?',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCheckText(
                        'Invitations will be sent to all selected members',
                      ),
                      _buildCheckText(
                        'Each member must accept the wallet consent agreement',
                      ),
                      _buildCheckText(
                        'The group activates when all members have accepted',
                      ),
                      _buildCheckText(
                        'First contribution will be deducted on the start date',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,)
              ],
            ),
          ),
          GlowingButton(text: 'Confirm & send invites', onPressed: onNext),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onEdit,
            child: const Text(
              'Edit',
              style: TextStyle(color: AppColors.textGray, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textGray),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCheckText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
