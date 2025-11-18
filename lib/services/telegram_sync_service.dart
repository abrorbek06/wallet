import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/storage.dart';
import 'package:http/http.dart' as http;
// HTTP package already imported above

/// Simple helper to fetch transactions from the local Telegram bot HTTP API
/// and merge them into the app's stored transactions.
class TelegramSyncService {
  final String? baseUrl;

  TelegramSyncService({this.baseUrl = 'http://127.0.0.1:5001'});

  /// Fetch transactions from the bot and merge them into local storage.
  /// Returns number of new transactions added.
  Future<int> fetchAndMergeTransactions() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/transactions'));
      if (res.statusCode != 200) {
        debugPrint(
          'TelegramSync: failed to fetch transactions ${res.statusCode}',
        );
        return 0;
      }

      final List<dynamic> remote = jsonDecode(res.body);
      // Convert remote JSON to Transaction objects
      final List<Transaction> remoteTxs =
          remote.map((r) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(r);
            // Convert simple type string from 'income'/'expense' to the enum style
            if (map['type'] == 'income') {
              map['type'] = 'TransactionType.income';
            } else if (map['type'] == 'expense') {
              map['type'] = 'TransactionType.expense';
            }
            // Normalize currency field
            if (map['inputCurrency'] != null) {
              map['inputCurrency'] =
                  (map['inputCurrency'] as String).toUpperCase();
            }
            return Transaction.fromJson(map);
          }).toList();

      // Load local transactions
      final List<Transaction> local = await loadTransactions();

      // Create map of existing ids for quick check
      final existingIds = local.map((t) => t.id).toSet();

      // Filter remote to ones we don't have
      final newTxs =
          remoteTxs.where((t) => !existingIds.contains(t.id)).toList();
      if (newTxs.isEmpty) return 0;

      // Merge and save
      final merged = [...local, ...newTxs];
      await saveTransactions(merged);

      return newTxs.length;
    } catch (e) {
      debugPrint('TelegramSync: error while syncing: $e');
      return 0;
    }
  }

  /// Push a single transaction to the bot's /transactions endpoint.
  /// Returns true if the bot accepted the POST (status code 201).
  Future<bool> pushTransaction(Transaction tx) async {
    try {
      // Use provided baseUrl or fallback to persisted bot url
      final botUrl =
          baseUrl != null && baseUrl!.isNotEmpty
              ? baseUrl!
              : (await loadTelegramBotUrl()) ?? 'http://127.0.0.1:5001';
      final uri = Uri.parse('$botUrl/transactions');
      // Build payload matching the bot's expected type strings
      final payload = Map<String, dynamic>.from(tx.toJson());
      payload['type'] =
          tx.type == TransactionType.income ? 'income' : 'expense';
      payload['inputCurrency'] = tx.inputCurrency.toUpperCase();
      payload['date'] = tx.date.toIso8601String();
      final body = jsonEncode(payload);
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint('TelegramSync: failed to push transaction $e');
      return false;
    }
  }
}
