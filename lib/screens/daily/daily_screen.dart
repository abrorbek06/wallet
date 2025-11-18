import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../../models/storage.dart';
import '../../functions/category_managment.dart';
import 'package:app/services/currency_service.dart';
import 'package:app/services/exchange_rate_service.dart';
import '../../l10n/app_localizations.dart';

class DailyScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const DailyScreen({super.key, required this.transactions});

  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  double? _dailyLimit;
  String _dailyLimitCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadDailyLimit();
  }

  Future<void> _loadDailyLimit() async {
    final limit = await loadDailyLimit();
    final currency = await loadDailyLimitCurrency();
    setState(() {
      _dailyLimit = limit;
      _dailyLimitCurrency = currency;
    });
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
            (sum, t) => sum + _convertTransactionAmount(t),
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

  /// Convert transaction amount from its input currency to display currency
  double _convertTransactionAmount(Transaction t) {
    final displayCurrencyStr =
        CurrencyService.instance.currency == Currency.USD ? 'USD' : 'UZS';
    return ExchangeRateService.convert(
      t.amount,
      t.inputCurrency,
      displayCurrencyStr,
    );
  }

  /// Calculate total spent today
  double _getTodaySpent() {
    return _getTodayTransactions().fold<double>(
      0.0,
      (sum, t) => sum + _convertTransactionAmount(t),
    );
  }

  /// Get remaining budget (or overspent amount)
  double _getRemainingBudget() {
    if (_dailyLimit == null) return 0;
    final dailyLimitInDisplay = _convertDailyLimitToDisplayCurrency();
    return dailyLimitInDisplay - _getTodaySpent();
  }

  /// Convert daily limit from its input currency to display currency
  double _convertDailyLimitToDisplayCurrency() {
    if (_dailyLimit == null) return 0;
    final displayCurrencyStr =
        CurrencyService.instance.currency == Currency.USD ? 'USD' : 'UZS';
    return ExchangeRateService.convert(
      _dailyLimit!,
      _dailyLimitCurrency,
      displayCurrencyStr,
    );
  }

  /// Format date for display
  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == yesterday) {
      return AppLocalizations.of(context).t('yesterday');
    }

    // Show day of week and date (localized short names)
    final loc = AppLocalizations.of(context);
    final dayNames = [
      loc.t('mon'),
      loc.t('tue'),
      loc.t('wed'),
      loc.t('thu'),
      loc.t('fri'),
      loc.t('sat'),
      loc.t('sun'),
    ];
    final dayName = dayNames[dateToCheck.weekday - 1];
    return '$dayName, ${dateToCheck.month}/${dateToCheck.day}';
  }

  /// Get color based on spending percentage with 7 color grades
  /// 0-40%: Green, 40-50%: Light Green, 50-60%: Yellow, 60-70%: Light Orange,
  /// 70-80%: Orange, 80-90%: Red-Orange, 90-100%: Red
  Color _getStatusColor(double percentage) {
    if (percentage <= 0.4) {
      return Colors.green; // Green - Safe
    } else if (percentage <= 0.5) {
      // Green to Light Green gradient
      final t = (percentage - 0.4) / 0.1;
      return Color.lerp(Colors.green, Color(0xFF66BB6A), t) ??
          Color(0xFF66BB6A);
    } else if (percentage <= 0.6) {
      // Light Green to Yellow gradient
      final t = (percentage - 0.5) / 0.1;
      return Color.lerp(Color(0xFF66BB6A), Colors.amber, t) ?? Colors.amber;
    } else if (percentage <= 0.7) {
      // Yellow to Light Orange gradient
      final t = (percentage - 0.6) / 0.1;
      return Color.lerp(Colors.amber, Color(0xFFFFB74D), t) ??
          Color(0xFFFFB74D);
    } else if (percentage <= 0.8) {
      // Light Orange to Orange gradient
      final t = (percentage - 0.7) / 0.1;
      return Color.lerp(Color(0xFFFFB74D), Colors.orange, t) ?? Colors.orange;
    } else if (percentage <= 0.9) {
      // Orange to Red-Orange gradient
      final t = (percentage - 0.8) / 0.1;
      return Color.lerp(Colors.orange, Colors.deepOrange, t) ??
          Colors.deepOrange;
    } else {
      return Colors.red; // Red - Exceeded
    }
  }

  /// Get status text and icon
  Map<String, dynamic> _getStatusInfo(double percentage) {
    if (percentage <= 0.4) {
      return {
        'text': AppLocalizations.of(context).t('status_safe'),
        'icon': Icons.check_circle,
      };
    } else if (percentage <= 0.5) {
      return {
        'text': AppLocalizations.of(context).t('status_good'),
        'icon': Icons.check_circle,
      };
    } else if (percentage <= 0.6) {
      return {
        'text': AppLocalizations.of(context).t('status_caution'),
        'icon': Icons.info,
      };
    } else if (percentage <= 0.7) {
      return {
        'text': AppLocalizations.of(context).t('status_alert'),
        'icon': Icons.info,
      };
    } else if (percentage <= 0.8) {
      return {
        'text': AppLocalizations.of(context).t('status_warning'),
        'icon': Icons.warning,
      };
    } else if (percentage <= 0.9) {
      return {
        'text': AppLocalizations.of(context).t('status_critical'),
        'icon': Icons.warning_amber,
      };
    } else {
      return {
        'text': AppLocalizations.of(context).t('status_exceeded'),
        'icon': Icons.cancel,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final todaySpent = _getTodaySpent();
    final remaining = _getRemainingBudget();
    final todayTransactions = _getTodayTransactions();
    final dailyLimitInDisplay = _convertDailyLimitToDisplayCurrency();

    // Calculate percentage for color coding
    final percentage =
        dailyLimitInDisplay > 0
            ? (todaySpent / dailyLimitInDisplay).clamp(0.0, 1.5)
            : 0.0;

    final statusColor = _getStatusColor(percentage);
    final statusInfo = _getStatusInfo(percentage);

    return Scaffold(
      backgroundColor: ThemeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: ThemeProvider.getBackgroundColor(),
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).t('todays_spending'),
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
                border: Border.all(color: statusColor, width: 2),
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
                            AppLocalizations.of(context).t('daily_limit'),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dailyLimit != null
                                ? CurrencyService.instance.formatAmount(
                                  _convertDailyLimitToDisplayCurrency(),
                                )
                                : AppLocalizations.of(context).t('not_set'),
                            style: TextStyle(
                              color: ThemeProvider.getTextColor(),
                              fontSize:
                                  CurrencyService.instance
                                              .formatAmount(
                                                _convertDailyLimitToDisplayCurrency(),
                                              )
                                              .length >=
                                          10
                                      ? 22
                                      : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          String selectedCurrency = _dailyLimitCurrency;
                          final result = await showDialog<double?>(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController(
                                text: _dailyLimit?.toStringAsFixed(2) ?? '',
                              );
                              return StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return AlertDialog(
                                    backgroundColor:
                                        ThemeProvider.getCardColor(),
                                    title: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).t('set_daily_limit'),
                                      style: TextStyle(
                                        color: ThemeProvider.getTextColor(),
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: controller,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Enter daily spending limit',
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        // Currency Selector
                                        SegmentedButton<String>(
                                          segments: const [
                                            ButtonSegment(
                                              label: Text('USD'),
                                              value: 'USD',
                                            ),
                                            ButtonSegment(
                                              label: Text("so'm"),
                                              value: 'UZS',
                                            ),
                                          ],
                                          selected: {selectedCurrency},
                                          onSelectionChanged: (
                                            Set<String> newSelection,
                                          ) {
                                            setDialogState(() {
                                              selectedCurrency =
                                                  newSelection.first;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, null),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).t('cancel'),
                                        ),
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
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).t('save'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                          if (result != null) {
                            await saveDailyLimit(
                              result,
                              currency: selectedCurrency,
                            );
                            setState(() {
                              _dailyLimit = result;
                              _dailyLimitCurrency = selectedCurrency;
                            });
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(AppLocalizations.of(context).t('edit')),
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
                          AppLocalizations.of(context).t('spending_progress'),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
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
                        value:
                            (dailyLimitInDisplay > 0)
                                ? (todaySpent / dailyLimitInDisplay).clamp(0, 1)
                                : 0,
                        minHeight: 16,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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
                        AppLocalizations.of(context).t('spent_today'),
                        CurrencyService.instance.formatAmount(todaySpent),
                        statusColor.withOpacity(0.1),
                        statusColor,
                      ),
                      _buildDetailCard(
                        remaining >= 0
                            ? AppLocalizations.of(context).t('remaining')
                            : AppLocalizations.of(context).t('overspent'),
                        CurrencyService.instance.formatAmount(remaining.abs()),
                        (remaining >= 0 ? Colors.green : Colors.red)
                            .withOpacity(0.1),
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
              AppLocalizations.of(context).t('today_transactions'),
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
                AppLocalizations.of(context).t('previous_days'),
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
                              _formatDate(date, context),
                              style: TextStyle(
                                color: ThemeProvider.getTextColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(dayData['transactions'] as List).length} ${AppLocalizations.of(context).t('transactions')}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '-${CurrencyService.instance.formatAmount(total)}',
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
            '-${CurrencyService.instance.formatAmount(transaction.amount, inputCurrency: transaction.inputCurrency)}',
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
