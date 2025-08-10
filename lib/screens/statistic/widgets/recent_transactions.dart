import 'package:flutter/material.dart';
import 'package:app/models/models.dart';
import 'package:app/models/themes.dart';
import 'transaction_item.dart';

class RecentTransactionsSummary extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Transaction> allTransactions;
  final VoidCallback showAllTransactions;
  final Function(Transaction) showTransactionDetails;

  const RecentTransactionsSummary({
    super.key,
    required this.transactions,
    required this.allTransactions,
    required this.showAllTransactions,
    required this.showTransactionDetails,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sorted.take(5).toList();

    if (recentTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          _buildTransactionCountIndicator(recentTransactions),
          SizedBox(height: 16),
          ..._buildTransactionItems(recentTransactions),
          _buildShowMoreButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No recent transactions',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'Add some transactions to see them here',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: ThemeProvider.getPrimaryColor(),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: showAllTransactions,
          // icon: Icon(Icons.arrow_forward, size: 16),
          label: Text('View All'),
          style: TextButton.styleFrom(
            foregroundColor: ThemeProvider.getPrimaryColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCountIndicator(List<Transaction> recentTransactions) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeProvider.getPrimaryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Showing ${recentTransactions.length} of ${allTransactions.length} transactions',
        style: TextStyle(
          color: ThemeProvider.getPrimaryColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Widget> _buildTransactionItems(List<Transaction> transactions) {
    return transactions.asMap().entries.map((entry) {
      final index = entry.key;
      final transaction = entry.value;
      return TransactionItem(
        transaction: transaction,
        isLast: index == transactions.length - 1,
        onTap: () => showTransactionDetails(transaction),
      );
    }).toList();
  }

  Widget _buildShowMoreButton() {
    if (allTransactions.length <= 5) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 12),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: showAllTransactions,
        icon: Icon(Icons.add, size: 18),
        label: Text('Show ${allTransactions.length - 5} More Transactions'),
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeProvider.getPrimaryColor(),
          side: BorderSide(
            color: ThemeProvider.getPrimaryColor().withOpacity(0.3),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
