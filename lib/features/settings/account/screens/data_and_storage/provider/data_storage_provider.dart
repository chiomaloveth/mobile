import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';
import '../services/data_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class StorageData {
  final int messageBytes;
  final int mediaBytes;
  final int documentBytes;
  final int cacheBytes;

  int get totalBytes => messageBytes + mediaBytes + documentBytes + cacheBytes;

  StorageData({
    this.messageBytes = 0,
    this.mediaBytes = 0,
    this.documentBytes = 0,
    this.cacheBytes = 0,
  });

  String get formattedTotal => _formatBytes(totalBytes);
  String get formattedMessages => _formatBytes(messageBytes);
  String get formattedMedia => _formatBytes(mediaBytes);
  String get formattedDocs => _formatBytes(documentBytes);
  String get formattedCache => _formatBytes(cacheBytes);

  static String _formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1048576)
      return "${(bytes / 1024).toStringAsFixed(decimals)} KB";
    if (bytes < 1073741824)
      return "${(bytes / 1048576).toStringAsFixed(decimals)} MB";
    return "${(bytes / 1073741824).toStringAsFixed(decimals)} GB";
  }
}

class NetworkUsageData {
  final int sentBytes;
  final int receivedBytes;

  NetworkUsageData({this.sentBytes = 0, this.receivedBytes = 0});

  String get formattedSent => StorageData._formatBytes(sentBytes);
  String get formattedReceived => StorageData._formatBytes(receivedBytes);
  String get formattedTotal =>
      StorageData._formatBytes(sentBytes + receivedBytes);
}

