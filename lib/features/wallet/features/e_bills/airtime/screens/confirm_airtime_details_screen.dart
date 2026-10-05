import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/features/e_bills/services/e_bills_services.dart';

import '../../../../../../utilities/constants/app_colors.dart';
import '../../mobile_data/mobile_data_screen.dart';
import '../../utilities/enter_pin_bottom_sheet.dart';
import 'airtime_receipt_screen.dart';
import 'security_pin_screen.dart';

class ConfirmAirtimeDetailsScreen extends StatefulWidget {
  final String phoneNumber;
  final String amount;
  final String networkName;
  const ConfirmAirtimeDetailsScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
    required this.networkName,
  });

  @override
  State<ConfirmAirtimeDetailsScreen> createState() => _ConfirmAirtimeDetailsScreenState();
}

class _ConfirmAirtimeDetailsScreenState extends State<ConfirmAirtimeDetailsScreen> {
  final EBillsServices _eBillsServices = EBillsServices();
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you sure?',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Are you sure you want to confirm this payment? This action cannot be undone.',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBrown,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showPinSheet(context);
                        },
                        child: const Text(
                          'Proceed',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showPinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnterPinBottomSheet(
        // 1. We expect a bool return now
        onClick: () async {
          // Await the int status code from your backend
          int statusCode = await _eBillsServices.buyAirtime(
              context: context,
              phoneNumber: widget.phoneNumber,
              service: widget.networkName,
              amount: widget.amount
          );

          // Check if it was successful
          if (statusCode == 200 || statusCode == 201) {
            return true; // Tells the bottom sheet to call onSuccess()
          } else if (statusCode == -1) {
            // Throwing an error here triggers the catch block inside
            // EnterPinBottomSheet, which will show your red SnackBar!
            throw 'Check your internet connection';
          } else {
            throw 'Transaction failed. Please try again.';
          }
        },
        onSuccess: () {
          // Bottom sheet is already popped by EnterPinBottomSheet,
          // so we just navigate to the receipt screen.
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AirtimeReceiptFlow()
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(
          0xFF000000,
        ), // Pure black for glow contrast
        body: SafeArea(
          child: Stack(
            children: [
              // Background Glow Effect (Highlight from Figma)
              Positioned.fill(
                child: Center(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6900).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              // Main Content
              Column(
                children: [
                  // App Bar
                  _AppBar(onBack: () => Navigator.pop(context)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Phone Icon Circle
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0x33FF6900),
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: const Color(0x4DFF8904),
                              ),
                            ),
                            child: const Icon(
                              Icons.smartphone,
                              color: Color(0xFFFFB86A),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Amount to Pay',
                            style: GoogleFonts.inter(
                              color: const Color(0xB2FFD6A8),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₦',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 25.97,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.amount,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Details Card (Glassmorphic Container)
                          _DetailsCard(
                            serviceType: 'Airtime Recharge',
                            provider: widget.networkName.toUpperCase(),
                            phoneNumber: widget.phoneNumber,
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Buttons
                  _BottomButtons(
                    onConfirm: () => _showConfirmationDialog(context),
                    onEdit: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _AppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 17),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Details',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Review your airtime recharge',
                style: GoogleFonts.inter(
                  color: const Color(0xB2FFD6A8),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String serviceType;
  final String provider;
  final String phoneNumber;

  const _DetailsCard({
    required this.serviceType,
    required this.provider,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF8904).withValues(alpha: 0.05),
                const Color(0xFF000000).withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(25.97),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _DetailRow(label: 'Service Type', value: serviceType),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  height: 1.08,
                  width: 295.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF000000).withValues(alpha: 0.0),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                        const Color(0xFF000000).withValues(alpha: 0.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              _DetailRow(label: 'Provider', value: provider),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  height: 1.08,
                  width: 295.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF000000).withValues(alpha: 0.0),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                        const Color(0xFF000000).withValues(alpha: 0.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              _DetailRow(label: 'Phone Number', value: phoneNumber),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFFFFD6A8).withValues(alpha: 0.7),
            fontSize: 15.15,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15.15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const _BottomButtons({required this.onConfirm, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Column(
        children: [
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E1A0B), Color(0xFF6A3710)],
                  //stops: [0.0, 0.3],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                'Confirm & Pay',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              alignment: Alignment.center,
              child: Text(
                'Edit Details',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

