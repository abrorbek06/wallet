import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';

import '../../functions/category_managment.dart';
import '../../models/models.dart';
import '../../models/themes.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(Transaction) onAddTransaction;

  const AddTransactionDialog({super.key, required this.onAddTransaction});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  final DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final categories =
        _selectedType == TransactionType.income
            ? CategoryManager.incomeCategories
            : CategoryManager.expenseCategories;

    return Dialog(
      backgroundColor: ThemeProvider.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).t('add_transaction'),
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Transaction Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(
                              () => _selectedType = TransactionType.income,
                            ),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedType == TransactionType.income
                                    ? Colors.green
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context).t('income'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _selectedType == TransactionType.income
                                      ? Colors.white
                                      : ThemeProvider.getTextColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(
                              () => _selectedType = TransactionType.expense,
                            ),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedType == TransactionType.expense
                                    ? Colors.red
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context).t('expense'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _selectedType == TransactionType.expense
                                      ? Colors.white
                                      : ThemeProvider.getTextColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: ThemeProvider.getTextColor()),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).t('title'),
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ThemeProvider.getPrimaryColor(),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).t('please_enter_title');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: ThemeProvider.getTextColor()),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).t('amount'),
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Colors.grey,
                    size: 20,
                  ),
                  // prefixText: 'so\'m',
                  // hintText: "so'm",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ThemeProvider.getPrimaryColor(),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(
                      context,
                    ).t('please_enter_amount');
                  }
                  if (double.tryParse(value) == null) {
                    return AppLocalizations.of(
                      context,
                    ).t('please_enter_valid_number');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                style: TextStyle(color: ThemeProvider.getTextColor()),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).t('category'),
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ThemeProvider.getPrimaryColor(),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(
                              category.icon,
                              color: category.color,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(
                      context,
                    ).t('please_select_category');
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context).t('cancel'),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedCategoryId == null ||
                            _selectedCategoryId!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                ).t('please_select_category'),
                              ),
                            ),
                          );
                          return;
                        }

                        final transaction = Transaction(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text,
                          categoryId: _selectedCategoryId!,
                          amount: double.parse(_amountController.text),
                          date: _selectedDate,
                          type: _selectedType,
                        );

                        widget.onAddTransaction(transaction);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.getPrimaryColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).t('add_transaction'),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
