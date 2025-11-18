import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'exchange_rate_service.dart';

enum Currency { USD, UZS }

class CurrencyService extends ChangeNotifier {
  static const _prefKey = 'selected_currency';
  static late CurrencyService instance;
  static final ValueNotifier<Currency> notifier = ValueNotifier<Currency>(
    Currency.USD,
  );

  late SharedPreferences _prefs;
  Currency _currency = Currency.USD;

  CurrencyService._();

  static Future<void> init() async {
    final s = CurrencyService._();
    s._prefs = await SharedPreferences.getInstance();
    final v = s._prefs.getString(_prefKey);
    if (v == 'UZS') s._currency = Currency.UZS;
    notifier.value = s._currency;
    instance = s;
  }

  Currency get currency => _currency;

  Future<void> setCurrency(Currency c) async {
    _currency = c;
    await _prefs.setString(_prefKey, c == Currency.UZS ? 'UZS' : 'USD');
    notifier.value = c;
    notifyListeners();
  }

  String symbol() {
    return _currency == Currency.USD ? r'$' : "so'm";
  }

  /// Format amount for display, with optional conversion from input currency
  String formatAmount(double amount, {String? inputCurrency}) {
    double displayAmount = amount;

    // If input currency differs from display currency, convert
    if (inputCurrency != null &&
        inputCurrency != 'USD' &&
        inputCurrency != 'UZS') {
      inputCurrency = 'USD'; // Default to USD if invalid
    }

    if (inputCurrency != null) {
      final displayCurrencyStr = _currency == Currency.USD ? 'USD' : 'UZS';
      if (inputCurrency != displayCurrencyStr) {
        displayAmount = ExchangeRateService.convert(
          amount,
          inputCurrency,
          displayCurrencyStr,
        );
      }
    }

    if (_currency == Currency.USD) {
      // show two decimals for USD
      final f = NumberFormat.currency(locale: 'en_US', symbol: r'$');
      return f.format(displayAmount);
    } else {
      // UZS typically shown without decimals and with grouping
      final rounded = displayAmount.round();
      final f = NumberFormat.decimalPattern();
      return '${f.format(rounded)} ${"so'm"}';
    }
  }
}
