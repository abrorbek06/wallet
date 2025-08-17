import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const _incomeCategoriesKey = 'incomeCategories';
const _expenseCategoriesKey = 'expenseCategories';

Future<void> saveCategories(
  List<Category> income,
  List<Category> expense,
) async {
  final prefs = await SharedPreferences.getInstance();
  final incomeJson = income.map((c) => jsonEncode(c.toJson())).toList();
  final expenseJson = expense.map((c) => jsonEncode(c.toJson())).toList();
  await prefs.setStringList(_incomeCategoriesKey, incomeJson);
  await prefs.setStringList(_expenseCategoriesKey, expenseJson);
}

Future<List<Category>> loadCategories(bool isIncome) async {
  final prefs = await SharedPreferences.getInstance();
  final key = isIncome ? _incomeCategoriesKey : _expenseCategoriesKey;
  final jsonList = prefs.getStringList(key);
  if (jsonList == null) return [];
  return jsonList
      .map((jsonStr) => Category.fromJson(jsonDecode(jsonStr)))
      .toList();
}
