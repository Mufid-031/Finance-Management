class Wallet {
  final String id;
  final String name;
  final double balance;
  final int iconCode;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
  });

  // Tambahkan copyWith untuk kemudahan update state
  Wallet copyWith({String? id, String? name, double? balance, int? iconCode}) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
    );
  }
}
