# Telegram Bot & Flutter Integration - Complete Setup Guide

## What's Been Implemented

### 1. **Python Telegram Bot** (`tools/telegram_bot/bot.py`)
- ✅ Interactive conversation flows for `/income`, `/expense` commands
- ✅ `/balance` command showing balance in USD and UZS
- ✅ Flask HTTP API (port 5001):
  - `GET /transactions` – returns all transactions as JSON
  - `POST /transactions` – accepts transaction JSON and saves it
- ✅ Real-time push support via `APP_CALLBACK_URL` (lines 66-73 in bot.py)
  - When a new transaction is created, bot POSTs it to the callback URL
- ✅ Python 3.13+ compatibility (imghdr polyfill, timezone-aware datetime)
- ✅ Persistent storage in `transactions.json`

### 2. **Flutter Callback Server** (`lib/services/telegram_callback_server.dart`)
- ✅ `TelegramCallbackServer` class listening on port 5002
- ✅ Accepts POST requests at `/telegram` endpoint
- ✅ Automatically parses bot JSON and creates Transaction objects
- ✅ Deduplicates transactions by ID
- ✅ Persists received transactions to SharedPreferences
- ✅ Callback function for UI updates (SnackBar, notifications, etc.)
- ✅ Graceful error handling and logging

### 3. **Telegram Sync Service** (`lib/services/telegram_sync_service.dart`)
- ✅ `fetchAndMergeTransactions()` – pulls from bot, merges with app storage
- ✅ `pushTransaction()` – sends app transaction to bot in real-time
- ✅ Type/currency format conversion (app enum ↔ bot string)
- ✅ Bot URL configurable (defaults to `http://127.0.0.1:5001`)

### 4. **Settings UI** (`lib/screens/settings/settings_screen.dart`)
- ✅ "Telegram Sync" card with toggle for auto-sync
- ✅ Text field to configure bot server URL
- ✅ "Sync Now" button to manually fetch transactions
- ✅ Persists settings to SharedPreferences

### 5. **Home Screen Integration** (`lib/screens/home/home_screen.dart`)
- ✅ Auto-fetches from bot on app startup (if sync enabled)
- ✅ Auto-pushes new transactions to bot (if sync enabled)
- ✅ `_syncWithTelegramBot()` helper method

### 6. **Storage Helpers** (`lib/models/storage.dart`)
- ✅ `saveTelegramAutoSync()` / `loadTelegramAutoSync()` – toggle persistence
- ✅ `saveTelegramBotUrl()` / `loadTelegramBotUrl()` – URL persistence