// ─────────────────────────────────────────────────────────────────────────────
// STORAGE USAGE NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class StorageUsageNotifier extends StateNotifier<AsyncValue<StorageData>> {
  final DataStorageService _dataStorageService = DataStorageService();
  
  StorageUsageNotifier() : super(const AsyncValue.loading()) {
    Future.microtask(() => calculateStorage());
  }

  Future<void> calculateStorage() async {
    try {
      if (mounted) state = const AsyncValue.loading();

      // Try to get real storage data from backend first
      Map<String, dynamic>? backendData;
      try {
        backendData = await _dataStorageService.getStorageInfo();
      } catch (e) {
        print('Failed to get backend storage info: $e');
      }

      int messageBytes = 0;
      int mediaBytes = 0;
      int documentBytes = 0;
      int cacheBytes = 0;

      if (backendData != null) {
        // Use backend data if available
        messageBytes = (backendData['usedStorage'] as int?) ?? 0;
        mediaBytes = (backendData['mediaStorage'] as int?) ?? 0;
        documentBytes = (backendData['documentsStorage'] as int?) ?? 0;
        cacheBytes = (backendData['cacheStorage'] as int?) ?? 0;
      } else {
        // Fallback to local calculation
        // ── Messages: sum sizeInBytes from Hive records directly ─────────────
        try {
          final msgBox = await _getBoxAny(DBService.boxMessages);
          for (final msg in msgBox.values) {
            if (msg is MessageModel) messageBytes += msg.sizeInBytes;
          }
        } catch (_) {}

        // ── Media: sum sizeInBytes from Hive records directly ─────────────────
        try {
          final mediaBox = await _getBoxAny(DBService.boxMedia);
          for (final m in mediaBox.values) {
            if (m is MediaModel) mediaBytes += m.sizeInBytes;
          }
        } catch (_) {}

        // ── Documents: sum sizeInBytes from Hive records directly ─────────────
        try {
          final docBox = await _getBoxAny(DBService.boxDocs);
          for (final d in docBox.values) {
            if (d is DocumentModel) documentBytes += d.sizeInBytes;
          }
        } catch (_) {}

        // ── Cache: temp directory size ─────────────────────────────────────────
        try {
          final tempDir = await getTemporaryDirectory();
          cacheBytes = await _getDirSize(tempDir);
        } catch (_) {}
      }

      if (mounted) {
        state = AsyncValue.data(
          StorageData(
            messageBytes: messageBytes,
            mediaBytes: mediaBytes,
            documentBytes: documentBytes,
            cacheBytes: cacheBytes,
          ),
        );
      }
    } catch (e, st) {
      print('❌ Error calculating storage: $e');
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<int> _getDirSize(Directory dir) async {
    int total = 0;
    if (!dir.existsSync()) return 0;
    try {
      await for (final entity
          in dir
              .list(recursive: true, followLinks: false)
              .handleError((_) {})) {
        if (entity is File) {
          total += await entity.length().catchError((_) => 0);
        }
      }
    } catch (_) {}
    return total;
  }

  Future<void> clearCache() async {
    try {
      // Try backend cache clearing first
      final success = await _dataStorageService.clearCache();
      if (success) {
        print('✅ Backend cache cleared successfully');
      }
    } catch (e) {
      print('❌ Backend cache clear failed: $e');
    }

    // Also clear local cache
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      try {
        await for (final entity in tempDir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {}
        }
      } catch (e) {
        print('Error clearing local cache: $e');
      }
    }
    await calculateStorage();
  }

  Future<void> clearAllData() async {
    try {
      // Try backend media cache clearing first
      try {
        final success = await _dataStorageService.clearMediaCache();
        if (success) {
          print('✅ Backend media cache cleared successfully');
        }
      } catch (e) {
        print('❌ Backend media cache clear failed: $e');
      }

      // ── 1. Delete actual media files tracked in the media box ─────────────
      try {
        final mediaBox = await _getBoxAny(DBService.boxMedia);
        for (final m in mediaBox.values) {
          if (m is MediaModel) {
            final file = File(m.filePath);
            if (file.existsSync()) {
              await file.delete();
            }
          }
        }
      } catch (_) {}

      // ── 2. Delete actual document files tracked in the docs box ───────────
      try {
        final docBox = await _getBoxAny(DBService.boxDocs);
        for (final d in docBox.values) {
          if (d is DocumentModel) {
            final file = File(d.filePath);
            if (file.existsSync()) {
              await file.delete();
            }
          }
        }
      } catch (_) {}

      // ── 3. Clear all Hive boxes ────────────────────────────────────────────
      final msgBox = await _getBoxAny(DBService.boxMessages);
      final mediaBox2 = await _getBoxAny(DBService.boxMedia);
      final docBox2 = await _getBoxAny(DBService.boxDocs);
      final statsBox = await _getBoxAny(DBService.boxStats);

      await msgBox.clear();
      await mediaBox2.clear();
      await docBox2.clear();
      await statsBox.clear();

      await msgBox.compact();
      await mediaBox2.compact();
      await docBox2.compact();
      await statsBox.compact();

      // ── 4. Clear Flutter's in-memory image cache ───────────────────────────
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // ── 5. Reset network usage counters ───────────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('net_sent', 0);
      await prefs.setInt('net_recv', 0);

      // ── 6. Clear cache directory ───────────────────────────────────────────
      await clearCache();
    } catch (e) {
      print("Error clearing data: $e");
    }
  }

  Future<Box> _getBoxAny(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    } else {
      return await Hive.openBox(boxName);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NETWORK USAGE NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class NetworkUsageNotifier extends StateNotifier<AsyncValue<NetworkUsageData>> {
  NetworkUsageNotifier() : super(const AsyncValue.loading()) {
    _loadNetworkStats();
  }

  Future<void> _loadNetworkStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sent = prefs.getInt('net_sent') ?? 0;
      final recv = prefs.getInt('net_recv') ?? 0;
      if (mounted) {
        state = AsyncValue.data(
          NetworkUsageData(sentBytes: sent, receivedBytes: recv),
        );
      }
    } catch (e) {
      if (mounted) state = AsyncValue.data(NetworkUsageData());
    }
  }

  /// Call this whenever you upload or download data to accumulate real usage.
  ///
  /// Example – after uploading an image in message_screen.dart:
  ///   final size = await file.length();
  ///   ref.read(networkUsageProvider.notifier).record(sent: size);
  ///
  /// Example – after a file download completes:
  ///   ref.read(networkUsageProvider.notifier).record(received: downloadedBytes);
  Future<void> record({int sent = 0, int received = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final newSent = (prefs.getInt('net_sent') ?? 0) + sent;
    final newRecv = (prefs.getInt('net_recv') ?? 0) + received;
    await prefs.setInt('net_sent', newSent);
    await prefs.setInt('net_recv', newRecv);
    if (mounted) {
      state = AsyncValue.data(
        NetworkUsageData(sentBytes: newSent, receivedBytes: newRecv),
      );
    }
  }

  Future<void> refresh() async => _loadNetworkStats();

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('net_sent', 0);
    await prefs.setInt('net_recv', 0);
    if (mounted) state = AsyncValue.data(NetworkUsageData());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final storageUsageProvider =
    StateNotifierProvider<StorageUsageNotifier, AsyncValue<StorageData>>(
      (ref) => StorageUsageNotifier(),
    );

final networkUsageProvider =
    StateNotifierProvider<NetworkUsageNotifier, AsyncValue<NetworkUsageData>>(
      (ref) => NetworkUsageNotifier(),
    );
