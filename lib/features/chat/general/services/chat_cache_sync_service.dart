import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_list_item_hive.dart';
import 'package:qik_talk/features/chat/general/data/chat_message_hive.dart';
import 'package:qik_talk/features/chat/general/model/chat_history_model.dart';

class ChatCacheSyncService {
  ChatCacheSyncService._();

  static Box<List> get _messageBox => Hive.box<List>('chat_messages');
  static Box<ChatListItemHive> get _chatListBox =>
      Hive.box<ChatListItemHive>('chats');

  static bool hasLocalCache(String chatId) => _messageBox.containsKey(chatId);

  static Map<String, int> computeUnreadCountsSync({Iterable<String>? chatIds}) {
    final ids =
        chatIds?.toSet() ?? _messageBox.keys.map((e) => e.toString()).toSet();
    final counts = <String, int>{};

    for (final chatId in ids) {
      if (!_messageBox.containsKey(chatId)) continue;
      final messages = _loadMessages(chatId);
      counts[chatId] = messages.where((m) => !m.isMe && !m.isRead).length;
    }

    return counts;
  }

  static Future<void> upsertSocketMessage({
    required Map<String, dynamic> rawData,
    required String myUserId,
  }) async {
    final hasId = rawData['_id'] != null;
    final hasContent = rawData['content'] != null;
    if (!hasId || !hasContent) return;

    // Use a mutable variable so we can apply the isRead guard below.
    ChatMessage incoming;
    try {
      incoming = ChatMessage.fromJson(rawData, myUserId);
    } catch (_) {
      return;
    }

    // ✅ FIX: A message from someone else must always be stored as unread in
    // local Hive, regardless of what the server's readBy array says.
    // The backend may include the recipient in readBy before they open the
    // chat (e.g. for push-notification delivery tracking), which would
    // silently kill the unread badge. We only flip isRead → true when the
    // user actually opens the chat (via markIncomingMessagesRead).
    if (!incoming.isMe) {
      incoming = incoming.copyWith(isRead: false);
    }

    final chatId = _extractChatId(rawData, fallback: incoming.chatId);
    if (chatId.isEmpty) return;

    final existing = _loadMessages(chatId);
    final merged = _upsertMessage(
      existing: existing,
      incoming: incoming,
      tempId: rawData['tempId']?.toString(),
    );

    final senderId = _extractSenderId(rawData, myUserId: myUserId);

    await _messageBox.put(chatId, merged.map((e) => e.toHive()).toList());
    await _updateChatListPreviewFromMessage(
      chatId,
      incoming,
      senderId: senderId,
    );
  }

  static Future<void> upsertLocalMessage({
    required ChatMessage message,
    required String senderId,
    String? tempId,
  }) async {
    final chatId = message.chatId;
    if (chatId.isEmpty) return;

    final existing = _loadMessages(chatId);
    final merged = _upsertMessage(
      existing: existing,
      incoming: message,
      tempId: tempId,
    );

    await _messageBox.put(chatId, merged.map((e) => e.toHive()).toList());
    await _updateChatListPreviewFromMessage(
      chatId,
      message,
      senderId: senderId,
    );
  }

  static Future<void> markIncomingMessagesRead(String chatId) async {
    final messages = _loadMessages(chatId);
    if (messages.isEmpty) return;

    var changed = false;
    final updated = messages.map((msg) {
      if (msg.isMe || msg.isRead) return msg;
      changed = true;
      return msg.copyWith(isRead: true, status: MessageStatus.read);
    }).toList();

    if (changed) {
      await _messageBox.put(chatId, updated.map((e) => e.toHive()).toList());
    }

    final latest = updated.isNotEmpty ? updated.last : null;
    if (latest != null && !latest.isMe) {
      await _updateIncomingLastMessageReadFlag(chatId, latest.id);
    }
  }

  static Future<void> updateOutgoingMessageStatus(
    String chatId,
    MessageStatus status, {
    List<String>? messageIds,
  }) async {
    final messages = _loadMessages(chatId);
    if (messages.isEmpty) {
      await _updateChatListReadFlag(
        chatId,
        status: status,
        messageIds: messageIds,
      );
      return;
    }

    var changed = false;
    final updated = messages.map((msg) {
      if (!msg.isMe) return msg;
      final matches = messageIds == null || messageIds.contains(msg.id);
      if (!matches) return msg;

      final next = _applyStatus(msg, status);
      if (next.status != msg.status || next.isRead != msg.isRead) {
        changed = true;
      }
      return next;
    }).toList();

    if (changed) {
      await _messageBox.put(chatId, updated.map((e) => e.toHive()).toList());
    }

    await _updateChatListReadFlag(
      chatId,
      status: status,
      messageIds: messageIds,
    );
  }

  /// WhatsApp-style unread: local Hive is the source of truth until the user
  /// opens a chat and read receipts succeed via [markIncomingMessagesRead].
  /// Server counts are bootstrap hints only — never clear local unread here.
  static Future<void> reconcileUnreadCountsWithServer(
    Map<String, int> serverUnreadCounts, {
    Iterable<String>? chatIds,
  }) async {
    // Intentionally no-op. Previously this called markIncomingMessagesRead when
    // the server reported 0 unread, which cleared badges on socket events, list
    // refreshes, and app reopen even though the user had not opened the chat.
  }

