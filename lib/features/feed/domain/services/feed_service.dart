import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:qik_talk/features/feed/data/models/create_post_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_preference_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_reply_comment_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_story_dto.dart';
import 'package:qik_talk/features/feed/data/models/update_privacy_settings_dto.dart';
import 'package:qik_talk/features/feed/data/models/block_user_dto.dart';
import 'package:qik_talk/features/feed/data/models/unblock_user_dto.dart';

import 'package:qik_talk/features/feed/data/models/delete_account_dto.dart';
import 'package:qik_talk/features/feed/data/models/update_profile_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_preference_list.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_reply_comment_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_story_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/delete_comment_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/follow_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/follow_list_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_bookmark_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment_reply.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_notifications.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_notification_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_all_notifications_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_info_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_user_profile_post.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_preference_list.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_by_preference.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_info_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_post_profle_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/like_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/book_mark_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/music_search_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/share_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/view_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_post_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_viewers_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_privacy_settings_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/block_user_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/unblock_user_response.dart';

import 'package:qik_talk/features/feed/presentation/state/data/get_blocked_list_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/delete_account_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/update_privacy_settings_response.dart';

abstract class FeedService {
  Future<Either<Exception, CreatePostResponse>> createPost(CreatePostDto data);

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
  });

  Future<Either<Exception, LikeResponseData>> likePost(
    String id,
    Map<String, dynamic> data,
  );

  Future<Either<Exception, ShareResponseData>> sharePost(String postId);

  Future<Either<Exception, List<GetComment>>> getPostComments({
    required String postId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Exception, GetComment>> addComment(
    String postId,
    Map<String, dynamic> data,
  );

  Future<Either<Exception, LikeResponseData>> likeComment(
    String id,
    Map<String, dynamic> data,
  );

  Future<Either<Exception, GetComment>> addCommentWithMedia(
    String postId, {
    String? content,
    required File mediaFile,
    String type = 'voice',
    String? parentId,
  });

  Future<Either<Exception, GetCommentReply>> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Exception, CreateReplyCommentResponse>> addCommentReply(
    String postId,
    CreateReplyCommentDto data,
  );

  Future<Either<Exception, CreateReplyCommentResponse>> addReplyWithMedia({
    required String postId,
    String? content,
    required File mediaFile,
    String type = 'voice',
    String? parentComment,
  });

  Future<Either<Exception, BookMarkResponseData>> bookMarkPost(String postId);

  Future<Either<Exception, GetBookmarkResponse>> getBookmarkedPosts({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, GetUserInfoResponse>> getUserInfo();

  Future<Either<Exception, List<GetUserPostProfleResponseData>>>
  getUserPostsForProfile({int page = 1, int limit = 10});

  Future<Either<Exception, FollowResponseData>> followUser(String userId);

  Future<Either<Exception, FollowResponseData>> unfollowUser(String userId);

  Future<Either<Exception, GetFollowersResponse>> getFollowers(String userId);

  Future<Either<Exception, GetFollowingResponse>> getFollowing(String userId);

  Future<Either<Exception, GetPreferenceList>> getPreferenceList();

  Future<Either<Exception, CreatePreferenceList>> createPreferenceList({
    required CreatePreferenceDto data,
  });

  Future<Either<Exception, GetUserByPreference>> getUserByPreference();

  Future<Either<Exception, List<GetFeedResponseData>>> getFollowingFeed({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Exception, List<GetFeedResponseData>>> getPersonalizedFeed({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, List<GetFeedResponseData>>> searchFeed({
    required String query,
  });

  Future<Either<Exception, ViewResponseData>> viewPost({
    required String postId,
  });

  Future<Either<Exception, MusicSearchResponse>> searchMusic({
    required String query,
  });

  Future<Either<Exception, GetOtherInfoResponseData>> getOtherUserInfo({
    required String userId,
  });

  Future<Either<Exception, GetOtherUserProfilePost>> getOtherUserProfilePosts({
    required String userId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, DeleteCommentResponseData>> deleteComment({
    required String commentId,
  });

  Future<Either<Exception, GetUserInfoResponse>> updateProfile({
    required UpdateProfileDto data,
  });

  Future<Either<Exception, GetUserInfoResponse>> updateProfileWithImage({
    required UpdateProfileDto data,
    required File imageFile,
  });

  Future<Either<Exception, GetNotifications>> getReadNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, GetNotifications>> getFeedReadNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, GetNotifications>> getUserNotifications({
    required String userId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, GetNotifications>> getReadFeed({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, GetNotifications>> getReadSocialFeed({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, GetFeedResponseData>> getPostById(String id);

  Future<Either<Exception, ReadNotificationResponse>> markNotificationAsRead(String id);

  Future<Either<Exception, ReadAllNotificationsResponse>> markManyNotificationsAsRead(
    List<String> ids,
  );

  Future<Either<Exception, GetNotifications>> getNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Exception, ReadAllNotificationsResponse>> readAllNotifications();

  Future<Either<Exception, CreateStoryResponseData>> createStory({
    required CreateStoryDto data,
    required File mediaFile,
    List<File>? overlayVideoFiles,
    void Function(double)? onProgress,
  });

  Future<Either<dynamic, GetStoryResponseData>> getFollowingStories({
    int page = 1,
    int limit = 10,
  });
  Future<Either<dynamic, void>> viewStory(String id);
  Future<Either<Exception, GetStoryViewersResponse>> getStoryViewers(String id);
  Future<Either<Exception, List<Map<String, dynamic>>>> searchUsers(String query);
  Future<Either<Exception, UpdatePrivacySettingsResponse>> updatePrivacySettings({
    required UpdatePrivacySettingsDto data,
  });
  Future<Either<Exception, UnblockUserResponse>> unblockUser({
    required UnblockUserDto data,
  });
  Future<Either<Exception, BlockUserResponse>> blockUser({
    required BlockUserDto data,
  });

  Future<Either<Exception, GetBlockedListResponse>> getBlockedList();
  Future<Either<Exception, DeleteAccountResponse>> deleteAccount({
    required DeleteAccountDto data,
  });
  Future<Either<Exception, GetPrivacySettingsResponse>> getPrivacySettings();

  Future<Either<Exception, String>> submitReport({
    required String reportedItemId,
    required String itemType,
    required String reason,
    required String description,
    required String severity,
  });
}
