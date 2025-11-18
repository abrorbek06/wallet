# Telegram Bot for Wallet App

This is a Telegram bot that allows users to record income/expense transactions and view their balance. It syncs bidirectionally with the Flutter wallet app.

## Commands

- `/income` – Start interactive income entry (bot asks for amount, currency, description)
- `/expense` – Start interactive expense entry (bot asks for amount, currency, description)
- `/balance` – Show total balance in both USD and UZS (based on configured exchange rate)
- `/start` – Show help message

## Installation & Setup

### Prerequisites
- Python 3.13+
- pip
- A Telegram bot token (from BotFather)

### Steps

1. **Clone / Navigate to Bot Directory**
   ```bash
   cd tools/telegram_bot
   ```

2. **Create Virtual Environment**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # macOS/Linux
   # or: .venv\Scripts\activate  (Windows)
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Create `.env` File**
   ```bash
   cat > .env << EOF
   TELEGRAM_BOT_TOKEN=<your_bot_token_from_botfather>
   EXCHANGE_RATE=11500
   DATABASE_URL=http://127.0.0.1:5003
   APP_CALLBACK_URL=http://127.0.0.1:5002/telegram
   EOF
   ```
   - `TELEGRAM_BOT_TOKEN`: Required. Get from BotFather on Telegram.
   - `EXCHANGE_RATE`: Optional (default: 11500). UZS per 1 USD for currency conversions.
   - `DATABASE_URL`: Optional. **NEW**: URL of the app's shared database server (see setup below).
   - `APP_CALLBACK_URL`: Optional. URL of the app's callback server for real-time push (see setup below).

5. **Run the Bot**
   ```bash
   python bot.py
   ```
   The bot will start polling for messages and also start a Flask HTTP server on port 5001 for the API.

## Shared Database Architecture (NEW)

Both the app and bot now use the **same database** via a shared HTTP API:

```
App (port 5003)                Bot (port 5001)
  ↓                               ↓
SharedDatabaseServer      ← reads/writes to →    Python Bot
  ↓                                              ↓
SharedPreferences                      DATABASE_URL
  (app's local storage)            (http://127.0.0.1:5003)
```

### Setup: Enable Shared Database

1. **Start app with SharedDatabaseServer**
   - Add this to your Flutter app's `main.dart` or `HomeScreen`:
   ```dart
   import 'package:wallet/services/shared_database_server.dart';
   
   final dbServer = SharedDatabaseServer();
   await dbServer.start(port: 5003);
   ```

2. **Configure bot to use it**
   - Set in `.env`:
   ```
   DATABASE_URL=http://127.0.0.1:5003
   ```

3. **Restart bot**
   ```bash
   python bot.py
   ```
   - Bot will now read/write to app's SharedPreferences
   - `/balance` command shows app's actual balance
   - Transactions added via Telegram are saved to app's database

### Benefits

✅ **Single source of truth**: App and bot share the same transaction database
✅ **No duplication**: Transactions stored once, visible in both
✅ **Real-time sync**: Add in app → appears in bot immediately, and vice versa
✅ **Fallback support**: If app is offline, bot falls back to local JSON

## HTTP API

The bot's Flask API (`http://127.0.0.1:5001`) is now a **proxy** to the shared database:

### GET /transactions
Returns a JSON array of all saved transactions.

```bash
curl http://127.0.0.1:5001/transactions
```

### POST /transactions
Accepts a JSON transaction object and saves it.

```bash
curl -X POST http://127.0.0.1:5001/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "id": "unique-id",
    "title": "Coffee",
    "amount": 5.0,
    "inputCurrency": "USD",
    "type": "expense",
    "date": "2024-01-15T10:30:00Z",
    "isSettled": true
  }'
```

## Bidirectional Sync with Flutter App

### App → Bot (App Pushes to Bot)

When you add a transaction in the Flutter app with **Telegram Auto Sync** enabled (Settings), the app automatically POSTs it to the bot's `/transactions` endpoint.

### Bot → App (Bot Pushes to App - Real-Time)

To receive real-time notifications when you add a transaction via Telegram:

1. **Start the Flutter Callback Server**
   - The Flutter app includes a built-in callback server (`TelegramCallbackServer`).
   - Initialize it in `main.dart` or `HomeScreen`:
     ```dart
     final callbackServer = TelegramCallbackServer(
       onReceived: (tx) {
         // Handle received transaction (update UI, show SnackBar, etc.)
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Received: ${tx.title}'))
         );
       }
     );
     await callbackServer.start(port: 5002);
     ```

2. **Configure Bot with APP_CALLBACK_URL**
   - Set `APP_CALLBACK_URL=http://127.0.0.1:5002/telegram` in the bot's `.env`.
   - The bot will POST each new transaction to this endpoint immediately after creation.

3. **Testing Locally**
   - Ensure the bot is running: `python bot.py`
   - Ensure the Flutter app is running with the callback server started.
   - Both must be on the same network (same machine for localhost testing).
   - Send a transaction via Telegram (`/income 100 USD` etc.) and watch the app receive it in real-time.

### Manual Sync (Fallback)

If you don't set `APP_CALLBACK_URL` or prefer polling:

1. In the Flutter app Settings, enable **Telegram Auto Sync**.
2. Tap **Sync Now** to manually fetch all bot transactions and merge them into your app.
3. The app can also be configured to auto-fetch on startup.

## Development Notes

- Transactions are stored in `transactions.json` (file-based, no external DB required).
- The bot uses polling to listen to Telegram messages (not webhooks).
- For production, consider upgrading to webhooks and using HTTPS with proper authentication.
- This implementation is designed for **local development only**. For public deployment, secure the endpoints and add authentication.

## Troubleshooting

### Bot not starting
- Check that `TELEGRAM_BOT_TOKEN` is set correctly in `.env`.
- Ensure you have internet access (required for Telegram API).

### Transactions not syncing
- Verify `APP_CALLBACK_URL` is reachable from the bot (same network if using localhost).
- Check the bot logs for POST errors to the callback URL.
- Alternatively, use manual "Sync Now" in the app Settings.

### Exchange rate issues
- Verify `EXCHANGE_RATE` in `.env` is a valid number.
- Default is 11500 (UZS per 1 USD). Adjust based on current market rate.
