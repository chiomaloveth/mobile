class GeneratedWalletResponseModel {
  final String user;
  final String tempBVN;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String securePin;
  final String dob;
  final String identityVerificationStatus;
  final dynamic balance;
  final String currency;
  final String status;
  final List<dynamic> withdrawalRequests;
  final String walletMood;

  GeneratedWalletResponseModel({
    required this.user,
    required this.tempBVN,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.securePin,
    required this.dob,
    required this.identityVerificationStatus,
    required this.balance,
    required this.currency,
    required this.status,
    required this.withdrawalRequests,
    required this.walletMood,
  });

  factory GeneratedWalletResponseModel.fromMap(Map<String, dynamic> map) {
    return GeneratedWalletResponseModel(
      user: map['user'] ?? '',
      tempBVN: map['tempBVN'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      securePin: map['securePin'] ?? '',
      dob: map['dob'] ?? '',
      identityVerificationStatus: map['identityVerificationStatus'] ?? '',
      balance: map['balance'] ?? 0,
      currency: map['currency'] ?? '',
      status: map['status'] ?? '',
      withdrawalRequests: map['withdrawalRequests'] ?? [],
      walletMood: map['walletMood'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "user": user,
      "tempBVN": tempBVN,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "securePin": securePin,
      "dob": dob,
      "identityVerificationStatus": identityVerificationStatus,
      "balance": balance,
      "currency": currency,
      "status": status,
      "withdrawalRequests": withdrawalRequests,
      "walletMood": walletMood,
    };
  }
}
