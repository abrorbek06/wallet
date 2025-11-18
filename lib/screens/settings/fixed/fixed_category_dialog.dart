import 'package:app/functions/category_managment.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

import '../../../models/themes.dart';
import '../../../l10n/app_localizations.dart';
import 'fixed_enhanced_add_category.dart';

class CategoryManagementDialog extends StatefulWidget {
  final Function(Category) onAddCategory;
  final Function(String, bool) onRemoveCategory;

  const CategoryManagementDialog({
    super.key,
    required this.onAddCategory,
    required this.onRemoveCategory,
  });

  @override
  _CategoryManagementDialogState createState() =>
      _CategoryManagementDialogState();
}

class _CategoryManagementDialogState extends State<CategoryManagementDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeProvider.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeProvider.getPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: ThemeProvider.getPrimaryColor(),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).t('manage_categories'),
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: ThemeProvider.getPrimaryColor(),
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: ThemeProvider.getPrimaryColor(),
                tabs: [
                  Tab(
                    icon: Icon(Icons.add_circle),
                    text: AppLocalizations.of(context).t('income_categories'),
                  ),
                  Tab(
                    icon: Icon(Icons.remove_circle),
                    text: AppLocalizations.of(context).t('expense_categories'),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryList(CategoryManager.incomeCategories, true),
                  _buildCategoryList(CategoryManager.expenseCategories, false),
                ],
              ),
            ),

            // Add Button
            Container(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      () => _showAddCategoryDialog(
                        context,
                        _tabController.index == 0,
                      ),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context).t('add_new_category'),
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.getPrimaryColor(),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, bool isIncome) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: category.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, color: category.color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed:
                    () =>
                        _showDeleteCategoryDialog(context, category, isIncome),
                tooltip: AppLocalizations.of(
                  context,
                ).t('delete_category_tooltip'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, bool isIncome) {
    showDialog(
      context: context,
      builder:
          (context) => AddCategoryDialog(
            onAddCategory: (category) async {
              await CategoryManager.addCategory(category);
              setState(() {}); // Refresh the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    ).t('category_added').replaceAll('{name}', category.name),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            isIncome: isIncome,
          ),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    Category category,
    bool isIncome,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: ThemeProvider.getCardColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppLocalizations.of(context).t('delete_category_dialog_title'),
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)
                      .t('delete_category_dialog_content')
                      .replaceAll('{name}', category.name),
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).t('cannot_undo_action'),
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context).t('cancel'),
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await CategoryManager.removeCategory(category.id, isIncome);
                  setState(() {}); // Refresh the dialog
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)
                            .t('category_deleted_success')
                            .replaceAll('{name}', category.name),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).t('delete'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
