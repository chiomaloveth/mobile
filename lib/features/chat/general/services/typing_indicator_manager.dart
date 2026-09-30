import 'dart:async';
import 'package:flutter/foundation.dart';

/// Persistent typing indicator manager that handles typing state across the entire app.
/// This service maintains typing state like WhatsApp, showing "typing..." in place of
/// the last message and keeping it persistent while users are typing.
class TypingIndicatorManager {
  TypingIndicatorManager();

  /// Map of chatId -> Map of userId -> typing info
  final Map<String, Map<String, TypingInfo>> _typingStates = {};

  /// Map of chatId -> Set of userIds currently typing
  final Map<String, Set<String>> _activeTypers = {};

  /// Map of chatId -> Timer for auto-stop typing
  final Map<String, Timer> _typingTimers = {};

  /// Notifies listeners when typing state changes
  final ValueNotifier<Map<String, Set<String>>> _activeTypersNotifier =
      ValueNotifier({});

  /// Get active typers notifier for UI updates
  ValueNotifier<Map<String, Set<String>>> get activeTypersNotifier =>
      _activeTypersNotifier;

  /// Get typing state for a specific chat
  Set<String> getTypingUsers(String chatId) {
    return _activeTypers[chatId] ?? <String>{};
  }

  /// Check if a specific user is typing in a chat
  bool isUserTyping(String chatId, String userId) {
    return _activeTypers[chatId]?.contains(userId) ?? false;
  }

  /// Check if anyone is typing in a chat
  bool isAnyoneTyping(String chatId) {
    final typers = _activeTypers[chatId];
    return typers != null && typers.isNotEmpty;
  }

  /// Get typing text for display (like WhatsApp)
  String getTypingText(String chatId, Map<String, String> userNames) {
    final typers = _activeTypers[chatId];
    if (typers == null || typers.isEmpty) return '';

    final typersList = typers.toList();

    if (typersList.length == 1) {
      final userName = userNames[typersList.first] ?? 'Someone';
      return '$userName is typing...';
    } else if (typersList.length == 2) {
      final name1 = userNames[typersList.first] ?? 'Someone';
      final name2 = userNames[typersList[1]] ?? 'Someone';
      return '$name1 and $name2 are typing...';
    } else {
      final count = typersList.length;
      return '$count people are typing...';
    }
  }

  /// Start typing for a user in a chat
  void startTyping(String chatId, String userId, {String? userName}) {
    debugPrint('TypingIndicator: Start typing - Chat: $chatId, User: $userId');

    // Initialize chat state if needed
    _activeTypers.putIfAbsent(chatId, () => <String>{});
    _typingStates.putIfAbsent(chatId, () => <String, TypingInfo>{});

    // Add user to active typers
    _activeTypers[chatId]!.add(userId);
    _typingStates[chatId]![userId] = TypingInfo(
      userId: userId,
      userName: userName,
      startTime: DateTime.now(),
    );

    // Cancel existing timer for this chat
    _typingTimers[chatId]?.cancel();

    // Set new timer to stop typing after 10 seconds of no updates
    _typingTimers[chatId] = Timer(const Duration(seconds: 10), () {
      stopTyping(chatId, userId);
    });

    // Notify listeners
    _notifyListeners();
  }

  /// Stop typing for a user in a chat
  void stopTyping(String chatId, String userId) {
    debugPrint('TypingIndicator: Stop typing - Chat: $chatId, User: $userId');

    // Remove user from active typers
    _activeTypers[chatId]?.remove(userId);
    _typingStates[chatId]?.remove(userId);

    // Cancel timer if no one is typing in this chat
    if (_activeTypers[chatId]?.isEmpty == true) {
      _typingTimers[chatId]?.cancel();
      _typingTimers.remove(chatId);
    }

    // Notify listeners
    _notifyListeners();
  }

  /// Stop all typing in a chat (when user enters chat, etc.)
  void stopAllTypingInChat(String chatId) {
    debugPrint('TypingIndicator: Stop all typing in chat: $chatId');

    _activeTypers[chatId]?.clear();
    _typingStates[chatId]?.clear();
    _typingTimers[chatId]?.cancel();
    _typingTimers.remove(chatId);

    _notifyListeners();
  }

  /// Clear all typing state (app cleanup)
  void clearAll() {
    debugPrint('TypingIndicator: Clear all typing state');

    for (final timer in _typingTimers.values) {
      timer.cancel();
    }

    _typingStates.clear();
    _activeTypers.clear();
    _typingTimers.clear();

    _notifyListeners();
  }

  /// Get typing info for a user
  TypingInfo? getTypingInfo(String chatId, String userId) {
    return _typingStates[chatId]?[userId];
  }

  /// Update typing timer for a user (called on continuous typing)
  void updateTypingTimer(String chatId, String userId) {
    // Reset the timer for this chat
    _typingTimers[chatId]?.cancel();
    _typingTimers[chatId] = Timer(const Duration(seconds: 10), () {
      stopTyping(chatId, userId);
    });
  }

  void _notifyListeners() {
    // Create a copy to avoid modification during iteration
    final copy = Map<String, Set<String>>.from(
      _activeTypers.map((key, value) => MapEntry(key, Set<String>.from(value))),
    );
    _activeTypersNotifier.value = copy;
  }

  /// Dispose resources
  void dispose() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingStates.clear();
    _activeTypers.clear();
    _typingTimers.clear();
    // Do NOT dispose the notifier — it may still be in use elsewhere
  }
}

/// Information about a typing user
class TypingInfo {
  final String userId;
  final String? userName;
  final DateTime startTime;

  TypingInfo({required this.userId, this.userName, required this.startTime});

  Duration get typingDuration => DateTime.now().difference(startTime);
}
