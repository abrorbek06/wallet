"""
Telegram bot with conversational flow for recording transactions.
User sends /income or /expense, then bot asks step-by-step:
1. Bot: "How much?"
2. User: enters amount
3. Bot: "Currency (USD/UZS)?"
4. User: enters currency
5. Bot: "Description (optional)?"
6. User: enters description or skips
7. Bot: confirms and saves

Also supports HTTP API:
- GET  /transactions        -> returns list of transactions
- POST /transactions       -> add transaction with JSON body
"""

# Fallback imghdr module for Python 3.13+ where it was removed from stdlib
import sys
if sys.version_info >= (3, 13):
    import types
    imghdr = types.ModuleType('imghdr')
    imghdr.what = lambda f, h=None: None
    sys.modules['imghdr'] = imghdr

import os
import json
import uuid
import threading
from datetime import datetime, timezone
from flask import Flask, jsonify, request
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, ConversationHandler
from dotenv import load_dotenv

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_FILE = os.path.join(BASE_DIR, 'transactions.json')

load_dotenv()
TELEGRAM_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')
EXCHANGE_RATE = float(os.getenv('EXCHANGE_RATE', '11500'))
APP_CALLBACK_URL = os.getenv('APP_CALLBACK_URL')
DATABASE_URL = os.getenv('DATABASE_URL')  # NEW: Shared database endpoint

app = Flask(__name__)

# Use shared database if available, otherwise fall back to local JSON
USE_SHARED_DB = bool(DATABASE_URL)

# Ensure data file exists (fallback only)
if not USE_SHARED_DB and not os.path.exists(DATA_FILE):
    with open(DATA_FILE, 'w') as f:
        json.dump([], f, indent=2)

# Conversation states
AMOUNT, CURRENCY, DESCRIPTION = range(3)

# Global state storage for conversations
user_state = {}


