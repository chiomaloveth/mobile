class LocalAccountNumberResponseModel {
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;

  LocalAccountNumberResponseModel({
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
  });

  factory LocalAccountNumberResponseModel.fromMap(Map<String, dynamic> map) {
    return LocalAccountNumberResponseModel(
      bankName: map['bankName'] ?? '',
      bankCode: map['bankCode'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountName: map['accountName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'bankCode': bankCode,
      'accountNumber': accountNumber,
      'accountName': accountName,
    };
  }
}
