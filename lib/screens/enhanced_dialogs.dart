// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// import '../functions/card_input_formatters.dart';
// import '../functions/category_managment.dart';
// import '../main.dart';
// import '../models/models.dart';
//
// class AddTransactionDialog extends StatefulWidget {
//   final Function(Transaction) onAddTransaction;
//   final TransactionType transactionType;
//
//   const AddTransactionDialog({
//     super.key,
//     required this.onAddTransaction,
//     required this.transactionType,
//   });
//
//   @override
//   _AddTransactionDialogState createState() => _AddTransactionDialogState();
// }
//
// class _AddTransactionDialogState extends State<AddTransactionDialog> {
//   final _titleController = TextEditingController();
//   final _amountController = TextEditingController();
//   final DateTime _selectedDate = DateTime.now();
//   String? _selectedCategoryId;
//
//   @override
//   Widget build(BuildContext context) {
//     List<Category> categories =
//     widget.transactionType == TransactionType.income
//         ? CategoryManager.incomeCategories
//         : CategoryManager.expenseCategories;
//
//     return AlertDialog(
//       backgroundColor: ThemeProvider.getCardColor(),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: (widget.transactionType == TransactionType.income
//                   ? Colors.green
//                   : Colors.red)
//                   .withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               widget.transactionType == TransactionType.income
//                   ? Icons.add_circle
//                   : Icons.remove_circle,
//               color:
//               widget.transactionType == TransactionType.income
//                   ? Colors.green
//                   : Colors.red,
//             ),
//           ),
//           SizedBox(width: 12),
//           Text(
//             'Add ${widget.transactionType == TransactionType.income ? 'Income' : 'Expense'}',
//             style: TextStyle(
//               color: ThemeProvider.getTextColor(),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _titleController,
//               style: TextStyle(color: ThemeProvider.getTextColor()),
//               decoration: InputDecoration(
//                 labelText: 'Title',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.title, color: Colors.grey),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//
//             DropdownButtonFormField<String>(
//               value: _selectedCategoryId,
//               decoration: InputDecoration(
//                 labelText: 'Category',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.category, color: Colors.grey),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               dropdownColor: ThemeProvider.getCardColor(),
//               style: TextStyle(color: ThemeProvider.getTextColor()),
//               items:
//               categories.map((Category category) {
//                 return DropdownMenuItem<String>(
//                   value: category.id,
//                   child: Row(
//                     children: [
//                       Icon(category.icon, size: 20, color: category.color),
//                       SizedBox(width: 8),
//                       Text(category.name),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedCategoryId = newValue;
//                 });
//               },
//             ),
//             SizedBox(height: 16),
//
//             TextField(
//               controller: _amountController,
//               style: TextStyle(color: ThemeProvider.getTextColor()),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//               ],
//               decoration: InputDecoration(
//                 labelText: 'Amount',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.attach_money, color: Colors.grey),
//                 prefixText: '\$',
//                 prefixStyle: TextStyle(color: ThemeProvider.getTextColor()),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_titleController.text.isNotEmpty &&
//                 _amountController.text.isNotEmpty &&
//                 _selectedCategoryId != null) {
//               final transaction = Transaction(
//                 id: DateTime.now().millisecondsSinceEpoch.toString(),
//                 title: _titleController.text,
//                 categoryId: _selectedCategoryId!,
//                 amount:
//                 widget.transactionType == TransactionType.income
//                     ? double.parse(_amountController.text)
//                     : -double.parse(_amountController.text),
//                 date: _selectedDate,
//                 type: widget.transactionType,
//               );
//               widget.onAddTransaction(transaction);
//               Navigator.pop(context);
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Transaction added successfully'),
//                   backgroundColor:
//                   widget.transactionType == TransactionType.income
//                       ? Colors.green
//                       : Colors.red,
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Please fill all fields'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//             widget.transactionType == TransactionType.income
//                 ? Colors.green
//                 : Colors.red,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text('Add Transaction', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
// }
//
// class AddCardDialog extends StatefulWidget {
//   final Function(CreditCard) onAddCard;
//
//   const AddCardDialog({super.key, required this.onAddCard});
//
//   @override
//   _AddCardDialogState createState() => _AddCardDialogState();
// }
//
// class _AddCardDialogState extends State<AddCardDialog> {
//   final _cardNumberController = TextEditingController();
//   final _cardHolderController = TextEditingController();
//   final _expiryController = TextEditingController();
//   final _cvvController = TextEditingController();
//   final _balanceController = TextEditingController();
//   String _selectedCardType = 'VISA';
//   bool _isMain = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // Add listeners for real-time updates
//     _cardNumberController.addListener(() => setState(() {}));
//     _cardHolderController.addListener(() => setState(() {}));
//     _expiryController.addListener(() => setState(() {}));
//   }
//
//   // Real-time preview card
//   Widget _buildCardPreview() {
//     return Container(
//       width: double.infinity,
//       height: 200,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: ThemeProvider.getCardGradient(true),
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 15,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 _selectedCardType,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.credit_card, color: Colors.white, size: 24),
//               ),
//             ],
//           ),
//           Text(
//             _cardNumberController.text.isEmpty
//                 ? '****  ****  ****  ****'
//                 : _cardNumberController.text,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               letterSpacing: 2,
//               fontFamily: 'monospace',
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'CARD HOLDER',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     _cardHolderController.text.isEmpty
//                         ? 'YOUR NAME'
//                         : _cardHolderController.text.toUpperCase(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'EXPIRES',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     _expiryController.text.isEmpty
//                         ? '**/**'
//                         : _expiryController.text,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'monospace',
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: ThemeProvider.getCardColor(),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.credit_card, color: Colors.blue),
//           ),
//           SizedBox(width: 12),
//           Text(
//             'Add New Card',
//             style: TextStyle(
//               color: ThemeProvider.getTextColor(),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildCardPreview(),
//             SizedBox(height: 24),
//
//             DropdownButtonFormField<String>(
//               value: _selectedCardType,
//               decoration: InputDecoration(
//                 labelText: 'Card Type',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.credit_card, color: Colors.grey),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               dropdownColor: ThemeProvider.getCardColor(),
//               style: TextStyle(color: ThemeProvider.getTextColor()),
//               items:
//               ['VISA', 'MASTERCARD', 'AMERICAN EXPRESS'].map((
//                   String value,
//                   ) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedCardType = newValue!;
//                 });
//               },
//             ),
//             SizedBox(height: 16),
//
//             TextField(
//               controller: _cardNumberController,
//               style: TextStyle(
//                 color: ThemeProvider.getTextColor(),
//                 fontFamily: 'monospace',
//                 fontSize: 16,
//               ),
//               keyboardType: TextInputType.number,
//               maxLength: 19, // 16 digits + 3 spaces
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(16),
//                 CardNumberInputFormatter(),
//               ],
//               decoration: InputDecoration(
//                 labelText: 'Card Number',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.numbers, color: Colors.grey),
//                 counterText: '',
//                 hintText: '1234  5678  9012  3456',
//                 hintStyle: TextStyle(color: Colors.grey[400]),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//
//             TextField(
//               controller: _cardHolderController,
//               style: TextStyle(color: ThemeProvider.getTextColor()),
//               textCapitalization: TextCapitalization.characters,
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
//                 LengthLimitingTextInputFormatter(26),
//                 UpperCaseTextFormatter(),
//               ],
//               decoration: InputDecoration(
//                 labelText: 'Card Holder Name',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.person, color: Colors.grey),
//                 hintText: 'JOHN SMITH',
//                 hintStyle: TextStyle(color: Colors.grey[400]),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _expiryController,
//                     style: TextStyle(
//                       color: ThemeProvider.getTextColor(),
//                       fontFamily: 'monospace',
//                     ),
//                     keyboardType: TextInputType.number,
//                     maxLength: 5, // MM/YY
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(4),
//                       ExpiryDateInputFormatter(),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'Expiry Date',
//                       labelStyle: TextStyle(color: Colors.grey),
//                       prefixIcon: Icon(
//                         Icons.calendar_today,
//                         color: Colors.grey,
//                       ),
//                       counterText: '',
//                       hintText: 'MM/YY',
//                       hintStyle: TextStyle(color: Colors.grey[400]),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.withOpacity(0.3),
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: TextField(
//                     controller: _cvvController,
//                     style: TextStyle(
//                       color: ThemeProvider.getTextColor(),
//                       fontFamily: 'monospace',
//                     ),
//                     keyboardType: TextInputType.number,
//                     maxLength: 4,
//                     obscureText: true,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(4),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'CVV',
//                       labelStyle: TextStyle(color: Colors.grey),
//                       prefixIcon: Icon(Icons.lock, color: Colors.grey),
//                       counterText: '',
//                       hintText: '123',
//                       hintStyle: TextStyle(color: Colors.grey[400]),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.grey.withOpacity(0.3),
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//
//             TextField(
//               controller: _balanceController,
//               style: TextStyle(color: ThemeProvider.getTextColor()),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//               ],
//               decoration: InputDecoration(
//                 labelText: 'Initial Balance',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(
//                   Icons.account_balance_wallet,
//                   color: Colors.grey,
//                 ),
//                 prefixText: '\$',
//                 prefixStyle: TextStyle(color: ThemeProvider.getTextColor()),
//                 hintText: '0.00',
//                 hintStyle: TextStyle(color: Colors.grey[400]),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.blue, size: 20),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Set as main card',
//                       style: TextStyle(
//                         color: ThemeProvider.getTextColor(),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   Switch(
//                     value: _isMain,
//                     onChanged: (value) {
//                       setState(() {
//                         _isMain = value;
//                       });
//                     },
//                     activeColor: Colors.blue,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_cardNumberController.text.length >=
//                 19 && // 16 digits + 3 spaces
//                 _cardHolderController.text.isNotEmpty &&
//                 _expiryController.text.length == 5 &&
//                 _cvvController.text.length >= 3) {
//               // Validate expiry date
//               final expiryParts = _expiryController.text.split('/');
//               if (expiryParts.length == 2) {
//                 final month = int.tryParse(expiryParts[0]);
//                 final year = int.tryParse(expiryParts[1]);
//
//                 if (month != null &&
//                     year != null &&
//                     month >= 1 &&
//                     month <= 12) {
//                   final card = CreditCard(
//                     id: DateTime.now().millisecondsSinceEpoch.toString(),
//                     cardNumber: _cardNumberController.text,
//                     cardHolderName: _cardHolderController.text.toUpperCase(),
//                     expiryDate: _expiryController.text,
//                     cvv: _cvvController.text,
//                     cardType: _selectedCardType,
//                     balance: double.tryParse(_balanceController.text) ?? 0.0,
//                     isMain: _isMain,
//                   );
//                   widget.onAddCard(card);
//                   Navigator.pop(context);
//
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Card added successfully'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                   return;
//                 }
//               }
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Please enter a valid expiry date (MM/YY)'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Please fill all fields correctly'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//           child: Text(
//             'Add Card',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _cardNumberController.dispose();
//     _cardHolderController.dispose();
//     _expiryController.dispose();
//     _cvvController.dispose();
//     _balanceController.dispose();
//     super.dispose();
//   }
// }
//
// class AddCategoryDialog extends StatefulWidget {
//   final Function(Category, bool) onAddCategory;
//
//   const AddCategoryDialog({super.key, required this.onAddCategory});
//
//   @override
//   _AddCategoryDialogState createState() => _AddCategoryDialogState();
// }
//
// class _AddCategoryDialogState extends State<AddCategoryDialog> {
//   final _nameController = TextEditingController();
//   bool _isIncome = true;
//   IconData _selectedIcon = Icons.category;
//   Color _selectedColor = Colors.blue;
//
//   final List<IconData> _availableIcons = [
//     Icons.category,
//     Icons.work,
//     Icons.business,
//     Icons.computer,
//     Icons.trending_up,
//     Icons.restaurant,
//     Icons.directions_car,
//     Icons.shopping_bag,
//     Icons.receipt,
//     Icons.movie,
//     Icons.local_hospital,
//     Icons.school,
//     Icons.home,
//     Icons.flight,
//     Icons.fitness_center,
//     Icons.pets,
//     Icons.music_note,
//     Icons.book,
//   ];
//
//   final List<Color> _availableColors = [
//     Colors.blue,
//     Colors.green,
//     Colors.red,
//     Colors.purple,
//     Colors.orange,
//     Colors.pink,
//     Colors.teal,
//     Colors.indigo,
//     Colors.amber,
//     Colors.cyan,
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: ThemeProvider.getCardColor(),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.add, color: Colors.green),
//           ),
//           SizedBox(width: 12),
//           Text(
//             'Add New Category',
//             style: TextStyle(
//               color: ThemeProvider.getTextColor(),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Category Preview
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _selectedColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: _selectedColor.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(_selectedIcon, color: _selectedColor, size: 24),
//                   SizedBox(width: 12),
//                   Text(
//                     _nameController.text.isEmpty
//                         ? 'Category Name'
//                         : _nameController.text,
//                     style: TextStyle(
//                       color: ThemeProvider.getTextColor(),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//
//             // Category Type
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => _isIncome = true),
//                     child: Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color:
//                         _isIncome
//                             ? Colors.green.withOpacity(0.1)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color:
//                           _isIncome
//                               ? Colors.green
//                               : Colors.grey.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add_circle, color: Colors.green, size: 20),
//                           SizedBox(width: 8),
//                           Text(
//                             'Income',
//                             style: TextStyle(
//                               color: ThemeProvider.getTextColor(),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => _isIncome = false),
//                     child: Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color:
//                         !_isIncome
//                             ? Colors.red.withOpacity(0.1)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color:
//                           !_isIncome
//                               ? Colors.red
//                               : Colors.grey.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.remove_circle,
//                             color: Colors.red,
//                             size: 20,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'Expense',
//                             style: TextStyle(
//                               color: ThemeProvider.getTextColor(),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//
//             // Category Name
//             TextField(
//               controller: _nameController,
//               style: TextStyle(color: ThemeProvider.getTextColor()),
//               onChanged: (value) => setState(() {}),
//               decoration: InputDecoration(
//                 labelText: 'Category Name',
//                 labelStyle: TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(Icons.edit, color: Colors.grey),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//
//             // Icon Selection
//             Text(
//               'Select Icon',
//               style: TextStyle(
//                 color: ThemeProvider.getTextColor(),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 8),
//             SizedBox(
//               height: 120,
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 6,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                 ),
//                 itemCount: _availableIcons.length,
//                 itemBuilder: (context, index) {
//                   IconData icon = _availableIcons[index];
//                   bool isSelected = icon == _selectedIcon;
//
//                   return GestureDetector(
//                     onTap: () => setState(() => _selectedIcon = icon),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color:
//                         isSelected
//                             ? Colors.blue.withOpacity(0.2)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color:
//                           isSelected
//                               ? Colors.blue
//                               : Colors.grey.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Icon(
//                         icon,
//                         color: isSelected ? Colors.blue : Colors.grey,
//                         size: 20,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16),
//
//             // Color Selection
//             Text(
//               'Select Color',
//               style: TextStyle(
//                 color: ThemeProvider.getTextColor(),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children:
//               _availableColors.map((color) {
//                 bool isSelected = color == _selectedColor;
//
//                 return GestureDetector(
//                   onTap: () => setState(() => _selectedColor = color),
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: color,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color:
//                         isSelected ? Colors.white : Colors.transparent,
//                         width: 3,
//                       ),
//                     ),
//                     child:
//                     isSelected
//                         ? Icon(
//                       Icons.check,
//                       color: Colors.white,
//                       size: 20,
//                     )
//                         : null,
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_nameController.text.isNotEmpty) {
//               final category = Category(
//                 id: DateTime.now().millisecondsSinceEpoch.toString(),
//                 name: _nameController.text,
//                 icon: _selectedIcon,
//                 color: _selectedColor,
//               );
//               widget.onAddCategory(category, _isIncome);
//               Navigator.pop(context);
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Category added successfully'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Please enter a category name'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//           child: Text(
//             'Add Category',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
// }