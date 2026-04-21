class Wallet {
  final String id;
  final String name;
  final double balance;
  final int iconCode;
  final String currency;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.currency,
  });

  // Tambahkan copyWith untuk kemudahan update state
  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    int? iconCode,
    String? currency,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
      currency: currency ?? this.currency,
    );
  }
}
