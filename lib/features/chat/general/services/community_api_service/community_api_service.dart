import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:qik_talk/features/chat/general/model/community_model.dart';
import 'package:qik_talk/features/community/services/community_cache_service.dart';
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class CommunityApiService {
  final SaveValues _saveValues = SaveValues();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  String _extractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['message'] as String? ?? 'Something went wrong';
    } catch (_) {
      return 'Something went wrong';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LOCAL CACHE  (kept as a fallback / offline support)
  // ─────────────────────────────────────────────────────────────────────────────
  static const _cacheKey = 'qiktalk_community_ids_v2';

  Future<List<String>> getCachedCommunityIds() async {
    try {
      final raw = await _saveValues.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return [];
      return raw
          .split(',')
          .map((id) => id.trim())
          .where((id) => id.length >= 20)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> cacheCommunityId(String id) async {
    if (id.length < 20) return;
    try {
      final existing = await getCachedCommunityIds();
      if (!existing.contains(id)) {
        existing.add(id);
        await _saveValues.saveString(_cacheKey, existing.join(','));
        print('✅ Cached community ID: $id (total: ${existing.length})');
      }
    } catch (e) {
      print('⚠️ Failed to cache community ID: $e');
    }
  }

  Future<void> removeCachedCommunityId(String id) async {
    try {
      final existing = await getCachedCommunityIds();
      existing.remove(id);
      await _saveValues.saveString(_cacheKey, existing.join(','));
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GET MY COMMUNITIES
  //
  // Strategy (in priority order):
  //  1. PRIMARY  — GET /chat/community-byUserOrAdmin  (backend-authoritative list)
  //  2. FALLBACK — cached IDs fetched one-by-one via GET /chat/community/:id
  //
  // After a successful primary fetch we update the local cache so the fallback
  // stays in sync for offline / error scenarios.
  // ─────────────────────────────────────────────────────────────────────────────
  Future<List<CommunityModel>> getMyCommunities() async {
    // ── 1. PRIMARY: dedicated endpoint ───────────────────────────────────────
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(
            Uri.parse(ApiStrings.getCommunitiesByUserOrAdmin),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('📡 getMyCommunities (primary): ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Backend response shape for this endpoint (from the sample JSON):
        // { "success": true, "data": [ { "community": {...}, "isAdmin": bool,
        //   "isDirectMember": bool, "subGroupCount": N, "memberCount": N }, ... ] }
        List<dynamic> rawList = [];

        if (body is Map && body['data'] is List) {
          rawList = body['data'] as List;
        } else if (body is List) {
          // defensive: some backends return a bare array
          rawList = body;
        }

        if (rawList.isNotEmpty) {
          final results = <CommunityModel>[];
          final seen = <String>{};

          for (final item in rawList.whereType<Map<String, dynamic>>()) {
            // Each item has a "community" key containing the community object,
            // plus top-level "memberCount" and other metadata.
            Map<String, dynamic> communityMap;
            int? memberCount;

            if (item['community'] is Map<String, dynamic>) {
              communityMap = Map<String, dynamic>.from(
                item['community'] as Map<String, dynamic>,
              );
              // Prefer top-level memberCount from the wrapper if present
              memberCount =
                  item['memberCount'] as int? ??
                  (communityMap['users'] as List?)?.length;
            } else if (item['_id'] != null) {
              // Item IS the community directly
              communityMap = item;
              memberCount = item['memberCount'] as int?;
            } else {
              continue;
            }

            if (memberCount != null) {
              communityMap['_memberCount'] = memberCount;
            }

            final community = CommunityModel.fromJson(communityMap);
            if (community.id.isEmpty || seen.contains(community.id)) continue;

            results.add(community);
            seen.add(community.id);

            // Keep local cache in sync
            await cacheCommunityId(community.id);
          }

          await CommunityCacheService.saveCommunities(results);
          CommunityCacheService.prewarmCommunityMedia(results);
          print('📋 getMyCommunities: ${results.length} from primary endpoint');
          return results;
        }
      }
    } catch (e) {
      print('⚠️ getMyCommunities primary fetch failed: $e');
    }

    // ── 2. FALLBACK: locally cached community JSON ───────────────────────────
    final cachedCommunities = await CommunityCacheService.loadCommunities();
    if (cachedCommunities.isNotEmpty) {
      CommunityCacheService.prewarmCommunityMedia(cachedCommunities);
      print('📋 getMyCommunities: using local cache (${cachedCommunities.length})');
      return cachedCommunities;
    }

    // ── 3. FALLBACK: cached IDs ───────────────────────────────────────────────
    print('📋 getMyCommunities: falling back to cached IDs');
    final results = <CommunityModel>[];
    final seen = <String>{};
    final cachedIds = await getCachedCommunityIds();

    for (final id in cachedIds) {
      final res = await getCommunityInfo(id);
      if (res.success && res.community != null && !seen.contains(id)) {
        results.add(res.community!);
        seen.add(id);
      } else if (!res.success && res.statusCode == 404) {
        await removeCachedCommunityId(id);
      }
    }

    if (results.isNotEmpty) {
      await CommunityCacheService.saveCommunities(results);
      CommunityCacheService.prewarmCommunityMedia(results);
    }
    print('📋 getMyCommunities fallback total: ${results.length}');
    return results;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GET COMMUNITY INFO
  // GET /chat/community/:id
  // ─────────────────────────────────────────────────────────────────────────────
  Future<CommunityResponse> getCommunityInfo(String communityId) async {
    if (communityId.length < 20) {
      return const CommunityResponse(
        success: false,
        message: 'Invalid ID',
        statusCode: 400,
      );
    }

    try {
      final headers = await _authHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiStrings.baseUri}chat/community/$communityId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('📡 getCommunityInfo $communityId: ${response.statusCode}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        return CommunityResponse(
          success: false,
          message: 'Authentication error — please re-login',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        Map<String, dynamic> communityMap;
        int? memberCount;

        final dataField = body['data'];
        if (dataField is Map<String, dynamic>) {
          if (dataField['community'] is Map<String, dynamic>) {
            communityMap = Map<String, dynamic>.from(
              dataField['community'] as Map<String, dynamic>,
            );
            memberCount = dataField['memberCount'] as int?;
          } else if (dataField['_id'] != null) {
            communityMap = dataField;
          } else {
            communityMap = body;
          }
        } else {
          communityMap = body;
        }

        if (memberCount != null) {
          communityMap['_memberCount'] = memberCount;
        }

        final community = CommunityModel.fromJson(communityMap);
        await CommunityCacheService.saveCommunity(community);
        CommunityCacheService.prewarmSingleCommunityMedia(community);
        return CommunityResponse(
          success: true,
          message: 'OK',
          community: community,
          statusCode: 200,
        );
      }

      final cached = await CommunityCacheService.loadCommunity(communityId);
      if (cached != null && response.statusCode != 401 && response.statusCode != 403) {
        CommunityCacheService.prewarmSingleCommunityMedia(cached);
        return CommunityResponse(
          success: true,
          message: 'Loaded from cache',
          community: cached,
          statusCode: response.statusCode,
        );
      }

      return CommunityResponse(
        success: false,
        message: _extractError(response.body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ getCommunityInfo: $e');
      final cached = await CommunityCacheService.loadCommunity(communityId);
      if (cached != null) {
        CommunityCacheService.prewarmSingleCommunityMedia(cached);
        return CommunityResponse(
          success: true,
          message: 'Loaded from cache',
          community: cached,
        );
      }
      return CommunityResponse(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // RENAME COMMUNITY
  // PUT /chat/community/:communityId   body: { chatName, name }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<CommunityResponse> renameCommunity({
    required String communityId,
    required String newName,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/community/$communityId'),
            headers: headers,
            body: jsonEncode({'chatName': newName, 'name': newName}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '✏️ renameCommunity $communityId → "$newName": ${response.statusCode}',
      );
      return CommunityResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200
            ? 'Renamed successfully'
            : _extractError(response.body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ renameCommunity: $e');
      return CommunityResponse(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UPDATE COMMUNITY DESCRIPTION
  // PUT /chat/community/:communityId   body: { description }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<CommunityResponse> updateDescription({
    required String communityId,
    required String description,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiStrings.baseUri}chat/community/$communityId'),
            headers: headers,
            body: jsonEncode({'description': description}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '✏️ updateCommunityDescription $communityId: ${response.statusCode}',
      );
      return CommunityResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: response.statusCode == 200
            ? 'Updated'
            : _extractError(response.body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ updateCommunityDescription: $e');
      return CommunityResponse(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CREATE COMMUNITY
  // POST /chat/community   body: { name, description } or multipart
  // ─────────────────────────────────────────────────────────────────────────────
  Future<CommunityResponse> createCommunity({
    required String name,
    required String description,
    File? imageFile,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      http.Response response;

      if (imageFile != null) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');
        final req =
            http.MultipartRequest(
                'POST',
                Uri.parse('${ApiStrings.baseUri}chat/community'),
              )
              ..headers['Authorization'] = 'Bearer $token'
              ..fields['name'] = name
              ..fields['description'] = description;
        req.files.add(
          await http.MultipartFile.fromPath(
            'chatImage',
            imageFile.path,
            filename: p.basename(imageFile.path),
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
        final streamed = await req.send().timeout(const Duration(seconds: 30));
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http
            .post(
              Uri.parse('${ApiStrings.baseUri}chat/community'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'name': name, 'description': description}),
            )
            .timeout(const Duration(seconds: 20));
      }

      print('📡 createCommunity: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final community = CommunityModel.fromJson(body);
        if (community.id.isNotEmpty) await cacheCommunityId(community.id);
        return CommunityResponse(
          success: true,
          message: body['message'] as String? ?? 'Community created',
          community: community,
          statusCode: response.statusCode,
        );
      }
      return CommunityResponse(
        success: false,
        message: _extractError(response.body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ createCommunity: $e');
      return CommunityResponse(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ADD GROUP TO COMMUNITY
  // PUT /chat/community/add-group   body: { communityId, groupId }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<CommunityResponse> addGroupToCommunity({
    required String communityId,
    required String groupId,
  }) async {
    try {
      final headers = await _authHeaders();
      // Backend confirmed: PUT /chat/add-existing-group-to-community body: { communityId, groupId }
      final response = await http
          .put(
            Uri.parse(
              '${ApiStrings.baseUri}chat/add-existing-group-to-community',
            ),
            headers: headers,
            body: jsonEncode({'communityId': communityId, 'groupId': groupId}),
          )
          .timeout(const Duration(seconds: 15));

      print(
        '📡 addGroupToCommunity: ${response.statusCode} | body: ${response.body.substring(0, response.body.length.clamp(0, 300))}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        CommunityModel? updated;
        if (data['data'] is Map<String, dynamic>) {
          updated = CommunityModel.fromJson(data);
        }
        return CommunityResponse(
          success: true,
          message: data['message'] as String? ?? 'Group added',
          community: updated,
          statusCode: response.statusCode,
        );
      }
      return CommunityResponse(
        success: false,
        message: _extractError(response.body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ addGroupToCommunity: $e');
      return CommunityResponse(success: false, message: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // POST ANNOUNCEMENT
  // POST /chat/community/:communityId/announcement   body: { title, content }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> postAnnouncement({
    required String communityId,
    required String content,
    String? title,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            Uri.parse(
              '${ApiStrings.baseUri}chat/community/$communityId/announcement',
            ),
            headers: headers,
            body: jsonEncode({
              'content': content,
              'title':
                  title ??
                  content, // use content as title fallback if not provided
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('📡 postAnnouncement $communityId: ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? '',
        'data': data,
      };
    } catch (e) {
      print('❌ postAnnouncement: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CREATE GROUP IN COMMUNITY
  // POST /chat/group   body: { name, communityId, users, description? }
  // ─────────────────────────────────────────────────────────────────────────────
  Future<CommunityResponse> createGroupInCommunity({
    required String communityId,
    required String name,
    required List<String> userIds,
    String? description,
    File? imageFile,
  }) async {
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      http.Response response;

      if (imageFile != null) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');
        final req =
            http.MultipartRequest(
                'POST',
                Uri.parse('${ApiStrings.baseUri}chat/group'),
              )
              ..headers['Authorization'] = 'Bearer $token'
              ..fields['name'] = name
              ..fields['communityId'] = communityId
              ..fields['users'] = jsonEncode(userIds);
        if (description != null) req.fields['description'] = description;
        req.files.add(
          await http.MultipartFile.fromPath(
            'chatImage',
            imageFile.path,
            filename: p.basename(imageFile.path),
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
        final streamed = await req.send().timeout(const Duration(seconds: 30));
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http
            .post(
              Uri.parse('${ApiStrings.baseUri}chat/group'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'name': name,
                'communityId': communityId,
                'users': userIds,
                if (description != null && description.isNotEmpty)
                  'description': description,
              }),
            )
            .timeout(const Duration(seconds: 20));
      }

      print('📡 createGroupInCommunity: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const CommunityResponse(success: true, message: 'Group created');
      }
      return CommunityResponse(
        success: false,
        message: _extractError(response.body),
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ createGroupInCommunity: $e');
      return CommunityResponse(success: false, message: e.toString());
    }
  }
}
