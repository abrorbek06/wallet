import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/storage.dart';
import '../../functions/category_managment.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../settings/settings_screen.dart';
import '../statistics_screen.dart';
import 'EnhancedAddTransactionDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Transaction> transactions = [
    Transaction(
      id: '1',
      title: 'Monthly Salary',
      amount: 5000.00,
      date: DateTime(2024, 1, 1),
      type: TransactionType.income,
      categoryId: "1",
    ),
    Transaction(
      id: '2',
      title: 'Rent Payment',
      amount: -1500.00,
      date: DateTime(2024, 1, 5),
      type: TransactionType.expense,
      categoryId: "1",
    ),
    Transaction(
      id: '3',
      title: 'Grocery Shopping',
      amount: -350.00,
      date: DateTime(2024, 1, 8),
      type: TransactionType.expense,
      categoryId: "1",
    ),
  ];

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        transactions.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList('transactions', jsonList);
  }

  List<CreditCard> cards = [];

  void _loadTransactions() async {
    final loaded = await loadTransactions();
    setState(() {
      transactions = loaded;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _loadTransactions();
  }

  void _loadSampleData() {
    // Add some sample transactions for testing
    transactions = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.getBackgroundColor(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Screen
          _buildHomeScreen(),

          // Statistics Screen
          StatisticsScreen(transactions: transactions),

          // Cards Screen
          // _buildCardsScreen(),

          // Settings Screen
          SettingsScreen(
            currentTheme: ThemeProvider.currentTheme,
            onThemeChanged: _updateTheme,
            onAddCategory: _addCategory,
            onRemoveCategory: _removeCategory,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton:
          _currentIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: ThemeProvider.getPrimaryColor(),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.credit_card),
          //   label: 'Cards',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddTransactionDialog,
      backgroundColor: ThemeProvider.getPrimaryColor(),
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildHomeScreen() {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),

          // Welcome Header
          Text(
            'Welcome Back!',
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Here\'s your financial overview',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          SizedBox(height: 30),

          // Balance Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ThemeProvider.getCardGradient(true),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ThemeProvider.getPrimaryColor().withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "\$${balance.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: balance.toStringAsFixed(2).length >= 9 ? 30 : 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Income',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${totalIncome.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_down,
                                color: Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${totalExpense.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // Navigate to Statistics
                  });
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Transaction List
          ...transactions
              .take(5)
              .map((transaction) => _buildTransactionItem(transaction))
              ,
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final category =
        CategoryManager.getCategoryById(transaction.categoryId) ??
            Category(
              id: '',
              name: 'Other',
              icon: Icons.category,
              color: Colors.grey,
              type: isIncome ? 'income' : 'expense',
            );

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ThemeProvider.getBackgroundColor(),
            title: Text('Delete Transaction', style: TextStyle(color: ThemeProvider.getTextColor())),
            content: Text('Are you sure you want to delete this transaction?', style: TextStyle(color: ThemeProvider.getTextColor())),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel', style: TextStyle(color: ThemeProvider.getPrimaryColor())),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        setState(() {
          transactions.removeWhere((t) => t.id == transaction.id);
          saveTransactions(transactions); // shared_preferences dan ham o‘chirilsin
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeProvider.getCardColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      color: ThemeProvider.getTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    category.name,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Theme update callback for Settings Screen
  void _updateTheme(String theme) {
    setState(() {
      ThemeProvider.updateTheme(theme);
    });
  }

  // Category management callbacks for Settings Screen
  void _addCategory(Category category) {
    setState(() {
      CategoryManager.addCategory(category);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "${category.name}" added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeCategory(String categoryId, bool isIncome) {
    Category? category = CategoryManager.getCategoryById(categoryId);
    String categoryName = category?.name ?? 'Category';

    setState(() {
      CategoryManager.removeCategory(categoryId, isIncome);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$categoryName removed successfully!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
    });

    saveTransactions(transactions);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddTransactionDialog(onAddTransaction: _addTransaction),
    );
  }

  // Card management methods
  void _addCard(CreditCard card) {
    setState(() {
      cards.add(card);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card added successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // void _showAddCardDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AddCardDialog(onAddCard: _addCard),
  //   );
  // }
}
