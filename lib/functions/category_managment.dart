import 'package:flutter/material.dart';
import '../models/models.dart';

class CategoryManager {
  static List<Category> incomeCategories = [
    Category(
      id: '1',
      name: 'Salary',
      icon: Icons.work,
      color: Colors.green,
      type: 'income',
    ),
    Category(
      id: '2',
      name: 'Freelance',
      icon: Icons.computer,
      color: Colors.blue,
      type: 'income',
    ),
    Category(
      id: '3',
      name: 'Investment',
      icon: Icons.trending_up,
      color: Colors.purple,
      type: 'income',
    ),
    Category(
      id: '4',
      name: 'Business',
      icon: Icons.business,
      color: Colors.orange,
      type: 'income',
    ),
    Category(
      id: '5',
      name: 'Gift',
      icon: Icons.card_giftcard,
      color: Colors.pink,
      type: 'income',
    ),
  ];

  static List<Category> expenseCategories = [
    Category(
      id: '6',
      name: 'Food',
      icon: Icons.restaurant,
      color: Colors.red,
      type: 'expense',
    ),
    Category(
      id: '7',
      name: 'Transport',
      icon: Icons.directions_car,
      color: Colors.blue,
      type: 'expense',
    ),
    Category(
      id: '8',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.purple,
      type: 'expense',
    ),
    Category(
      id: '9',
      name: 'Bills',
      icon: Icons.receipt,
      color: Colors.orange,
      type: 'expense',
    ),
    Category(
      id: '10',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.green,
      type: 'expense',
    ),
    Category(
      id: '11',
      name: 'Health',
      icon: Icons.local_hospital,
      color: Colors.red,
      type: 'expense',
    ),
    Category(
      id: '12',
      name: 'Education',
      icon: Icons.school,
      color: Colors.indigo,
      type: 'expense',
    ),
  ];

  // Add a new category
  static void addCategory(Category category) {
    if (category.isIncome) {
      incomeCategories.add(category);
    } else {
      expenseCategories.add(category);
    }
  }

  // Remove a category by ID and type
  static void removeCategory(String categoryId, bool isIncome) {
    if (isIncome) {
      incomeCategories.removeWhere((cat) => cat.id == categoryId);
    } else {
      expenseCategories.removeWhere((cat) => cat.id == categoryId);
    }
  }

  // Get category by ID
  static Category? getCategoryById(String id) {
    try {
      return [
        ...incomeCategories,
        ...expenseCategories,
      ].firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  static Category? getCategoryByName(String name) {
    try {
      return [
        ...incomeCategories,
        ...expenseCategories,
      ].firstWhere((cat) => cat.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Get all categories
  static List<Category> getAllCategories() {
    return [...incomeCategories, ...expenseCategories];
  }

  // Get categories by type
  static List<Category> getCategoriesByType(String type) {
    return type == 'income' ? incomeCategories : expenseCategories;
  }

  // Check if category exists
  static bool categoryExists(String name, String type) {
    List<Category> categories = type == 'income' ? incomeCategories : expenseCategories;
    return categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase());
  }

  // Get category count
  static int getCategoryCount(String type) {
    return type == 'income' ? incomeCategories.length : expenseCategories.length;
  }

  // Clear all categories (for data reset)
  static void clearAllCategories() {
    incomeCategories.clear();
    expenseCategories.clear();
  }

  // Reset to default categories
  static void resetToDefaults() {
    clearAllCategories();

    // Re-add default income categories
    incomeCategories.addAll([
      Category(
        id: '1',
        name: 'Salary',
        icon: Icons.work,
        color: Colors.green,
        type: 'income',
      ),
      Category(
        id: '2',
        name: 'Freelance',
        icon: Icons.computer,
        color: Colors.blue,
        type: 'income',
      ),
      Category(
        id: '3',
        name: 'Investment',
        icon: Icons.trending_up,
        color: Colors.purple,
        type: 'income',
      ),
      Category(
        id: '4',
        name: 'Business',
        icon: Icons.business,
        color: Colors.orange,
        type: 'income',
      ),
      Category(
        id: '5',
        name: 'Gift',
        icon: Icons.card_giftcard,
        color: Colors.pink,
        type: 'income',
      ),
    ]);

    // Re-add default expense categories
    expenseCategories.addAll([
      Category(
        id: '6',
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.red,
        type: 'expense',
      ),
      Category(
        id: '7',
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue,
        type: 'expense',
      ),
      Category(
        id: '8',
        name: 'Shopping',
        icon: Icons.shopping_bag,
        color: Colors.purple,
        type: 'expense',
      ),
      Category(
        id: '9',
        name: 'Bills',
        icon: Icons.receipt,
        color: Colors.orange,
        type: 'expense',
      ),
      Category(
        id: '10',
        name: 'Entertainment',
        icon: Icons.movie,
        color: Colors.green,
        type: 'expense',
      ),
      Category(
        id: '11',
        name: 'Health',
        icon: Icons.local_hospital,
        color: Colors.red,
        type: 'expense',
      ),
      Category(
        id: '12',
        name: 'Education',
        icon: Icons.school,
        color: Colors.indigo,
        type: 'expense',
      ),
    ]);
  }

  // Export categories to JSON
  static Map<String, dynamic> exportCategories() {
    return {
      'incomeCategories': incomeCategories.map((cat) => cat.toJson()).toList(),
      'expenseCategories': expenseCategories.map((cat) => cat.toJson()).toList(),
    };
  }

  // Import categories from JSON
  static void importCategories(Map<String, dynamic> data) {
    if (data.containsKey('incomeCategories')) {
      incomeCategories = (data['incomeCategories'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    }

    if (data.containsKey('expenseCategories')) {
      expenseCategories = (data['expenseCategories'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    }
  }
}