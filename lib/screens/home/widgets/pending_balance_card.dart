import 'package:app/models/models.dart';
import 'package:app/models/themes.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';
import 'package:app/services/exchange_rate_service.dart';
import 'package:flutter/material.dart';

class PendingBalanceCard extends StatelessWidget {
  final List<Transaction> allTransactions;

  const PendingBalanceCard({super.key, required this.allTransactions});

  @override
  Widget build(BuildContext context) {
    // Show scheduled transactions that have not yet been settled (not confirmed/cancelled).
    // This includes scheduled items that are still awaiting user action.
    final scheduledTransactions =
        allTransactions
            .where((t) => t.isScheduled && !t.isSettled && !t.isLoan)
            .toList();

    // Convert each transaction to display currency
    final displayCurrencyStr =
        CurrencyService.instance.currency == Currency.USD ? 'USD' : 'UZS';

    double convertAmount(Transaction t) {
      return ExchangeRateService.convert(
        t.amount,
        t.inputCurrency,
        displayCurrencyStr,
      );
    }

    final pendingIncome = scheduledTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + convertAmount(t));

    final pendingExpense = scheduledTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + convertAmount(t));

    final pendingBalance = pendingIncome - pendingExpense;

    return Container(
      width: 340,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.3),
            Colors.orange.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('pending_balance'),
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyService.instance.formatAmount(
                  pendingBalance,
                  inputCurrency: displayCurrencyStr,
                ),
                style: TextStyle(
                  color: pendingBalance >= 0 ? Colors.green : Colors.red,
                  fontSize:
                      CurrencyService.instance
                                  .formatAmount(
                                    pendingBalance,
                                    inputCurrency: displayCurrencyStr,
                                  )
                                  .length >=
                              9
                          ? 28
                          : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context).t('future'),
                  style: TextStyle(
                    color: Colors.amber[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
                        Icon(Icons.trending_up, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context).t('future_income'),
                          style: TextStyle(
                            color: ThemeProvider.getTextColor().withOpacity(
                              0.7,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      CurrencyService.instance.formatAmount(
                        pendingIncome,
                        inputCurrency: displayCurrencyStr,
                      ),
                      style: TextStyle(
                        color: Colors.green,
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
                        Icon(Icons.trending_down, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context).t('future_expenses'),
                          style: TextStyle(
                            color: ThemeProvider.getTextColor().withOpacity(
                              0.7,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      CurrencyService.instance.formatAmount(
                        pendingExpense,
                        inputCurrency: displayCurrencyStr,
                      ),
                      style: TextStyle(
                        color: Colors.red,
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
    );
  }
}
