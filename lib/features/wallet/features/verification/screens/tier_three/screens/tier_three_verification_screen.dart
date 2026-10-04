import 'package:qik_talk/utilities/constants/app_theme.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';

import '../../../../../../../utilities/constants/app_colors.dart';
import '../components/custom_label.dart';
import '../components/dashed_upload_box.dart';
import '../components/info_card.dart';
import '../components/instructions_card.dart';
import '../components/primary_button.dart';
import '../components/selectable_card.dart';
import '../components/success_upload_box.dart';
import '../components/tier_three_custom_text_field.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int currentStep = 1;
  String? selectedDocumentType;
  bool isDocumentUploaded = false;
  bool isUtilityBillUploaded = false;
  bool isFaceCaptured = false;
  bool isRecording = false;
  bool isProcessingComplete = false;

  void nextStep() {
    if (currentStep < 6) {
      setState(() => currentStep++);
      if (currentStep == 6) _simulateProcessing();
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _simulateProcessing() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() => isProcessingComplete = true);
    }
  }

  String _getStepTitle() {
    switch (currentStep) {
      case 1:
        return 'Identity Details';
      case 2:
        return 'Document Upload';
      case 3:
        return 'Address Verification';
      case 4:
        return 'Facial Verification';
      case 5:
        return 'Video Verification';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(Theme.of(context).brightness == Brightness.dark),
      extendBodyBehindAppBar: true,
      appBar: currentStep < 6
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark)),
                onPressed: previousStep,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStepTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark),
                    ),
                  ),
                  Text(
                    'Step $currentStep of 6${currentStep == 5 ? ' (Optional)' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.6) : AppTheme.textSecondary(Theme.of(context).brightness == Brightness.dark),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF96D15).withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF96D15).withOpacity(0.2),
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                if (currentStep < 6) _buildProgressBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1.2,
                              ),
                            ),
                            child: _buildCurrentStep(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: List.generate(6, (index) {
          bool isActive = index < currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 5 ? 0 : 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFF6B00)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF6B00).withOpacity(0.4),
                          blurRadius: 4,
                        ),
                      ]
                    : [],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      case 5:
        return _buildStep5();
      case 6:
        return _buildStep6();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const InfoCard(
          icon: '⚡',
          title: 'Advanced Verification',
          description: 'Both BVN and NIN are required for Tier 3 verification',
        ),
        const SizedBox(height: 24),
        const CustomLabel('BVN Number'),
        const TierThreeCustomTextField(hintText: 'Enter 11-digit BVN'),
        const SizedBox(height: 20),
        const CustomLabel('NIN Number'),
        const TierThreeCustomTextField(hintText: 'Enter 11-digit NIN'),
        const SizedBox(height: 24),
        PrimaryButton(text: 'Continue', onPressed: nextStep),
      ],
    );
  }

  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Select document type:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        SelectableCard(
          title: "Driver's License",
          icon: '🪪',
          isSelected: selectedDocumentType == 'Driver',
          onTap: () => setState(() => selectedDocumentType = 'Driver'),
        ),
        const SizedBox(height: 12),
        SelectableCard(
          title: "International Passport",
          icon: '📕',
          isSelected: selectedDocumentType == 'Passport',
          onTap: () => setState(() => selectedDocumentType = 'Passport'),
        ),
        const SizedBox(height: 24),
        if (selectedDocumentType != null) ...[
          GestureDetector(
            onTap: () => setState(() => isDocumentUploaded = true),
            child: isDocumentUploaded
                ? SuccessUploadBox(
                    title: 'Document uploaded',
                    subtitle: 'id_document.jpg',
                  )
                : const DashedUploadBox(
                    title: 'Tap to upload ID',
                    subtitle: 'PNG or JPG (max. 5MB)',
                  ),
          ),
          const SizedBox(height: 24),
        ],
        const InstructionsCard(
          icon: '📋',
          title: 'Requirements:',
          items: [
            'Clear and readable',
            'Not expired',
            'Shows full name and photo',
          ],
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          text: 'Continue',
          onPressed: selectedDocumentType != null && isDocumentUploaded
              ? nextStep
              : null,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CustomLabel('Residential Address'),
        const TierThreeCustomTextField(hintText: 'e.g. 123 Lekki Phase 1'),
        const SizedBox(height: 24),
        if (!isUtilityBillUploaded)
          GestureDetector(
            onTap: () => setState(() => isUtilityBillUploaded = true),
            child: const DashedUploadBox(
              title: 'Upload Utility Bill',
              subtitle: 'Electricity or Water bill',
            ),
          )
        else
          const SuccessUploadBox(
            title: 'Bill uploaded',
            subtitle: 'utility_bill.pdf',
          ),
        const SizedBox(height: 24),
        const InstructionsCard(
          icon: '📄',
          title: 'Bill must be:',
          items: ['Not older than 3 months', 'Show your name clearly'],
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          text: 'Continue',
          onPressed: isUtilityBillUploaded ? nextStep : null,
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFaceCaptured
                        ? Colors.greenAccent
                        : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isFaceCaptured
                      ? Icons.check_circle
                      : Icons.face_unlock_outlined,
                  size: 70,
                  color: isFaceCaptured
                      ? Colors.greenAccent
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isFaceCaptured ? 'Face captured!' : 'Align face in the circle',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const InstructionsCard(
          icon: '📸',
          title: 'Tips:',
          items: ['Good lighting', 'No glasses/hats', 'Look straight'],
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          text: isFaceCaptured ? 'Continue' : 'Capture Face',
          onPressed: () {
            if (isFaceCaptured)
              nextStep();
            else
              setState(() => isFaceCaptured = true);
          },
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_outlined,
                size: 60,
                color: isRecording
                    ? Colors.redAccent
                    : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                isRecording ? 'Recording...' : 'Ready to record',
                style: TextStyle(
                  color: isRecording
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const InstructionsCard(
          icon: '📹',
          title: 'Say clearly:',
          items: ['"I am [Your Full Name]"', 'Show face for 3 seconds'],
        ),
        const SizedBox(height: 30),
        PrimaryButton(
          text: isRecording ? 'Processing...' : 'Start Recording',
          onPressed: () {
            setState(() => isRecording = true);
            Future.delayed(const Duration(seconds: 2), nextStep);
          },
        ),
        TextButton(
          onPressed: nextStep,
          child: const Text(
            'Skip for now',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildStep6() {
    if (!isProcessingComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFFF6B00)),
            const SizedBox(height: 40),
            const Text(
              "Finalizing...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressList(),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: Icon(
            Icons.verified_user_rounded,
            size: 80,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tier 3 Complete! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Text(
                'Daily Transaction Limit',
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 8),
              Text(
                'UNLIMITED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          text: 'Finish',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CustomBottomNav()),
              (r) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressList() {
    return Column(
      children: ['Verifying ID...', 'Matching Face...', 'Authenticating...']
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(s, style: const TextStyle(color: Colors.white38)),
            ),
          )
          .toList(),
    );
  }
}
