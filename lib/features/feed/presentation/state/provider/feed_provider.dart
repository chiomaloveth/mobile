import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:qik_talk/features/feed/data/models/update_profile_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_feed_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_bookmark_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_comment.dart';
import 'package:qik_talk/features/feed/presentation/state/data/follow_list_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_preference_list.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_notifications.dart';
//import 'package:qik_talk/features/feed/presentation/state/data/read_notification_response.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/feed/data/datasource/feed_datasource.dart';
import 'package:qik_talk/features/feed/data/models/create_post_dto.dart';
import 'package:qik_talk/utilities/metadata_utils.dart';
import 'package:qik_talk/features/feed/data/models/create_story_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_preference_dto.dart';
import 'package:qik_talk/features/feed/data/models/block_user_dto.dart';
import 'package:qik_talk/features/feed/data/models/unblock_user_dto.dart';

import 'package:qik_talk/features/feed/data/models/delete_account_dto.dart';
import 'package:qik_talk/features/feed/data/models/update_privacy_settings_dto.dart';
import 'package:qik_talk/features/feed/data/models/create_reply_comment_dto.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_reply_comment_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/create_post_response.dart';
import 'package:qik_talk/features/feed/data/services/feed_service_impl.dart';
import 'package:qik_talk/features/feed/domain/services/feed_service.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_post_profle_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/feed_state.dart';
//import 'package:qik_talk/features/feed/presentation/state/data/feed_user.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_info_response_data.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_other_user_profile_post.dart';
import 'package:qik_talk/utilities/services/media_cache_service.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_user_info_response.dart';
import 'package:qik_talk/features/feed/presentation/state/data/get_story_viewers_response.dart';
import 'package:qik_talk/utilities/services/video_compression_service.dart';
import 'package:qik_talk/utilities/media_utils.dart';


// Service provider
final feedServiceProvider = Provider<FeedService>((ref) {
  final dataSource = ref.watch(feedDataSourceProvider);
  return FeedServiceImpl(dataSource);
});

// Main feed provider
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final service = ref.watch(feedServiceProvider);
  return FeedNotifier(service);
});