def load_transactions():
    """Load transactions from shared database or local JSON"""
    if USE_SHARED_DB:
        try:
            import requests
            response = requests.get(f"{DATABASE_URL}/transactions", timeout=5)
            if response.status_code == 200:
                return response.json()
            else:
                print(f"Database error: {response.status_code}")
                return []
        except Exception as e:
            print(f"Failed to fetch from database: {e}")
            return []
    else:
        # Fallback to local JSON
        try:
            with open(DATA_FILE, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Failed to load local transactions: {e}")
            return []


def save_transactions(tx_list):
    """Save transactions to shared database or local JSON"""
    if USE_SHARED_DB:
        # Don't save directly; POST each transaction instead
        # (The database server handles persistence via app's SharedPreferences)
        pass
    else:
        # Fallback to local JSON
        try:
            with open(DATA_FILE, 'w') as f:
                json.dump(tx_list, f, indent=2, default=str)
        except Exception as e:
            print(f"Failed to save local transactions: {e}")


def add_transaction(tx):
    """Add a transaction to the database"""
    if USE_SHARED_DB:
        try:
            import requests
            # POST to shared database server
            response = requests.post(f"{DATABASE_URL}/transactions", json=tx, timeout=5)
            if response.status_code in [200, 201]:
                print(f"Transaction saved to shared database: {tx['id']}")
            else:
                print(f"Database error: {response.status_code} - {response.text}")
        except Exception as e:
            print(f"Failed to save to database: {e}")
    else:
        # Fallback to local JSON
        tx_list = load_transactions()
        tx_list.append(tx)
        save_transactions(tx_list)
    
    # Notify external callback (optional) - now redundant since database handles it
    # But keep for compatibility if callback is separate from database
    if APP_CALLBACK_URL:
        try:
            import requests
            requests.post(APP_CALLBACK_URL, json=tx, timeout=3)
        except Exception as e:
            print(f"Failed to notify APP_CALLBACK_URL: {e}")


def format_amount_in_both(amount, currency):
    if currency.upper() == 'USD':
        uzs = amount * EXCHANGE_RATE
        return f"${amount:.2f} / {int(uzs):,} UZS"
    else:
        usd = amount / EXCHANGE_RATE
        return f"{int(amount):,} UZS / ${usd:.2f}"


# Telegram command handlers
def handle_start(update, context):
    """Handle /start command"""
    update.message.reply_text(
        'Welcome to Transaction Bot! 💰\n\n'
        'Commands:\n'
        '/income - Add income\n'
        '/expense - Add expense\n'
        '/balance - Show balance\n\n'
        'I will guide you step-by-step through each transaction.'
    )


def handle_income_start(update, context):
    """Start income conversation"""
    user_id = update.message.from_user.id
    user_state[user_id] = {'type': 'income', 'amount': None, 'currency': None}
    update.message.reply_text('How much income? (enter amount)')
    return AMOUNT


def handle_expense_start(update, context):
    """Start expense conversation"""
    user_id = update.message.from_user.id
    user_state[user_id] = {'type': 'expense', 'amount': None, 'currency': None}
    update.message.reply_text('How much expense? (enter amount)')
    return AMOUNT


def handle_amount(update, context):
    """Handle amount input"""
    user_id = update.message.from_user.id
    try:
        amount = float(update.message.text.replace(',', ''))
        if amount <= 0:
            update.message.reply_text('Amount must be positive. Try again:')
            return AMOUNT
        user_state[user_id]['amount'] = amount
        update.message.reply_text('Which currency? (USD or UZS)')
        return CURRENCY
    except ValueError:
        update.message.reply_text('Invalid amount. Please enter a number:')
        return AMOUNT


def handle_currency(update, context):
    """Handle currency input"""
    user_id = update.message.from_user.id
    currency = update.message.text.strip().upper()
    if currency not in ['USD', 'UZS']:
        update.message.reply_text('Please enter USD or UZS:')
        return CURRENCY
    user_state[user_id]['currency'] = currency
    update.message.reply_text('Description? (or send /skip)')
    return DESCRIPTION


def handle_description(update, context):
    """Handle description input"""
    user_id = update.message.from_user.id
    description = update.message.text.strip()
    
    # Skip command
    if description.lower() == '/skip':
        description = ''
    
    # Save transaction
    tx = {
        'id': str(uuid.uuid4()),
        'title': description or f"{user_state[user_id]['type'].capitalize()} (via Telegram)",
        'amount': user_state[user_id]['amount'],
        'inputCurrency': user_state[user_id]['currency'],
        'type': user_state[user_id]['type'],
        'date': datetime.now(timezone.utc).isoformat(),
        'isSettled': True,
    }
    add_transaction(tx)
    
    # Confirm to user
    amount = user_state[user_id]['amount']
    currency = user_state[user_id]['currency']
    update.message.reply_text(
        f"✅ {user_state[user_id]['type'].capitalize()} saved!\n"
        f"{format_amount_in_both(amount, currency)}\n"
        f"Description: {description or 'None'}"
    )
    
    # Clean up state
    del user_state[user_id]
    return ConversationHandler.END


def handle_cancel(update, context):
    """Cancel conversation"""
    user_id = update.message.from_user.id
    if user_id in user_state:
        del user_state[user_id]
    update.message.reply_text('Cancelled.')
    return ConversationHandler.END


def handle_balance(update, context):
    """Show balance"""
    try:
        text = update.message.text or ''
        tokens = text.split()
        display = 'USD'
        if len(tokens) > 1 and tokens[1].upper() in ['USD', 'UZS']:
            display = tokens[1].upper()
        
        txs = load_transactions()
        income_usd = 0.0
        expense_usd = 0.0
        
        for t in txs:
            amt = float(t.get('amount', 0))
            curr = t.get('inputCurrency', 'UZS').upper()
            usd_amt = (amt / EXCHANGE_RATE) if curr == 'UZS' else amt
            
            if t.get('type') == 'income':
                income_usd += usd_amt
            else:
                expense_usd += usd_amt

        balance_usd = income_usd - expense_usd
        
        if display == 'USD':
            msg = f"💰 Income: ${income_usd:.2f}\n💸 Expenses: ${expense_usd:.2f}\n💵 Balance: ${balance_usd:.2f}"
        else:
            income_uzs = int(income_usd * EXCHANGE_RATE)
            expense_uzs = int(expense_usd * EXCHANGE_RATE)
            balance_uzs = int(balance_usd * EXCHANGE_RATE)
            msg = f"💰 Income: {income_uzs:,} UZS\n💸 Expenses: {expense_uzs:,} UZS\n💵 Balance: {balance_uzs:,} UZS"
        
        update.message.reply_text(msg)
    except Exception as e:
        update.message.reply_text(f'Error computing balance: {str(e)}')


# HTTP endpoints
@app.route('/transactions', methods=['GET'])
def http_get_transactions():
    txs = load_transactions()
    return jsonify(txs)


@app.route('/transactions', methods=['POST'])
def http_post_transaction():
    try:
        body = request.get_json(force=True)
        tx = {
            'id': str(uuid.uuid4()),
            'title': body.get('title', 'Imported'),
            'amount': float(body.get('amount', 0)),
            'inputCurrency': body.get('inputCurrency', 'UZS').upper(),
            'type': body.get('type', 'expense'),
            'date': datetime.now(timezone.utc).isoformat(),
            'isSettled': True,
        }
        add_transaction(tx)
        return jsonify({'status': 'ok', 'tx': tx}), 201
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)}), 400


