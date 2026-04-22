import 'dart:io';
import 'package:csv/csv.dart';
import 'package:finance_management/features/transaction/domain/transaction.dart';
import 'package:finance_management/features/wallet/domain/wallet.dart';
import 'package:finance_management/features/category/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportService {
  Future<void> exportTransactionsToCsv({
    required List<Transaction> transactions,
    required List<Wallet> wallets,
    required List<Category> categories,
    String filename = "boss_finance_report",
  }) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "Date",
      "Title",
      "Type",
      "Amount",
      "Wallet",
      "To Wallet (Transfer)",
      "Category",
    ]);

    for (var tx in transactions) {
      final walletName = wallets
          .firstWhere(
            (w) => w.id == tx.walletId,
            orElse: () => Wallet(
              id: '',
              name: 'Unknown',
              balance: 0,
              iconCode: 0,
              currency: '',
            ),
          )
          .name;

      final toWalletName = tx.toWalletId != null
          ? wallets
                .firstWhere(
                  (w) => w.id == tx.toWalletId,
                  orElse: () => Wallet(
                    id: '',
                    name: 'Unknown',
                    balance: 0,
                    iconCode: 0,
                    currency: '',
                  ),
                )
                .name
          : "";

      final categoryName = categories
          .firstWhere(
            (c) => c.id == tx.categoryId,
            orElse: () => Category(
              id: '',
              name: 'General',
              icon: Icons.category,
              type: CategoryType.expense,
            ),
          )
          .name;

      rows.add([
        tx.date.toIso8601String(),
        tx.title,
        tx.type.name.toUpperCase(),
        tx.amount,
        walletName,
        toWalletName,
        categoryName,
      ]);
    }

    String csvData = csv.encode(rows);

    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/$filename.csv");
    await file.writeAsString(csvData);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Berikut adalah laporan finansial Anda dari Vantage Finance.");
  }
}