  static String _extractChatId(
    Map<String, dynamic> rawData, {
    String fallback = '',
  }) {
    final dynamic chat = rawData['chat'];
    if (chat is Map) {
      final id = (chat['_id'] ?? chat['id'] ?? '').toString();
      if (id.isNotEmpty) return id;
    }

    final id = (rawData['chatId'] ?? chat ?? fallback).toString();
    return id == 'null' ? '' : id;
  }

  static String _extractSenderId(
    Map<String, dynamic> rawData, {
    required String myUserId,
  }) {
    final sender = rawData['sender'];
    if (sender is Map) {
      final id = (sender['_id'] ?? sender['id'] ?? '').toString();
      if (id.isNotEmpty) return id;
    }
    final id = sender?.toString() ?? '';
    return id.isNotEmpty ? id : myUserId;
  }

  static List<ChatMessage> _loadMessages(String chatId) {
    final cached = _messageBox.get(chatId);
    if (cached is! List) return <ChatMessage>[];

    return cached.whereType<ChatMessageHive>().map((e) => e.toChat()).toList()
      ..sort(
        (a, b) => _parseTimestamp(
          a.timestamp,
        ).compareTo(_parseTimestamp(b.timestamp)),
      );
  }

  static List<ChatMessage> _upsertMessage({
    required List<ChatMessage> existing,
    required ChatMessage incoming,
    String? tempId,
  }) {
    final result = List<ChatMessage>.from(existing);

    var index = result.indexWhere((m) => m.id == incoming.id);
    if (index == -1 && tempId != null && tempId.isNotEmpty) {
      index = result.indexWhere((m) => m.id == tempId);
    }
    if (index == -1 && incoming.isMe) {
      index = result.indexWhere(
        (m) => _looksLikeSamePendingMessage(m, incoming),
      );
    }

    if (index == -1) {
      result.add(incoming);
    } else {
      result[index] = _mergeMessage(result[index], incoming);
    }

    result.sort(
      (a, b) =>
          _parseTimestamp(a.timestamp).compareTo(_parseTimestamp(b.timestamp)),
    );

    final deduped = <ChatMessage>[];
    for (final msg in result) {
      final existingIndex = deduped.indexWhere((m) => m.id == msg.id);
      if (existingIndex != -1) {
        deduped[existingIndex] = _mergeMessage(deduped[existingIndex], msg);
        continue;
      }
      deduped.add(msg);
    }
    return deduped;
  }

  static bool _looksLikeSamePendingMessage(
    ChatMessage pending,
    ChatMessage incoming,
  ) {
    if (!pending.isMe || pending.status != MessageStatus.sending) return false;
    if (pending.text.trim() != incoming.text.trim()) return false;
    return (pending.isImage && incoming.isImage) ||
        (pending.isVideo && incoming.isVideo) ||
        (pending.isDocument && incoming.isDocument) ||
        (pending.isVoiceNote && incoming.isVoiceNote) ||
        (pending.isAudioFile && incoming.isAudioFile) ||
        (!pending.isImage &&
            !pending.isVideo &&
            !pending.isDocument &&
            !pending.isVoiceNote &&
            !pending.isAudioFile);
  }

  static ChatMessage _mergeMessage(ChatMessage existing, ChatMessage incoming) {
    final preserveExistingStatus =
        existing.status == MessageStatus.read ||
        (existing.status == MessageStatus.delivered &&
            incoming.status != MessageStatus.read);

    return incoming.copyWith(
      imageUrls: _preferLocalImageUrls(existing, incoming),
      isImage: existing.isImage || incoming.isImage,
      documentUrl: _preferLocalPath(
        existing.documentUrl,
        incoming.documentUrl,
        existing.isMe,
      ),
      documentName: incoming.documentName?.isNotEmpty == true
          ? incoming.documentName
          : existing.documentName,
      isDocument: existing.isDocument || incoming.isDocument,
      videoUrl: _preferLocalPath(
        existing.videoUrl,
        incoming.videoUrl,
        existing.isMe,
      ),
      videoThumbnail: existing.videoThumbnail ?? incoming.videoThumbnail,
      isVideo: existing.isVideo || incoming.isVideo,
      audioUrl: _preferLocalPath(
        existing.audioUrl,
        incoming.audioUrl,
        existing.isMe,
      ),
      audioName: incoming.audioName ?? existing.audioName,
      isVoiceNote: existing.isVoiceNote || incoming.isVoiceNote,
      isAudioFile: existing.isAudioFile || incoming.isAudioFile,
      replyToMessageId: incoming.replyToMessageId ?? existing.replyToMessageId,
      replyToText: incoming.replyToText ?? existing.replyToText,
      replyToIsMe: incoming.replyToIsMe ?? existing.replyToIsMe,
      replyToSenderName:
          incoming.replyToSenderName ?? existing.replyToSenderName,
      replyToMediaType: incoming.replyToMediaType ?? existing.replyToMediaType,
      replyToThumbnailUrl:
          incoming.replyToThumbnailUrl ?? existing.replyToThumbnailUrl,
      status: preserveExistingStatus ? existing.status : incoming.status,
      // Incoming messages only become read via markIncomingMessagesRead.
      isRead: incoming.isMe
          ? (existing.isRead || incoming.isRead)
          : (existing.isRead && incoming.isRead),
    );
  }

