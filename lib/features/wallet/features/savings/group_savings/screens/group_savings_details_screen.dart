import 'package:flutter/material.dart';
import '../../../../../../utilities/components/string_utilities/string_utilities.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../models/group_savings_data_model.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupData data;
  const GroupDetailsScreen({super.key, required this.data});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.data.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('Finance Group', style: TextStyle(fontSize: 12, color: AppColors.textGray, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.account_balance_wallet_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTopTab('Overview', 0)),
              Expanded(child: _buildTopTab('Members', 1)),
              Expanded(child: _buildTopTab('Activity', 2)),
            ],
          ),
          Expanded(
            child: tabIndex == 0 ? _buildOverview() : (tabIndex == 1 ? _buildMembers() : const Center(child: Text('Activity Log'))),
          )
        ],
      ),
    );
  }

  Widget _buildTopTab(String text, int index) {
    bool active = tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? Colors.white : Colors.transparent, width: 2)),
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(color: active ? Colors.white : AppColors.textGray, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildOverview() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Total Pool Value', style: TextStyle(color: AppColors.textGray)), Icon(Icons.monetization_on, color: Colors.white)],
              ),
              const SizedBox(height: 8),
              Text(StringUtilities.formatNaira(widget.data.totalPool), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Cycle Progress', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.4,
                  backgroundColor: Colors.black,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Cycle 2 of 5', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Next Payout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(StringUtilities.formatDate(DateTime.now().add(const Duration(days: 15))), style: const TextStyle(color: AppColors.textGray)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Recipient', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                  Text(widget.data.payoutOrder.length > 1 ? widget.data.payoutOrder[1] : 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Position', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('#1 in payout order', style: TextStyle(color: AppColors.textGray)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Received', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Contribution', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(StringUtilities.formatNaira(widget.data.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Per ${widget.data.frequency}', style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Members', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('${widget.data.memberCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${widget.data.memberCount - 1} active', style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMembers() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildMemberTile('You', 'https://i.pravatar.cc/150?u=99', true, true),
        ...widget.data.selectedMembers.map((e) => _buildMemberTile(e.name, e.avatarUrl, e.name.contains('A'), false)).toList(),
      ],
    );
  }

  Widget _buildMemberTile(String name, String avatarUrl, bool hasPaid, bool isReceived) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: hasPaid ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: hasPaid ? AppColors.primaryGreen : AppColors.primaryOrange)
                      ),
                      child: Text(hasPaid ? 'paid' : 'pending', style: TextStyle(color: hasPaid ? AppColors.primaryGreen : AppColors.primaryOrange, fontSize: 10)),
                    ),
                    if (isReceived) ...[
                      const SizedBox(width: 8),
                      const Text('Payout received', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                    ]
                  ],
                )
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textGray)
        ],
      ),
    );
  }
}