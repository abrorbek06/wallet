
//
// // Card Input Formatters
// class CardNumberInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     var text = newValue.text.replaceAll(' ', '');
//
//     if (text.length > 16) {
//       text = text.substring(0, 16);
//     }
//
//     var buffer = StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       var nonZeroIndex = i + 1;
//       if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
//         buffer.write('  ');
//       }
//     }
//
//     var string = buffer.toString();
//     return newValue.copyWith(
//       text: string,
//       selection: TextSelection.collapsed(offset: string.length),
//     );
//   }
// }
//
// class ExpiryDateInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     var text = newValue.text.replaceAll('/', '');
//
//     if (text.length > 4) {
//       text = text.substring(0, 4);
//     }
//
//     var buffer = StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       var nonZeroIndex = i + 1;
//       if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
//         buffer.write('/');
//       }
//     }
//
//     var string = buffer.toString();
//     return newValue.copyWith(
//       text: string,
//       selection: TextSelection.collapsed(offset: string.length),
//     );
//   }
// }
//
// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//
//   List<Transaction> transactions = [
//     Transaction(
//       id: '1',
//       title: 'Monthly Salary',
//       category: 'Income',
//       amount: 5000.00,
//       icon: Icons.work,
//       date: DateTime(2024, 1, 1),
//       type: TransactionType.income,
//     ),
//     Transaction(
//       id: '2',
//       title: 'Rent Payment',
//       category: 'Housing',
//       amount: -1500.00,
//       icon: Icons.home,
//       date: DateTime(2024, 1, 5),
//       type: TransactionType.expense,
//     ),
//     Transaction(
//       id: '3',
//       title: 'Grocery Shopping',
//       category: 'Food',
//       amount: -350.00,
//       icon: Icons.shopping_cart,
//       date: DateTime(2024, 1, 8),
//       type: TransactionType.expense,
//     ),
//   ];
//
//   List<CreditCard> cards = [
//     CreditCard(
//       id: '1',
//       cardNumber: '4532  1234  5678  9012',
//       cardHolderName: 'JOHN SMITH',
//       expiryDate: '12/28',
//       cvv: '123',
//       cardType: 'VISA',
//       balance: 8545.00,
//       isMain: true,
//     ),
//     CreditCard(
//       id: '2',
//       cardNumber: '5555  4444  3333  2222',
//       cardHolderName: 'JOHN SMITH',
//       expiryDate: '06/27',
//       cvv: '456',
//       cardType: 'MASTERCARD',
//       balance: 2340.50,
//       isMain: false,
//     ),
//   ];
//
//   double get currentBalance {
//     double balance = 0.0;
//     for (var transaction in transactions) {
//       balance += transaction.amount;
//     }
//     return balance;
//   }
//
//   List<FlSpot> get chartData {
//     List<FlSpot> spots = [];
//
//     // Calculate balance progression over 6 months
//     List<double> monthlyBalances = [
//       6500.0,  // Oct
//       7200.0,  // Nov
//       7800.0,  // Dec
//       currentBalance, // Jan (current)
//       currentBalance + 300, // Feb (projected)
//       currentBalance + 650, // Mar (projected)
//     ];
//
//     for (int i = 0; i < monthlyBalances.length; i++) {
//       spots.add(FlSpot(i.toDouble(), monthlyBalances[i]));
//     }
//     return spots;
//   }
//
//   void _addTransaction(Transaction transaction) {
//     setState(() {
//       transactions.insert(0, transaction);
//       // Update main card balance
//       if (cards.isNotEmpty) {
//         var mainCard = cards.firstWhere((card) => card.isMain, orElse: () => cards.first);
//         mainCard.balance += transaction.amount;
//       }
//     });
//   }
//
//   void _addCard(CreditCard card) {
//     setState(() {
//       if (card.isMain) {
//         for (var c in cards) {
//           c.isMain = false;
//         }
//       }
//       cards.add(card);
//     });
//   }
//
//   void _deleteCard(String cardId) {
//     setState(() {
//       cards.removeWhere((card) => card.id == cardId);
//       // If we deleted the main card, make the first remaining card main
//       if (cards.isNotEmpty && !cards.any((card) => card.isMain)) {
//         cards.first.isMain = true;
//       }
//     });
//   }
//
//   void _updateTheme(String theme) {
//     setState(() {
//       ThemeProvider.updateTheme(theme);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<String>(
//       valueListenable: ThemeProvider.themeNotifier,
//       builder: (context, theme, child) {
//         return Theme(
//           data: ThemeProvider.getTheme(theme),
//           child: Scaffold(
//             body: IndexedStack(
//               index: _selectedIndex,
//               children: [
//                 HomeScreen(
//                   transactions: transactions,
//                   cards: cards,
//                   onAddTransaction: _addTransaction,
//                 ),
//                 MyCardsScreen(
//                   cards: cards,
//                   onAddCard: _addCard,
//                   onDeleteCard: _deleteCard,
//                 ),
//                 StatisticsScreen(
//                   transactions: transactions,
//                   currentBalance: currentBalance,
//                   chartData: chartData,
//                 ),
//                 SettingsScreen(
//                   currentTheme: ThemeProvider.currentTheme,
//                   onThemeChanged: _updateTheme,
//                 ),
//               ],
//             ),
//             bottomNavigationBar: Container(
//               decoration: BoxDecoration(
//                 color: ThemeProvider.getBackgroundColor(),
//                 border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
//               ),
//               child: BottomNavigationBar(
//                 type: BottomNavigationBarType.fixed,
//                 backgroundColor: Colors.transparent,
//                 selectedItemColor: Colors.blue,
//                 unselectedItemColor: Colors.grey[600],
//                 currentIndex: _selectedIndex,
//                 elevation: 0,
//                 selectedFontSize: 12,
//                 unselectedFontSize: 12,
//                 onTap: (index) {
//                   setState(() {
//                     _selectedIndex = index;
//                   });
//                 },
//                 items: [
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.home_outlined),
//                     activeIcon: Icon(Icons.home),
//                     label: 'Home',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.credit_card_outlined),
//                     activeIcon: Icon(Icons.credit_card),
//                     label: 'My Cards',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.bar_chart_outlined),
//                     activeIcon: Icon(Icons.bar_chart),
//                     label: 'Statistics',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.settings_outlined),
//                     activeIcon: Icon(Icons.settings),
//                     label: 'Settings',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // Home Screen
// class HomeScreen extends StatefulWidget {
//   final List<Transaction> transactions;
//   final List<CreditCard> cards;
//   final Function(Transaction) onAddTransaction;
//
//   const HomeScreen({
//     Key? key,
//     required this.transactions,
//     required this.cards,
//     required this.onAddTransaction,
//   }) : super(key: key);
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   bool _showTransactions = true;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CreditCard mainCard = widget.cards.isNotEmpty
//         ? widget.cards.firstWhere((card) => card.isMain, orElse: () => widget.cards.first)
//         : CreditCard(
//       id: 'default',
//       cardNumber: '****  ****  ****  ****',
//       cardHolderName: 'NO CARD ADDED',
//       expiryDate: '**/**',
//       cvv: '***',
//       cardType: 'NONE',
//       balance: 0.0,
//       isMain: true,
//     );
//
//     return Scaffold(
//       backgroundColor: ThemeProvider.getBackgroundColor(),
//       appBar: AppBar(
//         backgroundColor: ThemeProvider.getBackgroundColor(),
//         title: Text('Home', style: TextStyle(color: ThemeProvider.getTextColor(), fontWeight: FontWeight.w600)),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _showTransactions ? Icons.visibility_off : Icons.visibility,
//               color: ThemeProvider.getTextColor(),
//             ),
//             onPressed: () {
//               setState(() {
//                 _showTransactions = !_showTransactions;
//               });
//             },
//             tooltip: _showTransactions ? 'Hide Transactions' : 'Show Transactions',
//           ),
//         ],
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Main Card Display
//               Hero(
//                 tag: 'main_card',
//                 child: Container(
//                   width: double.infinity,
//                   height: 220,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: ThemeProvider.getCardGradient(true),
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   padding: EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             mainCard.cardType,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(Icons.credit_card, color: Colors.white, size: 24),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         mainCard.cardNumber,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 22,
//                           letterSpacing: 2,
//                           fontFamily: 'monospace',
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'CARD HOLDER',
//                                 style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 mainCard.cardHolderName,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'EXPIRES',
//                                 style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 mainCard.expiryDate,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   fontFamily: 'monospace',
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'BALANCE',
//                                 style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 '\$${mainCard.balance.toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 32),
//
//               // Income/Expense Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       height: 56,
//                       child: ElevatedButton.icon(
//                         onPressed: () => _showAddTransactionDialog(context, TransactionType.income),
//                         icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
//                         label: Text(
//                           'Add Income',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green[600],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 4,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: Container(
//                       height: 56,
//                       child: ElevatedButton.icon(
//                         onPressed: () => _showAddTransactionDialog(context, TransactionType.expense),
//                         icon: Icon(Icons.remove_circle_outline, color: Colors.white, size: 24),
//                         label: Text(
//                           'Add Expense',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red[600],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 4,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               if (_showTransactions) ...[
//                 SizedBox(height: 32),
//
//                 // Transactions Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Recent Transactions',
//                       style: TextStyle(
//                         color: ThemeProvider.getTextColor(),
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '${widget.transactions.length} total',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//
//                 // Transactions List
//                 widget.transactions.isEmpty
//                     ? Container(
//                   padding: EdgeInsets.all(48),
//                   decoration: BoxDecoration(
//                     color: ThemeProvider.getCardColor(),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Icon(
//                           Icons.receipt_long,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'No transactions yet',
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Add your first transaction using the buttons above',
//                           style: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 14,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                     : ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: widget.transactions.length,
//                   itemBuilder: (context, index) {
//                     final transaction = widget.transactions[index];
//                     return Container(
//                       margin: EdgeInsets.only(bottom: 12),
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: ThemeProvider.getCardColor(),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: transaction.amount > 0
//                               ? Colors.green.withOpacity(0.3)
//                               : Colors.red.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 56,
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: (transaction.amount > 0 ? Colors.green : Colors.red).withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Icon(
//                               transaction.icon,
//                               color: transaction.amount > 0 ? Colors.green[600] : Colors.red[600],
//                               size: 28,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   transaction.title,
//                                   style: TextStyle(
//                                     color: ThemeProvider.getTextColor(),
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   transaction.category,
//                                   style: TextStyle(
//                                     color: Colors.grey[400],
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 SizedBox(height: 2),
//                                 Text(
//                                   '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
//                                   style: TextStyle(
//                                     color: Colors.grey[500],
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 '${transaction.amount > 0 ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                   color: transaction.amount > 0 ? Colors.green[600] : Colors.red[600],
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: (transaction.amount > 0 ? Colors.green : Colors.red).withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   transaction.amount > 0 ? 'Income' : 'Expense',
//                                   style: TextStyle(
//                                     color: transaction.amount > 0 ? Colors.green[600] : Colors.red[600],
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showAddTransactionDialog(BuildContext context, TransactionType type) {
//     showDialog(
//       context: context,
//       builder: (context) => AddTransactionDialog(
//         onAddTransaction: widget.onAddTransaction,
//         transactionType: type,
//       ),
//     );
//   }
// }
//
// // My Cards Screen
// class MyCardsScreen extends StatefulWidget {
//   final List<CreditCard> cards;
//   final Function(CreditCard) onAddCard;
//   final Function(String) onDeleteCard;
//
//   const MyCardsScreen({
//     Key? key,
//     required this.cards,
//     required this.onAddCard,
//     required this.onDeleteCard,
//   }) : super(key: key);
//
//   @override
//   _MyCardsScreenState createState() => _MyCardsScreenState();
// }
//
// class _MyCardsScreenState extends State<MyCardsScreen> with TickerProviderStateMixin {
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeProvider.getBackgroundColor(),
//       appBar: AppBar(
//         backgroundColor: ThemeProvider.getBackgroundColor(),
//         title: Text(
//           'My Cards',
//           style: TextStyle(
//             color: ThemeProvider.getTextColor(),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.add, color: Colors.blue),
//             ),
//             onPressed: () => _showAddCardDialog(context),
//             tooltip: 'Add New Card',
//           ),
//           SizedBox(width: 8),
//         ],
//       ),
//       body: widget.cards.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.credit_card_off,
//               size: 80,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 24),
//             Text(
//               'No cards added yet',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Add your first card to get started',
//               style: TextStyle(
//                 color: Colors.grey[500],
//                 fontSize: 14,
//               ),
//             ),
//             SizedBox(height: 32),
//             ElevatedButton.icon(
//               onPressed: () => _showAddCardDialog(context),
//               icon: Icon(Icons.add),
//               label: Text('Add Your First Card'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       )
//           : ListView.builder(
//         padding: EdgeInsets.all(20),
//         itemCount: widget.cards.length,
//         itemBuilder: (context, index) {
//           final card = widget.cards[index];
//           return AnimatedBuilder(
//             animation: _animationController,
//             builder: (context, child) {
//               return SlideTransition(
//                 position: Tween<Offset>(
//                   begin: Offset(0, 0.3),
//                   end: Offset.zero,
//                 ).animate(CurvedAnimation(
//                   parent: _animationController,
//                   curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
//                 )),
//                 child: FadeTransition(
//                   opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
//                     CurvedAnimation(
//                       parent: _animationController,
//                       curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
//                     ),
//                   ),
//                   child: Container(
//                     margin: EdgeInsets.only(bottom: 20),
//                     child: Stack(
//                       children: [
//                         Container(
//                           width: double.infinity,
//                           height: 220,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: ThemeProvider.getCardGradient(card.isMain),
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 15,
//                                 offset: Offset(0, 8),
//                               ),
//                             ],
//                           ),
//                           padding: EdgeInsets.all(24),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     card.cardType,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1.2,
//                                     ),
//                                   ),
//                                   Row(
//                                     children: [
//                                       if (card.isMain)
//                                         Container(
//                                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white.withOpacity(0.25),
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: Text(
//                                             'MAIN',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.bold,
//                                               letterSpacing: 1,
//                                             ),
//                                           ),
//                                         ),
//                                       SizedBox(width: 8),
//                                       Container(
//                                         padding: EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.2),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: Icon(Icons.credit_card, color: Colors.white, size: 24),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 card.cardNumber,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 22,
//                                   letterSpacing: 2,
//                                   fontFamily: 'monospace',
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'CARD HOLDER',
//                                         style: TextStyle(
//                                           color: Colors.white70,
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         card.cardHolderName,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'EXPIRES',
//                                         style: TextStyle(
//                                           color: Colors.white70,
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         card.expiryDate,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           fontFamily: 'monospace',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text(
//                                         'BALANCE',
//                                         style: TextStyle(
//                                           color: Colors.white70,
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         '\$${card.balance.toStringAsFixed(2)}',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         Positioned(
//                           top: 12,
//                           right: 12,
//                           child: IconButton(
//                             icon: Container(
//                               padding: EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Icon(Icons.delete, color: Colors.white, size: 20),
//                             ),
//                             onPressed: () => _showDeleteConfirmation(context, card),
//                             tooltip: 'Delete Card',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   void _showAddCardDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AddCardDialog(
//         onAddCard: widget.onAddCard,
//       ),
//     );
//   }
//
//   void _showDeleteConfirmation(BuildContext context, CreditCard card) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: ThemeProvider.getCardColor(),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           'Delete Card',
//           style: TextStyle(
//             color: ThemeProvider.getTextColor(),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.warning_amber_rounded,
//               color: Colors.orange,
//               size: 48,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Are you sure you want to delete this card?',
//               style: TextStyle(
//                 color: ThemeProvider.getTextColor(),
//                 fontSize: 16,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 8),
//             Text(
//               card.cardNumber,
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 14,
//                 fontFamily: 'monospace',
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey[400]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               widget.onDeleteCard(card.id);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Card deleted successfully'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'Delete',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Statistics Screen
// class StatisticsScreen extends StatefulWidget {
//   final List<Transaction> transactions;
//   final double currentBalance;
//   final List<FlSpot> chartData;
//
//   const StatisticsScreen({
//     Key? key,
//     required this.transactions,
//     required this.currentBalance,
//     required this.chartData,
//   }) : super(key: key);
//
//   @override
//   _StatisticsScreenState createState() => _StatisticsScreenState();
// }
//
// class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
//   bool _showChart = true;
//   bool _showTransactions = true;
//   List<String> months = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
//   int selectedMonthIndex = 3;
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   double get totalIncome {
//     return widget.transactions
//         .where((t) => t.amount > 0)
//         .fold(0.0, (sum, t) => sum + t.amount);
//   }
//
//   double get totalExpenses {
//     return widget.transactions
//         .where((t) => t.amount < 0)
//         .fold(0.0, (sum, t) => sum + t.amount.abs());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeProvider.getBackgroundColor(),
//       appBar: AppBar(
//         backgroundColor: ThemeProvider.getBackgroundColor(),
//         title: Text(
//           'Statistics',
//           style: TextStyle(
//             color: ThemeProvider.getTextColor(),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           PopupMenuButton<String>(
//             icon: Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.more_vert, color: Colors.blue),
//             ),
//             color: ThemeProvider.getCardColor(),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             onSelected: (value) {
//               setState(() {
//                 if (value == 'chart') {
//                   _showChart = !_showChart;
//                 } else if (value == 'transactions') {
//                   _showTransactions = !_showTransactions;
//                 }
//               });
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'chart',
//                 child: Row(
//                   children: [
//                     Icon(
//                       _showChart ? Icons.visibility_off : Icons.visibility,
//                       color: ThemeProvider.getTextColor(),
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       _showChart ? 'Hide Chart' : 'Show Chart',
//                       style: TextStyle(color: ThemeProvider.getTextColor()),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: 'transactions',
//                 child: Row(
//                   children: [
//                     Icon(
//                       _showTransactions ? Icons.visibility_off : Icons.visibility,
//                       color: ThemeProvider.getTextColor(),
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       _showTransactions ? 'Hide Transactions' : 'Show Transactions',
//                       style: TextStyle(color: ThemeProvider.getTextColor()),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(width: 8),
//         ],
//       ),
//       body: FadeTransition(
//         opacity: _animationController,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Balance Overview
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: ThemeProvider.getCardGradient(true),
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Current Balance',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       '\$${widget.currentBalance.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 42,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 24),
//
//               // Income/Expense Summary
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.green.withOpacity(0.3)),
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(Icons.trending_up, color: Colors.green[600], size: 32),
//                           SizedBox(height: 8),
//                           Text(
//                             'Total Income',
//                             style: TextStyle(
//                               color: Colors.green[600],
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             '\$${totalIncome.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               color: ThemeProvider.getTextColor(),
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.red.withOpacity(0.3)),
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(Icons.trending_down, color: Colors.red[600], size: 32),
//                           SizedBox(height: 8),
//                           Text(
//                             'Total Expenses',
//                             style: TextStyle(
//                               color: Colors.red[600],
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             '\$${totalExpenses.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               color: ThemeProvider.getTextColor(),
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               if (_showChart) ...[
//                 SizedBox(height: 32),
//
//                 // Chart Section Title
//                 Text(
//                   'Balance Trend',
//                   style: TextStyle(
//                     color: ThemeProvider.getTextColor(),
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 16),
//
//                 // Chart Container (Invisible Frame - ClipRect contains the chart)
//                 Container(
//                   width: double.infinity,
//                   height: 250,
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: ThemeProvider.getCardColor(),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ClipRect(
//                     child: LineChart(
//                       LineChartData(
//                         gridData: FlGridData(
//                           show: true,
//                           drawVerticalLine: false,
//                           horizontalInterval: 1000,
//                           getDrawingHorizontalLine: (value) {
//                             return FlLine(
//                               color: Colors.grey.withOpacity(0.2),
//                               strokeWidth: 1,
//                             );
//                           },
//                         ),
//                         titlesData: FlTitlesData(
//                           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         ),
//                         borderData: FlBorderData(show: false),
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: widget.chartData,
//                             isCurved: true,
//                             color: Colors.blue,
//                             barWidth: 4,
//                             dotData: FlDotData(
//                               show: true,
//                               getDotPainter: (spot, percent, barData, index) {
//                                 if (index == selectedMonthIndex) {
//                                   return FlDotCirclePainter(
//                                     radius: 8,
//                                     color: Colors.white,
//                                     strokeWidth: 4,
//                                     strokeColor: Colors.blue,
//                                   );
//                                 }
//                                 return FlDotCirclePainter(
//                                   radius: 4,
//                                   color: Colors.blue,
//                                 );
//                               },
//                             ),
//                             belowBarData: BarAreaData(
//                               show: true,
//                               color: Colors.blue.withOpacity(0.1),
//                             ),
//                           ),
//                         ],
//                         minX: 0,
//                         maxX: 5,
//                         minY: widget.chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 500,
//                         maxY: widget.chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 500,
//                         clipData: FlClipData.all(), // This ensures chart doesn't exceed bounds
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Month Selection
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: months.asMap().entries.map((entry) {
//                     int index = entry.key;
//                     String month = entry.value;
//                     bool isSelected = index == selectedMonthIndex;
//
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedMonthIndex = index;
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: Duration(milliseconds: 200),
//                         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: isSelected ? Colors.blue : Colors.transparent,
//                           borderRadius: BorderRadius.circular(25),
//                           border: Border.all(
//                             color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
//                             width: 1,
//                           ),
//                         ),
//                         child: Text(
//                           month,
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.grey[400],
//                             fontSize: 14,
//                             fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//
//               if (_showTransactions) ...[
//                 SizedBox(height: 32),
//
//                 // Transactions Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'All Transactions',
//                       style: TextStyle(
//                         color: ThemeProvider.getTextColor(),
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '${widget.transactions.length} total',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//
//                 // Transactions List
//                 widget.transactions.isEmpty
//                     ? Container(
//                   padding: EdgeInsets.all(48),
//                   decoration: BoxDecoration(
//                     color: ThemeProvider.getCardColor(),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Icon(
//                           Icons.receipt_long,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'No transactions yet',
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Add transactions from the Home screen',
//                           style: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 14,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                     : ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: widget.transactions.length,
//                   itemBuilder: (context, index) {
//                     final transaction = widget.transactions[index];
//                     return Container(
//                       margin: EdgeInsets.only(bottom: 12),
//                       padding: EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: ThemeProvider.getCardColor(),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: transaction.amount > 0
//                               ? Colors.green.withOpacity(0.3)
//                               : Colors.red.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 56,
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: (transaction.amount > 0 ? Colors.green : Colors.red).withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Icon(
//                               transaction.icon,
//                               color: transaction.amount > 0 ? Colors.green[600] : Colors.red[600],
//                               size: 28,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   transaction.title,
//                                   style: TextStyle(
//                                     color: ThemeProvider.getTextColor(),
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   transaction.category,
//                                   style: TextStyle(
//                                     color: Colors.grey[400],
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 SizedBox(height: 2),
//                                 Text(
//                                   '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
//                                   style: TextStyle(
//                                     color: Colors.grey[500],
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 '${transaction.amount > 0 ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                   color: transaction.amount > 0 ? Colors.green[600] : Colors.red[600],
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Container(
//                                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: (transaction.amount > 0 ? Colors.green : Colors.red).withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   transaction.amount > 0 ? 'Income' : 'Expense',
//                                   style: TextStyle(
//                                     color: transaction.amount > 0 ? Colors.green[600] : Colors.red[600],
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Settings Screen
// class SettingsScreen extends StatelessWidget {
//   final String currentTheme;
//   final Function(String) onThemeChanged;
//
//   const SettingsScreen({
//     Key? key,
//     required this.currentTheme,
//     required this.onThemeChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeProvider.getBackgroundColor(),
//       appBar: AppBar(
//         backgroundColor: ThemeProvider.getBackgroundColor(),
//         title: Text(
//           'Settings',
//           style: TextStyle(
//             color: ThemeProvider.getTextColor(),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(20),
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: ThemeProvider.getCardColor(),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.palette,
//                       color: Colors.blue,
//                       size: 24,
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       'Theme Selection',
//                       style: TextStyle(
//                         color: ThemeProvider.getTextColor(),
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Choose your preferred app theme',
//                   style: TextStyle(
//                     color: Colors.grey[400],
//                     fontSize: 14,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 _buildThemeOption('Dark Theme', 'dark', Icons.dark_mode, Colors.grey[800]!),
//                 SizedBox(height: 12),
//                 _buildThemeOption('Light Theme', 'light', Icons.light_mode, Colors.orange),
//                 SizedBox(height: 12),
//                 _buildThemeOption('Blue Theme', 'blue', Icons.water_drop, Colors.blue),
//                 SizedBox(height: 12),
//                 _buildThemeOption('Green Theme', 'green', Icons.eco, Colors.green),
//                 SizedBox(height: 12),
//                 _buildThemeOption('Purple Theme', 'purple', Icons.auto_awesome, Colors.purple),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 24),
//
//           // App Info
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: ThemeProvider.getCardColor(),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: Colors.blue,
//                       size: 24,
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       'App Information',
//                       style: TextStyle(
//                         color: ThemeProvider.getTextColor(),
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 _buildInfoRow('Version', '1.0.0'),
//                 _buildInfoRow('Developer', 'Finance App Team'),
//                 _buildInfoRow('Last Updated', 'January 2024'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildThemeOption(String title, String value, IconData icon, Color iconColor) {
//     return GestureDetector(
//       onTap: () => onThemeChanged(value),
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: currentTheme == value
//               ? Colors.blue.withOpacity(0.1)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: currentTheme == value
//                 ? Colors.blue
//                 : Colors.grey.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(icon, color: iconColor, size: 20),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: ThemeProvider.getTextColor(),
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             Radio<String>(
//               value: value,
//               groupValue: currentTheme,
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   onThemeChanged(newValue);
//                 }
//               },
//               activeColor: Colors.blue,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 14,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: ThemeProvider.getTextColor(),
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Models
// enum TransactionType { income, expense }
//
// class Transaction {
//   final String id;
//   final String title;
//   final String category;
//   final double amount;
//   final IconData icon;
//   final DateTime date;
//   final TransactionType type;
//
//   Transaction({
//     required this.id,
//     required this.title,
//     required this.category,
//     required this.amount,
//     required this.icon,
//     required this.date,
//     required this.type,
//   });
// }
//
// class CreditCard {
//   final String id;
//   String cardNumber;
//   String cardHolderName;
//   String expiryDate;
//   String cvv;
//   String cardType;
//   double balance;
//   bool isMain;
//
//   CreditCard({
//     required this.id,
//     required this.cardNumber,
//     required this.cardHolderName,
//     required this.expiryDate,
//     required this.cvv,
//     required this.cardType,
//     required this.balance,
//     this.isMain = false,
//   });
// }
//
// // Dialogs
// class AddTransactionDialog extends StatefulWidget {
//   final Function(Transaction) onAddTransaction;
//   final TransactionType transactionType;
//
//   const AddTransactionDialog({
//     Key? key,
//     required this.onAddTransaction,
//     required this.transactionType,
//   }) : super(key: key);
//
//   @override
//   _AddTransactionDialogState createState() => _AddTransactionDialogState();
// }
//
// class _AddTransactionDialogState extends State<AddTransactionDialog> {
//   final _titleController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _amountController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//
//   final List<String> _incomeCategories = [
//     'Salary', 'Freelance', 'Investment', 'Business', 'Gift', 'Other'
//   ];
//
//   final List<String> _expenseCategories = [
//     'Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Education', 'Other'
//   ];
//
//   IconData _getIconForCategory(String category, TransactionType type) {
//     if (type == TransactionType.income) {
//       switch (category.toLowerCase()) {
//         case 'salary': return Icons.work;
//         case 'freelance': return Icons.computer;
//         case 'investment': return Icons.trending_up;
//         case 'business': return Icons.business;
//         case 'gift': return Icons.card_giftcard;
//         default: return Icons.attach_money;
//       }
//     } else {
//       switch (category.toLowerCase()) {
//         case 'food': return Icons.restaurant;
//         case 'transport': return Icons.directions_car;
//         case 'shopping': return Icons.shopping_bag;
//         case 'bills': return Icons.receipt;
//         case 'entertainment': return Icons.movie;
//         case 'health': return Icons.local_hospital;
//         case 'education': return Icons.school;
//         default: return Icons.shopping_cart;
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> categories = widget.transactionType == TransactionType.income
//         ? _incomeCategories
//         : _expenseCategories;
//
//     return AlertDialog(
//       backgroundColor: ThemeProvider.getCardColor(),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: (widget.transactionType == TransactionType.income ? Colors.green : Colors.red).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               widget.transactionType == TransactionType.income ? Icons.add_circle : Icons.remove_circle,
//               color: widget.transactionType == TransactionType.income ? Colors.green : Colors.red,
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
//               items: categories.map((String category) {
//                 return DropdownMenuItem<String>(
//                   value: category,
//                   child: Row(
//                     children: [
//                       Icon(
//                         _getIconForCategory(category, widget.transactionType),
//                         size: 20,
//                         color: Colors.grey,
//                       ),
//                       SizedBox(width: 8),
//                       Text(category),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _categoryController.text = newValue ?? '';
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
//           child: Text(
//             'Cancel',
//             style: TextStyle(color: Colors.grey[400]),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_titleController.text.isNotEmpty &&
//                 _amountController.text.isNotEmpty &&
//                 _categoryController.text.isNotEmpty) {
//               final transaction = Transaction(
//                 id: DateTime.now().millisecondsSinceEpoch.toString(),
//                 title: _titleController.text,
//                 category: _categoryController.text,
//                 amount: widget.transactionType == TransactionType.income
//                     ? double.parse(_amountController.text)
//                     : -double.parse(_amountController.text),
//                 icon: _getIconForCategory(_categoryController.text, widget.transactionType),
//                 date: _selectedDate,
//                 type: widget.transactionType,
//               );
//               widget.onAddTransaction(transaction);
//               Navigator.pop(context);
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Transaction added successfully'),
//                   backgroundColor: widget.transactionType == TransactionType.income ? Colors.green : Colors.red,
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
//             backgroundColor: widget.transactionType == TransactionType.income ? Colors.green : Colors.red,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(
//             'Add Transaction',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _categoryController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
// }
//
// class AddCardDialog extends StatefulWidget {
//   final Function(CreditCard) onAddCard;
//
//   const AddCardDialog({Key? key, required this.onAddCard}) : super(key: key);
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
//             _cardNumberController.text.isEmpty ? '****  ****  ****  ****' : _cardNumberController.text,
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
//                     _cardHolderController.text.isEmpty ? 'YOUR NAME' : _cardHolderController.text.toUpperCase(),
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
//                     _expiryController.text.isEmpty ? '**/**' : _expiryController.text,
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
//               items: ['VISA', 'MASTERCARD', 'AMERICAN EXPRESS'].map((String value) {
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
//                       prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
//                       counterText: '',
//                       hintText: 'MM/YY',
//                       hintStyle: TextStyle(color: Colors.grey[400]),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
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
//                         borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
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
//                 prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.grey),
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
//           child: Text(
//             'Cancel',
//             style: TextStyle(color: Colors.grey[400]),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_cardNumberController.text.length >= 19 && // 16 digits + 3 spaces
//                 _cardHolderController.text.isNotEmpty &&
//                 _expiryController.text.length == 5 &&
//                 _cvvController.text.length >= 3) {
//
//               // Validate expiry date
//               final expiryParts = _expiryController.text.split('/');
//               if (expiryParts.length == 2) {
//                 final month = int.tryParse(expiryParts[0]);
//                 final year = int.tryParse(expiryParts[1]);
//
//                 if (month != null && year != null && month >= 1 && month <= 12) {
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
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
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
// // Additional Input Formatter for uppercase text
// class UpperCaseTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     return TextEditingValue(
//       text: newValue.text.toUpperCase(),
//       selection: newValue.selection,
//     );
//   }
// }