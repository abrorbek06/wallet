import 'package:app/models/models.dart';
import 'package:app/models/themes.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';

class PendingConfirmationDialog extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onConfirmed; // User confirms: YES, it happened
  final VoidCallback onRejected; // User confirms: NO, it didn't happen

  const PendingConfirmationDialog({
    super.key,
    required this.transaction,
    required this.onConfirmed,
    required this.onRejected,
  });

  Color get _typeColor {
    if (transaction.isLoan) return Colors.orange;
    return transaction.type == TransactionType.income
        ? Colors.green
        : Colors.red;
  }

  IconData get _typeIcon {
    if (transaction.isLoan) return Icons.handshake;
    return transaction.type == TransactionType.income
        ? Icons.arrow_downward
        : Icons.arrow_upward;
  }

  @override
  Widget build(BuildContext context) {
    final String typeLabel =
        transaction.isLoan
            ? (transaction.loanDirection == 'lend'
                ? AppLocalizations.of(context).t('loan_lent')
                : AppLocalizations.of(context).t('loan_borrowed'))
            : AppLocalizations.of(context).t(
              transaction.type == TransactionType.income ? 'income' : 'expense',
            );
    return AlertDialog(
      backgroundColor: ThemeProvider.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppLocalizations.of(context).t('confirm_transaction'),
        style: TextStyle(
          color: ThemeProvider.getTextColor(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type indicator
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_typeIcon, color: _typeColor, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeLabel,
                          style: TextStyle(
                            color: _typeColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          transaction.title,
                          style: TextStyle(
                            color: ThemeProvider.getTextColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Details
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeProvider.getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).t('amount_label'),
                        style: TextStyle(
                          color: ThemeProvider.getTextColor().withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        CurrencyService.instance.formatAmount(
                          transaction.amount,
                        ),
                        style: TextStyle(
                          color: _typeColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).t('due_date'),
                        style: TextStyle(
                          color: ThemeProvider.getTextColor().withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        transaction.scheduledDate != null
                            ? '${transaction.scheduledDate!.year}-${transaction.scheduledDate!.month.toString().padLeft(2, '0')}-${transaction.scheduledDate!.day.toString().padLeft(2, '0')}'
                            : AppLocalizations.of(context).t('no_date'),
                        style: TextStyle(
                          color: ThemeProvider.getTextColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.isLoan && transaction.counterparty != null)
                    Column(
                      children: [
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).t('person_label'),
                              style: TextStyle(
                                color: ThemeProvider.getTextColor().withOpacity(
                                  0.7,
                                ),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              transaction.counterparty!,
                              style: TextStyle(
                                color: ThemeProvider.getTextColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Question
            Text(
              AppLocalizations.of(context).t('did_transaction_happen'),
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        // NO Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRejected();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(
            AppLocalizations.of(context).t('no'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // YES Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmed();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.green),
          child: Text(
            AppLocalizations.of(context).t('yes'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
