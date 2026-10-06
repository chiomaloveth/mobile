import 'package:flutter/material.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../components/group_savings_glowing_button.dart';
import '../models/group_savings_data_model.dart';

class StepTwoSelectMembers extends StatefulWidget {
  final GroupData data;
  final VoidCallback onNext;
  const StepTwoSelectMembers({super.key, required this.data, required this.onNext});

  @override
  State<StepTwoSelectMembers> createState() => _StepTwoSelectMembersState();
}

class _StepTwoSelectMembersState extends State<StepTwoSelectMembers> {
  int get requiredMembers => widget.data.memberCount - 1;
  int get selectedCount => dummyContacts.where((c) => c.isSelected).length + freqContacts.where((c) => c.isSelected).length;

  void _toggleContact(Contact contact) {
    setState(() {
      if (contact.isSelected) {
        contact.isSelected = false;
      } else {
        if (selectedCount < requiredMembers) {
          contact.isSelected = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = selectedCount == requiredMembers;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryOrange.withOpacity(0.5))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Members selected', style: TextStyle(color: AppColors.primaryOrange)),
                Text('$selectedCount / $requiredMembers', style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search names or numbers',
              hintStyle: const TextStyle(color: AppColors.textGray),
              prefixIcon: const Icon(Icons.search, color: AppColors.textGray),
              filled: true,
              fillColor: AppColors.cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Frequently contacted', style: TextStyle(color: AppColors.textGray, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: freqContacts.length,
              itemBuilder: (context, index) {
                final c = freqContacts[index];
                return GestureDetector(
                  onTap: () => _toggleContact(c),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(radius: 26, backgroundImage: NetworkImage(c.avatarUrl)),
                            if (c.isSelected)
                              Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                  child: const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(c.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: dummyContacts.length,
                itemBuilder: (context, index) {
                  final c = dummyContacts[index];
                  bool isFirstA = index == 0;
                  bool isFirstB = index == 6;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstA || isFirstB)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                          child: Text(isFirstA ? 'A' : 'B', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGray)),
                        ),
                      ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl)),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: GestureDetector(
                          onTap: () => _toggleContact(c),
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: c.isSelected ? AppColors.primaryGreen : AppColors.textGray, width: 2),
                            ),
                            child: c.isSelected ? const Icon(Icons.check, size: 16, color: AppColors.primaryGreen) : null,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlowingButton(
            text: 'Continue to Contribution Order',
            isEnabled: isComplete,
            onPressed: () {
              widget.data.selectedMembers = [
                ...freqContacts.where((c) => c.isSelected),
                ...dummyContacts.where((c) => c.isSelected)
              ];
              widget.data.payoutOrder = ['You (Creator)', ...widget.data.selectedMembers.map((e) => e.name)];
              widget.onNext();
            },
          )
        ],
      ),
    );
  }
}