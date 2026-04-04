import 'package:finance_management/features/wallet/data/datasource/wallet_firestore_datasource.dart';
import 'package:finance_management/features/wallet/data/dto/wallet_dto.dart';
import 'package:finance_management/features/wallet/data/repository/wallet_repository.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletFirestoreDatasource datasource;
  WalletRepositoryImpl(this.datasource);

  @override
  Stream<List<Wallet>> watchWallets(String userId) {
    return datasource
        .watchAll(userId)
        .map(
          (list) => list
              .map((map) => WalletDTO.fromMap(map['id'], map).toDomain())
              .toList(),
        );
  }

  @override
  Future<void> addWallet(String userId, Wallet wallet) async {
    final dto = WalletDTO.fromDomain(wallet);
    await datasource.create(userId, dto.toMap());
  }

  @override
  Future<void> updateWallet(String userId, Wallet wallet) async {
    final dto = WalletDTO.fromDomain(wallet);
    await datasource.update(userId, wallet.id, dto.toMap());
  }

  @override
  Future<void> deleteWallet(String userId, String walletId) async {
    await datasource.delete(userId, walletId);
  }
}
