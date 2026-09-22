import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
class _CountryPickerPrefix extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;

  const _CountryPickerPrefix({
    required this.country,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.arrow_drop_down),
          ),
          const SizedBox(width: 4),
          Text('+${country.phoneCode}'),
        ],
      ),
    );
  }
}
