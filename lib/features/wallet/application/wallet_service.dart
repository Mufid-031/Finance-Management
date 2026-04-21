import 'package:finance_management/features/wallet/data/repository/wallet_repository.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:flutter/material.dart';

class WalletService {
  final WalletRepository repository;

  WalletService(this.repository);

  /// Mengambil aliran data dompet milik user secara real-time
  Stream<List<Wallet>> getWalletsStream(String userId) {
    return repository.watchWallets(userId);
  }

  /// Menambah dompet baru ke database
  Future<void> addWallet(String userId, Wallet wallet) async {
    return await repository.addWallet(userId, wallet);
  }

  /// Membuat dompet otomatis saat user pertama kali mendaftar (Onboarding)
  Future<void> createInitialWallet(String userId, {String currency = 'USD'}) async {
    final initial = Wallet(
      id: '', // Akan digenerate oleh Firestore
      name: 'Main Wallet',
      balance: 0.0,
      iconCode: Icons.account_balance_wallet.codePoint, // Simpan sebagai int
      currency: currency,
    );
    await repository.addWallet(userId, initial);
  }

  /// Memperbarui informasi dompet (Nama, Saldo, atau Ikon)
  Future<void> updateWallet(String userId, Wallet wallet) async {
    return await repository.updateWallet(userId, wallet);
  }

  /// Menghapus dompet berdasarkan ID
  Future<void> deleteWallet(String userId, String walletId) async {
    return await repository.deleteWallet(userId, walletId);
  }
}
