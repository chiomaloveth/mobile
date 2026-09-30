// lib/features/chat/single_chat/models/transaction_model.dart

class TransactionRecord {
  final String id;
  final String chatId;
  final String senderName;
  final String receiverName;
  final String receiverAccountNumber;
  final String receiverBank;
  final double amount;
  final DateTime timestamp;
  final bool isMe; // true = I sent, false = I received

  TransactionRecord({
    required this.id,
    required this.chatId,
    required this.senderName,
    required this.receiverName,
    required this.receiverAccountNumber,
    required this.receiverBank,
    required this.amount,
    required this.timestamp,
    required this.isMe,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderName': senderName,
    'receiverName': receiverName,
    'receiverAccountNumber': receiverAccountNumber,
    'receiverBank': receiverBank,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'isMe': isMe,
  };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        id: json['id'],
        chatId: json['chatId'],
        senderName: json['senderName'],
        receiverName: json['receiverName'],
        receiverAccountNumber: json['receiverAccountNumber'],
        receiverBank: json['receiverBank'],
        amount: (json['amount'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
        isMe: json['isMe'],
      );
}
