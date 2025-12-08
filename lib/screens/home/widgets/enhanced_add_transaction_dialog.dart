import 'package:app/screens/home/services/voice_input_service.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../functions/category_managment.dart';
import '../../../models/models.dart';
import '../../../models/themes.dart';
import 'voice_input_widget.dart';
import 'image_input_widget.dart'; // Added import for ImageInputWidget

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
  final VoiceInputService _voiceService = VoiceInputService();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  final DateTime _selectedDate = DateTime.now();
  bool _isVoiceMode = false;
  bool _isImageMode = false; // Added _isImageMode variable
  // New fields for scheduled transactions and loans
  bool _isScheduled = false;
  DateTime? _scheduledDate;
  final bool _isLoan = false;
  final String _counterparty = '';
  final String _loanDirection = 'lend'; // 'lend' or 'borrow'
  String _inputCurrency = 'USD'; // Currency for input (USD or UZS)

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    await _voiceService.initialize();
  }

  Future<DateTime?> _pickDate(BuildContext context, {DateTime? initial}) async {
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(Duration(days: 365 * 5));

    if (Platform.isIOS) {
      DateTime tempPicked = initial ?? DateTime.now().add(Duration(days: 1));
      return await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) {
          return Container(
            height: 320,
            color: ThemeProvider.getBackgroundColor(),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  color: ThemeProvider.getCardColor(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: Text(AppLocalizations.of(context).t('cancel')),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        child: Text(AppLocalizations.of(context).t('done')),
                        onPressed: () => Navigator.of(context).pop(tempPicked),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempPicked,
                    minimumDate: firstDate,
                    maximumDate: lastDate,
                    onDateTimeChanged: (DateTime newDate) {
                      tempPicked = newDate;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now().add(Duration(days: 1)),
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

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
        child:
            _isVoiceMode
                ? _buildVoiceInputMode()
                : _isImageMode
                ? _buildImageInputMode()
                : _buildManualInputMode(categories),
      ),
    );
  }

  Widget _buildManualInputMode(List<Category> categories) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Input Mode Toggles
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).t('add_transaction'),
                    style: TextStyle(
                      color: ThemeProvider.getTextColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isImageMode = true;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, color: Colors.orange, size: 16),
                        // SizedBox(width: 4),
                        // Text(
                        //   'Image',
                        //   style: TextStyle(
                        //     color: Colors.orange,
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                // Voice Input Toggle Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVoiceMode = true;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, color: Colors.deepPurple, size: 16),
                        // SizedBox(width: 4),
                        // Text(
                        //   'Voice',
                        //   style: TextStyle(
                        //     color: Colors.deepPurple,
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
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
                          () => setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategoryId =
                                null; // Reset category selection
                          }),
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
                          () => setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategoryId =
                                null; // Reset category selection
                          }),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(7),
                      ),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text("salom", style: TextStyle()),
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
                  return AppLocalizations.of(context).t('please_enter_amount');
                }
                if (double.tryParse(value) == null) {
                  return AppLocalizations.of(
                    context,
                  ).t('please_enter_valid_number');
                }
                return null;
              },
            ),
            SizedBox(height: 12),

            // Currency Selector for Input
            Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(label: Text('USD'), value: 'USD'),
                    ButtonSegment(label: Text("so'm"), value: 'UZS'),
                  ],
                  selected: {_inputCurrency},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _inputCurrency = newSelection.first;
                    });
                  },
                ),
              ],
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
                          Icon(category.icon, color: category.color, size: 20),
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
                  return 'Please select a category';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            // Scheduled Transaction Toggle & Date
            SwitchListTile(
              value: _isScheduled,
              title: Text(
                'Schedule for later',
                style: TextStyle(color: ThemeProvider.getTextColor()),
              ),
              onChanged: (val) async {
                if (val) {
                  final picked = await _pickDate(
                    context,
                    initial: DateTime.now().add(Duration(days: 1)),
                  );
                  if (picked != null) {
                    setState(() {
                      _isScheduled = true;
                      _scheduledDate = picked;
                    });
                  }
                } else {
                  setState(() {
                    _isScheduled = false;
                    _scheduledDate = null;
                  });
                }
              },
            ),

            if (_isScheduled && _scheduledDate != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _scheduledDate != null
                      ? 'Scheduled: ${_scheduledDate!.month}/${_scheduledDate!.day}/${_scheduledDate!.year}'
                      : AppLocalizations.of(context).t('no_date'),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
              SizedBox(height: 12),
            ],

            // if (_isLoan) ...[
            //   // Counterparty
            //   TextFormField(
            //     initialValue: _counterparty,
            //     style: TextStyle(color: ThemeProvider.getTextColor()),
            //     decoration: InputDecoration(
            //       labelText: 'Counterparty (who you lent/borrowed to/from)',
            //       labelStyle: TextStyle(color: Colors.grey),
            //       enabledBorder: OutlineInputBorder(
            //         borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderSide: BorderSide(
            //           color: ThemeProvider.getPrimaryColor(),
            //         ),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     onChanged: (v) => _counterparty = v,
            //   ),
            // ],

            // Voice Input Hint
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Try voice input or image upload for faster entry!',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
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

                      final amount = double.parse(_amountController.text);
                      final transaction = Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _titleController.text,
                        categoryId: _selectedCategoryId!,
                        amount: amount,
                        date: _selectedDate,
                        type: _selectedType,
                        isScheduled: _isScheduled,
                        scheduledDate: _scheduledDate,
                        isLoan: _isLoan,
                        counterparty: _isLoan ? _counterparty : null,
                        loanDirection: _isLoan ? _loanDirection : null,
                        // Immediate (non-scheduled) non-loan transactions are settled immediately.
                        // Scheduled transactions must remain unsettled until user confirmation.
                        isSettled: !_isLoan && !_isScheduled,
                        inputCurrency: _inputCurrency,
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
    );
  }

  Widget _buildVoiceInputMode() {
    return VoiceInputWidget(
      onTransactionAdded: (transactionData) {
        // Convert TransactionData to Transaction
        final categoryId = _getSuggestedCategoryId(
          transactionData.category,
          transactionData.type,
        );

        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: transactionData.description,
          amount: transactionData.amount,
          categoryId: categoryId,
          date: DateTime.now(),
          type:
              transactionData.type == 'income'
                  ? TransactionType.income
                  : TransactionType.expense,
          isScheduled: false,
          isLoan: false,
          isSettled: true,
        );

        widget.onAddTransaction(transaction);
        Navigator.pop(context);
      },
      onClose: () {
        setState(() {
          _isVoiceMode = false;
        });
      },
      showBackButton: true,
    );
  }

  Widget _buildImageInputMode() {
    return ImageInputWidget(
      onTransactionsExtracted: (transactions) {
        // Add all extracted transactions
        for (var transactionData in transactions) {
          final categoryId = _getSuggestedCategoryId(
            transactionData.category,
            transactionData.type,
          );

          final transaction = Transaction(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                transactions.indexOf(transactionData).toString(),
            title: transactionData.description,
            amount: transactionData.amount,
            categoryId: categoryId,
            date: DateTime.now(),
            type:
                transactionData.type == 'income'
                    ? TransactionType.income
                    : TransactionType.expense,
            isScheduled: false,
            isLoan: false,
            isSettled: true,
          );

          widget.onAddTransaction(transaction);
        }
        Navigator.pop(context);
      },
      onClose: () {
        setState(() {
          _isImageMode = false;
        });
      },
      showBackButton: true,
    );
  }

  String _getSuggestedCategoryId(String categoryName, String type) {
    final categories =
        type == 'income'
            ? CategoryManager.incomeCategories
            : CategoryManager.expenseCategories;

    // Try exact match first
    for (var category in categories) {
      if (category.name.toLowerCase() == categoryName.toLowerCase()) {
        return category.id;
      }
    }

    // Try partial match
    for (var category in categories) {
      if (category.name.toLowerCase().contains(categoryName.toLowerCase()) ||
          categoryName.toLowerCase().contains(category.name.toLowerCase())) {
        return category.id;
      }
    }

    // Return first category of the type as fallback
    return categories.isNotEmpty ? categories.first.id : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

class AddTransactionDialoge extends StatefulWidget {
  final Function(Transaction) onAddTransaction;

  const AddTransactionDialoge({super.key, required this.onAddTransaction});

  @override
  _AddTransactionDialogeState createState() => _AddTransactionDialogeState();
}

class _AddTransactionDialogeState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  final DateTime _selectedDate = DateTime.now();
  String _inputCurrency = 'USD'; // Currency for input (USD or UZS)

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
                            'Income',
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
                            'Expense',
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
                  labelText: 'Title',
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
                    return 'Please enter a title';
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
                  labelText: 'Amount',
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
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Currency Selector for Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(label: Text('USD'), value: 'USD'),
                      ButtonSegment(label: Text("so'm"), value: 'UZS'),
                    ],
                    selected: {_inputCurrency},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _inputCurrency = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                style: TextStyle(color: ThemeProvider.getTextColor()),
                decoration: InputDecoration(
                  labelText: 'Category',
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
                    return 'Please select a categoryy';
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
                          inputCurrency: _inputCurrency,
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
