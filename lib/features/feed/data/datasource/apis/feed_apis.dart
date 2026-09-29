import 'package:dio/dio.dart';
//import 'package:qik_talk/features/feed/data/models/block_user_dto.dart';
//import 'package:qik_talk/features/feed/data/models/create_post_dto.dart';

//import 'package:qik_talk/features/feed/data/models/create_preference_dto.dart';
//import 'package:qik_talk/features/feed/data/models/create_reply_comment_dto.dart';
//import 'package:qik_talk/features/feed/data/models/create_story_dto.dart';
//import 'package:qik_talk/features/feed/data/models/update_profile_dto.dart';
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
//import 'package:qik_talk/features/feed/presentation/state/data/get_comment_response_data.dart';
//import 'package:qik_talk/features/feed/presentation/state/data/get_comments_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response.dart';
//import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_single_post_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_notifications.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_notification_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/read_all_notifications_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_info_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_user_profile_post.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_preference_list.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_by_preference.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_info_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_post_profle_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/like_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/music_search_response.dart';

import 'package:qik_talk/features/feed/presentation/state/data/get_privacy_settings_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/block_user_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/unblock_user_response.dart';

import 'package:qik_talk/features/feed/presentation/state/data/get_blocked_list_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/delete_account_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/update_privacy_settings_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/view_story_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/share_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/view_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_post_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_viewers_response.dart';
import 'package:retrofit/retrofit.dart';

part 'feed_apis.g.dart';

@RestApi()
abstract class FeedApis {
  factory FeedApis(Dio dio, {String? baseUrl}) = _FeedApis;

  // // Create a new post
  @POST('social/feed')
  Future<CreatePostResponse> createPost(@Body() Map<String, dynamic> data);

  // // Like a post
  @PUT('social/feed/{id}/like')
  Future<LikeResponseData> likePost(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @PUT('social/feed/comment/{id}/like')
  Future<LikeResponseData> likeComment(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @POST('social/feed/{id}/share')
  Future<ShareResponseData> sharePost(@Path('id') String postId);

  // // Get comments for a post
  @GET('social/feed/{id}/comment')
  Future<List<GetComment>> getPostComments({
    @Path('id') required String postId,
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  // // Add a comment to a post
  @POST('social/feed/{id}/comment')
  Future<GetComment> addComment(
    @Path('id') String postId,
    @Body() Map<String, dynamic> data,
  );

  // Get replies for a specific comment
  @GET('social/feed/comment/{commentId}/replies')
  Future<GetCommentReply> getCommentReplies({
    @Path('commentId') required String commentId,
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  @POST('social/feed/{postId}/comment')
  Future<CreateReplyCommentResponse> addCommentReply(
    @Path('postId') String postId,
    @Body() Map<String, dynamic> data,
  );

  @POST('social/feed/{postId}/bookmark')
  Future<BookMarkResponseData> bookmarkPost(@Path('postId') String postId);

  @GET('social/feed/bookmarks')
  Future<GetBookmarkResponse> getBookmarkedPosts({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('user/user-info')
  Future<GetUserInfoResponse> getUserInfo({@Query('userId') String? userId});

  @GET('social/feed/user')
  Future<List<GetUserPostProfleResponseData>> getUserPostsForProfile({
    @Query('userId') String? userId,
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @POST('user/{userId}/follow')
  Future<FollowResponseData> followUser(@Path('userId') String userId);

  @DELETE('user/{userId}/unfollow')
  Future<FollowResponseData> unfollowUser(@Path('userId') String userId);

  @GET('user/{userId}/followers')
  Future<GetFollowersResponse> getFollowers(@Path('userId') String userId);

  @GET('user/{userId}/following')
  Future<GetFollowingResponse> getFollowing(@Path('userId') String userId);

  @GET('user/preferences/options')
  Future<GetPreferenceList> getPreferenceList();

  @POST('user/preferences')
  Future<CreatePreferenceList> createPreferenceList({
    @Body() required Map<String, dynamic> data,
  });

  @GET('user/match-preferences')
  Future<GetUserByPreference> getUserByPreference();

  @GET('social/feed/following')
  Future<GetFeedResponse> getFollowingFeed({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('social/feed/personalized')
  Future<GetFeedResponse> getPersonalizedFeed({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('feed/search')
  Future<GetFeedResponse> searchFeed({@Query('q') required String query});

  @POST('social/feed/view')
  Future<ViewResponseData> viewPost({
    @Body() required Map<String, dynamic> body,
  });

  @GET('music/search')
  Future<MusicSearchResponse> searchMusic({
    @Query('query') required String query,
  });

  @GET('social/feed/user/{userId}/info')
  Future<GetOtherInfoResponseData> getOtherUserInfo({
    @Path('userId') required String userId,
  });

  @GET('social/feed/user/{userId}/posts')
  Future<GetOtherUserProfilePost> getOtherUserProfilePosts({
    @Path('userId') required String userId,
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @DELETE('social/feed/{commentId}/comment')
  Future<DeleteCommentResponseData> deleteComment({
    @Path('commentId') required String commentId,
  });

  @PUT('users/profile/update')
  Future<GetUserInfoResponse> updateProfile({
    @Body() required Map<String, dynamic> data,
  });

  @GET('notification/feed')
  Future<GetNotifications> getNotifications({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('notification/feed/read')
  Future<GetNotifications> getReadNotifications({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('notification/feed/read')
  Future<GetNotifications> getFeedReadNotifications({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('notification/user-notifications')
  Future<GetNotifications> getUserNotifications({
    @Query('userId') required String userId,
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('feed/read')
  Future<GetNotifications> getReadFeed({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('social/feed/read')
  Future<GetNotifications> getReadSocialFeed({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('feed/{id}')
  Future<GetSinglePostResponse> getPostById(@Path('id') String id);

  @PATCH('notification/{id}/read')
  Future<ReadNotificationResponse> markNotificationAsRead(
    @Path('id') String id,
  );

  @PATCH('notification/mark-many-read')
  Future<ReadAllNotificationsResponse> markManyNotificationsAsRead(
    @Body() Map<String, dynamic> body,
  );

  @PATCH('notification/read-all')
  Future<ReadAllNotificationsResponse> readAllNotifications();

  @POST('social/feed/create-story')
  Future<CreateStoryResponseData> createStory({
    @Body() required Map<String, dynamic> data,
  });

  @GET('social/feed/story/following')
  Future<GetStoryResponseData> getFollowingStories({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @POST('social/feed/story/{id}/view')
  Future<ViewStoryResponse> viewStory(@Path('id') String id);

  @GET('social/feed/viewers/{id}')
  Future<GetStoryViewersResponse> getStoryViewers(@Path('id') String id);
  @POST('media/generate-upload-url')
  Future<dynamic> generateUploadUrl(@Body() Map<String, dynamic> data);

  @PATCH('privacy/update')
  Future<UpdatePrivacySettingsResponse> updatePrivacySettings(
    @Body() Map<String, dynamic> data,
  );

  @POST('users/unblock')
  Future<UnblockUserResponse> unblockUser(@Body() Map<String, dynamic> data);

  @POST('users/block')
  Future<BlockUserResponse> blockUser(@Body() Map<String, dynamic> data);

  @GET('users/blocked-list')
  Future<GetBlockedListResponse> getBlockedList();

  @DELETE('users/account/delete')
  Future<DeleteAccountResponse> deleteAccount(
    @Body() Map<String, dynamic> data,
  );

  @GET('privacy')
  Future<GetPrivacySettingsResponse> getPrivacySettings();

  @POST('report/submit')
  Future<dynamic> submitReport(@Body() Map<String, dynamic> data);
}
