import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simplified permission service for QikTalk
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request camera permission
  Future<PermissionResult> requestCamera(BuildContext context) async {
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        return PermissionResult.granted;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showSettingsDialog(context, 'Camera');
        }
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.denied;
      }
    } catch (e) {
      debugPrint('❌ Camera permission error: $e');
      return PermissionResult.denied;
    }
  }

  /// Request microphone permission
  Future<PermissionResult> requestMicrophone(BuildContext context) async {
    try {
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        return PermissionResult.granted;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showSettingsDialog(context, 'Microphone');
        }
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.denied;
      }
    } catch (e) {
      debugPrint('❌ Microphone permission error: $e');
      return PermissionResult.denied;
    }
  }

  /// Request storage permission (handles Android 13+ automatically)
  Future<PermissionResult> requestStorage(BuildContext context) async {
    try {
      PermissionStatus status;

      if (Platform.isAndroid) {
        // Try photos first (Android 13+)
        status = await Permission.photos.request();

        // If photos doesn't work, try storage (Android 12 and below)
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      } else {
        // iOS
        status = await Permission.photos.request();
      }

      if (status.isGranted || status.isLimited) {
        return PermissionResult.granted;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showSettingsDialog(context, 'Storage/Photos');
        }
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.denied;
      }
    } catch (e) {
      debugPrint('❌ Storage permission error: $e');
      // If permission_handler fails, just return granted and let the system handle it
      return PermissionResult.granted;
    }
  }

  /// Request contacts permission
  Future<PermissionResult> requestContacts(BuildContext context) async {
    try {
      final status = await Permission.contacts.request();

      if (status.isGranted) {
        return PermissionResult.granted;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showSettingsDialog(context, 'Contacts');
        }
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.denied;
      }
    } catch (e) {
      debugPrint('❌ Contacts permission error: $e');
      return PermissionResult.denied;
    }
  }

  /// Request notification permission
  Future<PermissionResult> requestNotification(BuildContext context) async {
    try {
      final status = await Permission.notification.request();

      if (status.isGranted) {
        return PermissionResult.granted;
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showSettingsDialog(context, 'Notifications');
        }
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.denied;
      }
    } catch (e) {
      debugPrint('❌ Notification permission error: $e');
      return PermissionResult.denied;
    }
  }

  /// Show settings dialog
  Future<void> _showSettingsDialog(
    BuildContext context,
    String permissionName,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permission Required',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Please enable $permissionName access in your device settings.',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A7F4B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Public method to show settings dialog
  Future<void> showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A7F4B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Permission result enum
enum PermissionResult { granted, denied, permanentlyDenied }
