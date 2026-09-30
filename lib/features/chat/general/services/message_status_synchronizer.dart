import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Synchronizes message delivery and read receipt status in real-time.
/// This service ensures:
/// - Messages transition through correct status states (sending → sent → delivered → read)
/// - No status downgrades (e.g., read → delivered)
/// - Immediate UI updates when status changes
/// - Proper socket event handling and acknowledgments
class MessageStatusSynchronizer {
  final IO.Socket? socket;
  final String chatId;
  final String userId;
  final Function(String messageId, MessageStatus newStatus) onStatusChange;
  final Function() onRefreshUI;

  MessageStatusSynchronizer({
    required this.socket,
    required this.chatId,
    required this.userId,
    required this.onStatusChange,
    required this.onRefreshUI,
  });

  /// Process a message when it's being sent
  /// Returns the updated message with status = sending
  ChatMessage processSendingMessage(ChatMessage message) {
    debugPrint('📤 [MSG_STATUS] Processing SENDING: ${message.id}');
    onStatusChange(message.id, MessageStatus.sending);
    return message.copyWith(status: MessageStatus.sending);
  }

  /// Handle successful send to server
  /// Updates status to 'sent' and broadcasts via socket if needed
  void handleMessageSent(String messageId) {
    debugPrint('✅ [MSG_STATUS] Message SENT: $messageId');
    onStatusChange(messageId, MessageStatus.sent);
    onRefreshUI();
  }

  /// Handle delivery confirmation from recipient
  /// Only updates if current status is lower (sent or sending)
  void handleMessageDelivered(String messageId) {
    debugPrint('📦 [MSG_STATUS] Message DELIVERED: $messageId');
    onStatusChange(messageId, MessageStatus.delivered);
    onRefreshUI();
  }

  /// Handle read confirmation from recipient
  /// Updates status to 'read' (blue ticks)
  void handleMessageRead(String messageId) {
    debugPrint('👁️ [MSG_STATUS] Message READ: $messageId');
    onStatusChange(messageId, MessageStatus.read);
    onRefreshUI();
  }

  /// Emit "message delivered" to the sender
  /// Call this when receiving a message to acknowledge delivery
  void emitDeliveryReceipt(String messageId) {
    if (socket?.connected == true) {
      socket?.emit('message delivered', {
        'chatId': chatId,
        'messageId': messageId,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('📤 [DELIVERY_ACK] Delivered receipt sent for $messageId');
    }
  }

  /// Emit "mark as read" to the sender
  /// Call this when the chat is visible to mark messages as read
  void emitReadReceipts(List<String> messageIds) {
    if (socket?.connected == true && messageIds.isNotEmpty) {
      socket?.emit('mark as read', {
        'chatId': chatId,
        'userId': userId,
        'messageIds': messageIds,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint(
        '📤 [READ_ACK] Read receipts sent for ${messageIds.length} messages',
      );
    }
  }

  /// Batch emit delivery receipts for multiple messages
  void emitBatchDeliveryReceipts(List<String> messageIds) {
    if (socket?.connected == true && messageIds.isNotEmpty) {
      for (final messageId in messageIds) {
        emitDeliveryReceipt(messageId);
      }
    }
  }

  /// Get the correct status display text for a message
  static String getStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return '⏱️ Sending';
      case MessageStatus.sent:
        return '✓ Sent';
      case MessageStatus.delivered:
        return '✓✓ Delivered';
      case MessageStatus.read:
        return '✓✓ Read';
      case MessageStatus.failed:
        return '⚠️ Failed';
    }
  }

  /// Get the status number (1, 2, or 3 ticks + color)
  static ({int ticks, bool isBlue}) getStatusTicks(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return (ticks: 0, isBlue: false); // Clock icon
      case MessageStatus.sent:
        return (ticks: 1, isBlue: false); // Single gray tick
      case MessageStatus.delivered:
        return (ticks: 2, isBlue: false); // Double gray ticks
      case MessageStatus.read:
        return (ticks: 2, isBlue: true); // Double blue ticks
      case MessageStatus.failed:
        return (ticks: 0, isBlue: false); // Error icon
    }
  }
}

/// Message status progression validator
/// Ensures messages never downgrade status
class StatusProgression {
  static const _progression = {
    MessageStatus.sending: [MessageStatus.sent, MessageStatus.failed],
    MessageStatus.sent: [MessageStatus.delivered, MessageStatus.failed],
    MessageStatus.delivered: [MessageStatus.read],
    MessageStatus.read: [MessageStatus.read], // Terminal state
    MessageStatus.failed: [MessageStatus.sending], // Can retry
  };

  /// Check if a status transition is valid
  static bool isValidTransition(
    MessageStatus currentStatus,
    MessageStatus newStatus,
  ) {
    final validNext = _progression[currentStatus] ?? [];
    return validNext.contains(newStatus);
  }

  /// Get the recommended next status
  static MessageStatus? getNextStatus(MessageStatus currentStatus) {
    final validNext = _progression[currentStatus] ?? [];
    return validNext.isNotEmpty ? validNext.first : null;
  }

  /// Check if a status is terminal (can't be changed)
  static bool isTerminal(MessageStatus status) {
    return status == MessageStatus.read;
  }
}
