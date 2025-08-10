// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../functions/card_input_formatters.dart';
// import '../main.dart';
// import '../models/models.dart';
// import 'main_screen.dart';
//
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
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.credit_card_off,
//                     size: 80,
//                     color: Colors.grey[400],
//                   ),
//                   SizedBox(height: 24),
//                   Text(
//                     'No cards added yet',
//                     style: TextStyle(
//                       color: Colors.grey[400],
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Add your first card to get started',
//                     style: TextStyle(
//                       color: Colors.grey[500],
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 32),
//                   ElevatedButton.icon(
//                     onPressed: () => _showAddCardDialog(context),
//                     icon: Icon(Icons.add),
//                     label: Text('Add Your First Card'),
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding: EdgeInsets.all(20),
//               itemCount: widget.cards.length,
//               itemBuilder: (context, index) {
//                 final card = widget.cards[index];
//                 return AnimatedBuilder(
//                   animation: _animationController,
//                   builder: (context, child) {
//                     return SlideTransition(
//                       position: Tween<Offset>(
//                         begin: Offset(0, 0.3),
//                         end: Offset.zero,
//                       ).animate(CurvedAnimation(
//                         parent: _animationController,
//                         curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
//                       )),
//                       child: FadeTransition(
//                         opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
//                           CurvedAnimation(
//                             parent: _animationController,
//                             curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
//                           ),
//                         ),
//                         child: Container(
//                           margin: EdgeInsets.only(bottom: 20),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 width: double.infinity,
//                                 height: 220,
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: ThemeProvider.getCardGradient(card.isMain),
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(20),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.3),
//                                       blurRadius: 15,
//                                       offset: Offset(0, 8),
//                                     ),
//                                   ],
//                                 ),
//                                 padding: EdgeInsets.all(24),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           card.cardType,
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             letterSpacing: 1.2,
//                                           ),
//                                         ),
//                                         Row(
//                                           children: [
//                                             if (card.isMain)
//                                               Container(
//                                                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white.withOpacity(0.25),
//                                                   borderRadius: BorderRadius.circular(12),
//                                                 ),
//                                                 child: Text(
//                                                   'MAIN',
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 10,
//                                                     fontWeight: FontWeight.bold,
//                                                     letterSpacing: 1,
//                                                   ),
//                                                 ),
//                                               ),
//                                             SizedBox(width: 8),
//                                             Container(
//                                               padding: EdgeInsets.all(8),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white.withOpacity(0.2),
//                                                 borderRadius: BorderRadius.circular(8),
//                                               ),
//                                               child: Icon(Icons.credit_card, color: Colors.white, size: 24),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     Text(
//                                       card.cardNumber,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 22,
//                                         letterSpacing: 2,
//                                         fontFamily: 'monospace',
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'CARD HOLDER',
//                                               style: TextStyle(
//                                                 color: Colors.white70,
//                                                 fontSize: 11,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                             SizedBox(height: 4),
//                                             Text(
//                                               card.cardHolderName,
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'EXPIRES',
//                                               style: TextStyle(
//                                                 color: Colors.white70,
//                                                 fontSize: 11,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                             SizedBox(height: 4),
//                                             Text(
//                                               card.expiryDate,
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontFamily: 'monospace',
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.end,
//                                           children: [
//                                             Text(
//                                               'BALANCE',
//                                               style: TextStyle(
//                                                 color: Colors.white70,
//                                                 fontSize: 11,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                             SizedBox(height: 4),
//                                             Text(
//                                               '\$${card.balance.toStringAsFixed(2)}',
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 12,
//                                 right: 12,
//                                 child: IconButton(
//                                   icon: Container(
//                                     padding: EdgeInsets.all(6),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red.withOpacity(0.2),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Icon(Icons.delete, color: Colors.white, size: 20),
//                                   ),
//                                   onPressed: () => _showDeleteConfirmation(context, card),
//                                   tooltip: 'Delete Card',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
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