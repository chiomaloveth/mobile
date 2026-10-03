class ExternalWalletModel {
  final String accountNumber;
  final String bankName;
  final String accountName;

  ExternalWalletModel({
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
  });

  factory ExternalWalletModel.fromMap(Map<String, dynamic> map) {
    return ExternalWalletModel(
      accountNumber: map['accountNumber'] ?? '',
      bankName: map['bankName'] ?? '',
      accountName: map['accountName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountNumber': accountNumber,
      'bankName': bankName,
      'accountName': accountName,
    };
  }
}

class InternalWalletModel {
  final String qiktalkTag;
  final String accountName;

  InternalWalletModel({required this.qiktalkTag, required this.accountName});

  factory InternalWalletModel.fromMap(Map<String, dynamic> map) {
    return InternalWalletModel(
      qiktalkTag: map['qiktalkTag'] ?? '',
      accountName: map['accountName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'qiktalkTag': qiktalkTag, 'accountName': accountName};
  }
}

class WalletDetailsModel {
  final ExternalWalletModel externalAccount;
  final InternalWalletModel internalAccount;

  WalletDetailsModel({
    required this.externalAccount,
    required this.internalAccount,
  });

  factory WalletDetailsModel.fromMap(Map<String, dynamic> map) {
    ExternalWalletModel externalAccount;
    if (map['externalAccount'] != null && map['externalAccount'] is Map) {
      try {
        externalAccount = ExternalWalletModel.fromMap(map['externalAccount']);
      } catch (e) {
        externalAccount = ExternalWalletModel.fromMap({});
      }
    } else {
      externalAccount = ExternalWalletModel.fromMap({});
    }

    InternalWalletModel internalAccount;
    if (map['internalAccount'] != null && map['internalAccount'] is Map) {
      try {
        internalAccount = InternalWalletModel.fromMap(map['internalAccount']);
      } catch (e) {
        internalAccount = InternalWalletModel.fromMap({});
      }
    } else {
      internalAccount = InternalWalletModel.fromMap({});
    }

    return WalletDetailsModel(
      externalAccount: externalAccount,
      internalAccount: internalAccount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'externalAccount': externalAccount.toMap(),
      'internalAccount': internalAccount.toMap(),
    };
  }
}
