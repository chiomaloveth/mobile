import 'dart:io';
import 'package:dio/dio.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_viewers_response.dart';
import 'package:qik_talk/utilities/media_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/core/network/network_provider.dart';
import 'package:qik_talk/features/feed/data/datasource/apis/feed_apis.dart';
import 'package:qik_talk/features/feed/data/models/create_post_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_preference_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_reply_comment_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_story_dto.dart';
import 'package:qik_talk/features/feed/data/models/block_user_dto.dart';
import 'package:qik_talk/features/feed/data/models/unblock_user_dto.dart';

import 'package:qik_talk/features/feed/data/models/delete_account_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/data/block_user_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/unblock_user_response.dart';

import 'package:qik_talk/features/feed/presentation/state/data/get_blocked_list_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/delete_account_response.dart';
import 'package:qik_talk/features/feed/data/models/update_privacy_settings_dto.dart';
import 'package:qik_talk/features/feed/data/models/update_profile_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/data/book_mark_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_preference_list.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_reply_comment_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_story_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/delete_comment_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/follow_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/follow_list_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_bookmark_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_reply.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_info_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_user_profile_post.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_preference_list.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_by_preference.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_info_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_post_profle_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/like_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/music_search_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/share_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/view_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_post_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_notifications.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_notification_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_all_notifications_response.dart';
//import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_single_post_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_privacy_settings_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/update_privacy_settings_response.dart';
//import 'package:qik_talk/utilities/media_utils.dart';

final feedDataSourceProvider = Provider<FeedDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final feedApis = FeedApis(dio);
  return FeedDataSource(feedApis, dio);
});

class FeedDataSource {
  final FeedApis _feedApis;
  final Dio _dio;

  FeedDataSource(this._feedApis, this._dio);

  Future<CreatePostResponse> createPost(CreatePostDto data) async {
    return await _feedApis.createPost(data.toJson());
  }

  Future<CreatePostResponse> createPostWithMedia({
    String? content,
    required List<File> mediaFiles,
    PostMusic? music,
    List<String>? tags,
    String? overlayText,
    List<String>? overlayVideoUrls,
    List<File>? overlayVideoFiles,
    bool? allowComments,
    List<String>? taggedUsers,
    void Function(double)? onProgress,
  }) async {
    int totalBytes = 0;
    for (var f in mediaFiles) totalBytes += await f.length();
    if (overlayVideoFiles != null) {
      for (var f in overlayVideoFiles) totalBytes += await f.length();
    }
    
    Map<String, int> progressMap = {};
    void updateProgress(String id, double p, int length) {
       progressMap[id] = (p * length).round();
       int sum = progressMap.values.fold(0, (a, b) => a + b);
       if (totalBytes > 0 && onProgress != null) {
          onProgress(sum / totalBytes);
       }
    }

    // Step 1 & 2: Upload all media files in parallel
    final mediaUrls = await Future.wait(
      mediaFiles.asMap().entries.map((entry) async {
        final file = entry.value;
        final length = await file.length();
        final id = 'media_${entry.key}';
        return _orchestrateUpload(file, onProgress: (p) => updateProgress(id, p, length));
      }),
    );

    // Step 1 & 2: Upload all overlay video files in parallel
    List<String>? newlyUploadedOverlays;
    if (overlayVideoFiles != null && overlayVideoFiles.isNotEmpty) {
      newlyUploadedOverlays = await Future.wait(
        overlayVideoFiles.asMap().entries.map((entry) async {
          final file = entry.value;
          final length = await file.length();
          final id = 'overlay_${entry.key}';
          return _orchestrateUpload(file, onProgress: (p) => updateProgress(id, p, length));
        }),
      );
    }

    // Combine existing overlay URLs with newly uploaded ones
    final allOverlayVideos = [...?overlayVideoUrls, ...?newlyUploadedOverlays];

    // Step 3: Save Reference
    final dto = CreatePostDto(
      content: content,
      media: mediaUrls,
      music: music,
      tags: tags,
      overlayText: overlayText,
      overlayVideos: allOverlayVideos.isEmpty ? null : allOverlayVideos,
      allowComment: allowComments,
      taggedUsers: taggedUsers,
    );

    return await _feedApis.createPost(dto.toJson());
  }

