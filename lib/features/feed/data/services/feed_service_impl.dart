import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:qik_talk/features/feed/data/datasource/feed_datasource.dart';
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
import 'package:qik_talk/features/feed/domain/services/feed_service.dart';
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
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
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
import 'package:qik_talk/features/feed/presentation/state/data/get_story_viewers_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_notifications.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_notification_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_all_notifications_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_privacy_settings_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/update_privacy_settings_response.dart';

class FeedServiceImpl implements FeedService {
  final FeedDataSource feedDataSource;

  FeedServiceImpl(this.feedDataSource);

  @override
  Future<Either<Exception, List<GetComment>>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await feedDataSource.getPostComments(
        postId: postId,
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getPostComments Error: $e');
      debugPrint('getPostComments StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, CreatePostResponse>> createPost(
    CreatePostDto data,
  ) async {
    try {
      final response = await feedDataSource.createPost(data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('createPost Error: $e');
      debugPrint('createPost StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, CreatePostResponse>> createPostWithMedia({
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
    try {
      final response = await feedDataSource.createPostWithMedia(
        content: content,
        mediaFiles: mediaFiles,
        music: music,
        tags: tags,
        overlayText: overlayText,
        overlayVideoUrls: overlayVideoUrls,
        overlayVideoFiles: overlayVideoFiles,
        allowComments: allowComments,
        taggedUsers: taggedUsers,
        onProgress: onProgress,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('createPostWithMedia Error: $e');
      debugPrint('createPostWithMedia StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetComment>> addComment(
    String postId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await feedDataSource.addComment(postId, data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('addComment Error: $e');
      debugPrint('addComment StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, LikeResponseData>> likePost(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await feedDataSource.likePost(id, data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('likePost Error: $e');
      debugPrint('likePost StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, ShareResponseData>> sharePost(String postId) async {
    try {
      final response = await feedDataSource.sharePost(postId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('sharePost Error: $e');
      debugPrint('sharePost StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, LikeResponseData>> likeComment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await feedDataSource.likeComment(id, data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('likeComment Error: $e');
      debugPrint('likeComment StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetComment>> addCommentWithMedia(
    String postId, {
    String? content,
    required File mediaFile,
    String type = 'voice',
    String? parentId,
  }) async {
    try {
      final response = await feedDataSource.addCommentWithMedia(
        postId,
        content: content,
        mediaFile: mediaFile,
        type: type,
        parentId: parentId,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('addCommentWithMedia Error: $e');
      debugPrint('addCommentWithMedia StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetCommentReply>> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await feedDataSource.getCommentReplies(
        commentId: commentId,
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getCommentReplies Error: $e');
      debugPrint('getCommentReplies StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, CreateReplyCommentResponse>> addCommentReply(
    String postId,
    CreateReplyCommentDto data,
  ) async {
    try {
      final response = await feedDataSource.addCommentReply(postId, data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('addCommentReply Error: $e');
      debugPrint('addCommentReply StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, CreateReplyCommentResponse>> addReplyWithMedia({
    required String postId,
    String? content,
    required File mediaFile,
    String type = 'voice',
    String? parentComment,
  }) async {
    try {
      final response = await feedDataSource.addReplyWithMedia(
        postId: postId,
        content: content,
        mediaFile: mediaFile,
        type: type,
        parentComment: parentComment,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('addReplyWithMedia Error: $e');
      debugPrint('addReplyWithMedia StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, BookMarkResponseData>> bookMarkPost(
    String postId,
  ) async {
    try {
      final response = await feedDataSource.bookmarkPost(postId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('bookMarkPost Error: $e');
      debugPrint('bookMarkPost StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetBookmarkResponse>> getBookmarkedPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getBookmarkedPosts(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint(' getBookmarkedPosts Error: $e');
      debugPrint(' getBookmarkedPosts StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetUserInfoResponse>> getUserInfo() async {
    try {
      final response = await feedDataSource.getUserInfo();
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getUserInfo Error: $e');
      debugPrint('getUserInfo StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<GetUserPostProfleResponseData>>>
  getUserPostsForProfile({int page = 1, int limit = 10}) async {
    try {
      final response = await feedDataSource.getUserPostsForProfile(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getUserPostsForProfile Error: $e');
      debugPrint('getUserPostsForProfile StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, FollowResponseData>> followUser(
    String userId,
  ) async {
    try {
      final response = await feedDataSource.followUser(userId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('followUser Error: $e');
      debugPrint('followUser StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, FollowResponseData>> unfollowUser(
    String userId,
  ) async {
    try {
      final response = await feedDataSource.unfollowUser(userId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('unfollowUser Error: $e');
      debugPrint('unfollowUser StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetFollowersResponse>> getFollowers(
    String userId,
  ) async {
    try {
      final response = await feedDataSource.getFollowers(userId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getFollowers Error: $e');
      debugPrint('getFollowers StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetFollowingResponse>> getFollowing(
    String userId,
  ) async {
    try {
      final response = await feedDataSource.getFollowing(userId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getFollowing Error: $e');
      debugPrint('getFollowing StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetPreferenceList>> getPreferenceList() async {
    try {
      final response = await feedDataSource.getPreferenceList();
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getPreferenceList Error: $e');
      debugPrint('getPreferenceList StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, CreatePreferenceList>> createPreferenceList({
    required CreatePreferenceDto data,
  }) async {
    try {
      final response = await feedDataSource.createPreferenceList(data: data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('createPreferenceList Error: $e');
      debugPrint('createPreferenceList StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetUserByPreference>> getUserByPreference() async {
    try {
      final response = await feedDataSource.getUserByPreference();
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getUserByPreference Error: $e');
      debugPrint('getUserByPreference StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<GetFeedResponseData>>> getFollowingFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getFollowingFeed(
        page: page,
        limit: limit,
      );
      return Right(response.data);
    } catch (e, stackTrace) {
      debugPrint('getFollowingFeed Error: $e');
      debugPrint('getFollowingFeed StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<GetFeedResponseData>>> getPersonalizedFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getPersonalizedFeed(
        page: page,
        limit: limit,
      );
      return Right(response.data);
    } catch (e, stackTrace) {
      debugPrint('getPersonalizedFeed Error: $e');
      debugPrint('getPersonalizedFeed StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<GetFeedResponseData>>> searchFeed({
    required String query,
  }) async {
    try {
      final response = await feedDataSource.searchFeed(query: query);
      return Right(response.data);
    } catch (e, stackTrace) {
      debugPrint('searchFeed Error: $e');
      debugPrint('searchFeed StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, ViewResponseData>> viewPost({
    required String postId,
  }) async {
    try {
      final response = await feedDataSource.viewPost(postId: postId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('viewPost Error: $e');
      debugPrint('viewPost StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, MusicSearchResponse>> searchMusic({
    required String query,
  }) async {
    try {
      final response = await feedDataSource.searchMusic(query: query);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('searchMusic Error: $e');
      debugPrint('searchMusic StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetOtherInfoResponseData>> getOtherUserInfo({
    required String userId,
  }) async {
    try {
      final response = await feedDataSource.getOtherUserInfo(userId: userId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getOtherUserInfo Error: $e');
      debugPrint('getOtherUserInfo StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetOtherUserProfilePost>> getOtherUserProfilePosts({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getOtherUserProfilePosts(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getOtherUserProfilePosts Error: $e');
      debugPrint('getOtherUserProfilePosts StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, DeleteCommentResponseData>> deleteComment({
    required String commentId,
  }) async {
    try {
      final response = await feedDataSource.deleteComment(commentId: commentId);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('deleteComment Error: $e');
      debugPrint('deleteComment StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetUserInfoResponse>> updateProfile({
    required UpdateProfileDto data,
  }) async {
    try {
      final response = await feedDataSource.updateProfile(data: data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('updateProfile Error: $e');
      debugPrint('updateProfile StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetUserInfoResponse>> updateProfileWithImage({
    required UpdateProfileDto data,
    required File imageFile,
  }) async {
    try {
      final response = await feedDataSource.updateProfileWithImage(
        data: data,
        imageFile: imageFile,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('updateProfileWithImage Error: $e');
      debugPrint('updateProfileWithImage StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetNotifications>> getReadNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getReadNotifications(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getReadNotifications Error: $e');
      debugPrint('getReadNotifications StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetNotifications>> getFeedReadNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getFeedReadNotifications(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getFeedReadNotifications Error: $e');
      debugPrint('getFeedReadNotifications StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetNotifications>> getUserNotifications({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getUserNotifications(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getUserNotifications Error: $e');
      debugPrint('getUserNotifications StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetNotifications>> getReadFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getReadFeed(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getReadFeed Error: $e');
      debugPrint('getReadFeed StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetNotifications>> getReadSocialFeed({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getReadSocialFeed(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getReadSocialFeed Error: $e');
      debugPrint('getReadSocialFeed StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetFeedResponseData>> getPostById(String id) async {
    try {
      final response = await feedDataSource.getPostById(id);
      return Right(response.data);
    } catch (e, stackTrace) {
      debugPrint('getPostById Error: $e');
      debugPrint('getPostById StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, ReadNotificationResponse>> markNotificationAsRead(
    String id,
  ) async {
    try {
      final response = await feedDataSource.markNotificationAsRead(id);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('markNotificationAsRead Error: $e');
      debugPrint('markNotificationAsRead StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, ReadAllNotificationsResponse>>
  markManyNotificationsAsRead(List<String> ids) async {
    try {
      final response = await feedDataSource.markManyNotificationsAsRead(ids);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('markManyNotificationsAsRead Error: $e');
      debugPrint('markManyNotificationsAsRead StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetNotifications>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getNotifications(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getNotifications Error: $e');
      debugPrint('getNotifications StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, ReadAllNotificationsResponse>>
  readAllNotifications() async {
    try {
      final response = await feedDataSource.readAllNotifications();
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('readAllNotifications Error: $e');
      debugPrint('readAllNotifications StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, CreateStoryResponseData>> createStory({
    required CreateStoryDto data,
    required File mediaFile,
    List<File>? overlayVideoFiles,
    void Function(double)? onProgress,
  }) async {
    try {
      final response = await feedDataSource.createStory(
        dto: data,
        mediaFile: mediaFile,
        overlayVideoFiles: overlayVideoFiles,
        onProgress: onProgress,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('createStory Error: $e');
      debugPrint('createStory StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetStoryResponseData>> getFollowingStories({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await feedDataSource.getFollowingStories(
        page: page,
        limit: limit,
      );
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getFollowingStories Error: $e');
      debugPrint('getFollowingStories StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<dynamic, void>> viewStory(String id) async {
    try {
      await feedDataSource.viewStory(id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<Exception, GetStoryViewersResponse>> getStoryViewers(
    String id,
  ) async {
    try {
      final response = await feedDataSource.getStoryViewers(id);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getStoryViewers Error: $e');
      debugPrint('getStoryViewers StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Map<String, dynamic>>>> searchUsers(
    String query,
  ) async {
    try {
      final response = await feedDataSource.searchUsers(query);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('searchUsers Error: $e');
      debugPrint('searchUsers StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, UpdatePrivacySettingsResponse>>
  updatePrivacySettings({required UpdatePrivacySettingsDto data}) async {
    try {
      final response = await feedDataSource.updatePrivacySettings(data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('updatePrivacySettings Error: $e');
      debugPrint('updatePrivacySettings StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetPrivacySettingsResponse>>
  getPrivacySettings() async {
    try {
      final response = await feedDataSource.getPrivacySettings();
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getPrivacySettings Error: $e');
      debugPrint('getPrivacySettings StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, UnblockUserResponse>> unblockUser({
    required UnblockUserDto data,
  }) async {
    try {
      final response = await feedDataSource.unblockUser(data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('unblockUser Error: $e');
      debugPrint('unblockUser StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, BlockUserResponse>> blockUser({
    required BlockUserDto data,
  }) async {
    try {
      final response = await feedDataSource.blockUser(data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('blockUser Error: $e');
      debugPrint('blockUser StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, GetBlockedListResponse>> getBlockedList() async {
    try {
      final response = await feedDataSource.getBlockedList();
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('getBlockedList Error: $e');
      debugPrint('getBlockedList StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, DeleteAccountResponse>> deleteAccount({
    required DeleteAccountDto data,
  }) async {
    try {
      final response = await feedDataSource.deleteAccount(data);
      return Right(response);
    } catch (e, stackTrace) {
      debugPrint('deleteAccount Error: $e');
      debugPrint('deleteAccount StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, String>> submitReport({
    required String reportedItemId,
    required String itemType,
    required String reason,
    required String description,
    required String severity,
  }) async {
    try {
      final response = await feedDataSource.submitReport(
        reportedItemId: reportedItemId,
        itemType: itemType,
        reason: reason,
        description: description,
        severity: severity,
      );
      if (response['success'] == true) {
        return Right(response['message'] ?? 'Report submitted successfully.');
      } else {
        return Left(
          Exception(response['message'] ?? 'Failed to submit report.'),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('submitReport Error: $e');
      debugPrint('submitReport StackTrace: $stackTrace');
      return Left(Exception(e.toString()));
    }
  }
}
