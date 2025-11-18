import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const _transactionsKey = 'transactions';
const _dailyLimitKey = 'daily_limit';
const _dailyLimitCurrencyKey =
    'daily_limit_currency'; // Currency for daily limit
const _dailyLimitWarnKey = 'daily_limit_warn_date';
const _transactionsBackupKey = 'transactions_backup';
const _transactionsBackupTimeKey = 'transactions_backup_time';
const _telegramAutoSyncKey = 'telegram_auto_sync';
const _telegramBotUrlKey = 'telegram_bot_url';

/// Central helper to get SharedPreferences instance (kept for readability and
/// to allow future migration hooks in one place).
Future<SharedPreferences> _prefs() async =>
    await SharedPreferences.getInstance();

/// Save the full transaction list (overwrites previous list).
Future<void> saveTransactions(List<Transaction> transactions) async {
  try {
    final prefs = await _prefs();
    final jsonList = transactions.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_transactionsKey, jsonList);
  } catch (e) {
    // If saving fails, at least log (in production replace with a logger)
    // ignore: avoid_print
    print('saveTransactions error: $e');
  }
}

/// Load transactions safely. Returns empty list on error or when none stored.
Future<List<Transaction>> loadTransactions() async {
  try {
    final prefs = await _prefs();
    final jsonList = prefs.getStringList(_transactionsKey);
    if (jsonList == null) return [];

    final List<Transaction> result = [];
    final List<String> malformedEntries = [];
    bool hadMalformed = false;
    for (final jsonStr in jsonList) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        final tx = Transaction.fromJson(map);

        // Normalize stored amounts: ensure amount is positive and type carries the sign
        if (tx.amount < 0) {
          result.add(
            Transaction(
              id: tx.id,
              title: tx.title,
              categoryId: tx.categoryId,
              amount: tx.amount.abs(),
              date: tx.date,
              type: tx.type,
              isScheduled: tx.isScheduled,
              scheduledDate: tx.scheduledDate,
              isLoan: tx.isLoan,
              counterparty: tx.counterparty,
              loanDirection: tx.loanDirection,
              isSettled: tx.isSettled,
              isPending: tx.isPending,
            ),
          );
        } else {
          result.add(tx);
        }
      } catch (e) {
        // Skip malformed entry but continue (don't break whole load)
        // Collect malformed entry for backup and mark flag.
        // Store as a wrapped JSON so we can keep the original raw value,
        // the parse error, and a timestamp. We still support older plain
        // raw-string backups in restore functions.
        final wrapped = jsonEncode({
          'raw': jsonStr,
          'error': e.toString(),
          'time': DateTime.now().toIso8601String(),
        });
        malformedEntries.add(wrapped);
        hadMalformed = true;
        // ignore: avoid_print
        print('Skipping malformed transaction entry: $e');
      }
    }

    // If we skipped malformed entries, persist the cleaned list back to storage
    if (hadMalformed) {
      try {
        // Save a backup of malformed entries (so user can inspect or restore if needed).
        // If previous backups exist, append to them instead of overwriting.
        final prefs = await _prefs();
        final existing = prefs.getStringList(_transactionsBackupKey) ?? [];
        final combined = List<String>.from(existing)..addAll(malformedEntries);
        await prefs.setStringList(_transactionsBackupKey, combined);
        await prefs.setString(
          _transactionsBackupTimeKey,
          DateTime.now().toIso8601String(),
        );
        await saveTransactions(result);
        // ignore: avoid_print
        print(
          'Cleaned malformed transactions from storage and appended backup.',
        );
      } catch (e) {
        // ignore: avoid_print
        print('Failed to persist cleaned transactions: $e');
      }
    }

    return result;
  } catch (e) {
    // ignore: avoid_print
    print('loadTransactions error: $e');
    return [];
  }
}

/// Append a single transaction to storage (reads current list, appends, saves).
Future<void> addTransaction(Transaction tx) async {
  final list = await loadTransactions();
  list.add(tx);
  await saveTransactions(list);
}

