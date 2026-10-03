class FundWalletGeneratedResponseModel {
  final String transactionId;
  final String reference;
  final String checkoutUrl;

  FundWalletGeneratedResponseModel({
    required this.transactionId,
    required this.reference,
    required this.checkoutUrl,
  });

  factory FundWalletGeneratedResponseModel.fromMap(Map<String, dynamic> map) {
    return FundWalletGeneratedResponseModel(
      transactionId: map['transactionId'] ?? '',
      reference: map['reference'] ?? '',
      checkoutUrl: map['checkoutUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'reference': reference,
      'checkoutUrl': checkoutUrl,
    };
  }
}
