import '../../domain/wallet.dart';

class WalletDTO {
  final String? id;
  final String name;
  final double balance;
  final String icon;

  WalletDTO({
    this.id,
    required this.name,
    required this.balance,
    required this.icon,
  });

  factory WalletDTO.fromMap(String id, Map<String, dynamic> json) {
    return WalletDTO(
      id: id,
      name: json['name'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'balance': balance, 'icon': icon};
  }

  Wallet toDomain() {
    return Wallet(id: id ?? '', name: name, balance: balance, icon: icon);
  }

  factory WalletDTO.fromDomain(Wallet domain) {
    return WalletDTO(
      id: domain.id,
      name: domain.name,
      balance: domain.balance,
      icon: domain.icon,
    );
  }
}
