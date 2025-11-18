import 'package:flutter/material.dart';

enum TransactionType { income, expense }

// Constant icon lookup map
const Map<int, IconData> _iconMap = {
  0xe3b0: Icons.home,
  0xe559: Icons.shopping_cart,
  0xe1b3: Icons.restaurant,
  0xe3a4: Icons.directions_car,
  0xe5d8: Icons.movie,
  0xe8af: Icons.fitness_center,
  0xe529: Icons.school,
  0xe0c6: Icons.healing,
  0xe0a9: Icons.pets,
  0xeb51: Icons.work,
  0xe47f: Icons.attach_money,
  0xe5c3: Icons.card_giftcard,
  0xe628: Icons.card_travel,
};

IconData _getIconByCodePoint(int codePoint) {
  return _iconMap[codePoint] ?? Icons.category;
}

class Transaction {
  final String id;
  final String title;
  final String categoryId;
  final double amount;
  final DateTime date;
  final TransactionType type;
  // Optional fields for scheduled transactions and loans/IOUs
  final bool isScheduled;
  final DateTime? scheduledDate;
  final bool isLoan;
  final String? counterparty;
  final String? loanDirection; // 'lend' or 'borrow'
  final bool isSettled;
  final bool isPending; // True if awaiting user confirmation
  final String inputCurrency; // 'USD' or 'UZS' - currency used when entering

  Transaction({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.type,
    this.isScheduled = false,
    this.scheduledDate,
    this.isLoan = false,
    this.counterparty,
    this.loanDirection,
    this.isSettled = false,
    this.isPending = false,
    this.inputCurrency = 'USD', // Default to USD if not specified
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'isScheduled': isScheduled,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'isLoan': isLoan,
      'counterparty': counterparty,
      'loanDirection': loanDirection,
      'isSettled': isSettled,
      'isPending': isPending,
      'inputCurrency': inputCurrency,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      categoryId: json['categoryId'],
      amount:
          (json['amount'] is int)
              ? (json['amount'] as int).toDouble()
              : json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      type:
          json['type'] == 'TransactionType.income'
              ? TransactionType.income
              : TransactionType.expense,
      isScheduled: json['isScheduled'] ?? false,
      scheduledDate:
          json['scheduledDate'] != null
              ? DateTime.parse(json['scheduledDate'])
              : null,
      isLoan: json['isLoan'] ?? false,
      counterparty: json['counterparty'],
      loanDirection: json['loanDirection'],
      isSettled: json['isSettled'] ?? false,
      isPending: json['isPending'] ?? false,
      inputCurrency: json['inputCurrency'] ?? 'USD',
    );
  }
}

class CreditCard {
  final String id;
  String cardNumber;
  String cardHolderName;
  String expiryDate;
  String cvv;
  String cardType;
  double balance;
  bool isMain;

  CreditCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
    required this.balance,
    this.isMain = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardType': cardType,
      'balance': balance,
      'isMain': isMain,
    };
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expiryDate: json['expiryDate'],
      cvv: json['cvv'],
      cardType: json['cardType'],
      balance: json['balance'].toDouble(),
      isMain: json['isMain'],
    );
  }
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'income' or 'expense'

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'type': type,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: _getIconByCodePoint(json['icon']),
      color: Color(json['color']),
      type: json['type'],
    );
  }

  // Helper method to check if category is for income
  bool get isIncome => type == 'income';

  // Helper method to check if category is for expense
  bool get isExpense => type == 'expense';
}

// Settings Model for app preferences
class AppSettings {
  bool budgetAlerts;
  bool dailyReminders;
  bool weeklyReports;
  String theme;
  String currency;
  bool biometricAuth;

  AppSettings({
    this.budgetAlerts = true,
    this.dailyReminders = false,
    this.weeklyReports = true,
    this.theme = 'dark',
    this.currency = 'USD',
    this.biometricAuth = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'budgetAlerts': budgetAlerts,
      'dailyReminders': dailyReminders,
      'weeklyReports': weeklyReports,
      'theme': theme,
      'currency': currency,
      'biometricAuth': biometricAuth,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      budgetAlerts: json['budgetAlerts'] ?? true,
      dailyReminders: json['dailyReminders'] ?? false,
      weeklyReports: json['weeklyReports'] ?? true,
      theme: json['theme'] ?? 'dark',
      currency: json['currency'] ?? 'USD',
      biometricAuth: json['biometricAuth'] ?? false,
    );
  }
}

// Budget Model for future budget tracking feature
class Budget {
  final String id;
  final String categoryId;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String period; // 'monthly', 'weekly', 'yearly'

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'period': period,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      period: json['period'],
    );
  }
}
