// Example: How to use SharedDatabaseServer in your Flutter app
//
// This enables the bot to read/write to the app's SharedPreferences database
// via HTTP API. Both app and bot will use the same transaction data.

// In main.dart:
/*
import 'package:wallet/services/shared_database_server.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start shared database server so bot can access app's data
  _initSharedDatabase();
  
  runApp(const MyApp());
}

Future<void> _initSharedDatabase() async {
  final dbServer = SharedDatabaseServer();
  
  try {
    final port = await dbServer.start(port: 5003);
    print('[App] Shared database server started on port $port');
    // Bot will use this to read/write transactions from .env:
    // DATABASE_URL=http://127.0.0.1:5003
  } catch (e) {
    print('[App] Failed to start database server: $e');
  }
}
*/

// In HomeScreen.initState():
/*
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedDatabaseServer dbServer;

  @override
  void initState() {
    super.initState();
    _initSharedDatabase();
  }

  Future<void> _initSharedDatabase() async {
    dbServer = SharedDatabaseServer();

    try {
      await dbServer.start(port: 5003);
      print('[HomeScreen] Shared database running on port 5003');
      
      // Verify bot can access it
      _testDatabaseConnection();
    } catch (e) {
      print('[HomeScreen] Database server error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database error: $e')),
      );
    }
  }

  Future<void> _testDatabaseConnection() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5003/health'),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        print('[HomeScreen] Database server is healthy');
      }
    } catch (e) {
      print('[HomeScreen] Database health check failed: $e');
    }
  }

  @override
  void dispose() {
    // Stop server on app exit
    dbServer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Shared Database: Port ${dbServer.listeningPort ?? "N/A"}'),
            Text(dbServer.isRunning ? '✅ Running' : '❌ Stopped'),
            const SizedBox(height: 20),
            Text(
              'Bot can now access this database via:\n'
              'DATABASE_URL=http://127.0.0.1:5003',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
*/

// Bot Setup (.env file):
/*
TELEGRAM_BOT_TOKEN=your_token_here
EXCHANGE_RATE=11500
DATABASE_URL=http://127.0.0.1:5003
APP_CALLBACK_URL=http://127.0.0.1:5002/telegram
*/

// Ports Summary:
// - 5001: Bot's Flask API (proxy to database)
// - 5002: App's Callback Server (receives push from bot)
// - 5003: App's Shared Database Server (bot reads/writes transactions)

// Data Flow with Shared Database:
/*
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter Wallet App                           │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ SharedDatabaseServer (port 5003)                         │  │
│  │   ↓ reads/writes                                         │  │
│  │ SharedPreferences (local storage)                        │  │
│  │   ↓                                                      │  │
│  │ Single source of truth for all transactions             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ TelegramCallbackServer (port 5002) - Optional           │  │
│  │ For real-time push from bot                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
           ↕ HTTP (reads/writes)
┌─────────────────────────────────────────────────────────────────┐
│                    Telegram Bot (Python)                        │
│                                                                  │
│  DATABASE_URL=http://127.0.0.1:5003                            │
│                ↓                                                │
│  Fetches transactions from app's SharedPreferences             │
│  Saves new transactions to app's SharedPreferences             │
│  /balance command shows app's actual balance                    │
│                                                                  │
│  Flask API (port 5001) - Proxy to SharedDatabaseServer         │
│  (for direct API access if needed)                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
*/

// Testing:
/*
1. Start app with SharedDatabaseServer running
2. Check bot can access database:
   curl http://127.0.0.1:5003/health
   → Should return: {"status":"ok","service":"shared-database-server"}

3. Send transaction via Telegram:
   /income 100 USD
   → Bot saves to http://127.0.0.1:5003/transactions

4. Open app:
   → New transaction appears in app's transaction list

5. Send /balance in Telegram:
   → Shows same balance as app

6. Add transaction in app:
   → If auto-sync enabled, sends to bot
   → Bot receives via TelegramCallbackServer

7. Check /balance again in Telegram:
   → Reflects app's new transaction
*/

// Configuration Checklist:
// ✅ Create SharedDatabaseServer in app startup
// ✅ Start on port 5003
// ✅ Set DATABASE_URL=http://127.0.0.1:5003 in bot .env
// ✅ Restart bot to apply changes
// ✅ Test curl http://127.0.0.1:5003/health
// ✅ Send transaction via Telegram
// ✅ Verify it appears in app without manual sync

// Notes:
// - This is for LOCAL DEVELOPMENT (localhost)
// - For physical devices, use machine's LAN IP:
//   Example: DATABASE_URL=http://192.168.1.100:5003
// - Server stops when app closes
// - Transactions persisted in SharedPreferences automatically
// - Fallback to local JSON if app server is offline
