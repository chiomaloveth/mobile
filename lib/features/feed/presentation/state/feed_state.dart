import 'package:qik_talk/features/feed/presentation/state/data/book_mark_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/follow_list_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_bookmark_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_info_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_post_profle_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/like_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_by_preference.dart';
import 'package:qik_talk/features/feed/presentation/state/data/share_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_post_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/music_search_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_info_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_user_profile_post.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_notifications.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_privacy_settings_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_blocked_list_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/delete_account_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/block_user_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/unblock_user_response.dart';

import 'package:qik_talk/features/feed/presentation/state/data/update_privacy_settings_response.dart';

enum PostUploadStatus { idle, uploading, success, failed }

const Object _omitValue = Object();

class FeedState {
  // Privacy Settings (Moved to top for verification)
  final UpdatePrivacySettingsResponse? privacySettings;
  final GetPrivacySettingsResponse? fetchedPrivacySettings;
  final bool isPrivacySettingsLoading;
  final bool isPrivacySettingsUpdating;
  final String? privacySettingsError;
  final UnblockUserResponse? unblockUserResponse;
  final bool isUnblockLoading;
  final String? unblockError;

  final BlockUserResponse? blockUserResponse;
  final bool isBlockLoading;
  final String? blockError;


  final GetBlockedListResponse? blockedListResponse;
  final bool isBlockedListLoading;
  final String? blockedListError;

  final DeleteAccountResponse? deleteAccountResponse;
  final bool isDeleteAccountLoading;
  final String? deleteAccountError;

  final List<GetFeedResponseData> followingPosts;
  final List<GetFeedResponseData> personalizedPosts;
  final GetBookmarkResponse? bookmarkedPosts;
  final List<GetUserPostProfleResponseData> userProfilePosts;
  final List<GetComment> comments;
  final List<MatchingUser> matchingUsers;
  final GetOtherInfoResponseData? otherUserInfo;
  final List<GetOtherUserProfilePostData> otherUserProfilePosts;
  final List<NotificationData> notifications;
  final List<StoryData> followingStories;

  final CreatePostResponse? createdPost;
  final GetComment? createdComment;
  final GetComment? replyingToComment;
  final LikeResponseData? like;
  final LikeResponseData? commentLike;
  final ShareResponseData? share;
  final BookMarkResponseData? bookMark;
  final GetUserInfoResponse? userInfo;
  final bool isFollowingFeedLoading;
  final bool isPersonalizedFeedLoading;
  final bool isBookmarkedLoading;
  final bool isCommentsLoading;
  final bool isUserInfoLoading;
  final bool isUserProfilePostsLoading;
  final bool isOtherUserInfoLoading;
  final bool isOtherUserProfilePostsLoading;
  final bool isFollowListLoading;
  final bool isFollowingLoadMoreLoading;
  final bool isPersonalizedLoadMoreLoading;
  final bool isMatchingUsersLoading;
  final bool isStoriesLoading;
  final bool followingHasReachedMax;
  final bool personalizedHasReachedMax;
  final List<FollowerItem> followers;
  final List<FollowingItem> following;
  final String? error;
  final String? followingFeedError;
  final String? personalizedFeedError;
  final String? notificationsError;

  final bool isNotificationsLoading;
  final bool notificationsHasReachedMax;
  final int notificationsPage;
  final int notificationsUnreadCount;

  final int followingPage;
  final int personalizedPage;
  final int userProfilePage;
  final int otherUserProfilePage;
  final bool userProfileHasReachedMax;
  final bool otherUserProfileHasReachedMax;
  final PostUploadStatus postUploadStatus;
  final String? postUploadError;
  final double postUploadProgress;

  // Music Search
  final List<MusicData> musicSearchResults;
  final bool isMusicSearching;

  // Feed Search
  final List<GetFeedResponseData> searchResults;
  final bool isSearchLoading;
  final String? searchError;