## Bidirectional Sync Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       Flutter Wallet App                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ HomeScreen → Add Transaction → TelegramSyncService        │  │
│  │                                 ↓ (if auto-sync enabled) │  │
│  │                            POST to Bot /transactions      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ TelegramCallbackServer (localhost:5002/telegram)         │  │
│  │     ← Receives real-time POST from bot                   │  │
│  │     → Saves to storage, triggers UI update                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ SettingsScreen → "Sync Now" → Fetch from Bot             │  │
│  │   (TelegramSyncService.fetchAndMergeTransactions)         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕ (HTTP)
┌─────────────────────────────────────────────────────────────────┐
│                   Telegram Bot (Python)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Telegram User → /income or /expense → Add Transaction    │  │
│  │                                         ↓                 │  │
│  │                                 Save to transactions.json │  │
│  │                                         ↓                 │  │
│  │                           POST to APP_CALLBACK_URL        │  │
│  │                        (http://127.0.0.1:5002/telegram)   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ HTTP API (Flask, port 5001)                              │  │
│  │   GET /transactions   → returns JSON array               │  │
│  │   POST /transactions  → accepts & saves transaction      │  │
│  │ Consumed by: app's TelegramSyncService                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Setup Instructions

### Bot Setup (Python)

1. Navigate to bot directory:
   ```bash
   cd tools/telegram_bot
   ```

2. Create virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Create `.env` file:
   ```bash
   cat > .env << EOF
   TELEGRAM_BOT_TOKEN=<your_token_from_botfather>
   EXCHANGE_RATE=11500
   APP_CALLBACK_URL=http://127.0.0.1:5002/telegram
   EOF
   ```

5. Run bot:
   ```bash
   python bot.py
   ```
   - Bot polling starts (listening for Telegram messages)
   - Flask server starts on port 5001 (HTTP API)
   - Waits for `APP_CALLBACK_URL` to be reachable

### App Setup (Flutter)

1. **Optional: Start Callback Server in Code**
   
   Add to `main.dart` or `HomeScreen`:
   ```dart
   import 'package:wallet/services/telegram_callback_server.dart';
   
   // In initState or main():
   final callbackServer = TelegramCallbackServer(
     onReceived: (tx) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Received: ${tx.title}'))
       );
     }
   );
   await callbackServer.start(port: 5002);
   ```
   
   See `lib/services/telegram_callback_server_example.dart` for full example.

2. **Configure Bot**
   
   Ensure bot's `.env` has:
   ```
   APP_CALLBACK_URL=http://127.0.0.1:5002/telegram
   ```

3. **Settings Configuration**
   
   In app Settings:
   - Enable "Telegram Sync" toggle
   - Set bot URL to `http://127.0.0.1:5001` (if running locally)
   - Optionally tap "Sync Now" to fetch existing transactions

## Testing the Full Flow

### Test 1: App → Bot
1. Open Settings, enable "Telegram Auto Sync"
2. Add transaction in app (e.g., Income $50)
3. Check bot's `transactions.json` or fetch via `GET /transactions`
4. ✓ Transaction appears in bot storage

### Test 2: Bot → App (Real-Time)
1. Ensure callback server is running on app (port 5002)
2. Ensure bot has `APP_CALLBACK_URL=http://127.0.0.1:5002/telegram`
3. Restart bot: `python bot.py`
4. Send transaction via Telegram: `/income 100 USD`
5. Watch app receive real-time SnackBar notification
6. Check app's transaction list for new entry
7. ✓ Transaction synced automatically

### Test 3: Bot → App (Manual Sync)
1. Add transaction via Telegram without callback running
2. In app Settings, tap "Sync Now"
3. ✓ App fetches and displays the transaction

## Troubleshooting

### Callback not working
- **Check bot logs** for "Failed to notify APP_CALLBACK_URL" errors
- **Verify port 5002** is not in use: `lsof -i :5002`
- **Ensure both are on same network** (localhost works only on same machine)
- **For physical devices**: Use your machine's LAN IP instead of 127.0.0.1
  - Example: `APP_CALLBACK_URL=http://192.168.1.100:5002/telegram`

### Sync not fetching
- **Verify bot URL** in Settings is correct (`http://127.0.0.1:5001`)
- **Check bot is running**: `curl http://127.0.0.1:5001/transactions`
- **Check app logs** for sync errors

### Exchange rate issues
- **Update `EXCHANGE_RATE`** in bot `.env` (e.g., 12000 for 12,000 UZS per USD)
- **Restart bot** after changing `.env`

## File Reference

### Python Bot
- `tools/telegram_bot/bot.py` – Main bot with ConversationHandler, Flask API, callback support
- `tools/telegram_bot/.env` – Bot configuration (token, exchange rate, callback URL)
- `tools/telegram_bot/requirements.txt` – Python dependencies
- `tools/telegram_bot/README.md` – Bot documentation
- `tools/telegram_bot/transactions.json` – Persistent transaction storage

### Flutter App
- `lib/services/telegram_callback_server.dart` – HTTP server for receiving bot pushes
- `lib/services/telegram_sync_service.dart` – Bidirectional sync logic
- `lib/models/storage.dart` – SharedPreferences helpers for Telegram settings
- `lib/screens/settings/settings_screen.dart` – UI for bot configuration
- `lib/screens/home/home_screen.dart` – Integration with add/load transactions
- `lib/services/telegram_callback_server_example.dart` – Usage example

## Advanced Configuration

### For Physical Device Testing
1. Find your machine's LAN IP:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
   Example: `192.168.1.100`

2. Update bot `.env`:
   ```
   APP_CALLBACK_URL=http://192.168.1.100:5002/telegram
   ```

3. In Flutter app, update bot URL setting to your machine's IP:
   ```
   http://192.168.1.100:5001
   ```

### For Production (Next Steps)
- [ ] Switch from polling to Telegram webhooks
- [ ] Add HTTPS/TLS support
- [ ] Add authentication (API keys, JWT tokens)
- [ ] Use a proper database (PostgreSQL, MongoDB) instead of `transactions.json`
- [ ] Rate limiting and input validation
- [ ] Error recovery and transaction deduplication on bot side

## Summary

You now have a fully functional bidirectional sync system:

✅ **App → Bot**: Add transaction in app → auto-pushes to bot (if enabled)
✅ **Bot → App (Real-time)**: Send `/income` in Telegram → instant SnackBar in app
✅ **Bot → App (Manual)**: "Sync Now" button fetches all bot transactions
✅ **Configuration**: Telegram settings persisted and configurable via UI
✅ **Transactions**: Synced across both systems with deduplication
✅ **Currency Conversion**: Automatic USD ↔ UZS conversion using exchange rate

This is a development-ready implementation. For production, add authentication, HTTPS, proper error handling, and database persistence.
