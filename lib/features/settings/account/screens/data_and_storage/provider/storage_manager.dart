import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import 'data_storage_provider.dart';
import 'data_storage_backend_provider.dart';

class AppStorageManager {

  // 1. SAVE MESSAGE
  static Future<void> saveMessage(String id, String content, WidgetRef ref) async {
    final bytes = content.length; // Approximate byte size for text
    final message = MessageModel(
      id: id,
      content: content,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sizeInBytes: bytes,
    );

    await DBService.messages.put(id, message);

    // Refresh UI
    ref.read(storageUsageProvider.notifier).calculateStorage();
  }

  // 2. SAVE MEDIA (Photos, Videos)
  static Future<void> saveMedia(String id, File file, String type, WidgetRef ref) async {
    final int size = await file.length();

    final media = MediaModel(
      id: id,
      filePath: file.path,
      type: type, // 'photo' or 'video'
      sizeInBytes: size,
    );

    await DBService.media.put(id, media);
    ref.read(storageUsageProvider.notifier).calculateStorage();
  }

  // 3. SAVE DOCUMENT
  static Future<void> saveDocument(String id, File file, WidgetRef ref) async {
    final int size = await file.length();

    final doc = DocumentModel(
      id: id,
      filePath: file.path,
      sizeInBytes: size,
    );

    await DBService.docs.put(id, doc);
    ref.read(storageUsageProvider.notifier).calculateStorage();
  }

  // 4. TRACK NETWORK USAGE
  static Future<void> trackNetworkUsage(int sentBytes, int receivedBytes, WidgetRef ref) async {
    final box = DBService.stats;
    final currentStats = box.get('usage') ?? NetworkStatsModel();

    currentStats.sentBytes += sentBytes;
    currentStats.receivedBytes += receivedBytes;

    await currentStats.save(); // HiveObject save

    ref.read(networkUsageProvider.notifier).refresh();
  }

  // 5. CHECK AUTO DOWNLOAD
  static bool shouldDownload(String mediaType, WidgetRef ref) {
    // mediaType: 'photos', 'videos', 'docs'
    final settings = ref.read(dataSettingsProvider);
    switch (mediaType) {
      case 'photos': return settings.cellularPhotos;
      case 'videos': return settings.cellularVideos;
      case 'docs':   return settings.cellularDocs;
      default:       return false;
    }
  }
}