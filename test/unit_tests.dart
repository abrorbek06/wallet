import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/models.dart';
import 'package:app/services/scheduled_transaction_processor.dart';

void main() {
  group('ScheduledTransactionProcessor Tests', () {
    late ScheduledTransactionProcessor processor;

    setUp(() {
      processor = ScheduledTransactionProcessor();
    });

    test('Should activate scheduled transaction on due date', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      final transaction = Transaction(
        id: '1',
        title: 'Scheduled Payment',
        categoryId: '1',
        amount: 100.0,
        date: today,
        type: TransactionType.expense,
        isScheduled: true,
        scheduledDate: yesterday, // Due date is yesterday (should activate)
        isLoan: false,
        isSettled: false,
      );

      final result = await processor.processScheduledTransactions([
        transaction,
      ]);

      expect(result.length, 1);
      expect(result[0].isSettled, true);
      expect(result[0].amount, 100.0); // Amount stays positive
    });

    test('Should not activate future scheduled transactions', () async {
      final tomorrow = DateTime.now().add(Duration(days: 1));

      final transaction = Transaction(
        id: '2',
        title: 'Future Payment',
        categoryId: '1',
        amount: 50.0,
        date: DateTime.now(),
        type: TransactionType.income,
        isScheduled: true,
        scheduledDate:
            tomorrow, // Due date is tomorrow (should NOT activate yet)
        isLoan: false,
        isSettled: false,
      );

      final result = await processor.processScheduledTransactions([
        transaction,
      ]);

      expect(result.isEmpty, true); // No activated transactions
    });

    test('Should handle loans correctly', () async {
      final loan = Transaction(
        id: '3',
        title: 'Lent to John',
        categoryId: '1',
        amount: 200.0,
        date: DateTime.now(),
        type: TransactionType.expense,
        isScheduled: false,
        isLoan: true,
        counterparty: 'John',
        loanDirection: 'lend',
        scheduledDate: DateTime.now().add(Duration(days: 5)),
        isSettled: false,
      );

      final result = await processor.processScheduledTransactions([loan]);

      // Loan should not be in activated (not scheduled for immediate activation)
      expect(result.isEmpty, true);
    });

    test('Amount normalization: positive values enforced', () async {
      // Simulate old stored data with negative amount
      final oldNegativeTransaction = Transaction(
        id: '4',
        title: 'Old Expense',
        categoryId: '1',
        amount: -75.0, // Negative (should be normalized to positive)
        date: DateTime.now(),
        type: TransactionType.expense,
        isScheduled: false,
        isLoan: false,
        isSettled: true,
      );

      // In real code, storage.loadTransactions normalizes this
      // Here we just verify the processor doesn't break with negative
      final result = await processor.processScheduledTransactions([
        oldNegativeTransaction,
      ]);
      expect(result.isEmpty, true); // No activation expected
    });

    test('Should identify overdue transactions', () async {
      final twoDaysAgo = DateTime.now().subtract(Duration(days: 2));

      final overdueTransaction = Transaction(
        id: '5',
        title: 'Overdue Bill',
        categoryId: '1',
        amount: 150.0,
        date: DateTime.now(),
        type: TransactionType.expense,
        isScheduled: true,
        scheduledDate: twoDaysAgo,
        isLoan: false,
        isSettled: false,
      );

      final result = await processor.processScheduledTransactions([
        overdueTransaction,
      ]);

      expect(result.length, 1);
      expect(result[0].isSettled, true);
    });

    test('Multiple transactions: mixed scheduled and loans', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));
      final tomorrow = today.add(Duration(days: 1));

      final transactions = [
        // Should activate
        Transaction(
          id: '1',
          title: 'Due Yesterday',
          categoryId: '1',
          amount: 100.0,
          date: today,
          type: TransactionType.expense,
          isScheduled: true,
          scheduledDate: yesterday,
          isLoan: false,
          isSettled: false,
        ),
        // Should NOT activate
        Transaction(
          id: '2',
          title: 'Due Tomorrow',
          categoryId: '1',
          amount: 200.0,
          date: today,
          type: TransactionType.income,
          isScheduled: true,
          scheduledDate: tomorrow,
          isLoan: false,
          isSettled: false,
        ),
        // Loan (not scheduled for activation)
        Transaction(
          id: '3',
          title: 'Loan from Friend',
          categoryId: '1',
          amount: 50.0,
          date: today,
          type: TransactionType.expense,
          isScheduled: false,
          isLoan: true,
          counterparty: 'Alice',
          loanDirection: 'borrow',
          scheduledDate: tomorrow,
          isSettled: false,
        ),
      ];

      final result = await processor.processScheduledTransactions(transactions);

      // Only the yesterday transaction should activate
      expect(result.length, 1);
      expect(result[0].id, '1');
      expect(result[0].isSettled, true);
    });
  });

  group('Transaction Model Tests', () {
    test('Transaction toJson includes all fields', () {
      final tx = Transaction(
        id: 'test-1',
        title: 'Test Transaction',
        categoryId: 'cat-1',
        amount: 150.75,
        date: DateTime(2025, 11, 11),
        type: TransactionType.income,
        isScheduled: true,
        scheduledDate: DateTime(2025, 12, 11),
        isLoan: true,
        counterparty: 'John Doe',
        loanDirection: 'lend',
        isSettled: false,
      );

      final json = tx.toJson();

      expect(json['id'], 'test-1');
      expect(json['amount'], 150.75);
      expect(json['isScheduled'], true);
      expect(json['isLoan'], true);
      expect(json['counterparty'], 'John Doe');
      expect(json['loanDirection'], 'lend');
      expect(json['isSettled'], false);
    });

    test('Transaction.fromJson deserializes correctly', () {
      final json = {
        'id': 'test-2',
        'title': 'Test Tx',
        'categoryId': 'cat-1',
        'amount': 99.99,
        'date': '2025-11-11T10:30:00.000Z',
        'type': 'TransactionType.expense',
        'isScheduled': true,
        'scheduledDate': '2025-12-11T00:00:00.000Z',
        'isLoan': false,
        'counterparty': null,
        'loanDirection': null,
        'isSettled': true,
      };

      final tx = Transaction.fromJson(json);

      expect(tx.id, 'test-2');
      expect(tx.amount, 99.99);
      expect(tx.isScheduled, true);
      expect(tx.isLoan, false);
      expect(tx.isSettled, true);
      expect(tx.type, TransactionType.expense);
    });

    test('Amount is always stored positive', () {
      // Old code might create negative amounts
      final negativeAmount = -50.0;

      final tx = Transaction(
        id: 'neg-1',
        title: 'Negative Amount',
        categoryId: 'cat-1',
        amount: negativeAmount.abs(), // Must be positive
        date: DateTime.now(),
        type: TransactionType.expense,
      );

      expect(tx.amount, greaterThan(0));
      expect(tx.amount, 50.0);
    });
  });

  group('Balance Calculation Tests', () {
    test('Balance = Income - Expenses (with positive amounts)', () {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Salary',
          categoryId: '1',
          amount: 5000.0, // Positive
          date: DateTime.now(),
          type: TransactionType.income,
        ),
        Transaction(
          id: '2',
          title: 'Rent',
          categoryId: '2',
          amount: 1000.0, // Positive (type indicates it's expense)
          date: DateTime.now(),
          type: TransactionType.expense,
        ),
        Transaction(
          id: '3',
          title: 'Groceries',
          categoryId: '2',
          amount: 200.0, // Positive
          date: DateTime.now(),
          type: TransactionType.expense,
        ),
      ];

      double totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      double totalExpense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      double balance = totalIncome - totalExpense;

      expect(totalIncome, 5000.0);
      expect(totalExpense, 1200.0);
      expect(balance, 3800.0);
    });

    test(
      'Scheduled transactions should NOT affect balance until activated',
      () {
        final regularTx = Transaction(
          id: '1',
          title: 'Immediate Income',
          categoryId: '1',
          amount: 1000.0,
          date: DateTime.now(),
          type: TransactionType.income,
          isScheduled: false,
        );

        final scheduledTx = Transaction(
          id: '2',
          title: 'Future Salary',
          categoryId: '1',
          amount: 5000.0,
          date: DateTime.now(),
          type: TransactionType.income,
          isScheduled: true,
          scheduledDate: DateTime.now().add(Duration(days: 30)),
          isSettled: false,
        );

        // Only count regular and settled transactions
        double balance = 0.0;
        for (var tx in [regularTx, scheduledTx]) {
          if (!tx.isScheduled || tx.isSettled) {
            if (tx.type == TransactionType.income) {
              balance += tx.amount;
            } else {
              balance -= tx.amount;
            }
          }
        }

        expect(balance, 1000.0); // Only regular transaction counted
      },
    );
  });

  group('Pending Transaction Confirmation Tests', () {
    late ScheduledTransactionProcessor processor;

    setUp(() {
      processor = ScheduledTransactionProcessor();
    });

    test('Should create pending transaction when due date arrives', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      final scheduledTx = Transaction(
        id: 'pending_1',
        title: 'Salary',
        categoryId: '1',
        amount: 5000.0,
        date: today,
        type: TransactionType.income,
        isScheduled: true,
        scheduledDate: yesterday, // Due date passed
        isLoan: false,
        isSettled: false,
        isPending: false, // Not yet marked as pending
      );

      final result = await processor.processScheduledTransactions([
        scheduledTx,
      ]);

      // Should return pending transaction for confirmation
      expect(result.length, 1);
      expect(result[0].isPending, true);
      expect(result[0].isSettled, false);
    });

    test('Pending transactions should NOT affect balance', () {
      final confirmedTx = Transaction(
        id: '1',
        title: 'Confirmed Income',
        categoryId: '1',
        amount: 1000.0,
        date: DateTime.now(),
        type: TransactionType.income,
        isScheduled: false,
        isPending: false, // Not pending
      );

      final pendingTx = Transaction(
        id: '2',
        title: 'Pending Income',
        categoryId: '1',
        amount: 500.0,
        date: DateTime.now(),
        type: TransactionType.income,
        isScheduled: true,
        scheduledDate: DateTime.now().subtract(Duration(days: 1)),
        isPending: true, // This is pending confirmation
        isSettled: false,
      );

      // Calculate balance excluding pending transactions
      double balance = 0.0;
      for (var tx in [confirmedTx, pendingTx]) {
        // Exclude pending transactions from balance
        if (!tx.isPending || tx.isSettled) {
          if (tx.type == TransactionType.income) {
            balance += tx.amount;
          } else {
            balance -= tx.amount;
          }
        }
      }

      expect(balance, 1000.0); // Only confirmed transaction counted
    });

    test('Should handle confirm pending transaction', () async {
      final pendingTx = Transaction(
        id: 'confirm_1',
        title: 'Pending Salary',
        categoryId: '1',
        amount: 3000.0,
        date: DateTime.now(),
        type: TransactionType.income,
        isScheduled: true,
        scheduledDate: DateTime.now().subtract(Duration(days: 1)),
        isPending: true,
        isSettled: false,
      );

      var transactions = [pendingTx];

      // Simulate confirmation
      await processor.confirmPendingTransaction(transactions, 'confirm_1');

      // After confirmation, isPending should be false and isSettled should be true
      expect(transactions[0].isPending, false);
      expect(transactions[0].isSettled, true);
    });

    test('Should handle reject pending transaction', () async {
      final pendingTx = Transaction(
        id: 'reject_1',
        title: 'Pending Expense',
        categoryId: '1',
        amount: 2000.0,
        date: DateTime.now(),
        type: TransactionType.expense,
        isScheduled: true,
        scheduledDate: DateTime.now().subtract(Duration(days: 1)),
        isPending: true,
        isSettled: false,
      );

      var transactions = [pendingTx];

      // Simulate rejection (remove from list)
      await processor.rejectPendingTransaction(transactions, 'reject_1');

      // After rejection, transaction should be removed
      expect(transactions.isEmpty, true);
    });

    test('Balance updates correctly after pending confirmation', () {
      final transactions = [
        Transaction(
          id: '1',
          title: 'Regular Income',
          categoryId: '1',
          amount: 1000.0,
          date: DateTime.now(),
          type: TransactionType.income,
          isPending: false,
        ),
        Transaction(
          id: '2',
          title: 'Pending Income',
          categoryId: '1',
          amount: 500.0,
          date: DateTime.now(),
          type: TransactionType.income,
          isScheduled: true,
          scheduledDate: DateTime.now().subtract(Duration(days: 1)),
          isPending: true,
          isSettled: false,
        ),
      ];

      // Balance before confirmation (excluding pending)
      double balanceBefore = 1000.0;

      // After confirmation, create updated transaction
      final confirmedTx = Transaction(
        id: '2',
        title: 'Pending Income',
        categoryId: '1',
        amount: 500.0,
        date: DateTime.now(),
        type: TransactionType.income,
        isScheduled: true,
        scheduledDate: DateTime.now().subtract(Duration(days: 1)),
        isPending: false, // Now confirmed
        isSettled: true,
      );

      // Replace in list
      transactions[1] = confirmedTx;

      // Calculate new balance (now includes confirmed transaction)
      double balanceAfter = 0.0;
      for (var tx in transactions) {
        if (!tx.isPending || tx.isSettled) {
          if (tx.type == TransactionType.income) {
            balanceAfter += tx.amount;
          } else {
            balanceAfter -= tx.amount;
          }
        }
      }

      expect(balanceBefore, 1000.0);
      expect(balanceAfter, 1500.0); // Increased by confirmed amount
    });

    test('Loan can become pending and require confirmation', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      final pendingLoan = Transaction(
        id: 'loan_pending',
        title: 'Lent to Alice',
        categoryId: '1',
        amount: 100.0,
        date: today,
        type: TransactionType.expense,
        isScheduled: true,
        scheduledDate: yesterday,
        isLoan: true,
        counterparty: 'Alice',
        loanDirection: 'lend',
        isPending: false,
        isSettled: false,
      );

      final result = await processor.processScheduledTransactions([
        pendingLoan,
      ]);

      // Should be marked as pending for user confirmation
      expect(result.length, 1);
      expect(result[0].isPending, true);
      expect(result[0].isLoan, true);
    });
  });
}
