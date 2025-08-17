import 'package:app/functions/category_managment.dart';
import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../models/themes.dart';
import '../services/voice_input_service.dart';

class TransactionPreviewDialog extends StatelessWidget {
  final TransactionData transactionData;
  final Function(Transaction) onConfirm;
  final VoidCallback onCancel;

  const TransactionPreviewDialog({
    super.key,
    required this.transactionData,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transactionData.type == 'income';
    final categories = isIncome 
        ? CategoryManager.incomeCategories 
        : CategoryManager.expenseCategories;
    
    final category = categories.firstWhere(
      (cat) => cat.name.toLowerCase() == transactionData.category.toLowerCase(),
      orElse: () => categories.first,
    );

    return Dialog(
      backgroundColor: ThemeProvider.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
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
                Text(
                  'Transaction Preview',
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Dashboard-style transaction card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isIncome 
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isIncome ? Colors.green : Colors.red).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isIncome ? 'INCOME' : 'EXPENSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Amount - always $200
                  Text(
                    '\$${transactionData.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Description
                  Text(
                    transactionData.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Category with icon
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final categoryId = _getSuggestedCategoryId(
                        transactionData.category,
                        transactionData.type,
                      );

                      final transaction = Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: transactionData.description,
                        amount: transactionData.type == 'income' 
                            ? transactionData.amount 
                            : -transactionData.amount,
                        categoryId: categoryId,
                        date: DateTime.now(),
                        type: transactionData.type == 'income' 
                            ? TransactionType.income 
                            : TransactionType.expense,
                      );

                      onConfirm(transaction);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.getPrimaryColor(),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Transaction',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSuggestedCategoryId(String categoryName, String type) {
    final categories = type == 'income' 
        ? CategoryManager.incomeCategories 
        : CategoryManager.expenseCategories;
    
    for (var category in categories) {
      if (category.name.toLowerCase() == categoryName.toLowerCase()) {
        return category.id;
      }
    }
    
    return categories.isNotEmpty ? categories.first.id : '';
  }
}
