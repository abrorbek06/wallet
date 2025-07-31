import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const _transactionsKey = 'transactions';

Future<void> saveTransactions(List<Transaction> transactions) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = transactions.map((t) => jsonEncode(t.toJson())).toList();
  await prefs.setStringList(_transactionsKey, jsonList);
}

Future<List<Transaction>> loadTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = prefs.getStringList(_transactionsKey);

  if (jsonList == null) return [];

  return jsonList
      .map((jsonStr) => Transaction.fromJson(jsonDecode(jsonStr)))
      .toList();
}