  FeedState({
    this.privacySettings,
    this.fetchedPrivacySettings,
    this.isPrivacySettingsLoading = false,
    this.isPrivacySettingsUpdating = false,
    this.privacySettingsError,
    this.unblockUserResponse,
    this.isUnblockLoading = false,
    this.unblockError,
    this.blockUserResponse,
    this.isBlockLoading = false,
    this.blockError,

    this.blockedListResponse,
    this.isBlockedListLoading = false,
    this.blockedListError,
    this.deleteAccountResponse,
    this.isDeleteAccountLoading = false,
    this.deleteAccountError,
    this.followingPosts = const [],
    this.personalizedPosts = const [],
    this.bookmarkedPosts,
    this.userProfilePosts = const [],
    this.comments = const [],
    this.matchingUsers = const [],
    this.isFollowingFeedLoading = false,
    this.isPersonalizedFeedLoading = false,
    this.isBookmarkedLoading = false,
    this.isUserInfoLoading = false,
    this.isUserProfilePostsLoading = false,
    this.isFollowListLoading = false,
    this.isFollowingLoadMoreLoading = false,
    this.isPersonalizedLoadMoreLoading = false,
    this.isMatchingUsersLoading = false,
    this.followingHasReachedMax = false,
    this.personalizedHasReachedMax = false,
    this.followers = const [],
    this.following = const [],
    this.createdPost,
    this.isCommentsLoading = false,
    this.createdComment,
    this.replyingToComment,
    this.like,
    this.commentLike,
    this.share,
    this.bookMark,
    this.userInfo,
    this.error,
    this.followingFeedError,
    this.personalizedFeedError,
    this.followingPage = 1,
    this.personalizedPage = 1,
    this.userProfilePage = 1,
    this.userProfileHasReachedMax = false,
    this.otherUserInfo,
    this.otherUserProfilePosts = const [],
    this.isOtherUserInfoLoading = false,
    this.isOtherUserProfilePostsLoading = false,
    this.otherUserProfilePage = 1,
    this.otherUserProfileHasReachedMax = false,
    this.postUploadStatus = PostUploadStatus.idle,
    this.postUploadError,
    this.postUploadProgress = 0.0,
    this.musicSearchResults = const [],
    this.isMusicSearching = false,
    this.searchResults = const [],
    this.isSearchLoading = false,
    this.searchError,
    this.notifications = const [],
    this.isNotificationsLoading = false,
    this.notificationsHasReachedMax = false,
    this.notificationsPage = 1,
    this.notificationsUnreadCount = 0,
    this.notificationsError,
    this.followingStories = const [],
    this.isStoriesLoading = false,
  });


