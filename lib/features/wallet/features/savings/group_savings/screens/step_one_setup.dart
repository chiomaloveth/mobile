import 'package:flutter/material.dart';
import '../../../../../../utilities/components/string_utilities/string_utilities.dart';
import '../../../../../../utilities/constants/app_colors.dart';
import '../components/group_savings_glowing_button.dart';
import '../models/group_savings_data_model.dart';

class StepOneSetup extends StatefulWidget {
  final GroupData data;
  final VoidCallback onNext;
  const StepOneSetup({super.key, required this.data, required this.onNext});

  @override
  State<StepOneSetup> createState() => _StepOneSetupState();
}

class _StepOneSetupState extends State<StepOneSetup> {
  late TextEditingController nameCtrl;
  late TextEditingController amountCtrl;
  late TextEditingController memberCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.data.name);
    amountCtrl = TextEditingController(text: widget.data.amount > 0 ? widget.data.amount.toStringAsFixed(0) : '');
    memberCtrl = TextEditingController(text: widget.data.memberCount.toString());
  }

  void _updateData() {
    setState(() {
      widget.data.name = nameCtrl.text;
      widget.data.amount = double.tryParse(amountCtrl.text) ?? 0.0;
      widget.data.memberCount = int.tryParse(memberCtrl.text) ?? 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isValid = widget.data.name.isNotEmpty && widget.data.amount > 0 && widget.data.memberCount >= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildLabel('Group Name *'),
                _buildTextField(nameCtrl, 'e.g., Monthly Savings Circle', onChanged: (_) => _updateData()),
                const SizedBox(height: 20),

                _buildLabel('Contribution Amount *'),
                _buildTextField(amountCtrl, '0.00', prefix: '₦  ', isNumber: true, onChanged: (_) => _updateData()),
                const SizedBox(height: 20),

                _buildLabel('Contribution Frequency *'),
                Row(
                  children: [
                    _buildFreqBtn('Weekly'),
                    const SizedBox(width: 10),
                    _buildFreqBtn('Bi-weekly'),
                    const SizedBox(width: 10),
                    _buildFreqBtn('Monthly'),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('Number of Members *'),
                _buildTextField(memberCtrl, 'Min 3 members', isNumber: true, onChanged: (_) => _updateData()),
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 20),
                  child: Text('Minimum 3 members required for finance groups', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                ),

                _buildLabel('Start Date *'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.textGray),
                      const SizedBox(width: 10),
                      Text(StringUtilities.formatDate(widget.data.startDate), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.data.amount > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total pool per cycle:', style: TextStyle(color: AppColors.textGray)),
                            Text(StringUtilities.formatNaira(widget.data.totalPool), style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cycle duration:', style: TextStyle(color: AppColors.textGray)),
                            Text('${widget.data.memberCount} ${widget.data.frequency.toLowerCase()} periods', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                const SizedBox(height: 15,),
              ],
            ),
          ),
          GlowingButton(text: 'Continue to Select Members', isEnabled: isValid, onPressed: widget.onNext),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 14)),
  );

  Widget _buildTextField(TextEditingController ctrl, String hint, {String? prefix, bool isNumber = false, Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGray),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Colors.white, fontSize: 16),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildFreqBtn(String text) {
    bool isSelected = widget.data.frequency == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => widget.data.frequency = text);
          _updateData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryOrange.withOpacity(0.8) : AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: isSelected ? Colors.white : AppColors.textGray, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }
}