/// Update a transaction by id. If not found, no-op.
Future<void> updateTransaction(Transaction tx) async {
  final list = await loadTransactions();
  final idx = list.indexWhere((t) => t.id == tx.id);
  if (idx != -1) {
    list[idx] = tx;
    await saveTransactions(list);
  }
}

/// Remove a transaction by id.
Future<void> removeTransactionById(String id) async {
  final list = await loadTransactions();
  list.removeWhere((t) => t.id == id);
  await saveTransactions(list);
}

/// Clear all transactions (useful for testing or reset).
Future<void> clearAllTransactions() async {
  final prefs = await _prefs();
  await prefs.remove(_transactionsKey);
}

// ---- Daily limit helpers ----
Future<void> saveDailyLimit(double? limit, {String currency = 'USD'}) async {
  try {
    final prefs = await _prefs();
    if (limit == null) {
      await prefs.remove(_dailyLimitKey);
      await prefs.remove(_dailyLimitCurrencyKey);
    } else {
      await prefs.setDouble(_dailyLimitKey, limit);
      await prefs.setString(_dailyLimitCurrencyKey, currency);
    }
  } catch (e) {
    // ignore: avoid_print
    print('saveDailyLimit error: $e');
  }
}

Future<double?> loadDailyLimit() async {
  try {
    final prefs = await _prefs();
    if (!prefs.containsKey(_dailyLimitKey)) return null;
    return prefs.getDouble(_dailyLimitKey);
  } catch (e) {
    // ignore: avoid_print
    print('loadDailyLimit error: $e');
    return null;
  }
}

Future<String> loadDailyLimitCurrency() async {
  try {
    final prefs = await _prefs();
    return prefs.getString(_dailyLimitCurrencyKey) ?? 'USD';
  } catch (e) {
    // ignore: avoid_print
    print('loadDailyLimitCurrency error: $e');
    return 'USD';
  }
}

Future<void> saveDailyLimitWarnDate(String? isoDate) async {
  try {
    final prefs = await _prefs();
    if (isoDate == null) {
      await prefs.remove(_dailyLimitWarnKey);
    } else {
      await prefs.setString(_dailyLimitWarnKey, isoDate);
    }
  } catch (e) {
    // ignore: avoid_print
    print('saveDailyLimitWarnDate error: $e');
  }
}

// Telegram integration preferences
Future<void> saveTelegramAutoSync(bool enabled) async {
  try {
    final prefs = await _prefs();
    await prefs.setBool(_telegramAutoSyncKey, enabled);
  } catch (e) {
    print('saveTelegramAutoSync error: $e');
  }
}

Future<bool> loadTelegramAutoSync() async {
  try {
    final prefs = await _prefs();
    return prefs.getBool(_telegramAutoSyncKey) ?? false;
  } catch (e) {
    print('loadTelegramAutoSync error: $e');
    return false;
  }
}

Future<void> saveTelegramBotUrl(String url) async {
  try {
    final prefs = await _prefs();
    await prefs.setString(_telegramBotUrlKey, url);
  } catch (e) {
    print('saveTelegramBotUrl error: $e');
  }
}

Future<String?> loadTelegramBotUrl() async {
  try {
    final prefs = await _prefs();
    return prefs.getString(_telegramBotUrlKey);
  } catch (e) {
    print('loadTelegramBotUrl error: $e');
    return null;
  }
}

Future<String?> loadDailyLimitWarnDate() async {
  try {
    final prefs = await _prefs();
    if (!prefs.containsKey(_dailyLimitWarnKey)) return null;
    return prefs.getString(_dailyLimitWarnKey);
  } catch (e) {
    // ignore: avoid_print
    print('loadDailyLimitWarnDate error: $e');
    return null;
  }
}

/// Load the raw malformed transaction backups (if any).
Future<List<String>> loadTransactionsBackup() async {
  try {
    final prefs = await _prefs();
    final list = prefs.getStringList(_transactionsBackupKey);
    return list ?? [];
  } catch (e) {
    // ignore: avoid_print
    print('loadTransactionsBackup error: $e');
    return [];
  }
}

