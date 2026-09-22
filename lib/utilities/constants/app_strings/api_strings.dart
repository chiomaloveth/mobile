import 'package:qik_talk/utilities/constants/app_config.dart';

class ApiStrings {
  static const serverUrlOne = AppConfig.apiUrl;
  static const baseUriTwo = AppConfig.baseUrl;
  static const baseUriImage = AppConfig.imageUrl;
  static const localServerUrl = "http://192.168.1.125:5000";
  static const baseUri = serverUrlOne;
  static const sufyanBranch = AppConfig.baseUrl;

  static const String twoFaStatus = baseUri + 'auth/security/two-factor/status';
  static const String twoFaEnable = baseUri + 'auth/security/two-factor/pin';
  static const String twoFaVerify = baseUri + 'auth/security/2fa/verify';
  static const String twoFaDisable =
      baseUri + 'auth/security/two-factor/disable';
  static const String twoFaRecoveryEmail =
      baseUri + 'auth/security/two-factor/recovery-email';
  static const String twoFaRecoveryEmailVerify =
      baseUri + 'auth/security/two-factor/recovery-email/verify';
  static const String twoFaResetRequest =
      baseUri + 'auth/security/two-factor/reset/request';
  static const String twoFaResetConfirm =
      baseUri + 'auth/security/two-factor/reset/confirm';
  static const String twoFaCheckPin = baseUri + 'auth/2fa/pin';
  static const String twoFaSetPin = twoFaEnable;

  // Auth endpoints
  static const String requestOtp = baseUri + 'auth/request-otp';
  static const String verifyOtp = baseUri + 'auth/verify-otp';
  static const String login = baseUri + 'auth/login';
  static const String forgetPassword = baseUri + 'auth/forgot-password';
  static const String verifyEmailOtp = baseUri + 'auth/verify-reset-otp';
  static const String passwordReset = baseUri + 'auth/reset-password';
  static const String createLoginDetails = baseUri + 'auth/security';

  // User endpoints
  static const String uploadPhotoUsername = baseUri + 'user/profile/update';
  static const String checkUserExist = baseUri + 'user/search';
  static const String syncContacts = baseUri + 'user/sync-contacts';
  static const String changePassword =
      baseUri + 'user/settings/change-password';
  static const String updateDataSettings = baseUri + 'user/profile/update';
  static const String getUserInfo = baseUri + 'user/user-info';
  static const String deleteAccountRequestOtp =
      baseUri + 'user/account/delete/request-otp';
  static const String deleteAccountVerifyOtp =
      baseUri + 'user/account/delete/verify-otp';
  static const String deleteAccountConfirm =
      baseUri + 'user/account/delete/confirm';
  static const String updatePrivacy = baseUri + 'privacy/update';

  // Chat endpoints
  static const String accessNewChat = baseUri + 'chat/access';
  static const String getAllChat = baseUri + 'chat';
  static const String getChatHistory = baseUri + 'message/';
  static const String markAsRead = baseUri + 'message/read';
  static const String sendMessageToApi = baseUri + 'message';
  static const String forwardMessage = baseUri + 'message/forward';

  static const String uploadStatus = baseUri + 'social/status';

  static const String getUnreadChatCount = baseUri + 'chat/unread-count';
  static const String getUnreadChatCountPerChat = baseUri + 'chat/unread-chats';

  // AI Chat endpoint
  static const String aiChat = baseUri + 'ai/chat';

  // Social Feed endpoints
  static const String socialFeed = baseUri + 'social/feed';

  static String viewStatus(String statusId) =>
      '${baseUri}social/status/$statusId/view';

  // Group endpoints
  static const String createGroup = baseUri + 'chat/group';
  static const String renameGroup = baseUri + 'chat/group/rename';
  static const String addUserToGroup = baseUri + 'chat/group/add';
  static const String removeUserFromGroup = baseUri + 'chat/group/remove';
  static const String makeUserAdmin = baseUri + 'chat/group/admin/add';
  static const String removeUserFromAdmin = baseUri + 'chat/group/admin/remove';

  // Community endpoints
  static const String getCommunitiesByUserOrAdmin =
      baseUri + 'chat/community-byUserOrAdmin';

  // Helper methods for dynamic endpoints
  static String likeFeed(String postId) => '${baseUri}social/feed/$postId/like';
  static String commentFeed(String postId) =>
      '${baseUri}social/feed/$postId/comment';
  static String deleteFeed(String postId) => '${baseUri}social/feed/$postId';
  static String updateGroupDescription(String groupId) =>
      '${baseUri}chat/group/$groupId/description';
  static String leaveGroup(String groupId) =>
      '${baseUri}chat/group/$groupId/leave';

  static String getGroupDetails(String groupId) => '${baseUri}chat/$groupId';
  static String getGroupProfile(String groupId) =>
      '${baseUri}chat/group/$groupId';

  // Settings - Backups
  static const String getBackups = '${baseUri}settings/backups';
  static const String createBackup = '${baseUri}settings/backups';
  static const String googleDriveStatus =
      '${baseUri}settings/backups/google-drive/status';
  static const String connectGoogleDrive =
      '${baseUri}settings/backups/google-drive/connect';
  static const String disconnectGoogleDrive =
      '${baseUri}settings/backups/google-drive/disconnect';
  static const String listGoogleDriveFiles =
      '${baseUri}settings/backups/google-drive/files';
  static const String uploadToGoogleDrive =
      '${baseUri}settings/backups/google-drive/upload';
  static const String restoreFromGoogleDrive =
      '${baseUri}settings/backups/google-drive/restore';
  static String deleteGoogleDriveFile(String fileId) =>
      '${baseUri}settings/backups/google-drive/files/$fileId';

  // Settings - Premium
  static const String getPremiumStatus = '${baseUri}settings/premium/status';
  static const String getPremiumPlans = '${baseUri}settings/premium/plans';
  static const String subscribePremium = '${baseUri}settings/premium/subscribe';
  static const String cancelPremium = '${baseUri}settings/premium/cancel';
  static const String upgradePremium = '${baseUri}settings/premium/upgrade';
  static const String getBillingHistory =
      '${baseUri}settings/premium/billing/history';
  static const String updatePaymentMethod =
      '${baseUri}settings/premium/billing/payment-method';

  // Settings - Notifications
  static const String updateNotificationSettings =
      '${baseUri}user/settings/notifications';
  static const String getNotificationSettings =
      '${baseUri}user/settings/notifications';

  // Settings - 2FA alias routes
  static const String twoFactorStatus =
      '${baseUri}settings/security/two-factor/status';
  static const String createTwoFactorPin =
      '${baseUri}settings/security/two-factor/pin';
  static const String verifyTwoFactorPin =
      '${baseUri}settings/security/two-factor/verify';
  static const String updateTwoFactorPin =
      '${baseUri}settings/security/two-factor/pin';
  static const String addRecoveryEmail =
      '${baseUri}settings/security/two-factor/recovery-email';
  static const String verifyRecoveryEmail =
      '${baseUri}settings/security/two-factor/recovery-email/verify';
  static const String disableTwoFactor =
      '${baseUri}settings/security/two-factor/disable';
  static const String resetTwoFactorRequest =
      '${baseUri}settings/security/two-factor/reset/request';
  static const String resetTwoFactorConfirm =
      '${baseUri}settings/security/two-factor/reset/confirm';

  // Change Phone Number
  static const String changeNumberRequest =
      baseUri + 'user/settings/change-number/request';
  static const String changeNumberVerify =
      baseUri + 'user/settings/change-number/verify';
  static const String requestAccountInfo =
      baseUri + 'user/settings/account-info/request';
}
