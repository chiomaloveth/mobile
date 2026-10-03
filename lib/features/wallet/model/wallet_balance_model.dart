class WalletBalanceModel {
  final double balance;
  final String formatted;

  WalletBalanceModel({
    required this.balance,
    required this.formatted,
  });

  factory WalletBalanceModel.fromMap(Map<String, dynamic> map) {
    return WalletBalanceModel(
      balance: (map['balance'] ?? 0).toDouble(),
      formatted: map['formatted'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': balance,
      'formatted': formatted,
    };
  }
}