  static List<String>? _preferLocalImageUrls(
    ChatMessage existing,
    ChatMessage incoming,
  ) {
    final existingUrls = existing.imageUrls ?? const <String>[];
    final incomingUrls = incoming.imageUrls ?? const <String>[];
    if (existing.isMe && existingUrls.any(_isLocalPath)) return existingUrls;
    if (incomingUrls.isNotEmpty) return incomingUrls;
    return existingUrls.isNotEmpty ? existingUrls : null;
  }

  static String? _preferLocalPath(
    String? existing,
    String? incoming,
    bool preferExisting,
  ) {
    if (preferExisting && _isLocalPath(existing)) return existing;
    if (incoming != null && incoming.isNotEmpty) return incoming;
    return existing;
  }

  static bool _isLocalPath(String? value) {
    if (value == null || value.isEmpty) return false;
    return !value.startsWith('http');
  }

  static ChatMessage _applyStatus(ChatMessage msg, MessageStatus status) {
    if (msg.status == MessageStatus.read) return msg;
    if (msg.status == MessageStatus.delivered && status == MessageStatus.sent) {
      return msg;
    }
    if (msg.status == MessageStatus.delivered &&
        status == MessageStatus.delivered) {
      return msg;
    }

    return msg.copyWith(
      isRead: msg.isRead || status == MessageStatus.read,
      status:
          status == MessageStatus.sent && msg.status == MessageStatus.delivered
          ? msg.status
          : status,
    );
  }

  static Future<void> _updateChatListPreviewFromMessage(
    String chatId,
    ChatMessage message, {
    required String senderId,
  }) async {
    final chatItem = _chatListBox.get(chatId);
    if (chatItem == null) return;
    // ✅ Touch updatedAt so AnimatedBuilder on chatBox.listenable() fires
    // in ChatComponent and GroupComponent, triggering an immediate badge refresh.

    final createdAt = _parseTimestamp(message.timestamp);
    // ✅ FIX: For incoming messages (not sent by me), always write isRead:false
    // in the chat list preview so the hasUnread check in the list tile works
    // correctly until the user opens the chat and calls markIncomingMessagesRead.
    final previewJson = jsonEncode({
      '_id': message.id,
      'content': message.text,
      'senderId': senderId,
      'isRead': message.isMe ? message.isRead : false,
      'status': message.status.name,
      'isImage': message.isImage,
      'isVoiceNote': message.isVoiceNote,
      'isAudio': message.isAudioFile,
      'isVideo': message.isVideo,
      'isDocument': message.isDocument,
      'isContact': false,
      'createdAt': createdAt.toIso8601String(),
    });

    await _chatListBox.put(
      chatId,
      chatItem.copyWith(lastMessageJson: previewJson, updatedAt: createdAt),
    );
  }

  static Future<void> _updateIncomingLastMessageReadFlag(
    String chatId,
    String latestMessageId,
  ) async {
    final chatItem = _chatListBox.get(chatId);
    if (chatItem == null || chatItem.lastMessageJson.isEmpty) return;

    try {
      final decoded =
          jsonDecode(chatItem.lastMessageJson) as Map<String, dynamic>;
      final lastMessageId = (decoded['_id'] ?? decoded['id'] ?? '').toString();
      if (lastMessageId != latestMessageId) return;
      decoded['isRead'] = true;
      await _chatListBox.put(
        chatId,
        chatItem.copyWith(lastMessageJson: jsonEncode(decoded)),
      );
    } catch (_) {}
  }

  static Future<void> _updateChatListReadFlag(
    String chatId, {
    required MessageStatus? status,
    List<String>? messageIds,
  }) async {
    final chatItem = _chatListBox.get(chatId);
    if (chatItem == null || chatItem.lastMessageJson.isEmpty) return;

    try {
      final decoded =
          jsonDecode(chatItem.lastMessageJson) as Map<String, dynamic>;
      final lastMessageId = (decoded['_id'] ?? decoded['id'] ?? '').toString();
      final senderId = decoded['senderId']?.toString() ?? '';
      final matches = messageIds == null || messageIds.contains(lastMessageId);
      if (!matches) return;

      if (status != null && senderId.isNotEmpty) {
        final currentStatus = decoded['status']?.toString();
        if (currentStatus == 'read') return;
        if (status == MessageStatus.delivered && currentStatus == 'read') {
          return;
        }
        decoded['status'] = status.name;
        if (status == MessageStatus.read) {
          decoded['isRead'] = true;
        }
      }

      await _chatListBox.put(
        chatId,
        chatItem.copyWith(lastMessageJson: jsonEncode(decoded)),
      );
    } catch (_) {}
  }

  static DateTime _parseTimestamp(String value) {
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }
}
