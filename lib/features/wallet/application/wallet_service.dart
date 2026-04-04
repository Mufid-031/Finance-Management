import 'package:finance_management/features/wallet/data/repository/wallet_repository.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';

class WalletService {
  final WalletRepository repository;
  WalletService(this.repository);

  Stream<List<Wallet>> getWalletsStream(String userId) {
    return repository.watchWallets(userId);
  }

  Future<void> addWallet(String userId, Wallet wallet) async {
    return await repository.addWallet(userId, wallet);
  }

  Future<void> createInitialWallet(String userId) async {
    final initial = Wallet(
      id: '',
      name: 'Main Wallet',
      balance: 0.0,
      icon: 'account_balance_wallet',
    );
    await repository.addWallet(userId, initial);
  }

  Future<void> updateWallet(String userId, Wallet wallet) async {
    return await repository.updateWallet(userId, wallet);
  }

  Future<void> deleteWallet(String userId, String walletId) async {
    return await repository.deleteWallet(userId, walletId);
  }
}
