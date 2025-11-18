import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/models.dart';
import '../models/storage.dart';

/// Shared Database Server
/// Exposes app's SharedPreferences as an HTTP API for the bot to access.
/// This ensures both app and bot read/write to the same database.
///
/// Usage:
/// 1. Start in main.dart or HomeScreen:
///    final dbServer = SharedDatabaseServer();
///    await dbServer.start(port: 5003);
///
/// 2. Configure bot to use this endpoint:
///    BOT_DATABASE_URL=http://127.0.0.1:5003
///
/// 3. Bot will fetch/push to:
///    - GET /transactions  → returns app's SharedPreferences transactions
///    - POST /transactions → saves to app's SharedPreferences
///    - GET /settings      → returns exchange rate, etc.
class SharedDatabaseServer {
  HttpServer? _server;
  int? _listeningPort;

  /// Start the database server on localhost
  /// Returns the port the server is listening on
  Future<int> start({int port = 5003}) async {
    try {
      _server = await HttpServer.bind('127.0.0.1', port);
      _listeningPort = port;

      // Listen for incoming requests
      _server!.listen(_handleRequest);

      print('[SharedDB] Server started on http://127.0.0.1:$port');
      return port;
    } catch (e) {
      print('[SharedDB] Failed to start: $e');
      rethrow;
    }
  }

  /// Handle incoming HTTP request
  Future<void> _handleRequest(HttpRequest request) async {
    try {
      // Enable CORS for bot access
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add(
        'Access-Control-Allow-Methods',
        'GET, POST, OPTIONS',
      );
      request.response.headers.add(
        'Access-Control-Allow-Headers',
        'Content-Type',
      );

      if (request.method == 'OPTIONS') {
        request.response.statusCode = 200;
        request.response.close();
        return;
      }

      if (request.method == 'GET' && request.uri.path == '/transactions') {
        // Return all transactions from app's SharedPreferences
        final transactions = await loadTransactions();
        final jsonList = transactions.map((t) => t.toJson()).toList();

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(jsonList))
          ..close();

        print(
          '[SharedDB] GET /transactions → returned ${transactions.length} transactions',
        );
      } else if (request.method == 'POST' &&
          request.uri.path == '/transactions') {
        // Accept transaction from bot and save to app's SharedPreferences
        final body = await utf8.decoder.bind(request).join();
        final json = jsonDecode(body) as Map<String, dynamic>;

        try {
          // Parse the transaction
          final tx = _parseTransaction(json);
          if (tx != null) {
            // Load existing transactions
            final existing = await loadTransactions();

            // Check for duplicates by ID
            final isDuplicate = existing.any((t) => t.id == tx.id);

            if (!isDuplicate) {
              existing.add(tx);
              await saveTransactions(existing);

              request.response
                ..statusCode = 201
                ..headers.contentType = ContentType.json
                ..write(
                  jsonEncode({
                    'status': 'ok',
                    'message': 'Transaction saved to app database',
                    'txId': tx.id,
                    'totalCount': existing.length,
                  }),
                )
                ..close();

              print(
                '[SharedDB] POST /transactions → saved transaction ${tx.id}',
              );
            } else {
              request.response
                ..statusCode = 200
                ..headers.contentType = ContentType.json
                ..write(
                  jsonEncode({
                    'status': 'ok',
                    'message': 'Transaction already exists (duplicate)',
                    'txId': tx.id,
                  }),
                )
                ..close();

              print(
                '[SharedDB] POST /transactions → duplicate ${tx.id}, skipped',
              );
            }
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
        } catch (e) {
          request.response
            ..statusCode = 400
            ..write(jsonEncode({'status': 'error', 'message': e.toString()}))
            ..close();
        }
      } else if (request.method == 'GET' && request.uri.path == '/health') {
        // Health check endpoint
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({'status': 'ok', 'service': 'shared-database-server'}),
          )
          ..close();

        print('[SharedDB] GET /health → ok');
      } else {
        request.response
          ..statusCode = 404
          ..write(jsonEncode({'status': 'error', 'message': 'Not found'}))
          ..close();
      }
    } catch (e) {
      print('[SharedDB] Error handling request: $e');
      try {
        request.response
          ..statusCode = 500
          ..write(jsonEncode({'status': 'error', 'message': e.toString()}))
          ..close();
      } catch (_) {
        // Response already closed, ignore
      }
    }
  }

  /// Parse transaction from bot/API format
  Transaction? _parseTransaction(Map<String, dynamic> json) {
    try {
      // Handle both app format and bot format
      final typeStr = json['type'] as String?;
      final type =
          (typeStr == 'income' || typeStr == 'TransactionType.income')
              ? TransactionType.income
              : TransactionType.expense;

      return Transaction(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Transaction',
        categoryId: json['categoryId'] as String? ?? 'other',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        type: type,
        inputCurrency:
            (json['inputCurrency'] as String? ?? 'UZS').toUpperCase(),
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        isScheduled: json['isScheduled'] as bool? ?? false,
        scheduledDate:
            json['scheduledDate'] == null
                ? null
                : DateTime.tryParse(json['scheduledDate'] as String? ?? ''),
        isLoan: json['isLoan'] as bool? ?? false,
        counterparty: json['counterparty'] as String?,
        loanDirection: json['loanDirection'] as String?,
        isSettled: json['isSettled'] as bool? ?? false,
        isPending: json['isPending'] as bool? ?? false,
      );
    } catch (e) {
      print('[SharedDB] Failed to parse transaction: $e');
      return null;
    }
  }

  /// Stop the database server
  Future<void> stop() async {
    await _server?.close();
    _server = null;
    _listeningPort = null;
    print('[SharedDB] Server stopped');
  }

  /// Check if server is running
  bool get isRunning => _server != null && _listeningPort != null;

  /// Get the listening port
  int? get listeningPort => _listeningPort;
}
