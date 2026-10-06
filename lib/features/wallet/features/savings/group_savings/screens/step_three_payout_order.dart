import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../components/group_savings_glowing_button.dart';
import '../models/group_savings_data_model.dart';

class StepThreePayoutOrder extends StatefulWidget {
  final GroupData data;
  final VoidCallback onNext;

  const StepThreePayoutOrder({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  State<StepThreePayoutOrder> createState() => _StepThreePayoutOrderState();
}

class _StepThreePayoutOrderState extends State<StepThreePayoutOrder> {
  bool isAutoAssign = true;
  late List<String> currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = List.from(widget.data.payoutOrder);
  }

  void _shuffle() {
    setState(() {
      String creator = currentOrder[0];
      List<String> others = currentOrder.sublist(1);
      others.shuffle(Random());
      currentOrder = [creator, ...others];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab('Auto Assign', true)),
                  Expanded(child: _buildTab('Manual', false)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF191E2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Payout order will be randomly assigned.\nYou can shuffle to get a different order.',
                style: TextStyle(color: Colors.lightBlueAccent, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            if (isAutoAssign)
              GestureDetector(
                onTap: _shuffle,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shuffle, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Shuffle Order',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            isAutoAssign ? _buildListView() : _buildReorderableList(),
            _buildInfoBox(),
            const SizedBox(height: 20),
            GlowingButton(
              text: 'Continue to summary',
              onPressed: () {
                widget.data.payoutOrder = currentOrder;
                widget.onNext();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isAuto) {
    bool active = isAutoAssign == isAuto;
    return GestureDetector(
      onTap: () => setState(() => isAutoAssign = isAuto),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryOrange.withOpacity(0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textGray,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        for (int i = 0; i < currentOrder.length; i++) ...[
          _buildOrderTile(i, currentOrder[i], false),
        ],
      ],
    );
  }

  Widget _buildReorderableList() {
    return Column(
      children: [
        for (int index = 0; index < currentOrder.length; index++)
          if (index == 0)
            _buildOrderTile(
              index,
              currentOrder[index],
              true,
              key: ValueKey(currentOrder[index]),
            )
          else
            DragTarget<int>(
              onWillAcceptWithDetails: (details) => details.data != index,
              onAcceptWithDetails: (details) {
                final oldIndex = details.data;
                int newIndex = index;

                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = currentOrder.removeAt(oldIndex);
                  currentOrder.insert(newIndex, item);
                });
              },
              builder: (context, candidateData, rejectedData) {
                final isHovered = candidateData.isNotEmpty;

                return LongPressDraggable<int>(
                  data: index,
                  feedback: Material(
                    elevation: 6.0,
                    color: Colors.transparent,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: _buildOrderTile(index, currentOrder[index], true),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildOrderTile(index, currentOrder[index], true),
                  ),
                  child: Container(
                    decoration: isHovered
                        ? BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                            ),
                          )
                        : null,
                    child: _buildOrderTile(
                      index,
                      currentOrder[index],
                      true,
                      key: ValueKey(currentOrder[index]),
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }

  Widget _buildOrderTile(int index, String name, bool isManual, {Key? key}) {
    bool isCreator = index == 0;
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isCreator
                ? AppColors.primaryOrange
                : const Color(0xFF333333),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isCreator)
                  const Text(
                    'First payout recipient',
                    style: TextStyle(color: AppColors.textGray, fontSize: 12),
                  )
                else
                  Text(
                    'Position ${index + 1}',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (isManual && !isCreator)
            const Icon(Icons.drag_indicator, color: AppColors.textGray),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it works',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildBullet('Each member contributes at the same time every cycle'),
          _buildBullet('The person in position 1 receives the first payout'),
          _buildBullet(
            'The cycle continues until everyone has received their payout',
          ),
          _buildBullet(
            'This order cannot be changed once the group is created',
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: CircleAvatar(radius: 3, backgroundColor: AppColors.textGray),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
