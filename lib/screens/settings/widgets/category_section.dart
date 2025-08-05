import 'package:app/screens/settings/fixed/fixed_category_dialog.dart';
import 'package:flutter/material.dart';

import '../../../functions/category_managment.dart';
import '../../../models/models.dart';
import '../../../models/themes.dart';

class CategorySection extends StatelessWidget {
  final Function(Category) onAddCategory;
  final Function(String, bool) onRemoveCategory;

  const CategorySection({
    super.key,
    required this.onAddCategory,
    required this.onRemoveCategory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CategoryManagementDialog(
            onAddCategory: onAddCategory,
            onRemoveCategory: (id, isIncome) {
              onRemoveCategory(id, isIncome);
              CategoryManager.removeCategory(id, isIncome);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeProvider.getCardColor(),
          borderRadius: BorderRadius.circular(16),
        ),
        child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Colors.green,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Category Management',
                            style: TextStyle(
                              color: ThemeProvider.getTextColor(),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your income and expense categories',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${CategoryManager.incomeCategories.length} Income',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${CategoryManager.expenseCategories.length} Expense',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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

  Widget _categoryChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
