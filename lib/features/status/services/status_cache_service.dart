import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:qik_talk/features/status/model/my_status_model.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';

class StatusCacheService {
  // ── Hive box name ──────────────────────────────────────────────────────
  static const _boxName = 'status_cache';
  static const _keyJson = 'statuses_json';
  static const _keyTs = 'cache_ts';

  // ── Media cache subfolder ──────────────────────────────────────────────
  static const _mediaFolder = 'status_media';

  // Cache is considered stale after this many minutes
  static const _staleMins = 30;

  // ── Open box (idempotent) ──────────────────────────────────────────────
  static Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  READ
  // ══════════════════════════════════════════════════════════════════════

  /// Load the cached status list instantly (returns [] if nothing cached).
  static Future<List<MyStatusModel>> loadCached() async {
    try {
      final box = await _box();
      final raw = box.get(_keyJson);
      if (raw == null || raw is! String || raw.isEmpty) return [];
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => MyStatusModel.fromJson(e as Map<String, dynamic>))
          .where((s) => s.updates.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('StatusCache load error: $e');
      return [];
    }
  }

  /// True if the cache exists and is newer than [_staleMins].
  static Future<bool> isFresh() async {
    try {
      final box = await _box();
      final ts = box.get(_keyTs) as String?;
      if (ts == null) return false;
      final saved = DateTime.tryParse(ts);
      if (saved == null) return false;
      return DateTime.now().difference(saved).inMinutes < _staleMins;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  WRITE
  // ══════════════════════════════════════════════════════════════════════

  /// Persist the status list to Hive. Called after a successful API fetch.
  static Future<void> save(List<MyStatusModel> statuses) async {
    try {
      final box = await _box();
      final encoded = json.encode(statuses.map((s) => s.toJson()).toList());
      await box.put(_keyJson, encoded);
      await box.put(_keyTs, DateTime.now().toIso8601String());
      debugPrint('✅ StatusCache: saved ${statuses.length} users');
    } catch (e) {
      debugPrint('StatusCache save error: $e');
    }
  }

  /// Remove a single status update by [statusId] from the Hive cache.
  /// Called immediately after a successful delete API call so the UI
  /// never shows the deleted status — even offline / before next fetch.
  static Future<void> removeStatus(String statusId) async {
    try {
      final box = await _box();
      final raw = box.get(_keyJson);
      if (raw == null || raw is! String || raw.isEmpty) return;

      final list = json.decode(raw) as List<dynamic>;

      // Each item is a MyStatusModel shape: { user: {...}, updates: [...] }
      final updated = list
          .map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            final updates = (map['updates'] as List<dynamic>? ?? []).where((u) {
              final id = (u as Map<String, dynamic>)['_id']?.toString() ?? '';
              return id != statusId;
            }).toList();
            map['updates'] = updates;
            return map;
          })
          // Drop users who now have zero updates
          .where((item) => (item['updates'] as List).isNotEmpty)
          .toList();

      await box.put(_keyJson, json.encode(updated));
      await box.put(_keyTs, DateTime.now().toIso8601String());
      debugPrint('🗑️ StatusCache: removed status $statusId from cache');
    } catch (e) {
      debugPrint('StatusCache removeStatus error: $e');
    }
  }

  /// Clear all cached data (call on logout).
  static Future<void> clear() async {
    try {
      final box = await _box();
      await box.deleteAll([_keyJson, _keyTs]);
      await _clearMediaFiles();
      debugPrint('🗑️ StatusCache: cleared');
    } catch (e) {
      debugPrint('StatusCache clear error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  MEDIA CACHE
  // ══════════════════════════════════════════════════════════════════════

  /// Returns the local path if the URL is already cached, null otherwise.
  /// Checks both the legacy status-specific folder and the shared media cache.
  static Future<String?> localMediaPath(String url) async {
    if (url.isEmpty) return null;
    try {
      final shared = MediaCacheService().getCachedPath(url);
      if (shared != null && File(shared).existsSync()) return shared;

      final file = await _fileForUrl(url);
      if (await file.exists()) return file.path;
    } catch (_) {}
    return null;
  }

  static Future<String?> cacheMediaNow(
    String url, {
    required String mediaType,
  }) async {
    if (url.isEmpty || !url.startsWith('http')) return null;
    final cached = MediaCacheService().getCachedPath(url);
    if (cached != null && File(cached).existsSync()) return cached;

    try {
      final shared = await MediaCacheService().cacheMedia(
        url: url,
        mediaType: mediaType,
      );
      if (shared != null && shared.isNotEmpty) return shared;
    } catch (_) {}

    try {
      final file = await _fileForUrl(url);
      if (await file.exists()) return file.path;
      await _downloadMedia(url, file);
      if (await file.exists()) return file.path;
    } catch (_) {}
    return null;
  }

  /// Pre-download all image/video URLs in [statuses] to local storage.
  /// Fire-and-forget — call without await after updating the UI.
  static Future<void> prewarmMedia(List<MyStatusModel> statuses) async {
    for (final s in statuses) {
      final avatarUrl = s.user.profilePicture.trim();
      if (avatarUrl.isNotEmpty) {
        cacheMediaNow(avatarUrl, mediaType: 'image');
      }

      for (final u in s.updates) {
        final url = u.media.trim();
        if (url.isNotEmpty && u.mediaType != 'text') {
          cacheMediaNow(
            url,
            mediaType: u.mediaType == 'video' ? 'video' : 'image',
          );
        }

        final reshared = u.resharedFrom;
        if (reshared != null) {
          if (reshared.ownerProfilePicture.trim().isNotEmpty) {
            cacheMediaNow(
              reshared.ownerProfilePicture.trim(),
              mediaType: 'image',
            );
          }
          if (reshared.media.trim().isNotEmpty &&
              reshared.mediaType != 'text') {
            cacheMediaNow(
              reshared.media.trim(),
              mediaType: reshared.mediaType == 'video' ? 'video' : 'image',
            );
          }
        }
      }
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  static Future<File> _fileForUrl(String url) async {
    final dir = await getApplicationSupportDirectory();
    final folder = Directory('${dir.path}/$_mediaFolder');
    if (!await folder.exists()) await folder.create(recursive: true);
    final hash = md5.convert(utf8.encode(url)).toString();
    final ext = _extFromUrl(url);
    return File('${folder.path}/$hash$ext');
  }

  static String _extFromUrl(String url) {
    try {
      final path = Uri.parse(url).path;
      final dot = path.lastIndexOf('.');
      if (dot == -1) return '';
      final ext = path.substring(dot).split('?').first.toLowerCase();
      // Only allow known safe extensions
      const known = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.mp4', '.mov'];
      return known.contains(ext) ? ext : '';
    } catch (_) {
      return '';
    }
  }

  static Future<void> _downloadMedia(String url, File dest) async {
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(minutes: 3));
      if (res.statusCode == 200) {
        await dest.writeAsBytes(res.bodyBytes);
        debugPrint(
          '📥 StatusCache: cached media → ${dest.path.split('/').last}',
        );
      }
    } catch (e) {
      debugPrint('StatusCache download failed ($url): $e');
    }
  }

  static Future<void> _clearMediaFiles() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final folder = Directory('${dir.path}/$_mediaFolder');
      if (await folder.exists()) await folder.delete(recursive: true);
    } catch (_) {}
  }
}