  Future<LikeResponseData> likePost(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _feedApis.likePost(id, data);
  }

  Future<List<GetComment>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _feedApis.getPostComments(
      postId: postId,
      page: page,
      limit: limit,
    );
    return response;
  }

  Future<GetComment> addComment(
    String postId,
    Map<String, dynamic> data,
  ) async {
    final response = await _feedApis.addComment(postId, data);
    return response;
  }

  Future<ShareResponseData> sharePost(String postId) async {
    return await _feedApis.sharePost(postId);
  }

  Future<LikeResponseData> likeComment(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _feedApis.likeComment(id, data);
  }

  Future<GetComment> addCommentWithMedia(
    String postId, {
    String? content,
    required File mediaFile,
    String type = 'voice',
    String? parentId,
  }) async {
    // Step 1 & 2: Upload media
    final publicUrl = await _orchestrateUpload(mediaFile);

    // Step 3: Save Reference
    final data = {
      if (content != null && content.isNotEmpty) 'content': content,
      'type': type,
      if (parentId != null) 'parentId': parentId,
      'media': [publicUrl],
    };

    return await _feedApis.addComment(postId, data);
  }

  Future<GetCommentReply> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 20,
  }) async {
    return await _feedApis.getCommentReplies(
      commentId: commentId,
      page: page,
      limit: limit,
    );
  }

  Future<CreateReplyCommentResponse> addCommentReply(
    String postId,
    CreateReplyCommentDto data,
  ) async {
    return await _feedApis.addCommentReply(postId, data.toJson());
  }

  Future<CreateReplyCommentResponse> addReplyWithMedia({
    required String postId,
    String? content,
    required File mediaFile,
    String type = 'voice',
    String? parentComment,
  }) async {
    // Step 1 & 2: Upload media
    final publicUrl = await _orchestrateUpload(mediaFile);

    // Step 3: Save Reference
    final data = {
      if (content != null && content.isNotEmpty) 'content': content,
      'type': type,
      if (parentComment != null) 'parentComment': parentComment,
      'media': [publicUrl],
    };

    final response = await _dio.post(
      'social/feed/comment/$parentComment/reply',
      data: data,
    );

    return CreateReplyCommentResponse.fromJson(response.data);
  }

  Future<BookMarkResponseData> bookmarkPost(String postId) async {
    return await _feedApis.bookmarkPost(postId);
  }

  Future<GetBookmarkResponse> getBookmarkedPosts({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getBookmarkedPosts(page: page, limit: limit);
  }

  Future<GetUserInfoResponse> getUserInfo({String? userId}) async {
    return await _feedApis.getUserInfo(userId: userId);
  }

  Future<List<GetUserPostProfleResponseData>> getUserPostsForProfile({
    String? userId,
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getUserPostsForProfile(
      userId: userId,
      page: page,
      limit: limit,
    );
  }

  Future<FollowResponseData> followUser(String userId) async {
    return await _feedApis.followUser(userId);
  }

  Future<FollowResponseData> unfollowUser(String userId) async {
    return await _feedApis.unfollowUser(userId);
  }

  Future<GetFollowersResponse> getFollowers(String userId) async {
    return await _feedApis.getFollowers(userId);
  }

  Future<GetFollowingResponse> getFollowing(String userId) async {
    return await _feedApis.getFollowing(userId);
  }

  Future<GetPreferenceList> getPreferenceList() async {
    return await _feedApis.getPreferenceList();
  }

  Future<CreatePreferenceList> createPreferenceList({
    required CreatePreferenceDto data,
  }) async {
    return await _feedApis.createPreferenceList(data: data.toJson());
  }

  Future<GetUserByPreference> getUserByPreference() async {
    return await _feedApis.getUserByPreference();
  }

  Future<GetFeedResponse> getFollowingFeed({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getFollowingFeed(page: page, limit: limit);
  }

  Future<GetFeedResponse> getPersonalizedFeed({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getPersonalizedFeed(page: page, limit: limit);
  }

  Future<GetFeedResponse> searchFeed({
    required String query,
  }) async {
    return await _feedApis.searchFeed(
      query: query,
    );
  }

  Future<ViewResponseData> viewPost({required String postId}) async {
    return await _feedApis.viewPost(body: {'postId': postId});
  }

  Future<MusicSearchResponse> searchMusic({required String query}) async {
    final response = await _feedApis.searchMusic(query: query);
    return response;
  }

  Future<GetOtherInfoResponseData> getOtherUserInfo({
    required String userId,
  }) async {
    return await _feedApis.getOtherUserInfo(userId: userId);
  }

  Future<GetOtherUserProfilePost> getOtherUserProfilePosts({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getOtherUserProfilePosts(
      userId: userId,
      page: page,
      limit: limit,
    );
  }

  Future<DeleteCommentResponseData> deleteComment({
    required String commentId,
  }) async {
    return await _feedApis.deleteComment(commentId: commentId);
  }

  Future<GetUserInfoResponse> updateProfile({
    required UpdateProfileDto data,
  }) async {
    return await _feedApis.updateProfile(data: data.toJson());
  }

  Future<GetUserInfoResponse> updateProfileWithImage({
    required UpdateProfileDto data,
    required File imageFile,
  }) async {
    // Step 1 & 2: Upload media directly to get the public URL string
    final publicUrl = await _orchestrateUpload(imageFile);

    // Step 3: Attach the string URL into the JSON payload
    final updatedData = data.copyWith(profilePicture: publicUrl);

    // Step 4: Send via standard JSON API call
    return await _feedApis.updateProfile(data: updatedData.toJson());
  }

  Future<GetNotifications> getReadNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getReadNotifications(page: page, limit: limit);
  }

  Future<GetNotifications> getFeedReadNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getFeedReadNotifications(page: page, limit: limit);
  }

  Future<GetNotifications> getUserNotifications({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getUserNotifications(
      userId: userId,
      page: page,
      limit: limit,
    );
  }

  Future<GetNotifications> getReadFeed({int page = 1, int limit = 10}) async {
    return await _feedApis.getReadFeed(page: page, limit: limit);
  }

  Future<GetNotifications> getReadSocialFeed({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getReadSocialFeed(page: page, limit: limit);
  }

  Future<GetSinglePostResponse> getPostById(String id) async {
    return await _feedApis.getPostById(id);
  }

  Future<ReadNotificationResponse> markNotificationAsRead(String id) async {
    return await _feedApis.markNotificationAsRead(id);
  }

  Future<ReadAllNotificationsResponse> markManyNotificationsAsRead(
    List<String> ids,
  ) async {
    return await _feedApis.markManyNotificationsAsRead({'ids': ids});
  }

  Future<GetNotifications> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getNotifications(page: page, limit: limit);
  }

  Future<ReadAllNotificationsResponse> readAllNotifications() async {
    return await _feedApis.readAllNotifications();
  }

  Future<CreateStoryResponseData> createStory({
    required CreateStoryDto dto,
    required File mediaFile,
    List<File>? overlayVideoFiles,
    void Function(double)? onProgress,
  }) async {
    int totalBytes = await mediaFile.length();
    if (overlayVideoFiles != null) {
      for (var f in overlayVideoFiles) totalBytes += await f.length();
    }
    
    Map<String, int> progressMap = {};
    void updateProgress(String id, double p, int length) {
       progressMap[id] = (p * length).round();
       int sum = progressMap.values.fold(0, (a, b) => a + b);
       if (totalBytes > 0 && onProgress != null) {
          onProgress(sum / totalBytes);
       }
    }

    // Step 1 & 2: Upload main media
    final mediaLength = await mediaFile.length();
    final publicUrl = await _orchestrateUpload(mediaFile, onProgress: (p) => updateProgress('main', p, mediaLength));

    // Step 1 & 2: Upload overlay videos if any
    List<String>? overlayUrls;
    if (overlayVideoFiles != null && overlayVideoFiles.isNotEmpty) {
      overlayUrls = await Future.wait(
        overlayVideoFiles.asMap().entries.map((entry) async {
          final file = entry.value;
          final length = await file.length();
          final id = 'overlay_${entry.key}';
          return _orchestrateUpload(file, onProgress: (p) => updateProgress(id, p, length));
        }),
      );
    }

    // Step 3: Save Reference
    final updatedDto = dto.copyWith(
      media: [publicUrl],
      overlayVideos: overlayUrls ?? dto.overlayVideos,
    );

    return await _feedApis.createStory(data: updatedDto.toJson());
  }

  Future<GetStoryResponseData> getFollowingStories({
    int page = 1,
    int limit = 10,
  }) async {
    return await _feedApis.getFollowingStories(page: page, limit: limit);
  }

  Future<void> viewStory(String id) async {
    await _feedApis.viewStory(id);
  }

  Future<GetStoryViewersResponse> getStoryViewers(String id) async {
    return await _feedApis.getStoryViewers(id);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _dio.post(
        'user/search',
        data: {'query': query},
      );
      final body = response.data;
      if (body is List) {
        return body.cast<Map<String, dynamic>>();
      } else if (body is Map && body['_id'] != null) {
        return [Map<String, dynamic>.from(body)];
      }
      return [];
    } catch (e) {
      print('❌ User search error: $e');
      return [];
    }
  }

  Future<UpdatePrivacySettingsResponse> updatePrivacySettings(
    UpdatePrivacySettingsDto data,
  ) async {
    return await _feedApis.updatePrivacySettings(data.toJson());
  }

  Future<UnblockUserResponse> unblockUser(
    UnblockUserDto data,
  ) async {
    return await _feedApis.unblockUser(data.toJson());
  }

  Future<BlockUserResponse> blockUser(
    BlockUserDto data,
  ) async {
    return await _feedApis.blockUser(data.toJson());
  }


  Future<GetBlockedListResponse> getBlockedList() async {
    return await _feedApis.getBlockedList();
  }

  Future<DeleteAccountResponse> deleteAccount(
    DeleteAccountDto data,
  ) async {
    return await _feedApis.deleteAccount(data.toJson());
  }

  Future<GetPrivacySettingsResponse> getPrivacySettings() async {
    return await _feedApis.getPrivacySettings();
  }

  Future<dynamic> submitReport({
    required String reportedItemId,
    required String itemType,
    required String reason,
    required String description,
    required String severity,
  }) async {
    return await _feedApis.submitReport({
      'reportedItemId': reportedItemId,
      'itemType': itemType,
      'reason': reason,
      'description': description,
      'severity': severity,
    });
  }

  Future<String> _orchestrateUpload(File file, {void Function(double)? onProgress}) async {
    final fileName = file.path.split('/').last;
    final mimeType = MediaUtils.getMediaType(file.path).toString();

    try {
      // Step 1: Generate Upload URL
      final generateResponse = await _feedApis.generateUploadUrl({
        'fileName': fileName,
        'mimeType': mimeType,
      });

      // Data is wrapped in a 'data' object from your backend
      final responseData = generateResponse['data'] as Map<String, dynamic>?;
      final uploadUrl = responseData?['uploadUrl'];
      final publicUrl = responseData?['publicUrl'];

      if (uploadUrl == null || publicUrl == null) {
        throw Exception('Failed to generate upload URLs from backend response');
      }

      // Step 2: Direct Binary Upload
      final fileLength = await file.length();

      // We explicitly create a clean Options object here to avoid any
      // unexpected headers from the global Dio instance.
      await _dio.put(
        uploadUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': fileLength,
            // Explicitly excluding Authorization header for the direct cloud upload
          },
        ),
        onSendProgress: (count, total) {
          if (total > 0 && onProgress != null) {
            onProgress(count / total);
          }
        },
      );

      return publicUrl;
    } catch (e) {
      print('❌ Media Upload Error for $fileName: $e');
      rethrow;
    }
  }
}