  FeedState copyWith({
    UpdatePrivacySettingsResponse? privacySettings,
    GetPrivacySettingsResponse? fetchedPrivacySettings,
    bool? isPrivacySettingsLoading,
    bool? isPrivacySettingsUpdating,
    String? privacySettingsError,
    UnblockUserResponse? unblockUserResponse,
    bool? isUnblockLoading,
    String? unblockError,
    BlockUserResponse? blockUserResponse,
    bool? isBlockLoading,
    String? blockError,

    GetBlockedListResponse? blockedListResponse,
    bool? isBlockedListLoading,
    String? blockedListError,
    DeleteAccountResponse? deleteAccountResponse,
    bool? isDeleteAccountLoading,
    String? deleteAccountError,
    List<GetFeedResponseData>? followingPosts,
    List<GetFeedResponseData>? personalizedPosts,
    GetBookmarkResponse? bookmarkedPosts,
    List<GetUserPostProfleResponseData>? userProfilePosts,
    List<GetComment>? comments,
    List<MatchingUser>? matchingUsers,
    Object? createdPost = _omitValue,
    bool? isFollowingFeedLoading,
    bool? isPersonalizedFeedLoading,
    bool? isBookmarkedLoading,
    bool? isCommentsLoading,
    bool? isUserInfoLoading,
    bool? isUserProfilePostsLoading,
    bool? isFollowListLoading,
    bool? isFollowingLoadMoreLoading,
    bool? isPersonalizedLoadMoreLoading,
    bool? isMatchingUsersLoading,
    bool? followingHasReachedMax,
    bool? personalizedHasReachedMax,
    List<FollowerItem>? followers,
    List<FollowingItem>? following,

    Object? createdComment = _omitValue,
    Object? replyingToComment = _omitValue,
    Object? like = _omitValue,
    Object? commentLike = _omitValue,
    Object? share = _omitValue,
    Object? bookMark = _omitValue,
    Object? userInfo = _omitValue,
    String? error,
    String? followingFeedError,
    String? personalizedFeedError,
    int? followingPage,
    int? personalizedPage,
    int? userProfilePage,
    int? otherUserProfilePage,
    bool? userProfileHasReachedMax,
    bool? otherUserProfileHasReachedMax,
    PostUploadStatus? postUploadStatus,
    String? postUploadError,
    double? postUploadProgress,
    List<MusicData>? musicSearchResults,
    bool? isMusicSearching,
    List<GetFeedResponseData>? searchResults,
    bool? isSearchLoading,
    String? searchError,
    Object? otherUserInfo = _omitValue,
    List<GetOtherUserProfilePostData>? otherUserProfilePosts,
    bool? isOtherUserInfoLoading,
    bool? isOtherUserProfilePostsLoading,
    List<NotificationData>? notifications,
    bool? isNotificationsLoading,
    int? notificationsPage,
    int? notificationsUnreadCount,
    bool? notificationsHasReachedMax,
    String? notificationsError,
    List<StoryData>? followingStories,
    bool? isStoriesLoading,
  }) {
    return FeedState(
      privacySettings: privacySettings ?? this.privacySettings,
      fetchedPrivacySettings: fetchedPrivacySettings ?? this.fetchedPrivacySettings,
      isPrivacySettingsLoading:
          isPrivacySettingsLoading ?? this.isPrivacySettingsLoading,
      isPrivacySettingsUpdating:
          isPrivacySettingsUpdating ?? this.isPrivacySettingsUpdating,
      privacySettingsError: privacySettingsError ?? this.privacySettingsError,
      unblockUserResponse: unblockUserResponse ?? this.unblockUserResponse,
      isUnblockLoading: isUnblockLoading ?? this.isUnblockLoading,
      unblockError: unblockError ?? this.unblockError,
      blockUserResponse: blockUserResponse ?? this.blockUserResponse,
      isBlockLoading: isBlockLoading ?? this.isBlockLoading,
      blockError: blockError ?? this.blockError,

      blockedListResponse: blockedListResponse ?? this.blockedListResponse,
      isBlockedListLoading: isBlockedListLoading ?? this.isBlockedListLoading,
      blockedListError: blockedListError ?? this.blockedListError,
      deleteAccountResponse:
          deleteAccountResponse ?? this.deleteAccountResponse,
      isDeleteAccountLoading:
          isDeleteAccountLoading ?? this.isDeleteAccountLoading,
      deleteAccountError: deleteAccountError ?? this.deleteAccountError,
      followingPosts: followingPosts ?? this.followingPosts,
      personalizedPosts: personalizedPosts ?? this.personalizedPosts,
      bookmarkedPosts: bookmarkedPosts ?? this.bookmarkedPosts,
      userProfilePosts: userProfilePosts ?? this.userProfilePosts,
      otherUserProfilePosts:
          otherUserProfilePosts ?? this.otherUserProfilePosts,
      comments: comments ?? this.comments,
      matchingUsers: matchingUsers ?? this.matchingUsers,
      createdPost: createdPost == _omitValue
          ? this.createdPost
          : (createdPost as CreatePostResponse?),
      isFollowingFeedLoading:
          isFollowingFeedLoading ?? this.isFollowingFeedLoading,
      isPersonalizedFeedLoading:
          isPersonalizedFeedLoading ?? this.isPersonalizedFeedLoading,
      isBookmarkedLoading: isBookmarkedLoading ?? this.isBookmarkedLoading,
      isCommentsLoading: isCommentsLoading ?? this.isCommentsLoading,
      isUserInfoLoading: isUserInfoLoading ?? this.isUserInfoLoading,
      isUserProfilePostsLoading:
          isUserProfilePostsLoading ?? this.isUserProfilePostsLoading,
      isOtherUserInfoLoading:
          isOtherUserInfoLoading ?? this.isOtherUserInfoLoading,
      isOtherUserProfilePostsLoading:
          isOtherUserProfilePostsLoading ?? this.isOtherUserProfilePostsLoading,
      isFollowListLoading: isFollowListLoading ?? this.isFollowListLoading,
      isFollowingLoadMoreLoading:
          isFollowingLoadMoreLoading ?? this.isFollowingLoadMoreLoading,
      isPersonalizedLoadMoreLoading:
          isPersonalizedLoadMoreLoading ?? this.isPersonalizedLoadMoreLoading,
      isMatchingUsersLoading:
          isMatchingUsersLoading ?? this.isMatchingUsersLoading,
      followingHasReachedMax:
          followingHasReachedMax ?? this.followingHasReachedMax,
      personalizedHasReachedMax:
          personalizedHasReachedMax ?? this.personalizedHasReachedMax,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      otherUserInfo: otherUserInfo == _omitValue
          ? this.otherUserInfo
          : (otherUserInfo as GetOtherInfoResponseData?),

      createdComment: createdComment == _omitValue
          ? this.createdComment
          : (createdComment as GetComment?),
      replyingToComment: replyingToComment == _omitValue
          ? this.replyingToComment
          : (replyingToComment as GetComment?),
      like: like == _omitValue ? this.like : (like as LikeResponseData?),
      commentLike: commentLike == _omitValue
          ? this.commentLike
          : (commentLike as LikeResponseData?),
      share: share == _omitValue ? this.share : (share as ShareResponseData?),
      bookMark: bookMark == _omitValue
          ? this.bookMark
          : (bookMark as BookMarkResponseData?),
      userInfo: userInfo == _omitValue
          ? this.userInfo
          : (userInfo as GetUserInfoResponse?),
      error: error,
      followingFeedError: followingFeedError ?? this.followingFeedError,
      personalizedFeedError:
          personalizedFeedError ?? this.personalizedFeedError,
      followingPage: followingPage ?? this.followingPage,
      personalizedPage: personalizedPage ?? this.personalizedPage,
      userProfilePage: userProfilePage ?? this.userProfilePage,
      otherUserProfilePage: otherUserProfilePage ?? this.otherUserProfilePage,
      userProfileHasReachedMax:
          userProfileHasReachedMax ?? this.userProfileHasReachedMax,
      otherUserProfileHasReachedMax:
          otherUserProfileHasReachedMax ?? this.otherUserProfileHasReachedMax,
      postUploadStatus: postUploadStatus ?? this.postUploadStatus,
      postUploadError: postUploadError,
      postUploadProgress: postUploadProgress ?? this.postUploadProgress,
      musicSearchResults: musicSearchResults ?? this.musicSearchResults,
      isMusicSearching: isMusicSearching ?? this.isMusicSearching,
      searchResults: searchResults ?? this.searchResults,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      searchError: searchError ?? this.searchError,
      notifications: notifications ?? this.notifications,
      isNotificationsLoading:
          isNotificationsLoading ?? this.isNotificationsLoading,
      notificationsPage: notificationsPage ?? this.notificationsPage,
      notificationsUnreadCount:
          notificationsUnreadCount ?? this.notificationsUnreadCount,
      notificationsHasReachedMax:
          notificationsHasReachedMax ?? this.notificationsHasReachedMax,
      notificationsError: notificationsError ?? this.notificationsError,
      followingStories: followingStories ?? this.followingStories,
      isStoriesLoading: isStoriesLoading ?? this.isStoriesLoading,
    );
  }
}
