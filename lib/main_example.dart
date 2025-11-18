/// main.dart Integration Example
/// This shows the complete setup for shared database + callback server
library;

import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'services/shared_database_server.dart';
import 'services/telegram_callback_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start shared database server (bot reads/writes transactions here)
  // Port 5003
  final dbServer = SharedDatabaseServer();
  await dbServer.start(port: 5003);
  print('[App] Shared database server started on port 5003');

  // Start callback server for real-time push from bot
  // Port 5002
  final callbackServer = TelegramCallbackServer(
    onReceived: (transaction) {
      print('[App] Received transaction from bot: ${transaction.title}');
      // UI will be notified by the callback server (SnackBar, etc.)
    },
  );
  await callbackServer.start(port: 5002);
  print('[App] Callback server started on port 5002');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

/// Bot Configuration (.env)
/// DATABASE_URL=http://127.0.0.1:5003  # Reads/writes transactions
/// APP_CALLBACK_URL=http://127.0.0.1:5002/telegram  # Push notifications
/// TELEGRAM_BOT_TOKEN=your_token
/// EXCHANGE_RATE=11500
