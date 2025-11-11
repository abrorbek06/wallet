import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../../models/storage.dart';
import '../../functions/category_managment.dart';

class DailyScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const DailyScreen({super.key, required this.transactions});

  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  double? _dailyLimit;

  @override
  void initState() {
    super.initState();
    _loadDailyLimit();
  }

  Future<void> _loadDailyLimit() async {
    final limit = await loadDailyLimit();
    setState(() => _dailyLimit = limit);
  }

  /// Get today's transactions (expenses only, excluding unconfirmed scheduled)
  List<Transaction> _getTodayTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return widget.transactions.where((t) {
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      final isExpense = t.type == TransactionType.expense;
      final isConfirmed = !t.isScheduled || t.isSettled;
      return txDate == today && isExpense && isConfirmed;
    }).toList();
  }

  /// Get past days transactions grouped by date with total spent per day
  List<Map<String, dynamic>> _getPastDaysTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Group expenses by date (excluding today)
    Map<DateTime, List<Transaction>> grouped = {};

    for (var t in widget.transactions) {
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      final isExpense = t.type == TransactionType.expense;
      final isConfirmed = !t.isScheduled || t.isSettled;

      // Include only past days, not today
      if (txDate.isBefore(today) && isExpense && isConfirmed) {
        if (!grouped.containsKey(txDate)) {
          grouped[txDate] = [];
        }
        grouped[txDate]!.add(t);
      }
    }

    // Convert to list of maps with date and total
    final result =
        grouped.entries.map((entry) {
          final total = entry.value.fold<double>(
            0.0,
            (sum, t) => sum + t.amount,
          );
          return {
            'date': entry.key,
            'total': total,
            'transactions': entry.value,
          };
        }).toList();

    // Sort by date descending (newest first)
    result.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return result;
  }

  /// Calculate total spent today
  double _getTodaySpent() {
    return _getTodayTransactions().fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );
  }

  /// Get remaining budget (or overspent amount)
  double _getRemainingBudget() {
    if (_dailyLimit == null) return 0;
    return _dailyLimit! - _getTodaySpent();
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == yesterday) {
      return 'Yesterday';
    }

    // Show day of week and date
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[dateToCheck.weekday - 1];
    return '$dayName, ${dateToCheck.month}/${dateToCheck.day}';
  }

  /// Get color based on spending percentage
  /// 0-50%: Green, 50-70%: Yellow, 70-85%: Orange, 85-95%: Red-Orange, 95%+: Red
  Color _getStatusColor(double percentage) {
    if (percentage <= 0.5) {
      return Colors.green; // Green - Safe
    } else if (percentage <= 0.7) {
      // Green to Yellow gradient
      final t = (percentage - 0.5) / 0.2;
      return Color.lerp(Colors.green, Colors.amber, t) ?? Colors.amber;
    } else if (percentage <= 0.85) {
      // Yellow to Orange gradient
      final t = (percentage - 0.7) / 0.15;
      return Color.lerp(Colors.amber, Colors.orange, t) ?? Colors.orange;
    } else if (percentage <= 0.95) {
      // Orange to Red-Orange gradient
      final t = (percentage - 0.85) / 0.1;
      return Color.lerp(Colors.orange, Colors.deepOrange, t) ?? Colors.deepOrange;
    } else {
      return Colors.red; // Red - Exceeded
    }
  }

  /// Get status text and icon
  Map<String, dynamic> _getStatusInfo(double percentage) {
    if (percentage <= 0.5) {
      return {'text': '✓ Safe', 'icon': Icons.check_circle};
    } else if (percentage <= 0.7) {
      return {'text': '⚠ Caution', 'icon': Icons.info};
    } else if (percentage <= 0.85) {
      return {'text': '⚠ Warning', 'icon': Icons.warning};
    } else if (percentage <= 0.95) {
      return {'text': '⚠ Critical', 'icon': Icons.warning_amber};
    } else {
      return {'text': '⛔ Exceeded', 'icon': Icons.cancel};
    }
  }

  @override
  Widget build(BuildContext context) {
    final todaySpent = _getTodaySpent();
    final remaining = _getRemainingBudget();
    final todayTransactions = _getTodayTransactions();
    
    // Calculate percentage for color coding
    final percentage = _dailyLimit != null && _dailyLimit! > 0
        ? (todaySpent / _dailyLimit!).clamp(0.0, 1.5)
        : 0.0;
    
    final statusColor = _getStatusColor(percentage);
    final statusInfo = _getStatusInfo(percentage);

    return Scaffold(
      backgroundColor: ThemeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: ThemeProvider.getBackgroundColor(),
        elevation: 0,
        title: Text(
          'Today\'s Spending',
          style: TextStyle(
            color: ThemeProvider.getTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Budget Overview Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeProvider.getCardColor(),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo['icon'] as IconData,
                          color: statusColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusInfo['text'] as String,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Daily Limit Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Limit',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dailyLimit != null
                                ? '\$${_dailyLimit!.toStringAsFixed(2)}'
                                : 'Not set',
                            style: TextStyle(
                              color: ThemeProvider.getTextColor(),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final result = await showDialog<double?>(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController(
                                text: _dailyLimit?.toStringAsFixed(2) ?? '',
                              );
                              return AlertDialog(
                                backgroundColor: ThemeProvider.getCardColor(),
                                title: Text(
                                  'Set Daily Limit',
                                  style: TextStyle(
                                    color: ThemeProvider.getTextColor(),
                                  ),
                                ),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter daily spending limit',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final text = controller.text.trim();
                                      if (text.isEmpty) {
                                        return Navigator.pop(context, null);
                                      }
                                      final val = double.tryParse(text);
                                      Navigator.pop(context, val);
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (result != null) {
                            await saveDailyLimit(result);
                            setState(() => _dailyLimit = result);
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar with Dynamic Coloring
                  if (_dailyLimit != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spending Progress',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (todaySpent / _dailyLimit!).clamp(0, 1),
                        minHeight: 16,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Spending Details Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildDetailCard(
                        'Spent Today',
                        '\$${todaySpent.toStringAsFixed(2)}',
                        statusColor.withOpacity(0.1),
                        statusColor,
                      ),
                      _buildDetailCard(
                        remaining >= 0 ? 'Remaining' : 'Overspent',
                        '\$${remaining.abs().toStringAsFixed(2)}',
                        (remaining >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                        remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Today's Transactions
            Text(
              'Today\'s Transactions',
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (todayTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: ThemeProvider.getCardColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No spending today',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep up the good work! 💪',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayTransactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = todayTransactions[index];
                  return _buildTransactionTile(transaction);
                },
              ),
            const SizedBox(height: 32),

            // Past Days Summary
            if (_getPastDaysTransactions().isNotEmpty) ...[
              Text(
                'Previous Days',
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _getPastDaysTransactions().length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final dayData = _getPastDaysTransactions()[index];
                  final date = dayData['date'] as DateTime;
                  final total = dayData['total'] as double;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeProvider.getCardColor(),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(date),
                              style: TextStyle(
                                color: ThemeProvider.getTextColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(dayData['transactions'] as List).length} transactions',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '-\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    String label,
    String amount,
    Color backgroundColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  category.name,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '-\$${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
