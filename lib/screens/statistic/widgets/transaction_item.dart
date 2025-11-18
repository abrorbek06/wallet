import 'package:flutter/material.dart';
import 'package:app/models/models.dart';
import 'package:app/functions/category_managment.dart';
import 'package:app/models/themes.dart';
import '../../../l10n/app_localizations.dart';
import 'package:app/services/currency_service.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final bool isLast;
  final VoidCallback onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final defaultCategoryName = AppLocalizations.of(context).t('other');
    final category =
        CategoryManager.getCategoryById(transaction.categoryId) ??
        Category(
          id: '',
          name: defaultCategoryName,
          icon: Icons.category,
          color: Colors.grey,
          type: isIncome ? 'income' : 'expense',
        );

    // Format date
    final now = DateTime.now();
    final difference = now.difference(transaction.date);

    String dateText;
    if (difference.inDays == 0) {
      dateText =
          difference.inHours == 0
              ? AppLocalizations.of(context)
                  .t('minutes_ago')
                  .replaceFirst('{n}', difference.inMinutes.toString())
              : AppLocalizations.of(context)
                  .t('hours_ago')
                  .replaceFirst('{n}', difference.inHours.toString());
    } else if (difference.inDays == 1) {
      dateText = AppLocalizations.of(context).t('yesterday');
    } else if (difference.inDays < 7) {
      dateText = AppLocalizations.of(
        context,
      ).t('days_ago').replaceFirst('{n}', difference.inDays.toString());
    } else {
      dateText = '${transaction.date.month}/${transaction.date.day}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: category.color.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            _buildCategoryIcon(category),
            SizedBox(width: 16),
            _buildTransactionDetails(context, category, dateText),
            _buildAmountAndType(context, isIncome),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(Category category) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(category.icon, color: category.color, size: 20),
    );
  }

  Widget _buildTransactionDetails(
    BuildContext context,
    Category category,
    String dateText,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.title,
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  category.name,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              Flexible(
                child: Text(
                  dateText,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountAndType(BuildContext context, bool isIncome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isIncome ? '+' : '-'}${CurrencyService.instance.formatAmount(transaction.amount, inputCurrency: transaction.inputCurrency)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontSize:
                CurrencyService.instance
                            .formatAmount(
                              transaction.amount,
                              inputCurrency: transaction.inputCurrency,
                            )
                            .length >=
                        12
                    ? 12
                    : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color:
                isIncome
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isIncome
                ? AppLocalizations.of(context).t('income')
                : AppLocalizations.of(context).t('expense'),
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
