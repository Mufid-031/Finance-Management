import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_management/features/wallet/application/wallet_service.dart';
import 'package:finance_management/features/wallet/data/datasource/wallet_firestore_datasource.dart';
import 'package:finance_management/features/wallet/data/repository/wallet_repository.dart';
import 'package:finance_management/features/wallet/data/repository/wallet_repository_impl.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_notifier.dart';
import 'package:finance_management/features/wallet/presentation/providers/wallet_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Dependency Injection
final walletDataSourceProvider = Provider((ref) => WalletFirestoreDatasource());
final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepositoryImpl(ref.watch(walletDataSourceProvider)),
);
final walletServiceProvider = Provider(
  (ref) => WalletService(ref.watch(walletRepositoryProvider)),
);

// Provider untuk Aksi (UI Logic)
final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
      return WalletNotifier(ref.watch(walletServiceProvider), ref);
    });

// Provider untuk Data (Real-time Display)
final walletsStreamProvider = StreamProvider<List<Wallet>>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  final user = authStateAsync.value;

  if (user == null) return Stream.value([]);
  
  return ref.watch(walletServiceProvider).getWalletsStream(user.uid);
});

// Total Balance Auto-Calculate
final totalBalanceProvider = Provider<double>((ref) {
  final wallets = ref.watch(walletsStreamProvider).value ?? [];
  return wallets.fold(
    0.0,
    (previousValue, element) => previousValue + element.balance,
  );
});