/// Shared tab index for the feed screen (0 = Following, 1 = QikFlash).
/// Allows other screens (e.g. QikFlashScreen) to switch the active tab
/// before popping back.
final feedTabIndexProvider = StateProvider<int>((ref) => 0);

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedService _feedService;
  final SaveValues _saveValues = SaveValues();

  // In-memory session caches for other users allowing instant reload
  final Map<String, List<GetOtherUserProfilePostData>> _otherUserPostsCache =
      {};
  final Map<String, GetOtherInfoResponseData> _otherUserInfoCache = {};

  FeedNotifier(this._feedService) : super(FeedState()) {
    _loadCachedUserInfo();
    _loadCachedUserPosts();
  }

  Future<void> _loadCachedUserPosts() async {
    try {
      final cachedJson = await _saveValues.getString(
        AppPreferenceHelper.USER_POSTS_CACHE,
      );
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> dataList = jsonDecode(cachedJson);
        final posts = dataList
            .map((e) => GetUserPostProfleResponseData.fromJson(e))
            .toList();
        state = state.copyWith(userProfilePosts: posts);
      }
    } catch (e) {
      print('Failed to load cached user posts: $e');
    }
  }

  Future<void> _loadCachedUserInfo() async {
    try {
      final cachedJson = await _saveValues.getString(
        AppPreferenceHelper.USER_INFO_CACHE,
      );
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(cachedJson);
        final userInfo = GetUserInfoResponse.fromJson(data);
        state = state.copyWith(userInfo: userInfo);
      }
    } catch (e) {
      print('Failed to load cached user info: $e');
    }
  }

  Future<void> viewPost(String postId) async {
    final result = await _feedService.viewPost(postId: postId);
    result.fold((_) {}, (_) {});
  }

  Future<void> searchMusic(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        isMusicSearching: false,
        musicSearchResults: [],
        error: null,
      );
      return;
    }

    state = state.copyWith(isMusicSearching: true, error: null);

    final result = await _feedService.searchMusic(query: query);

    result.fold(
      (error) {
        state = state.copyWith(
          isMusicSearching: false,
          error: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isMusicSearching: false,
          musicSearchResults: response.data,
        );
      },
    );
  }

  Future<void> searchFeedPosts(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], searchError: null);
      return;
    }

    state = state.copyWith(isSearchLoading: true, searchError: null);

    final result = await _feedService.searchFeed(query: query);

    result.fold(
      (error) {
        state = state.copyWith(
          isSearchLoading: false,
          searchError: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isSearchLoading: false,
          searchResults: response,
        );
      },
    );
  }

  Future<String?> submitReport({
    required String reportedItemId,
    required String itemType,
    required String reason,
    required String description,
    required String severity,
  }) async {
    state = state.copyWith(error: null);

    final result = await _feedService.submitReport(
      reportedItemId: reportedItemId,
      itemType: itemType,
      reason: reason,
      description: description,
      severity: severity,
    );

    return result.fold(
      (error) => error.toString().replaceFirst('Exception: ', ''),
      (successMessage) => null,
    );
  }

  Future<void> loadFollowingFeed({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = state.copyWith(
        isFollowingFeedLoading: true,
        followingFeedError: null,
        followingHasReachedMax: false,
        followingPage: 1,
      );
    } else {
      state = state.copyWith(
        isFollowingLoadMoreLoading: true,
        followingFeedError: null,
      );
    }

    final result = await _feedService.getFollowingFeed(
      page: page,
      limit: limit,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isFollowingFeedLoading: false,
          isFollowingLoadMoreLoading: false,
          followingFeedError: error.toString(),
        );
      },
      (response) {
        final List<GetFeedResponseData> updatedPosts;
        if (page == 1) {
          // For Following feed, we KNOW we are following everyone by definition
          updatedPosts = response
              .map((p) => p.copyWith(isFollowing: true))
              .toList();
        } else {
          updatedPosts = [
            ...state.followingPosts,
            ...response.map((p) => p.copyWith(isFollowing: true)),
          ];
        }

        state = state.copyWith(
          isFollowingFeedLoading: false,
          isFollowingLoadMoreLoading: false,
          followingPosts: updatedPosts,
          followingPage: page,
          followingHasReachedMax: response.length < limit,
          followingFeedError: null,
        );

        // Preload new media in background
        _preloadMedia(response);

        // Sync connection status with following list
        _syncAllPostsWithFollowing();
      },
    );
  }

  Future<void> loadFollowingStories({int page = 1, int limit = 10}) async {
    state = state.copyWith(isStoriesLoading: true);

    final result = await _feedService.getFollowingStories(
      page: page,
      limit: limit,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isStoriesLoading: false,
          error: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isStoriesLoading: false,
          followingStories: response.data,
        );
      },
    );
  }

  Future<void> viewStory(String id) async {
    final result = await _feedService.viewStory(id);
    result.fold((_) {}, (_) {});
  }

  Future<void> loadMoreFollowingFeed() async {
    if (state.isFollowingLoadMoreLoading || state.followingHasReachedMax)
      return;
    await loadFollowingFeed(page: state.followingPage + 1);
  }

  Future<void> loadPersonalizedFeed({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = state.copyWith(
        isPersonalizedFeedLoading: true,
        personalizedFeedError: null,
        personalizedHasReachedMax: false,
        personalizedPage: 1,
      );
    } else {
      state = state.copyWith(
        isPersonalizedLoadMoreLoading: true,
        personalizedFeedError: null,
      );
    }

    final result = await _feedService.getPersonalizedFeed(
      page: page,
      limit: limit,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isPersonalizedFeedLoading: false,
          isPersonalizedLoadMoreLoading: false,
          personalizedFeedError: error.toString(),
        );
      },
      (response) {
        final List<GetFeedResponseData> updatedPosts;
        if (page == 1) {
          updatedPosts = response;
        } else {
          updatedPosts = [...state.personalizedPosts, ...response];
        }

        state = state.copyWith(
          isPersonalizedFeedLoading: false,
          isPersonalizedLoadMoreLoading: false,
          personalizedPosts: updatedPosts,
          personalizedPage: page,
          personalizedHasReachedMax: response.length < limit,
          personalizedFeedError: null,
        );

        // Preload new media in background
        _preloadMedia(response);

        // Sync connection status with following list
        _syncAllPostsWithFollowing();
      },
    );
  }

  Future<void> loadMorePersonalizedFeed() async {
    if (state.isPersonalizedLoadMoreLoading || state.personalizedHasReachedMax)
      return;
    await loadPersonalizedFeed(page: state.personalizedPage + 1);
  }

  /// Helper to preload media for newly fetched posts
  void _preloadMedia(List<GetFeedResponseData> posts) {
    try {
      final cacheService = MediaCacheService();
      final List<String> urlsToPreload = [];
      for (var post in posts) {
        if (post.media.isNotEmpty) {
          urlsToPreload.addAll(post.media);
        }
      }
      if (urlsToPreload.isNotEmpty) {
        // Preload images handles downloading the cache in the background
        cacheService.preloadImages(urlsToPreload);
      }
    } catch (e) {
      print('Failed to trigger media preloading: $e');
    }
  }

  /// Helper to update a post's state across all relevant lists in the state
  void _updatePostInAllLists(
    String postId,
    GetFeedResponseData Function(GetFeedResponseData) updateFn, {
    bool? isBookmarked,
  }) {
    // Sync followingPosts and personalizedPosts
    final updatedFollowingPosts = state.followingPosts.map((post) {
      return post.id == postId ? updateFn(post) : post;
    }).toList();

    final updatedPersonalizedPosts = state.personalizedPosts.map((post) {
      return post.id == postId ? updateFn(post) : post;
    }).toList();

    GetBookmarkResponse? currentBookmarked = state.bookmarkedPosts;
    GetBookmarkResponse? updatedBookmarked = currentBookmarked;

    // Special handling for the bookmarkedPosts list
    if (currentBookmarked != null && isBookmarked != null) {
      final List<GetBookmarkResponseData> bookmarkData = List.from(
        currentBookmarked.data,
      );
      if (!isBookmarked) {
        bookmarkData.removeWhere((p) => p.id == postId);
      } else if (!bookmarkData.any((p) => p.id == postId)) {
        // Note: We don't easily have the full GetBookmarkResponseData (like entry ID)
        // so we skip optimistic addition to the bookmark list here and wait for server/refresh
      }
      updatedBookmarked = currentBookmarked.copyWith(data: bookmarkData);
    } else if (currentBookmarked != null) {
      // General update (like/shares) for the bookmark list if the post exists there
      final List<GetBookmarkResponseData> bookmarkData = List.from(
        currentBookmarked.data,
      );
      bool changed = false;
      for (int i = 0; i < bookmarkData.length; i++) {
        if (bookmarkData[i].id == postId) {
          final updatedPost = updatedFollowingPosts.firstWhere(
            (p) => p.id == postId,
            orElse: () => updatedPersonalizedPosts.firstWhere(
              (p) => p.id == postId,
              orElse: () => GetFeedResponseData.empty(),
            ),
          );
          bookmarkData[i] = bookmarkData[i].copyWith(
            likes: updatedPost.likes,
            shares: updatedPost.shares,
          );
          changed = true;
        }
      }
      if (changed) {
        updatedBookmarked = currentBookmarked.copyWith(data: bookmarkData);
      }
    }

    state = state.copyWith(
      followingPosts: updatedFollowingPosts,
      personalizedPosts: updatedPersonalizedPosts,
      bookmarkedPosts: updatedBookmarked,
    );
  }

  /// Helper to update follow status for ALL posts by a specific user
  /// AND keep the state.following list in sync.
  void _updateUserFollowStatus(String userId, bool isFollowing) {
    final updatedFollowingPosts = state.followingPosts.map((post) {
      if (post.user.id == userId) {
        return post.copyWith(isFollowing: isFollowing);
      }
      return post;
    }).toList();

    final updatedPersonalizedPosts = state.personalizedPosts.map((post) {
      if (post.user.id == userId) {
        return post.copyWith(isFollowing: isFollowing);
      }
      return post;
    }).toList();

    // Also update the following list to keep it as single source of truth
    List<FollowingItem> updatedFollowing = List.from(state.following);
    final alreadyInList = updatedFollowing.any((f) => f.following.id == userId);

    if (isFollowing && !alreadyInList) {
      // Find the user's info from posts to build a synthetic FollowingItem
      final matchingPost = state.followingPosts
          .cast<GetFeedResponseData?>()
          .firstWhere(
            (p) => p!.user.id == userId,
            orElse: () => state.personalizedPosts
                .cast<GetFeedResponseData?>()
                .firstWhere((p) => p!.user.id == userId, orElse: () => null),
          );
      final username = matchingPost?.user.username ?? '';
      final profilePicture = matchingPost?.user.profilePicture ?? '';

      updatedFollowing.add(
        FollowingItem(
          id: 'optimistic_$userId',
          follower: state.userInfo?.data.id ?? '',
          following: FollowingUserInfo(
            id: userId,
            username: username,
            profilePicture: profilePicture,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } else if (!isFollowing && alreadyInList) {
      updatedFollowing.removeWhere((f) => f.following.id == userId);
    }

    // Also update otherUserInfo if it matches the userId
    GetOtherInfoResponseData? updatedOtherUserInfo = state.otherUserInfo;
    if (updatedOtherUserInfo?.data.id == userId) {
      updatedOtherUserInfo = updatedOtherUserInfo?.copyWith(
        data: updatedOtherUserInfo.data.copyWith(
          isFollowing: isFollowing,
          followersCount: isFollowing
              ? updatedOtherUserInfo.data.followersCount + 1
              : (updatedOtherUserInfo.data.followersCount - 1).clamp(
                  0,
                  999999999,
                ),
        ),
      );
    }

    state = state.copyWith(
      followingPosts: updatedFollowingPosts,
      personalizedPosts: updatedPersonalizedPosts,
      following: updatedFollowing,
      otherUserInfo: updatedOtherUserInfo,
    );
  }

  Future<void> loadComments(String postId) async {
    // Avoid double loading if already loading for the same post
    if (state.isCommentsLoading) return;

    state = state.copyWith(isCommentsLoading: true, error: null, comments: []);

    final result = await _feedService.getPostComments(postId: postId);

    result.fold(
      (error) {
        state = state.copyWith(
          isCommentsLoading: false,
          error: error.toString(),
        );
      },
      (comments) {
        state = state.copyWith(isCommentsLoading: false, comments: comments);
      },
    );
  }

  Future<GetComment?> addComment(
    String postId,
    Map<String, dynamic> data,
  ) async {
    // ── Optimistic UI: build a temporary comment and show it immediately ──
    final me = state.userInfo?.data;
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final parentComment = state.replyingToComment;

    final optimisticComment = GetComment(
      id: tempId,
      user: CommentUser(
        id: me?.id ?? '',
        username: me?.username ?? 'You',
        profilePicture: me?.profilePicture ?? '',
      ),
      post: postId,
      content: data['content'] as String?,
      type: 'text',
      parentComment: parentComment?.id,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Insert optimistic comment into the list right away
    final optimisticComments = List<GetComment>.from(state.comments);
    if (parentComment != null) {
      final parentIndex = optimisticComments.indexWhere(
        (c) => c.id == parentComment.id,
      );
      if (parentIndex != -1) {
        final parent = optimisticComments[parentIndex];
        final newReplies = List<GetComment>.from(parent.replies)
          ..add(optimisticComment);
        optimisticComments[parentIndex] = parent.copyWith(replies: newReplies);
      } else {
        optimisticComments.add(optimisticComment);
      }
    } else {
      optimisticComments.add(optimisticComment);
    }

    state = state.copyWith(
      comments: optimisticComments,
      replyingToComment: null,
      error: null,
    );

    // Optimistic update for comment count
    _updatePostInAllLists(
      postId,
      (p) => p.copyWith(commentCount: p.commentCount + 1),
    );

    // ── API call (background) ──
    final result = parentComment != null
        ? await _feedService.addCommentReply(
            postId,
            CreateReplyCommentDto(
              parentComment: parentComment.id,
              content: data['content'] ?? '',
            ),
          )
        : await _feedService.addComment(postId, data);

    return result.fold(
      (error) {
        // ── Rollback: remove the optimistic comment ──
        final rolledBack = List<GetComment>.from(state.comments);
        if (parentComment != null) {
          final parentIndex = rolledBack.indexWhere(
            (c) => c.id == parentComment.id,
          );
          if (parentIndex != -1) {
            final parent = rolledBack[parentIndex];
            final cleaned = parent.replies
                .where((r) => r.id != tempId)
                .toList();
            rolledBack[parentIndex] = parent.copyWith(replies: cleaned);
          }
        } else {
          rolledBack.removeWhere((c) => c.id == tempId);
        }

        state = state.copyWith(
          comments: rolledBack,
          error: error.toString(),
        );

        // Rollback comment count
        _updatePostInAllLists(
          postId,
          (p) => p.copyWith(commentCount: (p.commentCount - 1).clamp(0, 999999)),
        );

        return null;
      },
      (response) {
        // ── Success: swap temp comment with real server comment ──
        final GetComment comment;
        if (response is CreateReplyCommentResponse) {
          comment = GetComment(
            id: response.id ?? '',
            user: CommentUser(
              id: response.user.id ?? '',
              username: response.user.username ?? 'Unknown',
              profilePicture: response.user.profilePicture ?? '',
            ),
            post: response.post ?? postId,
            content: response.content,
            media: response.media,
            type: response.type ?? 'text',
            parentComment: response.parentComment,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
          );
        } else {
          comment = response as GetComment;
        }

        // Replace the temp comment with the real one
        final updatedComments = List<GetComment>.from(state.comments);
        if (comment.parentComment != null) {
          final parentIndex = updatedComments.indexWhere(
            (c) => c.id == comment.parentComment,
          );
          if (parentIndex != -1) {
            final parent = updatedComments[parentIndex];
            final newReplies = parent.replies
                .map((r) => r.id == tempId ? comment : r)
                .toList();
            updatedComments[parentIndex] = parent.copyWith(replies: newReplies);
          }
        } else {
          final tempIndex = updatedComments.indexWhere((c) => c.id == tempId);
          if (tempIndex != -1) {
            updatedComments[tempIndex] = comment;
          }
        }

        state = state.copyWith(
          createdComment: comment,
          comments: updatedComments,
        );

        return comment;
      },
    );
  }

  Future<GetComment?> addCommentWithMedia(
    String postId, {
    String? content,
    required File mediaFile,
    String type = 'voice',
  }) async {
    state = state.copyWith(isCommentsLoading: true, error: null);

    final parentComment = state.replyingToComment;

    final result = parentComment != null
        ? await _feedService.addReplyWithMedia(
            postId: postId,
            content: content,
            mediaFile: mediaFile,
            type: type,
            parentComment: parentComment.id,
          )
        : await _feedService.addCommentWithMedia(
            postId,
            content: content,
            mediaFile: mediaFile,
            type: type,
          );

    return result.fold(
      (error) {
        state = state.copyWith(
          isCommentsLoading: false,
          error: error.toString(),
        );
        return null;
      },
      (response) {
        final GetComment comment;
        if (response is CreateReplyCommentResponse) {
          comment = GetComment(
            id: response.id ?? '',
            user: CommentUser(
              id: response.user.id ?? '',
              username: response.user.username ?? 'Unknown',
              profilePicture: response.user.profilePicture ?? '',
            ),
            post: response.post ?? postId,
            content: response.content,
            media: response.media,
            type: response.type ?? 'text',
            parentComment: response.parentComment,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
          );
        } else {
          comment = response as GetComment;
        }

        final updatedComments = List<GetComment>.from(state.comments);
        if (comment.parentComment != null) {
          final parentIndex = updatedComments.indexWhere(
            (c) => c.id == comment.parentComment,
          );
          if (parentIndex != -1) {
            final parent = updatedComments[parentIndex];
            final newReplies = List<GetComment>.from(parent.replies)
              ..add(comment);
            updatedComments[parentIndex] = parent.copyWith(replies: newReplies);
          } else {
            // Parent not found in root, but just in case, add it root
            updatedComments.add(comment);
          }
        } else {
          updatedComments.add(comment);
        }

        state = state.copyWith(
          isCommentsLoading: false,
          createdComment: comment,
          comments: updatedComments,
          replyingToComment: null,
        );

        // Optimistic update for comment count
        _updatePostInAllLists(
          postId,
          (p) => p.copyWith(commentCount: p.commentCount + 1),
        );

        return comment;
      },
    );
  }

  void setReplyingTo(GetComment? comment) {
    state = state.copyWith(replyingToComment: comment);
  }

  void clearReplyingTo() {
    state = state.copyWith(replyingToComment: null);
  }

  Future<void> loadReplies(String commentId) async {
    state = state.copyWith(error: null);

    final result = await _feedService.getCommentReplies(commentId: commentId);

    result.fold(
      (error) {
        state = state.copyWith(error: error.toString());
      },
      (response) {
        // Map GetCommentReplyData to GetComment
        final replies = response.data.map((reply) {
          return GetComment(
            id: reply.id,
            user: CommentUser(
              id: reply.user.id ?? '',
              username: reply.user.username ?? 'Unknown',
              profilePicture: reply.user.profilePicture ?? '',
            ),
            post: reply.post ?? '',
            content: reply.content,
            media: (reply.media != null && reply.media!.isNotEmpty)
                ? reply.media!.first.toString()
                : null,
            likes: reply.likes?.map((e) => e.toString()).toList() ?? [],
            parentComment: reply.parentComment,
            type: reply.type ?? 'text',
            createdAt: reply.createdAt,
            updatedAt: reply.updatedAt,
            v: reply.v ?? 0,
            replies: [], // We don't support nested replies for now
          );
        }).toList();

        final updatedComments = List<GetComment>.from(state.comments);
        final parentIndex = updatedComments.indexWhere(
          (c) => c.id == commentId || c.commentId == commentId,
        );

        if (parentIndex != -1) {
          final parent = updatedComments[parentIndex];
          updatedComments[parentIndex] = parent.copyWith(replies: replies);
          state = state.copyWith(comments: updatedComments);
        }
      },
    );
  }

  Future<void> refreshFeed() async {
    await loadFollowingFeed(page: 1);
    await loadPersonalizedFeed(page: 1);
  }

  void filterPosts(String query) {
    // Search is temporarily disabled while we refine tab-specific searching
    // If needed, we can implement filtering for Following/Personalized list here
  }

  Future<void> toggleLike(String postId, String userId) async {
    final originalState = state;

    // Optimistic Update
    _updatePostInAllLists(postId, (post) {
      final likes = List<String>.from(post.likes);
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      return post.copyWith(likes: likes);
    });

    final result = await _feedService.likePost(postId, {'userId': userId});

    result.fold(
      (error) {
        state = originalState.copyWith(error: error.toString());
      },
      (response) {
        final isActuallyLiked = response.liked ?? false;
        _updatePostInAllLists(postId, (post) {
          final likes = List<String>.from(post.likes);
          if (isActuallyLiked && !likes.contains(userId)) {
            likes.add(userId);
          } else if (!isActuallyLiked && likes.contains(userId)) {
            likes.remove(userId);
          }
          return post.copyWith(likes: likes);
        });
      },
    );
  }

  Future<void> toggleLikeComment(String commentId, String userId) async {
    // 1. Optimistic Update (Immediate UI change)
    final originalComments = state.comments;

    // Local function to toggle likes in a comment or its replies
    GetComment toggleLikes(GetComment comment) {
      if (comment.id == commentId || comment.commentId == commentId) {
        final likes = List<String>.from(comment.likes);
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }
        return comment.copyWith(likes: likes);
      }

      // Check replies
      if (comment.replies.isNotEmpty) {
        final updatedReplies = comment.replies.map(toggleLikes).toList();
        return comment.copyWith(replies: updatedReplies);
      }

      return comment;
    }

    final updatedComments = state.comments.map(toggleLikes).toList();
    state = state.copyWith(comments: updatedComments);

    final result = await _feedService.likeComment(commentId, {
      'userId': userId,
    });

    result.fold(
      (error) {
        // Rollback on error
        state = state.copyWith(
          comments: originalComments,
          error: error.toString(),
        );
      },
      (response) {
        // Sync state with server response
        final isActuallyLiked = response.liked ?? false;

        GetComment syncLikes(GetComment comment) {
          if (comment.id == commentId || comment.commentId == commentId) {
            final likes = List<String>.from(comment.likes);
            if (isActuallyLiked && !likes.contains(userId)) {
              likes.add(userId);
            } else if (!isActuallyLiked && likes.contains(userId)) {
              likes.remove(userId);
            }
            return comment.copyWith(likes: likes);
          }

          if (comment.replies.isNotEmpty) {
            final updatedReplies = comment.replies.map(syncLikes).toList();
            return comment.copyWith(replies: updatedReplies);
          }

          return comment;
        }

        final finalComments = state.comments.map(syncLikes).toList();
        state = state.copyWith(comments: finalComments);
      },
    );
  }

  Future<void> deleteComment({
    required String commentId,
    required String postId,
    String? parentCommentId,
  }) async {
    final originalState = state;

    // 1. Optimistic Update
    final List<GetComment> updatedComments = List.from(state.comments);

    if (parentCommentId != null) {
      // It's a reply, find the parent and remove the child
      final parentIndex = updatedComments.indexWhere(
        (c) => c.id == parentCommentId || c.commentId == parentCommentId,
      );
      if (parentIndex != -1) {
        final parent = updatedComments[parentIndex];
        final newReplies = parent.replies
            .where((r) => r.id != commentId)
            .toList();
        updatedComments[parentIndex] = parent.copyWith(replies: newReplies);
      }
    } else {
      // It's a top-level comment
      updatedComments.removeWhere(
        (c) => c.id == commentId || c.commentId == commentId,
      );
    }

    state = state.copyWith(comments: updatedComments);

    // 2. API Call
    final result = await _feedService.deleteComment(commentId: commentId);

    result.fold(
      (error) {
        // Rollback on error
        state = originalState.copyWith(error: error.toString());
      },
      (response) {
        // 3. Sync comment count for the post
        _updatePostInAllLists(
          postId,
          (p) =>
              p.copyWith(commentCount: (p.commentCount - 1).clamp(0, 999999)),
        );
      },
    );
  }

  void createPost(
    CreatePostDto dto, {
    List<File>? mediaFiles,
    List<File>? overlayVideoFiles,
  }) async {
    state = state.copyWith(
      postUploadStatus: PostUploadStatus.uploading,
      postUploadError: null,
    );

    // ✂️ Trim videos to 3 minutes max
    List<File>? processedMedia = mediaFiles;
    if (mediaFiles != null) {
      processedMedia = [];
      for (var f in mediaFiles) {
        if (MediaUtils.isVideo(f.path)) {
          processedMedia.add(await VideoCompressionService.trimIfNecessary(input: f));
        } else {
          processedMedia.add(f);
        }
      }
    }

    List<File>? processedOverlays = overlayVideoFiles;
    if (overlayVideoFiles != null) {
      processedOverlays = [];
      for (var f in overlayVideoFiles) {
        processedOverlays.add(await VideoCompressionService.trimIfNecessary(input: f));
      }
    }

    final result = (processedMedia != null && processedMedia.isNotEmpty)
        ? await _feedService.createPostWithMedia(
            content: dto.content,
            mediaFiles: processedMedia,
            music: dto.music,
            tags: dto.tags,
            overlayText: dto.overlayText,
            overlayVideoUrls: dto.overlayVideos,
            overlayVideoFiles: processedOverlays,
            allowComments: dto.allowComment,
            taggedUsers: dto.taggedUsers,
            onProgress: (p) {
              state = state.copyWith(postUploadProgress: p);
            },
          )
        : await _feedService.createPost(dto);


    result.fold(
      (error) {
        state = state.copyWith(
          postUploadStatus: PostUploadStatus.failed,
          postUploadError: error.toString(),
        );
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && state.postUploadStatus == PostUploadStatus.failed) {
            state = state.copyWith(postUploadStatus: PostUploadStatus.idle);
          }
        });
      },
      (post) {
        final mapped = _mapCreatePostToFeed(post, dto.overlayText);
        if (mapped != null) {
          final following = List<GetFeedResponseData>.from(
            state.followingPosts,
          )..insert(0, mapped);
          final personalized = List<GetFeedResponseData>.from(
            state.personalizedPosts,
          )..insert(0, mapped);

          state = state.copyWith(
            followingPosts: following,
            personalizedPosts: personalized,
          );
        }

        state = state.copyWith(
          postUploadStatus: PostUploadStatus.success,
          createdPost: post,
        );
        // Auto-reset status after a brief delay so the success banner shows
        Future.delayed(const Duration(seconds: 3), () {
          state = state.copyWith(postUploadStatus: PostUploadStatus.idle);
        });
      },
    );
  }

  void createStory(
    CreateStoryDto dto, {
    required File mediaFile,
    List<File>? overlayVideoFiles,
  }) async {
    state = state.copyWith(
      postUploadStatus: PostUploadStatus.uploading,
      postUploadError: null,
    );

    // ✂️ Trim videos to 3 minutes max
    File processedMedia = mediaFile;
    if (MediaUtils.isVideo(mediaFile.path)) {
      processedMedia = await VideoCompressionService.trimIfNecessary(input: mediaFile);
    }

    List<File>? processedOverlays = overlayVideoFiles;
    if (overlayVideoFiles != null) {
      processedOverlays = [];
      for (var f in overlayVideoFiles) {
        processedOverlays.add(await VideoCompressionService.trimIfNecessary(input: f));
      }
    }

    final result = await _feedService.createStory(
      data: dto,
      mediaFile: processedMedia,
      overlayVideoFiles: processedOverlays,
      onProgress: (p) {
        state = state.copyWith(postUploadProgress: p);
      },
    );


    result.fold(
      (error) {
        state = state.copyWith(
          postUploadStatus: PostUploadStatus.failed,
          postUploadError: error.toString(),
        );
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && state.postUploadStatus == PostUploadStatus.failed) {
            state = state.copyWith(postUploadStatus: PostUploadStatus.idle);
          }
        });
      },
      (response) {
        state = state.copyWith(
          postUploadStatus: PostUploadStatus.success,
          // createdStory: response, // We don't have a createdStory field in state yet, but success is enough for now
        );
        // Ensure stories are refreshed immediately so the new one (with stitched overlays) appears correctly
        loadFollowingStories();

        // Auto-reset status after a brief delay
        Future.delayed(const Duration(seconds: 3), () {
          state = state.copyWith(postUploadStatus: PostUploadStatus.idle);
        });
      },
    );
  }

  GetFeedResponseData? _mapCreatePostToFeed(
    CreatePostResponse post,
    String? overlayText,
  ) {
    final me = state.userInfo?.data;
    final userId = post.user ?? '';
    final FeedUser user = (me != null && me.id == userId)
        ? FeedUser(
            id: me.id,
            username: me.username ?? 'Me',
            profilePicture: me.profilePicture,
          )
        : FeedUser(id: userId, username: 'QikTalk User', profilePicture: '');

    // Use centralized metadata stitching
    final stitchedOverlays = MetadataUtils.stitchFeedOverlays(
      overlayText,
      post.overlayVideos ?? [],
    );

    return GetFeedResponseData(
      id: post.id,
      user: user,
      content: post.content,
      media: post.media,
      likes: post.likes,
      shares: post.shares,
      bookmarks: post.bookmarks,
      views: post.views,
      sharedFrom: post.sharedFrom,
      music: post.music,
      privacy: post.privacy,
      allowComment: post.allowComment ?? true,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      isFollowing: post.isFollowing ?? false,
      overlayText: overlayText,
      overlays: stitchedOverlays.isEmpty ? null : stitchedOverlays,
      overlayVideos: post.overlayVideos,
    );
  }

  Future<bool> sharePost(String postId) async {
    state = state.copyWith(error: null);

    final result = await _feedService.sharePost(postId);

    return result.fold(
      (error) {
        state = state.copyWith(error: error.toString());
        return false;
      },
      (shareResponse) {
        final sharingUserId = shareResponse.data.user;

        _updatePostInAllLists(postId, (post) {
          final shares = List<String>.from(post.shares);
          if (!shares.contains(sharingUserId)) {
            shares.add(sharingUserId);
          }
          return post.copyWith(shares: shares);
        });

        state = state.copyWith(share: shareResponse);
        return true;
      },
    );
  }

  void resetUploadStatus() {
    state = state.copyWith(
      postUploadStatus: PostUploadStatus.idle,
      postUploadError: null,
    );
  }

  Future<void> loadBookmarkedPosts({int page = 1, int limit = 10}) async {
    state = state.copyWith(isBookmarkedLoading: true, error: null);

    final result = await _feedService.getBookmarkedPosts(
      page: page,
      limit: limit,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isBookmarkedLoading: false,
          error: error.toString(),
        );
      },
      (posts) {
        state = state.copyWith(
          isBookmarkedLoading: false,
          bookmarkedPosts: posts,
        );
      },
    );
  }

  Future<void> toggleBookmark(String postId, String userId) async {
    final originalState = state;

    // Safe lookup across all lists — avoids StateError when post is not in
    // state (e.g. when bookmarking from the Bookmarks or profile tab).
    final postToBookmark = [...state.followingPosts, ...state.personalizedPosts]
        .firstWhere(
          (p) => p.id == postId,
          orElse: () {
            // As a last resort, check the bookmarkedPosts list
            final bookmarked = state.bookmarkedPosts?.data ?? [];
            final match = bookmarked.where((b) => b.id == postId).toList();
            if (match.isEmpty)
              return GetFeedResponseData.empty(); // will be ignored below
            // Build a minimal GetFeedResponseData so the lookup doesn't throw
            return GetFeedResponseData(
              id: match.first.id,
              user: FeedUser(
                id: match.first.user.id ?? '',
                username: match.first.user.username ?? '',
                profilePicture: match.first.user.profilePicture ?? '',
              ),
              bookmarks: match.first.bookmarks
                  .map((e) => e.toString())
                  .toList(),
              likes: match.first.likes.map((e) => e.toString()).toList(),
              shares: match.first.shares.map((e) => e.toString()).toList(),
              createdAt:
                  DateTime.tryParse(match.first.createdAt) ?? DateTime.now(),
              updatedAt:
                  DateTime.tryParse(match.first.updatedAt) ?? DateTime.now(),
            );
          },
        );

    // 1. Optimistic update — toggle userId in/out of the bookmarks array
    final alreadyBookmarked = postToBookmark.bookmarks.contains(userId);
    _updatePostInAllLists(postId, (post) {
      final newBookmarks = List<String>.from(post.bookmarks);
      if (alreadyBookmarked) {
        newBookmarks.remove(userId);
      } else {
        newBookmarks.add(userId);
      }
      return post.copyWith(bookmarks: newBookmarks);
    }, isBookmarked: !alreadyBookmarked);

    final result = await _feedService.bookMarkPost(postId);

    result.fold(
      (error) {
        // Rollback on error
        state = originalState.copyWith(error: error.toString());
      },
      (response) {
        // Sync with server response — ensure bookmarks array matches
        _updatePostInAllLists(postId, (post) {
          final newBookmarks = List<String>.from(post.bookmarks);
          if (response.bookmarked && !newBookmarks.contains(userId)) {
            newBookmarks.add(userId);
          } else if (!response.bookmarked && newBookmarks.contains(userId)) {
            newBookmarks.remove(userId);
          }
          return post.copyWith(bookmarks: newBookmarks);
        }, isBookmarked: response.bookmarked);
        // Keep bookmarkedPosts in sync
        loadBookmarkedPosts();
      },
    );
  }

  Future<String?> toggleFollow(String postId, String userId) async {
    final originalState = state;

    // 1. Use central following list as source of truth for "willFollow"
    final isAlreadyFollowing = state.following.any(
      (f) => f.following.id == userId,
    );
    final willFollow = !isAlreadyFollowing;

    _updateUserFollowStatus(userId, willFollow);

    // 2. Call the correct endpoint
    final result = willFollow
        ? await _feedService.followUser(userId)
        : await _feedService.unfollowUser(userId);

    return result.fold(
      (error) {
        // Rollback on error
        state = originalState.copyWith(error: error.toString());
        return willFollow ? 'Failed to follow user' : 'Failed to unfollow user';
      },
      (response) {
        // Server confirmed — re-fetch following list for eventual consistency
        final currentUserId = state.userInfo?.data.id;
        if (currentUserId != null) {
          loadFollowing(currentUserId);
        }
        // If we are on someone's profile, refresh their info to update counts
        if (state.otherUserInfo?.data.id == userId) {
          loadOtherUserInfo(userId);
        }
        return null;
      },
    );
  }

  /// Follow/unfollow a user directly (without needing a postId)
  Future<String?> toggleFollowUser(String userId, bool willFollow) async {
    final originalState = state;

    // 1. Optimistic Update (posts + following list)
    _updateUserFollowStatus(userId, willFollow);

    // 2. Call endpoint
    final result = willFollow
        ? await _feedService.followUser(userId)
        : await _feedService.unfollowUser(userId);

    return result.fold(
      (error) {
        // Rollback on error
        state = originalState.copyWith(error: error.toString());
        return willFollow ? 'Failed to follow user' : 'Failed to unfollow user';
      },
      (response) {
        // Server confirmed — re-fetch following list for eventual consistency
        final currentUserId = state.userInfo?.data.id;
        if (currentUserId != null) {
          loadFollowing(currentUserId);
        }
        // If we are on someone's profile, refresh their info to update counts
        if (state.otherUserInfo?.data.id == userId) {
          loadOtherUserInfo(userId);
        }
        return null;
      },
    );
  }

  /// Fetch current user info (profile data, counts, etc.)
  Future<void> loadUserInfo({bool silent = false}) async {
    // Prevent redundant simultaneous fetches
    if (state.isUserInfoLoading) return;

    // Only show loading if not silent or if we don't have any data at all
    if (!silent || state.userInfo == null) {
      state = state.copyWith(isUserInfoLoading: true, error: null);
    }

    final result = await _feedService.getUserInfo();

    result.fold(
      (error) {
        state = state.copyWith(
          isUserInfoLoading: false,
          error: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(isUserInfoLoading: false, userInfo: response);
        getPrivacySettings();

        // Cache the response for faster subsequent loads
        try {
          _saveValues.saveString(
            AppPreferenceHelper.USER_INFO_CACHE,
            jsonEncode(response.toJson()),
          );
        } catch (e) {
          print('Failed to cache user info: $e');
        }

        // Automatically load connection lists for the user to sync feed status and follow back logic
        loadFollowing(response.data.id);
        loadFollowers(response.data.id);
      },
    );
  }

  /// Fetch ALL of the current user's posts for the profile grid.
  /// Automatically keeps fetching pages until all posts are loaded.
  Future<void> loadUserPostsForProfile({int limit = 10}) async {
    // If we already have posts (e.g. from cache), fetch silently in the background
    final isSilent = state.userProfilePosts.isNotEmpty;

    state = state.copyWith(
      isUserProfilePostsLoading: !isSilent,
      userProfilePosts: isSilent ? state.userProfilePosts : [],
      userProfilePage: 0,
      userProfileHasReachedMax: false,
      error: null,
    );

    int page = 1;
    List<GetUserPostProfleResponseData> allPosts = [];

    while (true) {
      final result = await _feedService.getUserPostsForProfile(
        page: page,
        limit: limit,
      );

      bool shouldStop = false;

      result.fold(
        (error) {
          shouldStop = true;
          state = state.copyWith(
            isUserProfilePostsLoading: false,
            error: error.toString(),
          );
        },
        (posts) {
          // Stop when backend returns empty — all posts have been fetched
          if (posts.isEmpty) {
            shouldStop = true;
          } else {
            allPosts = [...allPosts, ...posts];
            state = state.copyWith(
              userProfilePosts: allPosts,
              userProfilePage: page,
              userProfileHasReachedMax: posts.isEmpty,
            );
          }
        },
      );

      if (shouldStop) break;
      page++;
    }

    state = state.copyWith(
      isUserProfilePostsLoading: false,
      userProfileHasReachedMax: true,
    );

    // Cache the first 20 posts persistently
    try {
      final cacheLimit = allPosts.length > 20 ? 20 : allPosts.length;
      final cacheList = allPosts
          .take(cacheLimit)
          .map((e) => e.toJson())
          .toList();
      _saveValues.saveString(
        AppPreferenceHelper.USER_POSTS_CACHE,
        jsonEncode(cacheList),
      );
    } catch (e) {
      print('Failed to cache user posts: $e');
    }
  }

  /// Append the next page of the current user's profile posts (for manual refresh)
  Future<void> loadMoreUserPostsForProfile({int limit = 20}) async {
    if (state.isUserProfilePostsLoading || state.userProfileHasReachedMax)
      return;

    final nextPage = state.userProfilePage + 1;
    state = state.copyWith(isUserProfilePostsLoading: true, error: null);

    final result = await _feedService.getUserPostsForProfile(
      page: nextPage,
      limit: limit,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isUserProfilePostsLoading: false,
          error: error.toString(),
        );
      },
      (newPosts) {
        final combined = [...state.userProfilePosts, ...newPosts];
        state = state.copyWith(
          isUserProfilePostsLoading: false,
          userProfilePosts: combined,
          userProfilePage: nextPage,
          userProfileHasReachedMax: newPosts.length < limit,
        );
      },
    );
  }

  /// Fetch other user info (profile data, counts, etc.)
  Future<void> loadOtherUserInfo(String userId) async {
    // Check in-memory cache first for instant load
    if (_otherUserInfoCache.containsKey(userId)) {
      state = state.copyWith(
        otherUserInfo: _otherUserInfoCache[userId],
        isOtherUserInfoLoading: false, // Silent background refresh
        error: null,
      );
    } else {
      // Clear out previous other user info so it doesn't flash stale data
      if (state.otherUserInfo?.data.id != userId) {
        state = state.copyWith(
          isOtherUserInfoLoading: true,
          error: null,
          otherUserInfo: null, // Safely clears the previous user's data
        );
      } else {
        state = state.copyWith(isOtherUserInfoLoading: true, error: null);
      }
    }

    final result = await _feedService.getOtherUserInfo(userId: userId);

    result.fold(
      (error) {
        state = state.copyWith(
          isOtherUserInfoLoading: false,
          error: error.toString(),
        );
      },
      (response) {
        // Update cache
        _otherUserInfoCache[userId] = response;
        state = state.copyWith(
          isOtherUserInfoLoading: false,
          otherUserInfo: response,
        );
      },
    );
  }

  /// Fetch ALL of the other user's posts for the profile grid.
  Future<void> loadOtherUserPostsForProfile(
    String userId, {
    int limit = 10,
  }) async {
    final hasCachedPosts = _otherUserPostsCache.containsKey(userId);

    state = state.copyWith(
      isOtherUserProfilePostsLoading: !hasCachedPosts,
      otherUserProfilePosts: hasCachedPosts
          ? _otherUserPostsCache[userId]!
          : [],
      otherUserProfilePage: 0,
      otherUserProfileHasReachedMax: false,
      error: null,
    );

    int page = 1;
    List<GetOtherUserProfilePostData> allPosts = [];

    while (true) {
      final result = await _feedService.getOtherUserProfilePosts(
        userId: userId,
        page: page,
        limit: limit,
      );

      bool shouldStop = false;

      result.fold(
        (error) {
          shouldStop = true;
          state = state.copyWith(
            isOtherUserProfilePostsLoading: false,
            error: error.toString(),
          );
        },
        (response) {
          final posts = response.data;
          // Stop when backend returns empty — all posts have been fetched
          if (posts.isEmpty) {
            shouldStop = true;
          } else {
            allPosts = [...allPosts, ...posts];
            state = state.copyWith(
              otherUserProfilePosts: allPosts,
              otherUserProfilePage: page,
              otherUserProfileHasReachedMax: posts.isEmpty,
            );
          }
        },
      );

      if (shouldStop) break;
      page++;
    }

    state = state.copyWith(
      isOtherUserProfilePostsLoading: false,
      otherUserProfileHasReachedMax: true,
    );

    // Save to in-memory session cache
    if (allPosts.isNotEmpty) {
      _otherUserPostsCache[userId] = allPosts;
    }
  }

  /// Append the next page of the other user's profile posts
  Future<void> loadMoreOtherUserPostsForProfile(
    String userId, {
    int limit = 20,
  }) async {
    if (state.isOtherUserProfilePostsLoading ||
        state.otherUserProfileHasReachedMax)
      return;

    final nextPage = state.otherUserProfilePage + 1;
    state = state.copyWith(isOtherUserProfilePostsLoading: true, error: null);

    final result = await _feedService.getOtherUserProfilePosts(
      userId: userId,
      page: nextPage,
      limit: limit,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isOtherUserProfilePostsLoading: false,
          error: error.toString(),
        );
      },
      (response) {
        final newPosts = response.data;
        final combined = [...state.otherUserProfilePosts, ...newPosts];
        state = state.copyWith(
          isOtherUserProfilePostsLoading: false,
          otherUserProfilePosts: combined,
          otherUserProfilePage: nextPage,
          otherUserProfileHasReachedMax: newPosts.length < limit,
        );
      },
    );
  }

  /// Fetch followers for a given user
  Future<void> loadFollowers(String userId) async {
    state = state.copyWith(isFollowListLoading: true, error: null);

    final result = await _feedService.getFollowers(userId);

    result.fold(
      (error) {
        state = state.copyWith(
          isFollowListLoading: false,
          error: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isFollowListLoading: false,
          followers: response.data,
        );
      },
    );
  }

  /// Fetch users that a given user is following
  Future<void> loadFollowing(String userId) async {
    state = state.copyWith(isFollowListLoading: true, error: null);

    final result = await _feedService.getFollowing(userId);

    result.fold(
      (error) {
        state = state.copyWith(
          isFollowListLoading: false,
          error: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isFollowListLoading: false,
          following: response.data,
        );
        // Sync existing posts with the newly loaded following list
        _syncAllPostsWithFollowing();
      },
    );
  }

  /// Helper to sync all posts in state with the current following list
  void _syncAllPostsWithFollowing() {
    final followingIds = state.following.map((f) => f.following.id).toSet();

    final updatedPersonalized = state.personalizedPosts.map((post) {
      final isFollowing = followingIds.contains(post.user.id);
      return post.copyWith(isFollowing: isFollowing);
    }).toList();

    final updatedFollowingPosts = state.followingPosts.map((post) {
      final isFollowing = followingIds.contains(post.user.id);
      return post.copyWith(isFollowing: isFollowing);
    }).toList();

    state = state.copyWith(
      followingPosts: updatedFollowingPosts,
      personalizedPosts: updatedPersonalized,
    );
  }

  Future<void> getUserByPreference() async {
    state = state.copyWith(isMatchingUsersLoading: true, error: null);

    final result = await _feedService.getUserByPreference();

    result.fold(
      (error) {
        state = state.copyWith(
          isMatchingUsersLoading: false,
          error: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isMatchingUsersLoading: false,
          matchingUsers: response.data.matchingUsers,
        );
      },
    );
  }

  Future<void> updateProfile(UpdateProfileDto data) async {
    state = state.copyWith(isUserInfoLoading: true, error: null);

    final result = await _feedService.updateProfile(data: data);

    result.fold(
      (error) {
        state = state.copyWith(
          isUserInfoLoading: false,
          error: error.toString(),
        );
      },
      (response) async {
        state = state.copyWith(
          isUserInfoLoading: false,
          userInfo: response,
        );
        try {
          _saveValues.saveString(
            AppPreferenceHelper.USER_INFO_CACHE,
            jsonEncode(response.toJson()),
          );
        } catch (_) {}
      },
    );
  }

  Future<void> updateProfileWithImage({
    required UpdateProfileDto data,
    required File imageFile,
  }) async {
    state = state.copyWith(isUserInfoLoading: true, error: null);

    final result = await _feedService.updateProfileWithImage(
      data: data,
      imageFile: imageFile,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isUserInfoLoading: false,
          error: error.toString(),
        );
      },
      (response) async {
        state = state.copyWith(
          isUserInfoLoading: false,
          userInfo: response,
        );
        try {
          _saveValues.saveString(
            AppPreferenceHelper.USER_INFO_CACHE,
            jsonEncode(response.toJson()),
          );
        } catch (_) {}
      },
    );
  }

  Future<void> loadNotifications({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = state.copyWith(
        isNotificationsLoading: true,
        notificationsError: null,
        notificationsHasReachedMax: false,
        notificationsPage: 1,
      );
    }

    final result = await _feedService.getNotifications(
      page: page,
      limit: limit,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isNotificationsLoading: false,
          notificationsError: error.toString(),
        );
      },
      (response) {
        final List<NotificationData> updatedNotifications;
        if (page == 1) {
          updatedNotifications = response.data;
        } else {
          updatedNotifications = [...state.notifications, ...response.data];
        }

        state = state.copyWith(
          isNotificationsLoading: false,
          notifications: updatedNotifications,
          notificationsPage: page,
          notificationsHasReachedMax:
              response.data.isEmpty ||
              updatedNotifications.length >= response.totalCount,
          notificationsUnreadCount: response.unreadCount,
          notificationsError: null,
        );
      },
    );
  }

  Future<void> loadMoreNotifications() async {
    if (state.isNotificationsLoading || state.notificationsHasReachedMax)
      return;
    await loadNotifications(page: state.notificationsPage + 1);
  }

  Future<void> markNotificationAsRead(String id) async {
    // Optimistically update local state
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id && !(n.isRead ?? n.read ?? false)) {
        return n.copyWith(isRead: true, read: true);
      }
      return n;
    }).toList();

    // Check if we actually changed anything before decrementing
    final wasUnread = state.notifications.any(
      (n) => n.id == id && !(n.isRead ?? n.read ?? false),
    );
    final newUnreadCount = wasUnread && state.notificationsUnreadCount > 0
        ? state.notificationsUnreadCount - 1
        : state.notificationsUnreadCount;

    state = state.copyWith(
      notifications: updatedNotifications,
      notificationsUnreadCount: newUnreadCount,
    );

    final result = await _feedService.markNotificationAsRead(id);
    result.fold(
      (error) {
        // We don't rollback for "read" status as it's not critical, but we log the error
        debugPrint('Failed to mark notification as read: $error');
      },
      (response) {
        // The read notification endpoint now returns a single item response
        // We update just our global count
        state = state.copyWith(
          notificationsUnreadCount: response.unreadCount > 0
              ? response.unreadCount
              : 0,
        );
      },
    );
  }

  Future<GetFeedResponseData?> getPostById(String id) async {
    final result = await _feedService.getPostById(id);
    return result.fold((error) {
      debugPrint('Failed to fetch post by ID: $error');
      return null;
    }, (post) => post);
  }

  Future<void> readAllNotifications() async {
    final originalNotifications = state.notifications;
    final originalUnreadCount = state.notificationsUnreadCount;

    // 1. Optimistic Update
    final updatedNotifications = state.notifications.map((n) {
      return n.copyWith(isRead: true, read: true);
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      notificationsUnreadCount: 0,
    );

    final result = await _feedService.readAllNotifications();
    result.fold(
      (error) {
        // Rollback on error
        state = state.copyWith(
          notifications: originalNotifications,
          notificationsUnreadCount: originalUnreadCount,
          error: error.toString(),
        );
      },
      (response) {
        // Server confirmed. We update with the server's unread count just in case.
        // Note: ReadAllNotificationsResponse does not return the updated data list,
        // so we keep our optimistically updated list.
        state = state.copyWith(notificationsUnreadCount: response.unreadCount);
      },
    );
  }

  Future<GetStoryViewersResponse?> getStoryViewers(String id) async {
    final result = await _feedService.getStoryViewers(id);
    return result.fold((error) {
      debugPrint('Failed to fetch story viewers: $error');
      return null;
    }, (response) => response);
  }

  /// Search all QikTalk users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final result = await _feedService.searchUsers(query);
    return result.fold((error) {
      debugPrint('searchUsers Error: $error');
      return <Map<String, dynamic>>[];
    }, (users) => users);
  }

  Future<bool> updatePrivacySettings(
    UpdatePrivacySettingsDto data, {
    bool showLoading = false,
  }) async {
    final previousSettings = state.fetchedPrivacySettings;

    if (showLoading) {
      state = state.copyWith(
        isPrivacySettingsUpdating: true,
        privacySettingsError: null,
      );
    }

    final result = await _feedService.updatePrivacySettings(data: data);

    return result.fold(
      (error) {
        state = state.copyWith(
          isPrivacySettingsUpdating: false,
          privacySettingsError: error.toString(),
          fetchedPrivacySettings: previousSettings, // Rollback on error
        );
        debugPrint('❌ updatePrivacySettings Error: $error');
        return false;
      },
      (response) async {
        // Refresh settings from backend to ensure data consistency
        await getPrivacySettings();
        state = state.copyWith(isPrivacySettingsUpdating: false);
        return true;
      },
    );
  }

  Future<bool> getPrivacySettings() async {
    state = state.copyWith(
      isPrivacySettingsLoading: true,
      privacySettingsError: null,
    );

    final result = await _feedService.getPrivacySettings();

    return result.fold(
      (error) {
        state = state.copyWith(
          isPrivacySettingsLoading: false,
          privacySettingsError: error.toString(),
        );
        return false;
      },
      (response) {
        state = state.copyWith(
          isPrivacySettingsLoading: false,
          fetchedPrivacySettings: response,
        );
        return true;
      },
    );
  }

  Future<String?> blockUser(String userId) async {
    state = state.copyWith(isBlockLoading: true, blockError: null);

    final result = await _feedService.blockUser(
      data: BlockUserDto(userIdToBlock: userId),
    );

    return result.fold(
      (error) {
        state = state.copyWith(
          isBlockLoading: false,
          blockError: error.toString(),
        );
        return error.toString();
      },
      (response) {
        // Remove all posts by the blocked user from the current feed
        final updatedFollowingPosts = state.followingPosts
            .where((post) => post.user.id != userId)
            .toList();
        final updatedPersonalizedPosts = state.personalizedPosts
            .where((post) => post.user.id != userId)
            .toList();

        state = state.copyWith(
          isBlockLoading: false,
          followingPosts: updatedFollowingPosts,
          personalizedPosts: updatedPersonalizedPosts,
        );
        return null;
      },
    );
  }

  Future<bool> unblockUser(UnblockUserDto data) async {
    state = state.copyWith(isUnblockLoading: true, unblockError: null);

    final result = await _feedService.unblockUser(data: data);

    return result.fold(
      (error) {
        state = state.copyWith(
          isUnblockLoading: false,
          unblockError: error.toString(),
        );
        return false;
      },
      (response) {
        state = state.copyWith(
          isUnblockLoading: false,
          unblockUserResponse: response,
        );
        return true;
      },
    );
  }

  Future<void> getBlockedList() async {
    state = state.copyWith(isBlockedListLoading: true, blockedListError: null);

    final result = await _feedService.getBlockedList();

    result.fold(
      (error) {
        state = state.copyWith(
          isBlockedListLoading: false,
          blockedListError: error.toString(),
        );
      },
      (response) {
        state = state.copyWith(
          isBlockedListLoading: false,
          blockedListResponse: response,
        );
      },
    );
  }

  Future<bool> deleteAccount(DeleteAccountDto data) async {
    state = state.copyWith(
      isDeleteAccountLoading: true,
      deleteAccountError: null,
    );

    final result = await _feedService.deleteAccount(data: data);

    return result.fold(
      (error) {
        state = state.copyWith(
          isDeleteAccountLoading: false,
          deleteAccountError: error.toString(),
        );
        return false;
      },
      (response) {
        state = state.copyWith(
          isDeleteAccountLoading: false,
          deleteAccountResponse: response,
        );
        return true;
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preference List (Choose Interests)
// ─────────────────────────────────────────────────────────────────────────────

class PreferenceListState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final GetPreferenceList? data;

  const PreferenceListState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.data,
  });

  PreferenceListState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    GetPreferenceList? data,
  }) {
    return PreferenceListState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      data: data ?? this.data,
    );
  }
}

final preferenceListProvider =
    StateNotifierProvider<PreferenceListNotifier, PreferenceListState>((ref) {
      final service = ref.watch(feedServiceProvider);
      return PreferenceListNotifier(service);
    });

class PreferenceListNotifier extends StateNotifier<PreferenceListState> {
  final FeedService _feedService;

  PreferenceListNotifier(this._feedService)
    : super(const PreferenceListState()) {
    loadPreferenceList();
  }

  Future<void> loadPreferenceList() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _feedService.getPreferenceList();

    result.fold(
      (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
      },
    );
  }

  /// Saves the user's selected interests. Returns true on success.
  Future<bool> createPreferenceList({
    required List<String> entertainment,
    required List<String> homeFamily,
    required List<String> fashionBeauty,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    final result = await _feedService.createPreferenceList(
      data: CreatePreferenceDto(
        entertainment: entertainment,
        homeFamily: homeFamily,
        fashionBeauty: fashionBeauty,
      ),
    );

    return result.fold(
      (error) {
        state = state.copyWith(isSaving: false, error: error.toString());
        return false;
      },
      (_) {
        state = state.copyWith(isSaving: false);
        return true;
      },
    );
  }
}
