import 'package:app/models/models.dart';
import 'package:app/models/themes.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';
import 'package:flutter/material.dart';

class PendingTransactionsWidget extends StatelessWidget {
  final List<Transaction> pendingTransactions;
  final Function(Transaction) onTransactionTap;
  final Function(Transaction)? onConfirmed;
  final Function(Transaction)? onRejected;

  const PendingTransactionsWidget({
    super.key,
    required this.pendingTransactions,
    required this.onTransactionTap,
    this.onConfirmed,
    this.onRejected,
  });

  String _getTransactionLabel(BuildContext context, Transaction tx) {
    if (tx.isLoan) {
      final key = tx.loanDirection == 'lend' ? 'lent_to' : 'borrowed_from';
      return AppLocalizations.of(
        context,
      ).t(key).replaceFirst('{name}', tx.counterparty ?? '');
    }
    final base =
        tx.type == TransactionType.income
            ? AppLocalizations.of(context).t('income')
            : AppLocalizations.of(context).t('expense');
    final emoji = tx.type == TransactionType.income ? '📥 ' : '📤 ';
    return '$emoji$base';
  }

  Color _getTransactionColor(Transaction tx) {
    if (tx.isLoan) return Colors.orange;
    return tx.type == TransactionType.income ? Colors.green : Colors.red;
  }

  String _getDaysInfo(BuildContext context, DateTime? scheduledDate) {
    if (scheduledDate == null) return 'No date';

    final today = DateTime.now();
    final daysUntil = scheduledDate.difference(today).inDays;

    if (daysUntil < 0) {
      return AppLocalizations.of(
        context,
      ).t('days_overdue').replaceFirst('{n}', '${-daysUntil}');
    } else if (daysUntil == 0) {
      return AppLocalizations.of(context).t('due_today');
    } else if (daysUntil == 1) {
      return AppLocalizations.of(context).t('due_tomorrow');
    } else {
      return AppLocalizations.of(
        context,
      ).t('due_in_days').replaceFirst('{n}', '$daysUntil');
    }
  }

  Color _getStatusColor(DateTime? scheduledDate) {
    if (scheduledDate == null) return Colors.grey;

    final today = DateTime.now();
    final daysUntil = scheduledDate.difference(today).inDays;

    if (daysUntil < 0) return Colors.red; // Overdue
    if (daysUntil == 0) return Colors.orange; // Due today
    return Colors.green; // Upcoming
  }

  @override
  Widget build(BuildContext context) {
    if (pendingTransactions.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).t('pending_transactions'),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pendingTransactions.length}',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            color: ThemeProvider.getTextColor().withOpacity(0.1),
          ),
          SizedBox(height: 12),
          // List of pending transactions
          Column(
            children:
                pendingTransactions
                    .map((tx) => _buildPendingTransactionTile(context, tx))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTransactionTile(BuildContext context, Transaction tx) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeProvider.getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(tx.scheduledDate).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Amount indicator
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTransactionColor(tx).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CurrencyService.instance.formatAmount(tx.amount),
                  style: TextStyle(
                    color: _getTransactionColor(tx),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Title and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getTransactionLabel(context, tx),
                      style: TextStyle(
                        color: ThemeProvider.getTextColor().withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge (flexible to avoid overflow)
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(tx.scheduledDate).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getDaysInfo(context, tx.scheduledDate),
                    style: TextStyle(
                      color: _getStatusColor(tx.scheduledDate),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Action buttons at bottom
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      () =>
                          onRejected != null
                              ? onRejected!(tx)
                              : onTransactionTap(tx),
                  icon: Icon(Icons.close, size: 18),
                  label: Text(AppLocalizations.of(context).t('not_done')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      () =>
                          onConfirmed != null
                              ? onConfirmed!(tx)
                              : onTransactionTap(tx),
                  icon: Icon(Icons.check, size: 18),
                  label: Text(AppLocalizations.of(context).t('done')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.2),
                    foregroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
