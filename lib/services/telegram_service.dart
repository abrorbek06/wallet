import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelegramService {
  static const _tokenKey = 'telegram_bot_token';
  static const _chatIdKey = 'telegram_chat_id';

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
    final token = botToken ?? creds['token'];
    final chat = chatId ?? creds['chatId'];
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
