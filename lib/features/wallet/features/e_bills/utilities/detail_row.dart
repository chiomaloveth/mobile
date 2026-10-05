import 'package:flutter/material.dart';

import '../../../../../utilities/constants/app_colors.dart';

class DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final bool isLast;
  final bool emphasizeValue;

  const DetailRow({super.key, required this.title, required this.value, this.valueColor = AppColors.textWhite, this.isLast = false, this.emphasizeValue = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 14))),
            Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: valueColor, fontSize: emphasizeValue ? 16 : 14, fontWeight: emphasizeValue ? FontWeight.w900 : FontWeight.bold))),
          ],
        ),
        if (!isLast) const Divider(color: Colors.white12, height: 32, thickness: 1),
      ],
    );
  }
}