/// Clear the stored malformed transaction backups and their timestamp.
Future<void> clearTransactionsBackup() async {
  try {
    final prefs = await _prefs();
    await prefs.remove(_transactionsBackupKey);
    await prefs.remove(_transactionsBackupTimeKey);
  } catch (e) {
    // ignore: avoid_print
    print('clearTransactionsBackup error: $e');
  }
}

/// Attempt to restore a single malformed backup entry by index.
/// Returns true if restored successfully; false otherwise.
Future<bool> restoreMalformedEntry(int index) async {
  try {
    final prefs = await _prefs();
    final list = prefs.getStringList(_transactionsBackupKey) ?? [];
    if (index < 0 || index >= list.length) return false;
    final entry = list[index];
    // Support two formats:
    // 1) Legacy: plain raw transaction JSON string
    // 2) Wrapped: JSON object with { raw, error, time }
    String raw;
    try {
      final decoded = jsonDecode(entry);
      if (decoded is Map && decoded.containsKey('raw')) {
        raw = decoded['raw'] as String;
      } else {
        raw = entry;
      }
    } catch (_) {
      raw = entry;
    }

    final map = jsonDecode(raw) as Map<String, dynamic>;
    final tx = Transaction.fromJson(map);

    // Append to current transactions and persist
    final current = await loadTransactions();
    current.add(tx);
    await saveTransactions(current);

    // Remove restored entry from backup
    list.removeAt(index);
    await prefs.setStringList(_transactionsBackupKey, list);
    return true;
  } catch (e) {
    // ignore: avoid_print
    print('restoreMalformedEntry error: $e');
    return false;
  }
}

/// Attempt to restore all malformed backup entries. Returns number restored.
Future<int> restoreAllMalformedEntries() async {
  try {
    final prefs = await _prefs();
    final list = prefs.getStringList(_transactionsBackupKey) ?? [];
    int restored = 0;
    final current = await loadTransactions();
    final remaining = <String>[];

    for (final entry in list) {
      try {
        // Normalize entry to raw JSON string (handle wrapped and legacy)
        String raw;
        try {
          final decoded = jsonDecode(entry);
          if (decoded is Map && decoded.containsKey('raw')) {
            raw = decoded['raw'] as String;
          } else {
            raw = entry;
          }
        } catch (_) {
          raw = entry;
        }

        final map = jsonDecode(raw) as Map<String, dynamic>;
        final tx = Transaction.fromJson(map);
        current.add(tx);
        restored++;
      } catch (e) {
        // Keep entry for which restoration failed
        remaining.add(entry);
      }
    }

    await saveTransactions(current);
    if (remaining.isEmpty) {
      await prefs.remove(_transactionsBackupKey);
      await prefs.remove(_transactionsBackupTimeKey);
    } else {
      await prefs.setStringList(_transactionsBackupKey, remaining);
    }
    return restored;
  } catch (e) {
    // ignore: avoid_print
    print('restoreAllMalformedEntries error: $e');
    return 0;
  }
}

/// Return structured backup entries for inspection by a UI.
/// Each map will contain keys: 'raw', 'error', 'time'. For legacy entries
/// these may be null except 'raw'.
Future<List<Map<String, String?>>> loadTransactionsBackupWithMetadata() async {
  try {
    final prefs = await _prefs();
    final list = prefs.getStringList(_transactionsBackupKey) ?? [];
    final out = <Map<String, String?>>[];
    for (final entry in list) {
      try {
        final decoded = jsonDecode(entry);
        if (decoded is Map && decoded.containsKey('raw')) {
          out.add({
            'raw': decoded['raw']?.toString(),
            'error': decoded['error']?.toString(),
            'time': decoded['time']?.toString(),
          });
        } else {
          out.add({'raw': entry, 'error': null, 'time': null});
        }
      } catch (_) {
        out.add({'raw': entry, 'error': null, 'time': null});
      }
    }
    return out;
  } catch (e) {
    // ignore: avoid_print
    print('loadTransactionsBackupWithMetadata error: $e');
    return [];
  }
}
