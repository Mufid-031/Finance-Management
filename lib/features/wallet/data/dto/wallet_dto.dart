import 'package:flutter/material.dart';

import '../../domain/wallet.dart';

class WalletDTO {
  final String? id;
  final String name;
  final double balance;
  final int iconCode;
  final String currency;

  WalletDTO({
    this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.currency,
  });

  factory WalletDTO.fromMap(String id, Map<String, dynamic> map) {
    return WalletDTO(
      id: id,
      name: map['name'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      // GUNAKAN DEFAULT VALUE JIKA NULL
      iconCode: map['iconCode'] ?? Icons.account_balance_wallet.codePoint,
      currency: map['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'balance': balance,
      'iconCode': iconCode,
      'currency': currency,
    };
  }

  Wallet toDomain() {
    return Wallet(
      id: id ?? '',
      name: name,
      balance: balance,
      iconCode: iconCode,
      currency: currency,
    );
  }

  factory WalletDTO.fromDomain(Wallet domain) {
    return WalletDTO(
      id: domain.id,
      name: domain.name,
      balance: domain.balance,
      iconCode: domain.iconCode,
      currency: domain.currency,
    );
  }
}
