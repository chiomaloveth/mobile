import 'package:flutter/material.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../components/group_savings_glowing_button.dart';
import '../models/group_savings_data_model.dart';
import 'group_savings_details_screen.dart';

class GroupSavingsSuccessScreen extends StatelessWidget {
  final GroupData groupData;
  const GroupSavingsSuccessScreen({super.key, required this.groupData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 80),
              ),
              const SizedBox(height: 32),
              const Text('Group Created\nSuccessfully!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Your group has been created.\nInvitations have been sent to all\nmembers.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGray, fontSize: 16)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('What\'s next?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    _buildDotText('Members will receive group invitations'),
                    _buildDotText('You can start chatting once they join'),
                    _buildDotText('Manage your group settings anytime'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              GlowingButton(
                text: 'Open Group Chat',
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GroupDetailsScreen(data: groupData)));
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('View All Groups', style: TextStyle(color: AppColors.textGray, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const CircleAvatar(radius: 3, backgroundColor: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
        ],
      ),
    );
  }
}