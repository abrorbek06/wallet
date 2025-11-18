import 'package:app/models/models.dart';
import 'package:app/models/themes.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';
import 'package:app/screens/home/widgets/loan_settlement_dialog.dart';
import 'package:flutter/material.dart';

class ScheduledLoansWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onTransactionsUpdated;

  const ScheduledLoansWidget({
    super.key,
    required this.transactions,
    required this.onTransactionsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledTxs =
        transactions
            .where((t) => t.isScheduled && t.scheduledDate != null)
            .toList();
    final loanTxs =
        transactions.where((t) => t.isLoan && !t.isSettled).toList();

    if (scheduledTxs.isEmpty && loanTxs.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).t('scheduled_loans'),
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Spacer(),
              if (scheduledTxs.isNotEmpty || loanTxs.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${scheduledTxs.length + loanTxs.length}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          ...scheduledTxs.map((tx) => _buildScheduledItem(context, tx)),
          if (scheduledTxs.isNotEmpty && loanTxs.isNotEmpty)
            Divider(color: Colors.grey.withOpacity(0.2)),
          ...loanTxs.map((tx) => _buildLoanItem(context, tx)),
        ],
      ),
    );
  }

  Widget _buildScheduledItem(BuildContext context, Transaction tx) {
    final daysUntil =
        tx.scheduledDate != null
            ? tx.scheduledDate!.difference(DateTime.now()).inDays
            : 0;
    final isOverdue = tx.scheduledDate != null ? daysUntil < 0 : false;
    final isToday = tx.scheduledDate != null ? daysUntil == 0 : false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isOverdue
                ? Colors.red.withOpacity(0.05)
                : isToday
                ? Colors.orange.withOpacity(0.05)
                : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isOverdue
                  ? Colors.red.withOpacity(0.2)
                  : isToday
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            tx.type == TransactionType.income
                ? Icons.trending_up
                : Icons.trending_down,
            color:
                tx.type == TransactionType.income ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  isOverdue
                      ? AppLocalizations.of(context)
                          .t('days_overdue')
                          .replaceFirst('{n}', '${daysUntil.abs()}')
                      : isToday
                      ? AppLocalizations.of(context).t('due_today')
                      : AppLocalizations.of(
                        context,
                      ).t('due_in_days').replaceFirst('{n}', '$daysUntil'),
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyService.instance.formatAmount(tx.amount),
            style: TextStyle(
              color:
                  tx.type == TransactionType.income ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanItem(BuildContext context, Transaction tx) {
    final isLend = tx.loanDirection == 'lend';
    final statusColor = isLend ? Colors.green : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isLend ? Icons.arrow_downward : Icons.arrow_upward,
            color: statusColor,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (isLend
                          ? AppLocalizations.of(context).t('to_receive_from')
                          : AppLocalizations.of(context).t('to_pay_to'))
                      .replaceFirst('{name}', tx.counterparty ?? ''),
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  tx.title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyService.instance.formatAmount(tx.amount),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => LoanSettlementDialog(
                          loanTransaction: tx,
                          onSettled: onTransactionsUpdated,
                        ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppLocalizations.of(context).t('settle'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
