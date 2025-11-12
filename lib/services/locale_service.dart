import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

class LocaleService {
  static const _key = 'app_locale';

  static Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
