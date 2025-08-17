import 'package:app/models/themes.dart';
import 'package:flutter/material.dart';
import '../services/voice_input_service.dart';

class TransactionPreviewWidget extends StatelessWidget {
  final TransactionData transactionData;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onEdit;

  const TransactionPreviewWidget({
    super.key,
    required this.transactionData,
    required this.onConfirm,
    required this.onCancel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.preview,
                color: ThemeProvider.getPrimaryColor(),
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Transaction Preview',
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCancel,
                icon: Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Transaction Card with dashboard-style design
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: transactionData.type == 'income'
                    ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                    : [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: transactionData.type == 'income'
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: transactionData.type == 'income'
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transactionData.type.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Amount
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: transactionData.type == 'income'
                          ? Colors.green
                          : Colors.red,
                      size: 28,
                    ),
                    Text(
                      '\$${transactionData.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Description
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transactionData.description,
                        style: TextStyle(
                          color: ThemeProvider.getTextColor(),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Category - showing $200
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Colors.grey,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ThemeProvider.getPrimaryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeProvider.getPrimaryColor().withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        transactionData.category, // This will be "$200"
                        style: TextStyle(
                          color: ThemeProvider.getPrimaryColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.getPrimaryColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Add Transaction',
                    style: TextStyle(
                      color: Colors.white,
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
