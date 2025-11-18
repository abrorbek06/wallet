# Wallet App - Features & User Guide

A feature-rich Flutter wallet application that helps you track income, expenses, schedule future transactions, and manage IOUs/loans with smart notifications.

## 🎯 Core Features

### 1. **Transaction Management**
- **Income & Expense Tracking**: Categorize transactions as income or expense
- **Multiple Input Methods**:
  - Manual entry with form validation
  - Voice input (Speech-to-Text) for hands-free entry
  - Image/Receipt scanning (OCR-powered)
  - Transaction preview before confirmation

### 2. **Platform-Aware Date Picker**
- **iOS**: Uses native Cupertino date picker with smooth modal design
- **Android**: Uses Material Design date picker for native feel
- Both support date range validation (1-5 years forward)

### 3. **Scheduled Transactions** ✨ NEW
Schedule income or expense transactions for future dates:
- Set a date when the transaction should be applied
- Get a reminder 1 day before the scheduled date
- Transaction automatically activates on the scheduled date
- Perfect for recurring bills, salary deposits, or expected payments

**How to use:**
1. Tap "Add Transaction"
2. Toggle "Schedule for later"
3. Select the date you want the transaction to apply
4. Complete the form and save
5. You'll receive a notification 1 day before the date

### 4. **Loans & IOUs** ✨ NEW
Track money you lent to others or borrowed from them:
- **Track who**: Store counterparty's name
- **Direction**: Specify if you lent (will receive) or borrowed (will pay)
- **Due Date**: Set when you expect to settle the loan
- **Settlement**: Mark as settled once money is exchanged

**How to use:**
1. Tap "Add Transaction"
2. Toggle "This is a loan / IOU"
3. Enter counterparty name and direction (lend/borrow)
4. Set the due date
5. Save and receive reminders
6. On the due date, tap "Settle" to confirm payment/receipt

### 5. **Smart Notifications** 🔔
- Automatic reminders for scheduled transactions (1 day before)
- Loan due date reminders
- Immediate notification on the due date
- Click notification to quickly settle from app

### 6. **Statistics & Analytics**
- View income/expense breakdown by category
- Track balance trends over time
- Filter by period: This Week, This Month, Last 3 Months, This Year, All Time
- Monthly and category-wise analysis

### 7. **Recent Transactions & Scheduled/Loans Dashboard**
- View 5 most recent transactions on home screen
- **Scheduled & Loans widget** shows:
  - All pending scheduled transactions with days remaining
  - All unsettled loans with direction and status
  - Quick "Settle" button for loans
  - Color-coded status (overdue, due today, upcoming)

### 8. **Amount Normalization** 🔧 FIXED
- All amounts are stored as **positive values**
- Transaction type (Income/Expense) determines the sign
- Fixes previous bug where month-to-month balances were inconsistent
- Old stored negative amounts are automatically normalized on app startup

## 📊 Balance Calculation

### Formula:
```
Total Balance = Sum(Income amounts) - Sum(Expense amounts)
```

### Important Notes:
- **Amounts are always positive** in storage
- The type field determines if amount is added (+income) or subtracted (-expense)
- Scheduled transactions don't affect balance until activation date
- Loans are tracked separately and don't affect main balance

## 🔄 Transaction Flow

### Creating a Regular Transaction:
1. Open "Add Transaction" dialog
2. Choose Income or Expense
3. Fill in: Title, Amount, Category
4. Optional: Set scheduled date
5. Save → Immediately appears in balance

