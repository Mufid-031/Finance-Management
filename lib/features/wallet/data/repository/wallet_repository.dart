import 'package:finance_management/features/wallet/domain/wallet.dart';

abstract class WalletRepository {
  Stream<List<Wallet>> watchWallets(String userId);
  Future<void> addWallet(String userId, Wallet dto);
  Future<void> updateWallet(String userId, Wallet dto);
  Future<void> deleteWallet(String userId, String walletId);
}
