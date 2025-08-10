import 'package:app/screens/statistic/widgets/charts/balance_trend_chart.dart';
import 'package:app/screens/statistic/widgets/charts/expense_categories_chart.dart';
import 'package:app/screens/statistic/widgets/charts/income_categories_chart.dart';
import 'package:app/screens/statistic/widgets/charts/income_expense_pie_chart.dart';
import 'package:app/screens/statistic/widgets/transaction_item.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app/functions/category_managment.dart';
import 'package:app/models/models.dart';
import 'package:app/models/storage.dart';
import 'package:app/models/themes.dart';

import 'widgets/charts/category_list_item.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/summary_card.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const StatisticsScreen({
    super.key,
    required this.transactions,
  });

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isIncomeTransaction(Transaction transaction) {
    return transaction.type == TransactionType.income;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: ThemeProvider.getBackgroundColor(),
        elevation: 0,
        title: Text(
          'Statistics',
          style: TextStyle(
            color: ThemeProvider.getTextColor(),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.date_range, color: ThemeProvider.getTextColor()),
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem<String>(
                value: period,
                child: Row(
                  children: [
                    Icon(
                      _selectedPeriod == period ? Icons.check : Icons.calendar_today,
                      color: _selectedPeriod == period ? ThemeProvider.getPrimaryColor() : Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      period,
                      style: TextStyle(
                        color: _selectedPeriod == period ? ThemeProvider.getPrimaryColor() : ThemeProvider.getTextColor(),
                        fontWeight: _selectedPeriod == period ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(),

          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: ThemeProvider.getCardColor(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              indicator: BoxDecoration(
                color: ThemeProvider.getPrimaryColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: Icon(Icons.pie_chart, size: 20),
                  text: 'Overview',
                ),
                Tab(
                  icon: Icon(Icons.trending_up, size: 20),
                  text: 'Income',
                ),
                Tab(
                  icon: Icon(Icons.trending_down, size: 20),
                  text: 'Expenses',
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildIncomeTab(),
                _buildExpenseTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final filteredTransactions = _getFilteredTransactions();
    final totalIncome = _calculateTotalIncome(filteredTransactions);
    final totalExpense = _calculateTotalExpense(filteredTransactions);
    final balance = totalIncome - totalExpense;

    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: 'Total Income',
              amount: totalIncome,
              color: Colors.green,
              icon: Icons.trending_up,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Total Expense',
              amount: totalExpense,
              color: Colors.red,
              icon: Icons.trending_down,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Balance',
              amount: balance,
              color: balance >= 0 ? Colors.blue : Colors.orange,
              icon: balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final filteredTransactions = _getFilteredTransactions();
    final totalIncome = _calculateTotalIncome(filteredTransactions);
    final totalExpense = _calculateTotalExpense(filteredTransactions);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          BalanceTrendChart(
            balanceTrendData: _generateRealBalanceTrendData(),
            getDateForIndex: _getDateForIndex,
          ),
          SizedBox(height: 24),
          IncomeExpensePieChart(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
          ),
          SizedBox(height: 24),
          RecentTransactionsSummary(
            transactions: filteredTransactions,
            allTransactions: widget.transactions,
            showAllTransactions: _showAllTransactions,
            showTransactionDetails: _showTransactionDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTab() {
    final incomeByCategory = _getIncomeByCategory();
    final totalIncome = incomeByCategory.values.fold(0.0, (sum, amount) => sum + amount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          IncomeCategoriesChart(incomeByCategory: incomeByCategory),
          SizedBox(height: 24),
          _buildIncomeCategoriesList(incomeByCategory, totalIncome),
        ],
      ),
    );
  }

  Widget _buildExpenseTab() {
    final expenseByCategory = _getExpenseByCategory();
    final totalExpense = expenseByCategory.values.fold(0.0, (sum, amount) => sum + amount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          ExpenseCategoriesChart(expenseByCategory: expenseByCategory),
          SizedBox(height: 24),
          _buildExpenseCategoriesList(expenseByCategory, totalExpense),
        ],
      ),
    );
  }

  Widget _buildIncomeCategoriesList(Map<String, double> incomeByCategory, double totalIncome) {
    if (incomeByCategory.isEmpty) {
      return _buildEmptyCategoriesList('income');
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income Breakdown',
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...incomeByCategory.entries.map((entry) {
            final category = CategoryManager.getCategoryById(entry.key) ??
                Category(id: '', name: 'Other', icon: Icons.category, 
                        color: Colors.grey, type: 'income');
            final percentage = totalIncome > 0 ? (entry.value / totalIncome) * 100 : 0.0;

            return CategoryListItem(
              category: category,
              amount: entry.value,
              percentage: percentage,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoriesList(Map<String, double> expenseByCategory, double totalExpense) {
    if (expenseByCategory.isEmpty) {
      return _buildEmptyCategoriesList('expense');
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Breakdown',
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...expenseByCategory.entries.map((entry) {
            final category = CategoryManager.getCategoryById(entry.key) ??
                Category(id: '', name: 'Other', icon: Icons.category, 
                        color: Colors.grey, type: 'expense');
            final percentage = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0.0;

            return CategoryListItem(
              category: category,
              amount: entry.value,
              percentage: percentage,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoriesList(String type) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'No $type categories to display',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Helper methods
  List<Transaction> _getFilteredTransactions() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 3, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        return widget.transactions;
    }

    return widget.transactions.where((transaction) {
      return transaction.date.isAfter(startDate) || 
             transaction.date.isAtSameMomentAs(startDate);
    }).toList();
  }

  double _calculateTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => _isIncomeTransaction(t))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => !_isIncomeTransaction(t))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> _getIncomeByCategory() {
    final filteredTransactions = _getFilteredTransactions();
    final incomeTransactions = filteredTransactions.where(_isIncomeTransaction);

    Map<String, double> incomeByCategory = {};
    for (var transaction in incomeTransactions) {
      incomeByCategory[transaction.categoryId] =
          (incomeByCategory[transaction.categoryId] ?? 0.0) + transaction.amount;
    }
    return incomeByCategory;
  }

  Map<String, double> _getExpenseByCategory() {
    final filteredTransactions = _getFilteredTransactions();
    final expenseTransactions = filteredTransactions.where((t) => !_isIncomeTransaction(t));

    Map<String, double> expenseByCategory = {};
    for (var transaction in expenseTransactions) {
      expenseByCategory[transaction.categoryId] =
          (expenseByCategory[transaction.categoryId] ?? 0.0) + transaction.amount;
    }
    return expenseByCategory;
  }

  DateTime _getDateForIndex(int index) {
    final filteredTransactions = _getFilteredTransactions();
    filteredTransactions.sort((a, b) => a.date.compareTo(b.date));

    Set<DateTime> uniqueDates = {};
    for (var transaction in filteredTransactions) {
      uniqueDates.add(DateTime(
        transaction.date.year, 
        transaction.date.month, 
        transaction.date.day
      ));
    }

    final sortedDates = uniqueDates.toList()..sort();
    return index >= 0 && index < sortedDates.length 
        ? sortedDates[index] 
        : DateTime.now();
  }

  String _allTransactionsFilter = 'All';

  void _showAllTransactions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          List<Transaction> filteredTransactions;
          if (_allTransactionsFilter == 'Income') {
            filteredTransactions = widget.transactions.where((t) => _isIncomeTransaction(t)).toList();
          } else if (_allTransactionsFilter == 'Expense') {
            filteredTransactions = widget.transactions.where((t) => !_isIncomeTransaction(t)).toList();
          } else {
            filteredTransactions = widget.transactions;
          }
          // Sort by most recent first
          filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: ThemeProvider.getBackgroundColor(),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Transactions',
                          style: TextStyle(
                            color: ThemeProvider.getTextColor(),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: ThemeProvider.getTextColor()),
                        ),
                      ],
                    ),
                  ),
                  // Filter Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Text('Filter:', style: TextStyle(color: ThemeProvider.getTextColor(), fontWeight: FontWeight.w500)),
                        SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _allTransactionsFilter,
                          dropdownColor: ThemeProvider.getCardColor(),
                          items: ['All', 'Income', 'Expense'].map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type, style: TextStyle(color: ThemeProvider.getTextColor())),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                _allTransactionsFilter = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
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
                                title: Text('Delete Transaction'),
                                content: Text('Are you sure you want to delete this transaction?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                    child: Text('Delete', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            setState(() {
                              widget.transactions.removeWhere((t) => t.id == transaction.id);
                              saveTransactions(widget.transactions);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Transaction deleted'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: TransactionItem(
                            transaction: transaction,
                            isLast: index == filteredTransactions.length - 1,
                            onTap: () => _showTransactionDetails(transaction),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final isIncome = _isIncomeTransaction(transaction);
    final category = CategoryManager.getCategoryById(transaction.categoryId) ??
        Category(id: '', name: 'Other', icon: Icons.category, 
                color: Colors.grey, type: isIncome ? 'income' : 'expense');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ThemeProvider.getCardColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTransactionHeader(category, isIncome),
              SizedBox(height: 24),
              _buildTransactionDetailRow('Title', transaction.title),
              _buildTransactionDetailRow('Category', category.name),
              _buildTransactionDetailRow('Amount', '\$${transaction.amount.toStringAsFixed(2)}'),
              _buildTransactionDetailRow('Type', isIncome ? 'Income' : 'Expense'),
              _buildTransactionDetailRow('Date', '${transaction.date.month}/${transaction.date.day}/${transaction.date.year}'),
              _buildTransactionDetailRow('Time', '${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}'),
              SizedBox(height: 24),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(Category category, bool isIncome) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color, size: 28),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Details',
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isIncome ? 'Income Transaction' : 'Expense Transaction',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
  }
  

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeProvider.getPrimaryColor(),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Close',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateRealBalanceTrendData() {
    final filteredTransactions = _getFilteredTransactions();

    if (filteredTransactions.isEmpty) {
      return [];
    }

    // Sort transactions by date
    filteredTransactions.sort((a, b) => a.date.compareTo(b.date));

    // Group transactions by date
    Map<DateTime, double> dailyBalanceChanges = {};

    for (var transaction in filteredTransactions) {
      final dateKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      final amount = _isIncomeTransaction(transaction) ? transaction.amount.toDouble() : -transaction.amount.toDouble();
      dailyBalanceChanges[dateKey] = (dailyBalanceChanges[dateKey] ?? 0.0) + amount;
    }

    // Convert to cumulative balance over time
    List<FlSpot> spots = [];
    double cumulativeBalance = 0.0;
    int index = 0;

    final sortedDates = dailyBalanceChanges.keys.toList()..sort();

    for (var date in sortedDates) {
      cumulativeBalance += dailyBalanceChanges[date]!;
      spots.add(FlSpot(index.toDouble(), cumulativeBalance));
      index++;
    }

    return spots;
  }
}