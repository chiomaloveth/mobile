import 'package:hive_ce/hive.dart';

part 'offline_message_queue.g.dart';

/// Represents a queued message waiting to be sent
@HiveType(typeId: 3)
class QueuedMessage extends HiveObject {
  @HiveField(0)
  final String tempId;

  @HiveField(1)
  final String chatId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String? replyToId;

  @HiveField(4)
  final DateTime queuedAt;

  @HiveField(5)
  final String type; // 'text', 'image', 'video', 'audio', 'document'

  @HiveField(6)
  final Map<String, dynamic>? metadata; // For file paths, etc.

  @HiveField(7)
  int retryCount;

  QueuedMessage({
    required this.tempId,
    required this.chatId,
    required this.content,
    this.replyToId,
    required this.queuedAt,
    this.type = 'text',
    this.metadata,
    this.retryCount = 0,
  });
}

/// Service to manage offline message queue
class OfflineMessageQueue {
  static final OfflineMessageQueue _instance = OfflineMessageQueue._internal();
  factory OfflineMessageQueue() => _instance;
  OfflineMessageQueue._internal();

  late Box<QueuedMessage> _queueBox;
  bool _isInitialized = false;
  bool _isProcessing = false;

  /// Initialize the queue
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // ✅ Adapter is registered in main.dart, not here
      _queueBox = await Hive.openBox<QueuedMessage>('offline_message_queue');
      _isInitialized = true;
      print(
        '✅ Offline queue initialized with ${_queueBox.length} pending messages',
      );
    } catch (e) {
      print('❌ Error initializing offline queue: $e');
    }
  }

  /// Add a message to the queue
  Future<void> enqueue({
    required String tempId,
    required String chatId,
    required String content,
    String? replyToId,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) await initialize();

    final message = QueuedMessage(
      tempId: tempId,
      chatId: chatId,
      content: content,
      replyToId: replyToId,
      queuedAt: DateTime.now(),
      type: type,
      metadata: metadata,
    );

    await _queueBox.put(tempId, message);
    print('📤 Message queued: $tempId');
  }

  /// Process all queued messages
  Future<void> processQueue({
    required Future<String?> Function(QueuedMessage) sendFunction,
  }) async {
    if (!_isInitialized) await initialize();
    if (_isProcessing) return;
    if (_queueBox.isEmpty) return;

    _isProcessing = true;
    print('🔄 Processing ${_queueBox.length} queued messages...');

    final messages = _queueBox.values.toList()
      ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));

    for (final message in messages) {
      try {
        final serverId = await sendFunction(message);

        if (serverId != null) {
          // Success - remove from queue
          await _queueBox.delete(message.tempId);
          print('✅ Queued message sent: ${message.tempId} → $serverId');
        } else {
          // Failed - increment retry count
          message.retryCount++;
          await message.save();

          // Remove after 3 failed attempts
          if (message.retryCount >= 3) {
            await _queueBox.delete(message.tempId);
            print(
              '❌ Message removed after 3 failed attempts: ${message.tempId}',
            );
          }
        }
      } catch (e) {
        print('❌ Error sending queued message ${message.tempId}: $e');
        message.retryCount++;
        await message.save();
      }
    }

    _isProcessing = false;
    print('✅ Queue processing complete');
  }

  /// Get pending message count
  int get pendingCount => _queueBox.length;

  /// Clear all queued messages
  Future<void> clear() async {
    if (!_isInitialized) return;
    await _queueBox.clear();
  }

  /// Check if a message is queued
  bool isQueued(String tempId) {
    return _queueBox.containsKey(tempId);
  }

  /// Remove a specific message from queue
  Future<void> remove(String tempId) async {
    await _queueBox.delete(tempId);
  }
}
