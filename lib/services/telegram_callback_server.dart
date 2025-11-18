import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/models.dart';
import '../models/storage.dart';

/// Telegram Callback Server
/// Listens for POST requests from Telegram bot when transactions are added.
///
/// Usage:
/// 1. Start server in main.dart or HomeScreen:
///    final server = TelegramCallbackServer();
///    await server.start(port: 5002);
///
/// 2. Set APP_CALLBACK_URL in bot .env:
///    APP_CALLBACK_URL=http://127.0.0.1:5002/telegram
///
/// 3. Bot will POST transactions to this endpoint when created.
class TelegramCallbackServer {
  HttpServer? _server;
  int? _listeningPort;
  final int defaultPort = 5002;
  late Function(Transaction) onTransactionReceived;

  TelegramCallbackServer({Function(Transaction)? onReceived}) {
    onTransactionReceived = onReceived ?? (_) {};
  }

  /// Start the callback server on localhost
  /// Returns the port the server is listening on
  Future<int> start({int port = 5002}) async {
    try {
      _server = await HttpServer.bind('127.0.0.1', port);
      _listeningPort = port;

      // Listen for incoming requests
      _server!.listen(_handleRequest);

      print('[CallbackServer] Started on http://127.0.0.1:$port');
      return port;
    } catch (e) {
      print('[CallbackServer] Failed to start: $e');
      rethrow;
    }
  }

  /// Handle incoming HTTP request
  Future<void> _handleRequest(HttpRequest request) async {
    try {
      if (request.method == 'POST' && request.uri.path == '/telegram') {
        // Read request body
        final body = await utf8.decoder.bind(request).join();
        final json = jsonDecode(body) as Map<String, dynamic>;

        // Parse transaction from bot format
        final tx = _parseTransaction(json);
        if (tx != null) {
          // Notify listener (UI will update)
          onTransactionReceived(tx);

          // Add to app storage to persist
          final existing = await loadTransactions();
          // Deduplicate by ID
          if (!existing.any((t) => t.id == tx.id)) {
            existing.add(tx);
            await saveTransactions(existing);
          }

          // Respond with 200 OK
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'status': 'ok', 'txId': tx.id}))
            ..close();

          print(
            '[CallbackServer] Received and saved transaction from bot: ${tx.id}',
          );
        } else {
          request.response
            ..statusCode = 400
            ..write(
              jsonEncode({
                'status': 'error',
                'message': 'Invalid transaction format',
              }),
            )
            ..close();
        }
      } else {
        request.response
          ..statusCode = 404
          ..write(jsonEncode({'status': 'error', 'message': 'Not found'}))
          ..close();
      }
    } catch (e) {
      print('[CallbackServer] Error handling request: $e');
      request.response
        ..statusCode = 500
        ..write(jsonEncode({'status': 'error', 'message': e.toString()}))
        ..close();
    }
  }

  /// Parse transaction from bot JSON format
  /// Bot sends: {id, title, amount, type: 'income'|'expense', inputCurrency, date, isSettled}
  Transaction? _parseTransaction(Map<String, dynamic> json) {
    try {
      final typeStr = json['type'] as String?; // 'income' or 'expense'
      final type =
          typeStr == 'income'
              ? TransactionType.income
              : TransactionType.expense;

      return Transaction(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Telegram Transaction',
        categoryId: 'telegram', // Default category for bot transactions
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        type: type,
        inputCurrency:
            (json['inputCurrency'] as String? ?? 'UZS').toUpperCase(),
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        isSettled: json['isSettled'] as bool? ?? true,
      );
    } catch (e) {
      print('[CallbackServer] Failed to parse transaction: $e');
      return null;
    }
  }

  /// Stop the callback server
  Future<void> stop() async {
    await _server?.close();
    _server = null;
    _listeningPort = null;
    print('[CallbackServer] Stopped');
  }

  /// Check if server is running
  bool get isRunning => _server != null && _listeningPort != null;

  /// Get the listening port
  int? get listeningPort => _listeningPort;
}
