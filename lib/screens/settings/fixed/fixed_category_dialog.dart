import 'package:app/functions/category_managment.dart';
import 'package:app/models/models.dart';
import 'package:app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

import '../../../models/themes.dart';
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
  _CategoryManagementDialogState createState() => _CategoryManagementDialogState();
}

class _CategoryManagementDialogState extends State<CategoryManagementDialog> with TickerProviderStateMixin {
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
                  Icon(Icons.category, color: ThemeProvider.getPrimaryColor(), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Category Management',
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
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: ThemeProvider.getPrimaryColor(),
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: ThemeProvider.getPrimaryColor(),
                tabs: [
                  Tab(
                    icon: Icon(Icons.add_circle),
                    text: 'Income Categories',
                  ),
                  Tab(
                    icon: Icon(Icons.remove_circle),
                    text: 'Expense Categories',
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
                  onPressed: () => _showAddCategoryDialog(context, _tabController.index == 0),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add New Category',
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
                onPressed: () => _showDeleteCategoryDialog(context, category, isIncome),
                tooltip: 'Delete Category',
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
      builder: (context) => AddCategoryDialog(
        onAddCategory: (category) {
          widget.onAddCategory(category);
          setState(() {}); // Refresh the dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${category.name}" added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
        isIncome: isIncome,
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, Category category, bool isIncome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeProvider.getCardColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Category',
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
              'Are you sure you want to delete "${category.name}" category?',
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onRemoveCategory(category.id, isIncome);
              setState(() {}); // Refresh the dialog
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "${category.name}" deleted successfully'),
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
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
