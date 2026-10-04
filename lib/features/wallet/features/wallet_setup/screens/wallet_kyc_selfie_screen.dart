import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qik_talk/features/wallet/features/wallet_setup/services/wallet_setup_services.dart';
import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';
import 'package:qik_talk/utilities/bottom_nav/provider/custom_bottom_nav_provider.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

import '../../transfer/screens/new_transfer_screens/transfer_mid_ref_screen.dart';

enum VerificationStep { capture, review, verifying, success }

class SelfieVerificationFlow extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const SelfieVerificationFlow({super.key, required this.data});

  @override
  ConsumerState<SelfieVerificationFlow> createState() =>
      _SelfieVerificationFlowState();
}

class _SelfieVerificationFlowState
    extends ConsumerState<SelfieVerificationFlow> {
  VerificationStep _currentStep = VerificationStep.capture;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;

  final WalletSetupServices _walletServices = WalletSetupServices();
  String _loadingMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras?.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      if (frontCamera != null) {
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
        _currentStep = VerificationStep.review;
      });
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _currentStep = VerificationStep.capture;
    });
  }

  Future<void> _startVerificationProcess() async {
    if (_capturedImage == null) return;

    setState(() {
      _currentStep = VerificationStep.verifying;
      _loadingMessage = "Generating secure wallet account...";
    });

    try {
      // Step 1: Generate wallet first (backend requires wallet to exist before facial verification)
      await _walletServices.generateWallet(context: context, data: widget.data);

      if (mounted) {
        setState(() {
          _loadingMessage = "Uploading facial verification...";
        });
      }

      // Step 2: Upload selfie for facial verification via MinIO
      await _walletServices.selfieImageUpload(
        context: context,
        image: _capturedImage!.path,
      );

      if (mounted) {
        setState(() {
          _currentStep = VerificationStep.success;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          _currentStep = VerificationStep.review;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color(0xFF090909),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF070505),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.4),
              radius: 1.2,
              colors: [Color(0xFF221105), Color(0xFF070505)],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(child: _buildCurrentStateView()),
        ),
      ),
    );
  }

  Widget _buildCurrentStateView() {
    switch (_currentStep) {
      case VerificationStep.capture:
        return _buildCaptureOrReviewPhase(isReview: false);
      case VerificationStep.review:
        return _buildCaptureOrReviewPhase(isReview: true);
      case VerificationStep.verifying:
        return _buildVerifyingPhase();
      case VerificationStep.success:
        return _buildSuccessPhase();
    }
  }

  Widget _buildCaptureOrReviewPhase({required bool isReview}) {
    return Column(
      children: [
        _buildAppBar(
          title: "Selfie Verification",
          subtitle: isReview
              ? "Step 2 of 2 (Optional)"
              : "Step 1 of 2 (Optional)",
        ),
        _buildProgressBar(step: isReview ? 2 : 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141312),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF282624),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2C2A28),
                          border: Border.all(
                            color: isReview
                                ? Colors.transparent
                                : const Color(0xFF4A4541),
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: isReview && _capturedImage != null
                            ? Image.file(
                                File(_capturedImage!.path),
                                fit: BoxFit.cover,
                              )
                            : (_isCameraInitialized
                                  ? Transform.scale(
                                      scale:
                                          _cameraController!.value.aspectRatio,
                                      child: Center(
                                        child: CameraPreview(
                                          _cameraController!,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_outline,
                                      size: 60,
                                      color: Colors.white,
                                    )),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isReview
                            ? "✓ Photo captured"
                            : "Position your face in the frame",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD1D1D1),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141312),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF282624),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📸 Tips for best results:",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB0B0B0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem("Ensure good lighting"),
                      _buildTipItem("Remove glasses and hat"),
                      _buildTipItem("Look directly at camera"),
                      _buildTipItem("Keep neutral expression"),
                      const SizedBox(height: 24),
                      isReview
                          ? Row(
                              children: [
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: "Retake",
                                    onTap: _retakePhoto,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildPrimaryGradientButton(
                                    text: "Continue",
                                    onTap: _startVerificationProcess,
                                  ),
                                ),
                              ],
                            )
                          : _buildPrimaryGradientButton(
                              text: "Capture Photo",
                              onTap: _takePhoto,
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TransferMidRefScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Skip for now",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFAFAFAF),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyingPhase() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF141312),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF282624), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  strokeCap: StrokeCap.round,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Verifying\nYour Identity",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Please wait while we verify\nyour information...",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFAFAFAF),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamically updates text based on API progress
                  _buildLoadingStepItem(_loadingMessage),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPhase() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF141312),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF282624), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2C2A28),
                  border: Border.all(color: const Color(0xFF4A4541), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Wallet Created\nSuccessfully!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Congratulations, your account and wallet have\nbeen successfully verified & created.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFAFAFAF),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1A19),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "🎉 You're now a verified user!",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD1D1D1),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildPrimaryGradientButton(
                text: "Go to Dashboard",
                onTap: () async {
                  if (mounted) {
                    // Mark wallet as registered so the gate doesn't trigger again.
                    ref.read(walletRegisteredProvider.notifier).state = true;
                    // Navigate directly to the wallet page, clearing the stack.
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const CustomBottomNav(),
                      ),
                      (route) => false,
                    );
                    // Switch to wallet tab after the nav is rebuilt.
                    Future.microtask(() {
                      ref
                          .read(customBottomNavProvider.notifier)
                          .setPageIndex(4);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.textPrimary(
                        Theme.of(context).brightness == Brightness.dark,
                      ),
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFFAFAFAF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({required int step}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE56A17), Color(0xFF983D08)],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: step == 2
                    ? const LinearGradient(
                        colors: [Color(0xFFE56A17), Color(0xFF983D08)],
                      )
                    : null,
                color: step == 2 ? null : const Color(0xFF2C2A28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFFAFAFAF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFFAFAFAF),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStepItem(String text) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE56A17)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF9A9A9A),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryGradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF4A2511), Color(0xFF8A4213)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF33302D)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
