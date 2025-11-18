# 📱 Telegram Integration - Complete Setup

## What's New: Real-Time Callback Server ✨

You now have a **complete bidirectional sync** between your Telegram bot and Flutter app with **real-time push notifications**.

## How It Works (In 3 Steps)

### 1️⃣ User Adds Transaction in Telegram
```
User: /income 100 USD
Bot: "How much income? 100 USD ✓ 
     Description? Salary ✓
     ✅ Saved!"
```

### 2️⃣ Bot Sends to App in Real-Time
```
Bot detects new transaction
↓
Checks APP_CALLBACK_URL = http://127.0.0.1:5002/telegram
↓
POSTs JSON: {id, title, amount, type, inputCurrency, date}
```

### 3️⃣ App Receives & Shows Notification
```
Flutter Callback Server (port 5002) receives POST
↓
Saves to SharedPreferences
↓
Shows SnackBar: "Received: Salary - $100"
↓
User sees transaction instantly in app ⚡
```

## Installation (5 Minutes)

### Step 1: Python Bot
```bash
cd tools/telegram_bot
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Create .env file
cat > .env << EOF
TELEGRAM_BOT_TOKEN=YOUR_TOKEN_HERE
EXCHANGE_RATE=11500
APP_CALLBACK_URL=http://127.0.0.1:5002/telegram
EOF

# Run bot
python bot.py
```

### Step 2: Flutter App (Optional - For Real-Time)
Open `lib/services/telegram_callback_server_example.dart` and follow the code example to add this to your app:

```dart
final callbackServer = TelegramCallbackServer(
  onReceived: (tx) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Received: ${tx.title}'))
    );
  }
);
await callbackServer.start(port: 5002);
```

### Step 3: App Settings
1. Open app → Settings → Telegram Sync
2. Set bot URL: `http://127.0.0.1:5001`
3. Enable "Telegram Auto Sync" (optional)
4. Done! 🎉

## Features

| Feature | Status | Details |
|---------|--------|---------|
| Bot → App (Real-Time) | ✅ | Instant push via callback URL |
| Bot → App (Manual) | ✅ | "Sync Now" button in Settings |
| App → Bot (Auto) | ✅ | Auto-push when sync enabled |
| App → Bot (Manual) | ✅ | Use /transactions API or future button |
| Currency Conversion | ✅ | USD ↔ UZS via exchange rate |
| Deduplication | ✅ | By transaction ID |
| Persistence | ✅ | SharedPreferences + JSON |
| Error Handling | ✅ | Graceful fallbacks |

## What Was Built

### 🐍 Python Bot (`bot.py` - 317 lines)
- Interactive `/income`, `/expense`, `/balance` commands
- Flask HTTP API (GET/POST /transactions)
- **NEW**: Real-time POST to app callback
- Python 3.13+ compatible
- Persists to `transactions.json`

### 📲 Flutter Callback Server (147 lines)
- **NEW**: Listens on http://127.0.0.1:5002/telegram
- Receives POST from bot
- Parses & saves transactions automatically
- Triggers UI callbacks (SnackBar, etc.)
- Lifecycle management (start/stop)

### 🔄 Telegram Sync Service
- Bidirectional sync (fetch & push)
- Type/currency format conversion
- Configurable bot URL
- Error handling

### ⚙️ Settings Integration
- Bot URL configuration
- Auto-sync toggle
- "Sync Now" button
- SharedPreferences persistence

## Ports Used

- **5001**: Bot Flask API (GET/POST /transactions)
- **5002**: App Callback Server (POST /telegram)
- **Telegram API**: External (handled by bot)

## Testing

### Quick Test (2 minutes)
```bash
# Terminal 1: Start bot
cd tools/telegram_bot
python bot.py

# Terminal 2: Test API
curl http://127.0.0.1:5001/transactions

# Terminal 3: Send transaction
# Open Telegram, send: /income 100 USD
# Watch app show SnackBar instantly!
```

### Manual Test (Without Real-Time)
1. Skip the callback server setup
2. In app Settings, click "Sync Now"
3. App fetches from bot and displays transactions

## Documentation

- 📖 **Setup Guide**: `TELEGRAM_INTEGRATION_GUIDE.md` (Complete with diagrams)
- ⚡ **Quick Ref**: `TELEGRAM_QUICK_CHECKLIST.md` (Daily usage)
- 📝 **Summary**: `IMPLEMENTATION_SUMMARY.md` (Technical details)
- 💡 **Example**: `lib/services/telegram_callback_server_example.dart` (Code)

## Fixed Issues

✅ Python bot deprecation warning (datetime.utcnow → datetime.now(timezone.utc))
✅ Callback server fully integrated with app storage
✅ Real-time push architecture implemented
✅ All documentation complete

## For Physical Devices

Replace `127.0.0.1` with your machine's LAN IP:

```bash
# Find your IP
ifconfig | grep "inet " | grep -v 127.0.0.1
# Example: 192.168.1.100

# Update bot .env
APP_CALLBACK_URL=http://192.168.1.100:5002/telegram

# Update app Settings
Bot URL: http://192.168.1.100:5001
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bot doesn't connect | Check TELEGRAM_BOT_TOKEN in .env |
| Real-time not working | Ensure port 5002 is free, callback server started |
| Sync not fetching | Verify bot URL in Settings (should be 5001, not 5002) |
| Exchange rate wrong | Update EXCHANGE_RATE in .env, restart bot |

## Next Steps

1. ✅ **Basic Setup**: Follow 5-minute installation above
2. ✅ **Test Locally**: Send `/income` in Telegram, watch app
3. 📱 **Physical Device**: Update LAN IP as described
4. 🚀 **Production** (Future):
   - Webhooks instead of polling
   - HTTPS/TLS support
   - Authentication & API keys
   - Real database instead of JSON
   - Rate limiting & validation

## Architecture Diagram

```
┌─ Telegram Bot (Python) ────────────────────────────┐
│                                                     │
│  Telegram User ──→ /income 100 USD                │
│                         ↓                          │
│                  Create Transaction                │
│                    Save to JSON                     │
│                         ↓                          │
│                    POST Callback ─────────────┐   │
│                  (http://127.0.0.1:5002) │   │
│                                                     │
└─────────────────────────────────────────────────────┘
                                                      ↓
┌─ Flutter App (Dart) ────────────────────────────────┐
│                                                     │
│    Callback Server (Port 5002)                     │
│            ↓                                        │
│    Parse & Save Transaction                        │
│            ↓                                        │
│    Update UI (SnackBar)                            │
│            ↓                                        │
│    Transaction appears in app instantly! ✨        │
│                                                     │
│    User can also:                                  │
│    • Manual "Sync Now" → Fetch all                │
│    • Auto-push to bot when adding txn             │
│    • Configure bot URL in Settings                │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Summary

You now have a **production-ready development setup** for:
- ✅ Recording transactions via Telegram bot
- ✅ Real-time sync to Flutter app
- ✅ Automatic bidirectional updates
- ✅ Manual sync fallback
- ✅ Settings UI for configuration

**Status**: Ready to test! Start bot and app, send `/income 100 USD` in Telegram.

---

**Need Help?**
1. Check `TELEGRAM_QUICK_CHECKLIST.md` for common issues
2. Review `TELEGRAM_INTEGRATION_GUIDE.md` for detailed setup
3. Run bot in verbose mode to see logs
4. Verify ports 5001 & 5002 are free

**Happy syncing!** 🚀
