import 'package:finance_management/features/transaction/domain/transaction.dart';

abstract class TransactionRepository {
  // Mengambil aliran transaksi terbaru
  Stream<List<Transaction>> watchTransactions(String userId);

  // Menambah transaksi sekaligus mengupdate saldo wallet (Atomic)
  Future<void> addTransaction(Transaction transaction);
}
