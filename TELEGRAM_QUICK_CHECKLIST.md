# Telegram Integration Quick Checklist

## One-Time Setup

### Bot Setup
- [ ] `cd tools/telegram_bot`
- [ ] `python -m venv .venv && source .venv/bin/activate`
- [ ] `pip install -r requirements.txt`
- [ ] Create `.env`:
  ```
  TELEGRAM_BOT_TOKEN=<your_token>
  EXCHANGE_RATE=11500
  APP_CALLBACK_URL=http://127.0.0.1:5002/telegram
  ```
- [ ] Run: `python bot.py`
- [ ] Verify Flask server started on port 5001
- [ ] Verify polling connected to Telegram

### App Setup (Optional - for Real-Time Push)
- [ ] Start Flutter callback server in code (see `telegram_callback_server_example.dart`)
- [ ] App will listen on port 5002 at `/telegram` endpoint
- [ ] Bot will POST new transactions here when created

### App Configuration (Mandatory)
- [ ] Open app Settings → Telegram Sync
- [ ] Set bot URL: `http://127.0.0.1:5001` (or your machine's LAN IP)
- [ ] Enable "Telegram Auto Sync" toggle (optional, for auto-push)

## Daily Usage

### Add Transaction via Telegram
1. Open Telegram → Search for your bot
2. Send `/income <amount> [USD|UZS] [description]`
   - Example: `/income 50000 UZS Salary`
   - Or: `/income 100` (defaults to USD)
3. If callback server running on app:
   - ✓ App shows SnackBar immediately
   - ✓ Transaction appears in app within seconds
4. If callback not running:
   - Use "Sync Now" in app Settings to fetch later

### Add Transaction in App
1. Open app → Add transaction via UI
2. If "Telegram Auto Sync" is ON:
   - ✓ Transaction auto-pushed to bot
   - ✓ Visible in `bot/transactions.json` immediately
3. If sync OFF:
   - Manually push via (future) "Push to Bot" button (or use Sync Service manually)

### Check Balance
- **Via Telegram**: Send `/balance` to bot
  - Shows: `Total: $100.50 / 1,155,000 UZS`
- **Via App**: Check home screen balance
  - Based on local transactions (may differ if bot has more)
  - Tap "Sync Now" to merge latest from bot

### Manual Sync
- **Bot → App**: Settings → Telegram Sync → "Sync Now"
  - Fetches all bot transactions, merges into app
- **App → Bot**: (Currently automatic if toggle ON, or manual in future)

## Monitoring

### Check Bot Transactions
```bash
curl http://127.0.0.1:5001/transactions
```

### Check Flask Server
```bash
lsof -i :5001  # Should show Python listening
lsof -i :5002  # Should show app listening (if callback running)
```

### Bot Logs
```bash
tail -f tools/telegram_bot/transactions.json  # See saved txs
# Check console output for errors/callback attempts
```

## Troubleshooting

| Problem | Check | Fix |
|---------|-------|-----|
| Bot doesn't start | `TELEGRAM_BOT_TOKEN` in `.env` | Get token from BotFather |
| Callback fails | Bot logs say "Failed to notify APP_CALLBACK_URL" | Ensure app is running with server started, port 5002 free |
| Sync doesn't work | Check app Settings → bot URL | Verify URL matches bot port (5001), not callback port (5002) |
| Exchange rate wrong | Check `.env` `EXCHANGE_RATE` | Update value and restart bot |
| Physical device test | Using localhost | Use machine's LAN IP in `APP_CALLBACK_URL` and app Settings |

## Key Ports
- **Bot API**: `5001` (Flask, `/transactions` endpoint)
- **App Callback**: `5002` (if enabled, `/telegram` endpoint)
- **Telegram**: (external, automatic)

## Files to Check
- Bot: `tools/telegram_bot/bot.py`
- App Callback: `lib/services/telegram_callback_server.dart`
- Sync Service: `lib/services/telegram_sync_service.dart`
- Settings: `lib/screens/settings/settings_screen.dart`
- Transactions Storage: `tools/telegram_bot/transactions.json`

## Full Docs
See `TELEGRAM_INTEGRATION_GUIDE.md` for detailed setup, architecture, and advanced configuration.