def start_flask():
    app.run(host='0.0.0.0', port=5001, debug=False, use_reloader=False)


def start_bot():
    if not TELEGRAM_TOKEN:
        print('TELEGRAM_BOT_TOKEN not set in environment. Bot will not start.')
        return
    
    updater = Updater(TELEGRAM_TOKEN, use_context=True)
    dp = updater.dispatcher
    
    # Add /start and /balance handlers
    dp.add_handler(CommandHandler('start', handle_start))
    dp.add_handler(CommandHandler('balance', handle_balance))
    
    # Income conversation
    income_conv = ConversationHandler(
        entry_points=[CommandHandler('income', handle_income_start)],
        states={
            AMOUNT: [MessageHandler(Filters.text & ~Filters.command, handle_amount)],
            CURRENCY: [MessageHandler(Filters.text & ~Filters.command, handle_currency)],
            DESCRIPTION: [MessageHandler(Filters.text & ~Filters.command, handle_description)],
        },
        fallbacks=[CommandHandler('cancel', handle_cancel)],
    )
    
    # Expense conversation
    expense_conv = ConversationHandler(
        entry_points=[CommandHandler('expense', handle_expense_start)],
        states={
            AMOUNT: [MessageHandler(Filters.text & ~Filters.command, handle_amount)],
            CURRENCY: [MessageHandler(Filters.text & ~Filters.command, handle_currency)],
            DESCRIPTION: [MessageHandler(Filters.text & ~Filters.command, handle_description)],
        },
        fallbacks=[CommandHandler('cancel', handle_cancel)],
    )
    
    dp.add_handler(income_conv)
    dp.add_handler(expense_conv)
    
    print('Starting Telegram polling...')
    updater.start_polling()
    updater.idle()


if __name__ == '__main__':
    # Run Flask in a separate daemon thread
    flask_thread = threading.Thread(target=start_flask, daemon=True)
    flask_thread.start()
    
    print('Flask server started on port 5001 (daemon thread)')
    print('Waiting for Telegram bot to start...')
    
    # Give Flask time to start
    import time
    time.sleep(1)
    
    # Run Telegram bot in main thread
    try:
        start_bot()
    except KeyboardInterrupt:
        print('\nShutdown requested.')
