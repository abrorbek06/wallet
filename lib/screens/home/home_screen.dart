import 'dart:convert';

import 'package:app/screens/daily/daily_screen.dart';
import 'package:app/screens/home/widgets/all_scheduled_transactions_widget.dart';
import 'package:app/screens/home/widgets/enhanced_add_transaction_dialog.dart';
import 'package:app/screens/home/widgets/pending_balance_card.dart';
import 'package:app/screens/home/widgets/pending_confirmation_dialog.dart';
import 'package:app/screens/home/widgets/pending_transactions_widget.dart';
import 'package:app/screens/statistic/statistics_screen.dart';
import 'package:app/services/scheduled_transaction_processor.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/storage.dart';
import '../../functions/category_managment.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ScheduledTransactionProcessor _scheduledProcessor =
      ScheduledTransactionProcessor();

  List<Transaction> transactions = [];
  double? _dailyLimit;

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

    // Process scheduled transactions and apply notifications
    await _processScheduledTransactions();
    // Load daily spending limit (if any)
    final limit = await loadDailyLimit();
    setState(() {
      _dailyLimit = limit;
    });
    // If daily limit exceeded and not warned today, show a SnackBar
    if (_dailyLimit != null) {
      final today = DateTime.now();
      final todayExpenses = transactions
          .where((t) {
            final d = t.date;
            final sameDay =
                d.year == today.year &&
                d.month == today.month &&
                d.day == today.day;
            return sameDay &&
                t.type == TransactionType.expense &&
                t.isSettled &&
                !t.isLoan;
          })
          .fold(0.0, (sum, t) => sum + t.amount);

      if (todayExpenses > _dailyLimit!) {
        final lastWarn = await loadDailyLimitWarnDate();
        final todayIso = DateTime.now().toIso8601String().substring(0, 10);
        if (lastWarn != todayIso) {
          // show warning
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('You have exceeded your daily spending limit.'),
                backgroundColor: Colors.red,
              ),
            );
          });
          await saveDailyLimitWarnDate(todayIso);
        }
      }
    }
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

          // Daily Screen
          DailyScreen(transactions: transactions),

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
          (_currentIndex == 0 || _currentIndex == 1)
              ? _buildFloatingActionButton()
              : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    final today = DateTime.now();
    final todayExpenses = transactions
        .where((t) {
          final d = t.date;
          final sameDay =
              d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
          return sameDay &&
              t.type == TransactionType.expense &&
              t.isSettled &&
              !t.isLoan;
        })
        .fold(0.0, (sum, t) => sum + t.amount);

    Widget dailyLimitBar() {
      final limit = _dailyLimit;
      if (limit == null) return SizedBox.shrink();
      final progress =
          (limit > 0) ? (todayExpenses / limit).clamp(0.0, 1.0) : 0.0;
      final exceeded = todayExpenses > limit;
      return Container(
        color: ThemeProvider.getCardColor(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today: \$${todayExpenses.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}',
                    style: TextStyle(
                      color:
                          exceeded ? Colors.red : ThemeProvider.getTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    color:
                        exceeded ? Colors.red : ThemeProvider.getPrimaryColor(),
                    backgroundColor: ThemeProvider.getPrimaryColor()
                        .withOpacity(0.12),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // OutlinedButton(
            //   onPressed: () async {
            //     final result = await showDialog<double?>(
            //       context: context,
            //       builder: (context) {
            //         final controller = TextEditingController(
            //           text: _dailyLimit?.toStringAsFixed(2) ?? '',
            //         );
            //         return AlertDialog(
            //           backgroundColor: ThemeProvider.getCardColor(),
            //           title: Text(
            //             'Set Daily Limit',
            //             style: TextStyle(color: ThemeProvider.getTextColor()),
            //           ),
            //           content: TextField(
            //             controller: controller,
            //             keyboardType: TextInputType.numberWithOptions(
            //               decimal: true,
            //             ),
            //             decoration: InputDecoration(
            //               hintText: 'Enter limit amount',
            //             ),
            //           ),
            //           actions: [
            //             TextButton(
            //               onPressed: () => Navigator.pop(context, null),
            //               child: Text('Cancel'),
            //             ),
            //             TextButton(
            //               onPressed: () {
            //                 final text = controller.text.trim();
            //                 if (text.isEmpty) {
            //                   return Navigator.pop(context, null);
            //                 }
            //                 final val = double.tryParse(text);
            //                 Navigator.pop(context, val);
            //               },
            //               child: Text('Save'),
            //             ),
            //           ],
            //         );
            //       },
            //     );

            //     if (result != null) {
            //       await saveDailyLimit(result);
            //       setState(() => _dailyLimit = result);
            //     }
            //   },
            //   child: Text('Limit'),
            // ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dailyLimitBar(),
        Container(
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
                icon: Icon(Icons.calendar_today),
                label: 'Daily',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Statistics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ],
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
    // Only include settled (confirmed) transactions in the current balance.
    // Scheduled transactions are not counted until they are confirmed and marked settled.
    final confirmedTransactions =
        transactions.where((t) => t.isSettled).toList();

    final totalIncome = confirmedTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = confirmedTransactions
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

          // Balance Cards Row - Scrollable horizontally
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Total Balance Card
                Container(
                  width: 340,
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
                        'Current Balance',
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
                          fontSize:
                              balance.toStringAsFixed(2).length >= 9 ? 30 : 36,
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
                SizedBox(width: 16),

                // Pending Balance Card
                PendingBalanceCard(allTransactions: transactions),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Pending Confirmations Section
          PendingTransactionsWidget(
            pendingTransactions:
                transactions.where((t) => t.isPending && !t.isSettled).toList(),
            onTransactionTap: (tx) {
              _showPendingConfirmationDialog(tx);
            },
            onConfirmed: (tx) {
              _confirmPendingTransactionDirectly(tx);
            },
            onRejected: (tx) {
              _rejectPendingTransactionDirectly(tx);
            },
          ),

          SizedBox(height: 12),

          // All Scheduled Transactions with Confirm/Cancel buttons
          AllScheduledTransactionsWidget(
            scheduledTransactions: transactions,
            onConfirmed: (tx) {
              _confirmPendingTransactionDirectly(tx);
            },
            onRejected: (tx) {
              _rejectPendingTransactionDirectly(tx);
            },
          ),

          // Scheduled & Loans Section
          // ScheduledLoansWidget(
          //   transactions: transactions,
          //   onTransactionsUpdated: () {
          //     setState(() {});
          //   },
          // ),

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

          // Transaction List - show most recent confirmed/non-scheduled transactions first
          ...(() {
            final filtered =
                transactions
                    .where((t) => !(t.isScheduled && !t.isSettled))
                    .toList();
            final sorted = List<Transaction>.from(filtered)
              ..sort((a, b) => b.date.compareTo(a.date));
            return sorted.take(5).map(_buildTransactionItem).toList();
          })(),
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
          builder:
              (context) => AlertDialog(
                backgroundColor: ThemeProvider.getBackgroundColor(),
                title: Text(
                  'Delete Transaction',
                  style: TextStyle(color: ThemeProvider.getTextColor()),
                ),
                content: Text(
                  'Are you sure you want to delete this transaction?',
                  style: TextStyle(color: ThemeProvider.getTextColor()),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: ThemeProvider.getPrimaryColor()),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        setState(() {
          transactions.removeWhere((t) => t.id == transaction.id);
          saveTransactions(
            transactions,
          ); // shared_preferences dan ham o‘chirilsin
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

  Future<void> _processScheduledTransactions() async {
    try {
      final activated = await _scheduledProcessor.processScheduledTransactions(
        transactions,
      );
      if (activated.isNotEmpty) {
        // Merge activated scheduled transactions
        for (var activatedTx in activated) {
          final idx = transactions.indexWhere((t) => t.id == activatedTx.id);
          if (idx != -1) {
            transactions[idx] = activatedTx;
          }
        }
        await saveTransactions(transactions);
        setState(() {});
      }
    } catch (e) {
      print('Error processing scheduled transactions: $e');
    }
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
    });

    saveTransactions(transactions);

    // Process scheduled transactions after adding
    _processScheduledTransactions();

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

  void _showPendingConfirmationDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder:
          (context) => PendingConfirmationDialog(
            transaction: transaction,
            onConfirmed: () async {
              // User confirmed: YES, this transaction happened
              await _scheduledProcessor.confirmPendingTransaction(
                transactions,
                transaction.id,
              );
              // Reload transactions from storage
              _loadTransactions();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction confirmed! Balance updated.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            onRejected: () async {
              // User rejected: NO, this transaction didn't happen
              await _scheduledProcessor.rejectPendingTransaction(
                transactions,
                transaction.id,
              );
              // Reload transactions from storage
              _loadTransactions();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction rejected and removed.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
    );
  }

  Future<void> _confirmPendingTransactionDirectly(
    Transaction transaction,
  ) async {
    // Direct confirmation without dialog - from button tap
    await _scheduledProcessor.confirmPendingTransaction(
      transactions,
      transaction.id,
    );
    _loadTransactions();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ ${transaction.title} confirmed! Balance updated.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _rejectPendingTransactionDirectly(
    Transaction transaction,
  ) async {
    // Direct rejection without dialog - from button tap
    await _scheduledProcessor.rejectPendingTransaction(
      transactions,
      transaction.id,
    );
    _loadTransactions();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✗ ${transaction.title} rejected.'),
        backgroundColor: Colors.orange,
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
