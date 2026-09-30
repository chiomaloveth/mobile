import 'dart:collection';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/chat/general/model/community_model.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';

class CommunityCacheService {
  static const _listKey = 'cached_communities_json_v2';
  static const _itemPrefix = 'cached_community_item_v2_';

  static Future<void> saveCommunities(List<CommunityModel> communities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _listKey,
      jsonEncode(communities.map((c) => c.toJson()).toList()),
    );

    for (final community in communities) {
      await saveCommunity(community, prefs: prefs);
    }
  }

  static Future<void> saveCommunity(
    CommunityModel community, {
    SharedPreferences? prefs,
  }) async {
    final sharedPrefs = prefs ?? await SharedPreferences.getInstance();
    await sharedPrefs.setString(
      '$_itemPrefix${community.id}',
      jsonEncode(community.toJson()),
    );
  }

  static Future<List<CommunityModel>> loadCommunities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_listKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => CommunityModel.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<CommunityModel?> loadCommunity(String communityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_itemPrefix$communityId');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return CommunityModel.fromJson(decoded);
      }

      final list = await loadCommunities();
      for (final item in list) {
        if (item.id == communityId) return item;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> upsertCommunity(CommunityModel community) async {
    final communities = await loadCommunities();
    final index = communities.indexWhere((c) => c.id == community.id);
    if (index >= 0) {
      communities[index] = community;
    } else {
      communities.insert(0, community);
    }
    await saveCommunities(communities);
  }

  static Future<void> prewarmCommunityMedia(
    Iterable<CommunityModel> communities,
  ) async {
    final urls = LinkedHashMap<String, String>();

    void addUrl(String? url, String type) {
      final value = _normalizeUrl(url);
      if (value.isEmpty || !value.startsWith('http')) return;
      urls.putIfAbsent(value, () => type);
    }

    for (final community in communities) {
      addUrl(community.chatImage, 'image');
      addUrl(
        community.communityBackground,
        _mediaTypeForUrl(community.communityBackground),
      );
    }

    for (final entry in urls.entries) {
      MediaCacheService().cacheMedia(url: entry.key, mediaType: entry.value);
    }
  }

  static Future<void> prewarmSingleCommunityMedia(CommunityModel community) {
    return prewarmCommunityMedia([community]);
  }

  static String _mediaTypeForUrl(String? url) {
    final lower = _normalizeUrl(url).toLowerCase();
    if (lower.contains('/video/upload/') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm')) {
      return 'video';
    }
    return 'image';
  }

  static String _normalizeUrl(String? url) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return ApiStrings.baseUriImage + value;
  }
}
