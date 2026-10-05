class ExternalBankTransferResponseModel {
  final String reference;
  final String amount;
  final String status;
  final String description;

  ExternalBankTransferResponseModel({
    required this.reference,
    required this.amount,
    required this.status,
    required this.description,
  });

  factory ExternalBankTransferResponseModel.fromMap(Map<String, dynamic> map) {
    return ExternalBankTransferResponseModel(
      reference: map['reference'] ?? '',
      amount: map['amount'] ?? '',
      status: map['status'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'amount': amount,
      'status': status,
      'description': description,
    };
  }
}
