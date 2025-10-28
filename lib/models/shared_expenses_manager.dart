import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_expenses.dart';

class SharedExpenseManager {
  static const _key = 'shared_expenses';

  Future<List<SharedExpense>> getAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List data = jsonDecode(jsonString);
    return data.map((e) => SharedExpense.fromMap(e)).toList();
  }

  Future<void> addExpense(SharedExpense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAllExpenses();
    current.add(expense);
    final jsonList = current.map((e) => e.toMap()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
