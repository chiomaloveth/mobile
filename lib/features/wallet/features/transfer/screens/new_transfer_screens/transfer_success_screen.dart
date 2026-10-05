import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:qik_talk/utilities/bottom_nav/screen/custom_bottom_nav.dart';
import '../../model/local_account_number_response_model.dart';

class TransferSuccessfulScreen extends StatelessWidget {
  final Map<String, dynamic> localAccountNumberResponseModel;

  const TransferSuccessfulScreen({
    super.key,
    required this.localAccountNumberResponseModel
  });

  @override
  Widget build(BuildContext context) {
    final Color textMuted = const Color(0xFF9E928A);
    final Color cardBackground = const Color(0xFF1E140F).withOpacity(0.85);
    final Color successGreen = const Color(0xFF15D261);
    final DateTime now = DateTime.now();
    final String currentDate = DateFormat('EEEE, d MMMM yyyy').format(now);
    final String currentTime = DateFormat('HH:mm:ss').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0804),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF3B2210),
                  Color(0xFF0C0704),
                  Colors.black,
                ],
                center: Alignment.topCenter,
                radius: 1.5,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E140F),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE56B1A).withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: -math.pi / 6,
                        child: const Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transfer Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thanks For Using Qiktalk',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        top: 10,
                        child: ClipPath(
                          clipper: WaveClipper(),
                          child: Container(
                            color: const Color(0xFF261D16).withOpacity(0.5),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  _buildDetailRow('Amount', '₦${_formatNumber(localAccountNumberResponseModel['amount'])}', textMuted, isBold: true),
                                  _buildFadingDivider(),
                                  _buildDetailRow('Method', 'Bank Transfer', textMuted),
                                  _buildFadingDivider(),
                                  _buildDetailRow('Payment Status', localAccountNumberResponseModel['status'], textMuted, valueColor: successGreen),
                                  _buildFadingDivider(),
                                  _buildDetailRow('Description', localAccountNumberResponseModel['description'] ?? '', textMuted),
                                  _buildFadingDivider(),
                                  _buildDetailRow('Ref Number', localAccountNumberResponseModel['reference'].toString().substring(0, 18), textMuted),
                                  _buildFadingDivider(),
                                  _buildDetailRow('Date', currentDate, textMuted),
                                  _buildFadingDivider(),
                                  _buildDetailRow('Time', currentTime, textMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await _generateAndSharePDF(context, currentDate, currentTime);
                              },
                              child: const Center(
                                child: Text(
                                  'Get PDF File',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B3A18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const CustomBottomNav()),
                                        (route) => false);
                              },
                              child: const Center(
                                child: Text(
                                  'Back To Home',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color labelColor, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 15,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFadingDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  String _formatNumber(num number) {
    String numStr = number.toString();
    List<String> parts = numStr.split('.');
    String integerPart = parts[0];
    String formatted = '';
    int count = 0;

    for (int i = integerPart.length - 1; i >= 0; i--) {
      formatted = integerPart[i] + formatted;
      count++;
      if (count % 3 == 0 && i != 0) {
        formatted = ',$formatted';
      }
    }

    if (parts.length > 1) {
      formatted += '.${parts[1]}';
    }
    return formatted;
  }

  Future<void> _generateAndSharePDF(BuildContext context, String date, String time) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Qiktalk Transfer Receipt',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange800,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                _buildPdfRow('Amount', 'NGN ${_formatNumber(localAccountNumberResponseModel['amount'])}', isBold: true),
                pw.Divider(color: PdfColors.grey300),
                _buildPdfRow('Method', 'Bank Transfer'),
                pw.Divider(color: PdfColors.grey300),
                _buildPdfRow('Payment Status', localAccountNumberResponseModel['status']),
                pw.Divider(color: PdfColors.grey300),
                _buildPdfRow('Description', localAccountNumberResponseModel['description'] ?? ''),
                pw.Divider(color: PdfColors.grey300),
                _buildPdfRow('Ref Number', localAccountNumberResponseModel['reference'].toString().substring(0, 18)),
                pw.Divider(color: PdfColors.grey300),
                _buildPdfRow('Date', date),
                pw.Divider(color: PdfColors.grey300),
                _buildPdfRow('Time', time),
                pw.SizedBox(height: 60),
                pw.Center(
                  child: pw.Text(
                    'Thanks For Using Qiktalk',
                    style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/Qiktalk_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is your Qiktalk transfer receipt.',
      );
    } catch (e) {
      debugPrint("Error generating or sharing PDF: $e");
    }
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 45, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}