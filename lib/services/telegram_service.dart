import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelegramService {
  // (Removed any accidental hardcoded values here.)
  // Optional: hardcode your bot token/chat id here if you prefer to embed it in code.
  // WARNING: hardcoding secrets in source is not recommended for production.
  // If you want to hardcode, set the values below (replace null with your values).
  // Example: static const String? _defaultBotToken = '123456:ABC-DEF...';
  static const String? _defaultBotToken = null;
  // Example for chat id: static const String? _defaultChatId = '123456789';
  static const String? _defaultChatId = null;

  // Keys used to persist credentials in SharedPreferences
  static const _tokenKey = '7625131432:AAHgBxHagdB08uf9A8twVTNYsZhq0UbOPss';
  static const _chatIdKey = '1648001576';

  /// Save bot token and chat id to SharedPreferences
  static Future<void> saveCredentials(String token, String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_chatIdKey, chatId);
  }

  /// Get saved credentials (may return null values)
  static Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'chatId': prefs.getString(_chatIdKey),
    };
  }

  /// Send feedback message to configured Telegram bot/chat
  /// Throws on error with descriptive message
  static Future<bool> sendFeedback(
    String message, {
    String? botToken,
    String? chatId,
  }) async {
    final creds = await getCredentials();
    // Resolve token/chat in the following order:
    // 1) explicit parameters passed to the call
    // 2) saved credentials in SharedPreferences
    // 3) optional hardcoded defaults in this file
    final token = botToken ?? creds['token'] ?? _defaultBotToken;
    final chat = chatId ?? creds['chatId'] ?? _defaultChatId;
    if (token == null || chat == null) {
      throw Exception('Telegram bot token or chat id not configured.');
    }

    final url = Uri.parse('https://api.telegram.org/bot$token/sendMessage');
    final body = {'chat_id': chat, 'text': message};

    final resp = await http.post(url, body: body);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['ok'] == true) return true;
      throw Exception('Telegram API error: ${data.toString()}');
    } else {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
  }
}
