class TransactionHistoryModel {
  final String id;
  final String buyer;
  final String merchant;
  final String product;
  final String amount;
  final String currency;
  final String status;
  final String type;
  final String paymentMethod;
  final String reference;
  final String createdAt;
  final Map<String, dynamic> metadata;

  TransactionHistoryModel({
    required this.id,
    required this.buyer,
    required this.merchant,
    required this.product,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    required this.paymentMethod,
    required this.reference,
    required this.createdAt,
    required this.metadata,
  });

  factory TransactionHistoryModel.fromMap(Map<String, dynamic> map) {
    return TransactionHistoryModel(
      id: map['id'] ?? map['_id'] ?? '',
      buyer: map['buyer'] ?? '',
      merchant: map['merchant'] ?? '',
      product: map['product'] ?? '',
      amount: map['amount']?.toString() ?? '0',
      currency: map['currency'] ?? 'NGN',
      status: map['status'] ?? '',
      type: map['type'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'wallet',
      reference: map['reference'] ?? '',
      createdAt: map['createdAt'] ?? '',
      metadata: map['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer': buyer,
      'merchant': merchant,
      'product': product,
      'amount': amount,
      'currency': currency,
      'status': status,
      'type': type,
      'paymentMethod': paymentMethod,
      'reference': reference,
      'createdAt': createdAt,
      'metadata': metadata,
    };
  }
}