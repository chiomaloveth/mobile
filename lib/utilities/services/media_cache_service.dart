import 'dart:io';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:qik_talk/core/network/network_provider.dart';

part 'media_cache_service.g.dart';

/// Represents cached media metadata
@HiveType(typeId: 4)
class MediaCacheEntry extends HiveObject {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final String localPath;

  @HiveField(2)
  final String? thumbnailPath;

  @HiveField(3)
  final DateTime cachedAt;

  @HiveField(4)
  final int fileSize;

  @HiveField(5)
  final String mediaType; // 'image', 'video', 'audio', 'document'

  MediaCacheEntry({
    required this.url,
    required this.localPath,
    this.thumbnailPath,
    required this.cachedAt,
    required this.fileSize,
    required this.mediaType,
  });
}

/// Service to manage media caching for offline access.
/// Singleton — call MediaCacheService() anywhere.
class MediaCacheService {
  static final MediaCacheService _instance = MediaCacheService._internal();
  factory MediaCacheService() => _instance;
  MediaCacheService._internal();

  late Box<MediaCacheEntry> _cacheBox;
  bool _isInitialized = false;
  late Directory _cacheDir;

  // Internal Dio client for optimized downloads
  final dio_lib.Dio _dio = dio_lib.Dio(
    dio_lib.BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ),
  )..interceptors.add(AuthInterceptor());

  // In-flight download tracking — prevents duplicate concurrent downloads
  final Map<String, Future<String?>> _inFlight = {};

  // URLs that returned permanent errors (401/403/404) — skip retries this session
  final Set<String> _failedUrls = {};

  /// Call once from main() after Hive is initialized.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cacheBox = await Hive.openBox<MediaCacheEntry>('media_cache');

      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/media_cache');
      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
      }

      _isInitialized = true;
      print('✅ MediaCacheService initialized: ${_cacheDir.path}');

      // Clean entries older than 30 days on startup
      await _cleanOldCache();
    } catch (e) {
      print('❌ Error initializing MediaCacheService: $e');
    }
  }

  // ── Key helpers ────────────────────────────────────────────────────────────

  String _getCacheKey(String url) => md5.convert(utf8.encode(url)).toString();

  // ── Public read API ────────────────────────────────────────────────────────

  /// Returns true if [url] is cached AND the file still exists on disk.
  bool isCached(String url) {
    if (!_isInitialized) return false;
    final key = _getCacheKey(url);
    final entry = _cacheBox.get(key);
    if (entry == null) return false;
    return File(entry.localPath).existsSync();
  }

  /// Returns the local file path for [url], or null if not cached.
  /// Verifies the file still exists — cleans up stale entries automatically.
  String? getCachedPath(String url) {
    if (!_isInitialized) return null;
    final key = _getCacheKey(url);
    final entry = _cacheBox.get(key);
    if (entry == null) return null;

    final file = File(entry.localPath);
    if (file.existsSync()) return entry.localPath;

    // File deleted from disk — remove stale Hive entry
    _cacheBox.delete(key);
    return null;
  }

  /// Returns the local thumbnail path for [url], or null if not cached.
  String? getThumbnailPath(String url) {
    if (!_isInitialized) return null;
    final key = _getCacheKey(url);
    final entry = _cacheBox.get(key);
    if (entry?.thumbnailPath == null) return null;
    if (File(entry!.thumbnailPath!).existsSync()) return entry.thumbnailPath;
    return null;
  }

  /// Remove a specific cache entry (e.g. after a file-not-found error).
  void invalidateCacheEntry(String url) {
    if (!_isInitialized) return;
    final key = _getCacheKey(url);
    final entry = _cacheBox.get(key);
    if (entry == null) return;
    try {
      File(entry.localPath).deleteSync();
    } catch (_) {}
    _cacheBox.delete(key);
  }

  /// Registers an already-downloaded local file as the cache entry for [url].
  /// Useful when media starts as a local file and later gets a remote URL.
  Future<void> registerCachedMedia({
    required String url,
    required String localPath,
    required String mediaType,
    String? thumbnailPath,
  }) async {
    if (!_isInitialized) await initialize();
    if (url.isEmpty || localPath.isEmpty) return;

    final file = File(localPath);
    if (!file.existsSync()) return;

    final key = _getCacheKey(url);
    final entry = MediaCacheEntry(
      url: url,
      localPath: localPath,
      thumbnailPath: thumbnailPath,
      cachedAt: DateTime.now(),
      fileSize: await file.length(),
      mediaType: mediaType,
    );

    await _cacheBox.put(key, entry);
  }

  // ── Download + cache ───────────────────────────────────────────────────────

  /// Download [url] and store locally. Returns the local path on success.
  /// Safe to call concurrently — deduplicates in-flight requests.
  Future<String?> cacheMedia({
    required String url,
    required String mediaType,
    String? thumbnailUrl,
  }) async {
    if (!_isInitialized) await initialize();

    // Already cached?
    final existing = getCachedPath(url);
    if (existing != null) return existing;

    // Skip URLs that previously returned permanent errors (401/403/404)
    if (_failedUrls.contains(url)) return null;

    // Deduplicate concurrent downloads of the same URL
    if (_inFlight.containsKey(url)) return _inFlight[url];

    final future = _downloadAndCache(
      url: url,
      mediaType: mediaType,
      thumbnailUrl: thumbnailUrl,
    );
    _inFlight[url] = future;

    try {
      return await future;
    } finally {
      _inFlight.remove(url);
    }
  }

  Future<String?> _downloadAndCache({
    required String url,
    required String mediaType,
    String? thumbnailUrl,
  }) async {
    try {
      print('📥 Downloading: $url');

      final response = await _dio.get<List<int>>(
        url,
        options: dio_lib.Options(responseType: dio_lib.ResponseType.bytes),
      );

      if (response.statusCode != 200 || response.data == null) {
        print('❌ Download failed (${response.statusCode}): $url');
        return null;
      }

      final List<int> bytes = response.data!;
      final key = _getCacheKey(url);
      final ext = path.extension(url).split('?').first;
      final filename = '$key$ext';
      final localPath = '${_cacheDir.path}/$filename';

      await File(localPath).writeAsBytes(bytes);

      String? thumbnailPath;
      if (thumbnailUrl != null) {
        try {
          final thumbResponse = await _dio.get<List<int>>(
            thumbnailUrl,
            options: dio_lib.Options(responseType: dio_lib.ResponseType.bytes),
          );
          if (thumbResponse.statusCode == 200 && thumbResponse.data != null) {
            final thumbExt = path.extension(thumbnailUrl).split('?').first;
            thumbnailPath = '${_cacheDir.path}/${key}_thumb$thumbExt';
            await File(thumbnailPath).writeAsBytes(thumbResponse.data!);
          }
        } catch (e) {
          print('⚠️ Thumbnail download failed: $e');
        }
      }

      final entry = MediaCacheEntry(
        url: url,
        localPath: localPath,
        thumbnailPath: thumbnailPath,
        cachedAt: DateTime.now(),
        fileSize: bytes.length,
        mediaType: mediaType,
      );

      await _cacheBox.put(key, entry);
      print('✅ Cached: $localPath');
      return localPath;
    } on dio_lib.DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && (statusCode == 401 || statusCode == 403 || statusCode == 404)) {
        _failedUrls.add(url);
        print('⛔ Permanently failed ($statusCode), blacklisted: $url');
      } else {
        print('❌ Cache error for $url: $e');
      }
      return null;
    } catch (e) {
      print('❌ Cache error for $url: $e');
      return null;
    }
  }

  // ── Preloading ─────────────────────────────────────────────────────────────

  /// Fire-and-forget preload for a list of image URLs.
  /// Call after loading chat history to warm the cache in the background.
  void preloadImages(List<String> urls) {
    for (final url in urls) {
      if (url.isNotEmpty && !isCached(url)) {
        cacheMedia(url: url, mediaType: 'image');
      }
    }
  }

  // ── Maintenance ────────────────────────────────────────────────────────────

  /// Remove cache entries older than 30 days.
  Future<void> _cleanOldCache() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final toDelete = <String>[];

    for (final entry in _cacheBox.values) {
      if (entry.cachedAt.isBefore(cutoff)) {
        toDelete.add(_getCacheKey(entry.url));
        try {
          File(entry.localPath).deleteSync();
        } catch (_) {}
        if (entry.thumbnailPath != null) {
          try {
            File(entry.thumbnailPath!).deleteSync();
          } catch (_) {}
        }
      }
    }

    for (final key in toDelete) {
      await _cacheBox.delete(key);
    }

    if (toDelete.isNotEmpty) {
      print('🗑️ Cleaned ${toDelete.length} expired cache entries');
    }
  }

  Future<void> clearCache() async {
    if (!_isInitialized) return;
    for (final entry in _cacheBox.values) {
      try {
        File(entry.localPath).deleteSync();
      } catch (_) {}
      if (entry.thumbnailPath != null) {
        try {
          File(entry.thumbnailPath!).deleteSync();
        } catch (_) {}
      }
    }
    await _cacheBox.clear();
    print('🗑️ Cache cleared');
  }

  Future<int> getCacheSize() async {
    int total = 0;
    for (final entry in _cacheBox.values) {
      total += entry.fileSize;
      if (entry.thumbnailPath != null) {
        try {
          total += await File(entry.thumbnailPath!).length();
        } catch (_) {}
      }
    }
    return total;
  }

  Map<String, dynamic> getCacheStats() => {
    'totalEntries': _cacheBox.length,
    'images': _cacheBox.values.where((e) => e.mediaType == 'image').length,
    'videos': _cacheBox.values.where((e) => e.mediaType == 'video').length,
    'audio': _cacheBox.values.where((e) => e.mediaType == 'audio').length,
    'documents': _cacheBox.values
        .where((e) => e.mediaType == 'document')
        .length,
  };
}
