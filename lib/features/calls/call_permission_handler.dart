import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:permission_handler/permission_handler.dart';

class CallPermissionHandler {
  static Future<bool> requestAudioPermissions(BuildContext context) async {
    final micStatus = await Permission.microphone.request();
    if (micStatus.isDenied || micStatus.isPermanentlyDenied) {
      if (context.mounted) {
        _showDeniedDialog(
          context,
          'Microphone Permission Required',
          'QikTalk needs microphone access to make audio calls.',
        );
      }
      return false;
    }
    return micStatus.isGranted;
  }

  static Future<bool> requestVideoPermissions(BuildContext context) async {
    final micStatus = await Permission.microphone.request();
    final cameraStatus = await Permission.camera.request();

    if (micStatus.isDenied || micStatus.isPermanentlyDenied) {
      if (context.mounted) {
        _showDeniedDialog(
          context,
          'Microphone Permission Required',
          'QikTalk needs microphone access to make calls.',
        );
      }
      return false;
    }
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      if (context.mounted) {
        _showDeniedDialog(
          context,
          'Camera Permission Required',
          'QikTalk needs camera access to make video calls.',
        );
      }
      return false;
    }
    return micStatus.isGranted && cameraStatus.isGranted;
  }

  static Future<bool> hasAudioPermissions() async =>
      Permission.microphone.isGranted;

  static Future<bool> hasVideoPermissions() async =>
      await Permission.microphone.isGranted &&
      await Permission.camera.isGranted;

  static void _showDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HexColor('#2E2E2E'),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: GoogleFonts.poppins(color: HexColor('#FF6B00')),
            ),
          ),
        ],
      ),
    );
  }
}
