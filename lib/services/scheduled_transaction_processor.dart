import 'package:app/models/models.dart';
import 'package:app/models/storage.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/services/currency_service.dart';

class ScheduledTransactionProcessor {
  static final ScheduledTransactionProcessor _instance =
      ScheduledTransactionProcessor._internal();

  factory ScheduledTransactionProcessor() {
    return _instance;
  }

  ScheduledTransactionProcessor._internal();

  final NotificationService _notificationService = NotificationService();

  /// Process scheduled and loan transactions:
  /// 1. Mark transactions as pending if their scheduled date is today or earlier
  /// 2. Schedule notifications for upcoming scheduled/loan transactions
  /// 3. Return list of transactions that need confirmation
  Future<List<Transaction>> processScheduledTransactions(
    List<Transaction> allTransactions,
  ) async {
    final List<Transaction> pendingConfirmations = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var transaction in allTransactions) {
      // Process scheduled transactions
      if (transaction.isScheduled &&
          transaction.scheduledDate != null &&
          !transaction.isSettled) {
        final schedDate = DateTime(
          transaction.scheduledDate!.year,
          transaction.scheduledDate!.month,
          transaction.scheduledDate!.day,
        );

        // If scheduled date is today or earlier, mark as pending confirmation
        if (schedDate.isBefore(today) || schedDate.isAtSameMomentAs(today)) {
          // Only add if not already pending
          if (!transaction.isPending) {
            pendingConfirmations.add(
              Transaction(
                id: transaction.id,
                title: transaction.title,
                categoryId: transaction.categoryId,
                amount: transaction.amount,
                date: transaction.date,
                type: transaction.type,
                isScheduled: true,
                scheduledDate: transaction.scheduledDate,
                isLoan: transaction.isLoan,
                counterparty: transaction.counterparty,
                loanDirection: transaction.loanDirection,
                isSettled: false, // Not settled yet
                isPending: true, // Waiting for confirmation
              ),
            );
          }
        }

        // Schedule a notification 1 day before the scheduled date
        final notificationDate = transaction.scheduledDate!.subtract(
          Duration(days: 1),
        );
        if (notificationDate.isAfter(now)) {
          await _notificationService.scheduleNotification(
            id: transaction.id.hashCode,
            title: 'Scheduled Transaction Reminder',
            body:
                '${transaction.title} for ${CurrencyService.instance.formatAmount(transaction.amount)} is due tomorrow',
            scheduledDateTime: notificationDate,
            payload: transaction.id,
          );
        }
      }

      // Process loan transactions
      if (transaction.isLoan && transaction.scheduledDate != null) {
        // Schedule notification 1 day before due date
        final notificationDate = transaction.scheduledDate!.subtract(
          Duration(days: 1),
        );
        if (notificationDate.isAfter(now) && !transaction.isSettled) {
          final direction =
              transaction.loanDirection == 'lend'
                  ? 'will receive from'
                  : 'owes to';
          await _notificationService.scheduleNotification(
            id: ('${transaction.id}_loan').hashCode,
            title: 'Loan Reminder',
            body:
                'You $direction ${transaction.counterparty} for ${CurrencyService.instance.formatAmount(transaction.amount)}. Due: ${transaction.scheduledDate!.month}/${transaction.scheduledDate!.day}',
            scheduledDateTime: notificationDate,
            payload: transaction.id,
          );
        }

        // If due date is today, show immediate notification
        final schedDate = DateTime(
          transaction.scheduledDate!.year,
          transaction.scheduledDate!.month,
          transaction.scheduledDate!.day,
        );
        if ((schedDate.isBefore(today) || schedDate.isAtSameMomentAs(today)) &&
            !transaction.isSettled) {
          final direction =
              transaction.loanDirection == 'lend' ? 'receive from' : 'pay to';
          await _notificationService.showNotification(
            id: ('${transaction.id}_loan_due').hashCode,
            title: 'Loan Due Today',
            body:
                'You should $direction ${transaction.counterparty} ${CurrencyService.instance.formatAmount(transaction.amount)}',
            payload: transaction.id,
          );
        }
      }
    }

    return pendingConfirmations;
  }

  /// Update a loan/scheduled transaction as settled
  Future<void> settleTransaction(
    List<Transaction> allTransactions,
    String transactionId,
    bool received,
  ) async {
    final index = allTransactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final oldTx = allTransactions[index];
      final settledTx = Transaction(
        id: oldTx.id,
        title: oldTx.title,
        categoryId: oldTx.categoryId,
        amount: oldTx.amount,
        date: oldTx.date,
        type: oldTx.type,
        isScheduled: oldTx.isScheduled,
        scheduledDate: oldTx.scheduledDate,
        isLoan: oldTx.isLoan,
        counterparty: oldTx.counterparty,
        loanDirection: oldTx.loanDirection,
        isSettled: true, // Mark as settled
        isPending: false, // No longer pending
      );

      allTransactions[index] = settledTx;
      await saveTransactions(allTransactions);

      // Cancel any pending notifications
      await _notificationService.cancelNotification(oldTx.id.hashCode);
      await _notificationService.cancelNotification(
        ('${oldTx.id}_loan').hashCode,
      );
    }
  }

  /// Confirm a pending transaction - mark it as settled and apply to balance
  Future<void> confirmPendingTransaction(
    List<Transaction> allTransactions,
    String transactionId,
  ) async {
    final index = allTransactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final oldTx = allTransactions[index];
      final confirmedTx = Transaction(
        id: oldTx.id,
        title: oldTx.title,
        categoryId: oldTx.categoryId,
        amount: oldTx.amount,
        date: oldTx.scheduledDate ?? oldTx.date,
        type: oldTx.type,
        // Once confirmed, it should no longer be treated as a scheduled transaction
        isScheduled: false,
        scheduledDate: null,
        isLoan: oldTx.isLoan,
        counterparty: oldTx.counterparty,
        loanDirection: oldTx.loanDirection,
        isSettled: true, // Mark as settled (confirmed)
        isPending: false, // No longer pending
      );

      allTransactions[index] = confirmedTx;
      await saveTransactions(allTransactions);
      // Cancel any scheduled notifications for this transaction
      await _notificationService.cancelNotification(oldTx.id.hashCode);
      await _notificationService.cancelNotification(
        ('${oldTx.id}_loan').hashCode,
      );
    }
  }

  /// Reject a pending transaction - remove it without applying to balance
  Future<void> rejectPendingTransaction(
    List<Transaction> allTransactions,
    String transactionId,
  ) async {
    // Simply remove the transaction from the list
    allTransactions.removeWhere((t) => t.id == transactionId);
    await saveTransactions(allTransactions);
  }
}
