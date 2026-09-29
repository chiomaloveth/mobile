import 'package:equatable/equatable.dart';

enum NotificationType {
  message,
  postLiked,
  orderReceived,
  paymentSuccess,
  airtimePurchase,
  adProcessed,
  reelTrending,
  userFollowed,
  reposted,
  productReview,
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? avatarUrl;
  final String? senderName;
  final String? relatedId; // e.g., postId, orderId

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.avatarUrl,
    this.senderName,
    this.relatedId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    timestamp,
    type,
    isRead,
    avatarUrl,
    senderName,
    relatedId,
  ];
}
