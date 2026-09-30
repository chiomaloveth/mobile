class FriendRequest {
  final String id; // message _id
  final String chatId; // chat._id
  final String userId; // sender._id
  final String username;
  final String profilePicture;
  final String messagePreview;
  final DateTime sentAt;

  FriendRequest({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.username,
    required this.profilePicture,
    required this.messagePreview,
    required this.sentAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    // New backend shape: chat object with otherUser + latestMessage + meta
    final otherUser = json['otherUser'] as Map<String, dynamic>? ?? {};
    final latestMessage = json['latestMessage'] as Map<String, dynamic>? ?? {};
    final sender = latestMessage['sender'] as Map<String, dynamic>? ?? {};

    final preview = latestMessage['content']?.toString().trim();

    return FriendRequest(
      // _id is now the CHAT id
      id: json['_id']?.toString() ?? '',
      chatId: json['_id']?.toString() ?? '',
      // The person who sent the request
      userId: otherUser['_id']?.toString() ?? '',
      username: otherUser['username']?.toString() ?? 'Unknown',
      profilePicture: otherUser['profilePicture']?.toString() ?? '',
      messagePreview: (preview != null && preview.isNotEmpty)
          ? preview
          : 'Wants to connect with you',
      sentAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
