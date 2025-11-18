import 'package:app/models/models.dart';
import 'package:app/models/themes.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';

class AllScheduledTransactionsWidget extends StatelessWidget {
  final List<Transaction> scheduledTransactions;
  final Function(Transaction) onConfirmed;
  final Function(Transaction) onRejected;

  const AllScheduledTransactionsWidget({
    super.key,
    required this.scheduledTransactions,
    required this.onConfirmed,
    required this.onRejected,
  });

  String _getTransactionLabel(Transaction tx, BuildContext context) {
    if (tx.isLoan) {
      final tpl =
          tx.loanDirection == 'lend'
              ? AppLocalizations.of(context).t('lent_to')
              : AppLocalizations.of(context).t('borrowed_from');
      return '${tx.loanDirection == 'lend' ? '↙️ ' : '↖️ '}${tpl.replaceFirst('{name}', tx.counterparty!)}';
    }
    return tx.type == TransactionType.income
        ? '📥 ${AppLocalizations.of(context).t('income')}'
        : '📤 ${AppLocalizations.of(context).t('expense')}';
  }

  Color _getTransactionColor(Transaction tx) {
    if (tx.isLoan) return Colors.orange;
    return tx.type == TransactionType.income ? Colors.green : Colors.red;
  }

  String _getDaysInfo(DateTime? scheduledDate, BuildContext context) {
    if (scheduledDate == null) {
      return AppLocalizations.of(context).t('no_date') ?? 'No date';
    }

    final today = DateTime.now();
    final daysUntil = scheduledDate.difference(today).inDays;

    if (daysUntil < 0) {
      return AppLocalizations.of(
        context,
      ).t('days_ago').replaceFirst('{n}', (-daysUntil).toString());
    } else if (daysUntil == 0) {
      return AppLocalizations.of(context).t('today');
    } else if (daysUntil == 1) {
      return AppLocalizations.of(context).t('tomorrow');
    } else {
      return AppLocalizations.of(
        context,
      ).t('in_days').replaceFirst('{n}', daysUntil.toString());
    }
  }

  Color _getStatusColor(DateTime? scheduledDate) {
    if (scheduledDate == null) return Colors.grey;

    final today = DateTime.now();
    final daysUntil = scheduledDate.difference(today).inDays;

    if (daysUntil < 0) return Colors.red; // Past due
    if (daysUntil == 0) return Colors.orange; // Today
    return Colors.green; // Future
  }

  @override
  Widget build(BuildContext context) {
    // Filter only scheduled transactions
    final scheduled =
        scheduledTransactions.where((t) => t.isScheduled).toList();

    if (scheduled.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).t('scheduled_transactions'),
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
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${scheduled.length}',
                  style: TextStyle(
                    color: Colors.blue,
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
          // List of scheduled transactions
          Column(
            children:
                scheduled
                    .map((tx) => _buildScheduledTransactionTile(context, tx))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTransactionTile(BuildContext context, Transaction tx) {
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
                      _getTransactionLabel(tx, context),
                      style: TextStyle(
                        color: ThemeProvider.getTextColor().withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge (flexible)
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(tx.scheduledDate).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getDaysInfo(tx.scheduledDate, context),
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
                  onPressed: () => onRejected(tx),
                  icon: Icon(Icons.close, size: 18),
                  label: Text(AppLocalizations.of(context).t('cancel')),
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
                  onPressed: () => onConfirmed(tx),
                  icon: Icon(Icons.check, size: 18),
                  label: Text(AppLocalizations.of(context).t('confirm')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    foregroundColor: Colors.blue,
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
