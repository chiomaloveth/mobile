import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/utilities/constants/app_theme.dart';

const Color _bgColor = Color(0xFF0A0A0A);
const Color _cardGlassColor = Color(0xFF1A1613);
const Color _brandBrown = Color(0xFF5A2A08);
const Color _textGrey = Color(0xFF8A8A8E);
const Color _successGreen = Color(0xFF32D74B);

class AirtimeReceiptFlow extends StatelessWidget {
  const AirtimeReceiptFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const AirtimeSuccessScreen();
  }
}

class AirtimeSuccessScreen extends StatelessWidget {
  const AirtimeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          _buildAmbientGlow(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _successGreen.withOpacity(0.15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _successGreen,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Airtime Recharge\nSuccessful!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Airtime has been credited",
                      style: TextStyle(color: Color(0xFF9E7C5D), fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "₦",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          "100",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Transaction Detail Card
                    _GlassReceiptCard(
                      child: Column(
                        children: [
                          _buildDetailRow("Provider", "MTN"),
                          _buildDivider(),
                          _buildDetailRow("Phone Number", "08167862376"),
                          _buildDivider(),
                          _buildDetailRow(
                            "Payment Status",
                            "Success",
                            valueColor: _successGreen,
                          ),
                          _buildDivider(),
                          _buildDetailRow("Ref Number", "REF442102541"),
                          _buildDivider(),
                          _buildDetailRow("Date", "Monday, 30 March 2026"),
                          _buildDivider(),
                          _buildDetailRow("Time", "14:19:31"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryButton(
                            Icons.share_outlined,
                            "Share",
                            () => _showShareSheet(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSecondaryButton(
                            Icons.file_download_outlined,
                            "Download",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AirtimeDetailsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPrimaryButton(
                      Icons.home_outlined,
                      "Back To Home",
                      () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AirtimeDetailsScreen extends StatelessWidget {
  const AirtimeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        surfaceTintColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary(Theme.of(context).brightness == Brightness.dark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Airtime Receipt",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Transaction details",
              style: TextStyle(color: _textGrey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildAmbientGlow(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _GlassReceiptCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const CircleAvatar(
                            backgroundColor: Color(0xFF3D2510),
                            radius: 30,
                            child: Text("💰", style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "QikTalk",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Transaction Receipt",
                            style: TextStyle(color: _textGrey, fontSize: 13),
                          ),
                          const SizedBox(height: 24),
                          _buildDashedLine(),
                          const SizedBox(height: 24),
                          const Text(
                            "Amount Paid",
                            style: TextStyle(color: _textGrey, fontSize: 14),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "₦",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "100",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDashedLine(),
                          const SizedBox(height: 24),
                          _buildDetailRow("Provider", "MTN"),
                          const SizedBox(height: 16),
                          _buildDetailRow("Phone Number", "08167862376"),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            "Status",
                            "Success",
                            valueColor: _successGreen,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow("Reference", "REF408981733"),
                          const SizedBox(height: 16),
                          _buildDetailRow("Date", "Monday, 30 March 2026"),
                          const SizedBox(height: 16),
                          _buildDetailRow("Time", "15:04:18"),
                          const SizedBox(height: 24),
                          _buildDashedLine(),
                          const SizedBox(height: 20),
                          const Text(
                            "Thank you for using PayFlow",
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                          const Text(
                            "support@payflow.com",
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryButton(
                            Icons.share_outlined,
                            "Share",
                            () => _showShareSheet(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSecondaryButton(
                            Icons.file_download_outlined,
                            "Download",
                            () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPrimaryButton(null, "Back To Home", () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Widget _buildAmbientGlow() {
  return Positioned(
    bottom: -100,
    left: 0,
    right: 0,
    child: Container(
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange.withOpacity(0.08),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    ),
  );
}

class _GlassReceiptCard extends StatelessWidget {
  final Widget child;

  const _GlassReceiptCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardGlassColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _textGrey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDivider() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    height: 1,
    color: Colors.white.withOpacity(0.05),
  );
}

Widget _buildDashedLine() {
  return Row(
    children: List.generate(
      30,
      (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? Colors.transparent : Colors.white12,
          height: 1,
        ),
      ),
    ),
  );
}

Widget _buildPrimaryButton(IconData? icon, String text, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSecondaryButton(IconData icon, String text, VoidCallback onTap) {
  return SizedBox(
    height: 56,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

void _showShareSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1611),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Share Receipt As",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildShareOption(
              icon: Icons.picture_as_pdf,
              iconColor: Color(0xFFE57373),
              title: "Share as PDF",
              subtitle: "Portable document format",
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              icon: Icons.image_outlined,
              iconColor: Color(0xFF64B5F6),
              title: "Share as Image",
              subtitle: "PNG image format",
            ),
            const SizedBox(height: 24),
            _buildPrimaryButton(null, "Cancel", () => Navigator.pop(context)),
          ],
        ),
      ),
    ),
  );
}

Widget _buildShareOption({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: _textGrey, fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );
}
