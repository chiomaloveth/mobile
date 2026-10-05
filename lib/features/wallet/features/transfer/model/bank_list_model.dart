class BankListModel {
  final String name;
  final String slug;
  final String code;
  final String country;
  final String nibss_bank_code;

  BankListModel({
    required this.name,
    required this.slug,
    required this.code,
    required this.country,
    required this.nibss_bank_code,
  });

  factory BankListModel.fromMap(Map<String, dynamic> map) {
    return BankListModel(
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      code: map['code'] ?? '',
      country: map['country'] ?? '',
      nibss_bank_code: map['nibss_bank_code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'slug': slug,
      'code': code,
      'country': country,
      'nibss_bank_code': nibss_bank_code
    };
  }
}
