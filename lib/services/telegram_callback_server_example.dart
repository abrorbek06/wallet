// Example: How to use TelegramCallbackServer in your Flutter app
//
// Place this code in your main.dart or HomeScreen to enable real-time
// notifications from the Telegram bot.

// In main.dart or main app initialization:
/*
import 'package:wallet/services/telegram_callback_server.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start the callback server to receive real-time transactions from bot
  _initCallbackServer();
  
  runApp(const MyApp());
}

Future<void> _initCallbackServer() async {
  final callbackServer = TelegramCallbackServer(
    onReceived: (transaction) {
      // Called whenever the bot POSTs a transaction
      print('[App] Received transaction from bot: ${transaction.title}');
      // You can trigger a UI update here, play a notification sound, etc.
    },
  );
  
  try {
    final port = await callbackServer.start(port: 5002);
    print('[App] Callback server started on port $port');
    // Store the server instance if you need to stop it later
    // (e.g., on app exit)
  } catch (e) {
    print('[App] Failed to start callback server: $e');
  }
}
*/

// In HomeScreen or a similar stateful widget:
/*
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TelegramCallbackServer callbackServer;

  @override
  void initState() {
    super.initState();
    _initCallbackServer();
  }

  Future<void> _initCallbackServer() async {
    callbackServer = TelegramCallbackServer(
      onReceived: (transaction) {
        // Update UI when transaction received
        setState(() {
          // Transactions are already saved to storage by the callback server
        });
        
        // Show a notification to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Received: ${transaction.title}'),
            duration: const Duration(seconds: 3),
            backgroundColor: transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
          ),
        );
      },
    );

    try {
      await callbackServer.start(port: 5002);
      print('Callback server started');
    } catch (e) {
      print('Failed to start callback server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Callback server error: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Stop callback server on app exit
    callbackServer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Center(
        child: Text('Callback server is running on port ${callbackServer.listeningPort}'),
      ),
    );
  }
}
*/

// Configuration Checklist:
// ✅ Create `TelegramCallbackServer` instance with `onReceived` callback
// ✅ Call `await server.start(port: 5002)` to start listening
// ✅ Set `APP_CALLBACK_URL=http://127.0.0.1:5002/telegram` in bot's `.env`
// ✅ Restart the bot: `python bot.py`
// ✅ Restart the Flutter app to start the callback server
// ✅ Test by sending a transaction via Telegram (`/income 100 USD`)
// ✅ You should see a SnackBar in the app confirming receipt

// Notes:
// - This is for LOCAL DEVELOPMENT ONLY (localhost/127.0.0.1)
// - For testing on physical devices, replace 127.0.0.1 with your machine's IP
//   Example: APP_CALLBACK_URL=http://192.168.1.100:5002/telegram
// - The callback server stops when the app closes
// - Transactions are automatically persisted to SharedPreferences