### Creating a Scheduled Transaction:
1. Open "Add Transaction" dialog
2. Choose Income or Expense
3. Fill in details
4. **Toggle "Schedule for later"** → Pick date
5. Save → Appears as "Scheduled" (doesn't affect balance yet)
6. On scheduled date → Automatically activates

### Creating a Loan:
1. Open "Add Transaction" dialog
2. Choose Income or Expense (based on nature)
3. **Toggle "This is a loan / IOU"**
4. Enter counterparty name
5. Choose direction: "I lent / I will receive" OR "I borrowed / I will pay"
6. **Set due date**
7. Save → Appears in "Scheduled & Loans" widget
8. On due date → Get notification and tap "Settle" to confirm

## 🔔 Notification Behavior

### Scheduled Transactions:
- **1 day before**: "Scheduled Transaction Reminder - [Title] for $X is due tomorrow"
- **On due date**: Transaction is automatically applied to balance

### Loans:
- **1 day before**: "Loan Reminder - You [will receive from/owe to] [Name] for $X"
- **On due date**: "Loan Due Today - You should [receive/pay] [Name] $X"
- Tap notification → Dialog to confirm settlement

## 📱 Data Storage

- **Local Storage**: SharedPreferences (SQLite migration planned)
- **Auto-save**: All transactions saved immediately
- **Backup**: Export/Import via JSON (planned feature)
- **Migration**: Old negative amounts auto-converted on load

## 🎨 UI Features

- **Dark Mode Support**: Full dark/light theme
- **Smooth Animations**: Transitions, loading states
- **Responsive Design**: Optimized for all screen sizes
- **Accessibility**: Clear labels, readable colors, voice input option

## ⚙️ Settings

- **Theme**: Switch between Dark and Light modes
- **Currency**: (Planned - currently USD)
- **Categories**: Add/remove income and expense categories
- **Biometric Auth**: (Planned)
- **Notifications**: (Planned - fine-grained control)

## 🚀 Planned Features

1. **SQLite Database**: Replace SharedPreferences for better performance
2. **Export/Import**: Backup and restore transactions as JSON/CSV
3. **Recurring Transactions**: Auto-repeat on custom intervals
4. **Budget Alerts**: Warn when category spending exceeds limit
5. **Recurring Loans**: Track monthly payments
6. **Cloud Sync**: Optional Firebase integration
7. **Multi-currency**: Support different currencies
8. **Advanced Charts**: More detailed analytics and graphs
9. **Receipt OCR Improvements**: Better text extraction
10. **Bill Splitting**: Share expenses with friends

## 🐛 Bug Fixes (v1.1)

### Fixed: Month-to-Month Balance Inconsistency
**Problem**: Income/expense amounts sometimes showed wrong signs across months, causing balance fluctuations.

**Root Cause**: Some transaction creation methods (voice, image) stored negative amounts for expenses, and balance calculation applied negative sign again.

**Solution**:
- Enforce positive-only amount storage
- Use transaction.type for sign determination
- Auto-normalize old stored data on load
- Fixed all transaction creation paths

## 📝 Usage Examples

### Example 1: Schedule Salary
```
Title: Monthly Salary
Amount: 5000.00
Category: Salary (Income)
Toggle: Schedule for later
Date: Dec 1, 2025
Result: Reminder Nov 30, Activates Dec 1, +$5000 to balance
```

### Example 2: Track a Loan to Friend
```
Title: Gaming Console
Amount: 150.00
Category: Loan (Expense - you lent money)
Toggle: This is a loan / IOU
Counterparty: John
Direction: I lent / I will receive
Due Date: Dec 15, 2025
Result: Listed in "Loans" widget, reminder Dec 14, settle on Dec 15
```

### Example 3: Borrow Money
```
Title: Emergency Cash
Amount: 500.00
Category: Loan (Expense - you borrowed)
Toggle: This is a loan / IOU
Counterparty: Sarah
Direction: I borrowed / I will pay
Due Date: Dec 20, 2025
Result: Listed in "Loans" widget, reminder Dec 19, settle when paid
```

## 🔐 Data Privacy

- All data stored locally on device
- No data sent to servers (currently)
- Biometric auth coming soon
- Optional cloud backup (planned)

## 📞 Support & Feedback

For bugs, feature requests, or suggestions, please open an issue on GitHub.

---

**Version**: 1.1  
**Last Updated**: November 11, 2025  
**Author**: Abrorbek  
**License**: MIT
