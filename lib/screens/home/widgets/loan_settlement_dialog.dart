import 'package:app/models/models.dart';
import 'package:app/models/themes.dart';
import 'package:app/services/scheduled_transaction_processor.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';
import 'package:flutter/material.dart';

class LoanSettlementDialog extends StatelessWidget {
  final Transaction loanTransaction;
  final VoidCallback onSettled;

  const LoanSettlementDialog({
    super.key,
    required this.loanTransaction,
    required this.onSettled,
  });

  @override
  Widget build(BuildContext context) {
    final isLend = loanTransaction.loanDirection == 'lend';
    final color = isLend ? Colors.green : Colors.orange;

    return AlertDialog(
      backgroundColor: ThemeProvider.getCardColor(),
      title: Row(
        children: [
          Icon(
            isLend ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              isLend
                  ? AppLocalizations.of(context).t('money_to_receive')
                  : AppLocalizations.of(context).t('money_to_pay'),
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t('transaction_details'),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context).t('counterparty_label')} ${loanTransaction.counterparty}',
                  style: TextStyle(color: ThemeProvider.getTextColor()),
                ),
                SizedBox(height: 8),
                Text(
                  '${AppLocalizations.of(context).t('amount')} ${CurrencyService.instance.formatAmount(loanTransaction.amount)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${AppLocalizations.of(context).t('description_label')} ${loanTransaction.title}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            isLend
                ? AppLocalizations.of(context)
                    .t('did_you_receive_from')
                    .replaceFirst('{name}', loanTransaction.counterparty ?? '')
                : AppLocalizations.of(context)
                    .t('did_you_pay_to')
                    .replaceFirst('{name}', loanTransaction.counterparty ?? ''),
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context).t('not_yet'),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _settleLoan(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isLend
                ? AppLocalizations.of(context).t('confirm_receive')
                : AppLocalizations.of(context).t('confirm_pay'),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _settleLoan(BuildContext context) async {
    final processor = ScheduledTransactionProcessor();
    // In a real app, you'd pass the full list and save. Here we just callback.
    await processor.settleTransaction([], loanTransaction.id, true);
    onSettled();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).t('loan_settled')),
        backgroundColor: Colors.green,
      ),
    );
  }
}
