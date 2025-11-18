import 'package:http/http.dart' as http;
import 'dart:convert';

/// Exchange rate service for converting between USD and UZS
/// Fetches live exchange rates from API
class ExchangeRateService {
  static double _usdToUzsRate = 12800.0; // Default fallback rate
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Get current USD to UZS rate
  static double get usdToUzsRate => _usdToUzsRate;

  /// Fetch current exchange rate from API
  /// Returns true if successful, false if using cached rate
  static Future<bool> fetchExchangeRate() async {
    try {
      // Check if we have a fresh cached rate
      if (_lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return true; // Using cached rate
      }

      // Try to fetch from multiple sources
      final rates = await Future.any([
        _fetchFromCBU(), // Central Bank of Uzbekistan
        _fetchFromOpenExchangeRates(),
      ]);

      if (rates > 0) {
        _usdToUzsRate = rates;
        _lastFetchTime = DateTime.now();
        return true;
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
      // Continue using cached rate
    }
    return false;
  }

  /// Fetch from Central Bank of Uzbekistan API
  static Future<double> _fetchFromCBU() async {
    final response = await http
        .get(Uri.parse('https://nbu.uz/uz/exchange-rates/json/'))
        .timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      for (var currency in data) {
        if (currency['code'] == 'USD') {
          final rate = double.parse(currency['cb_price'].toString());
          return rate;
        }
      }
    }
    return -1;
  }

  /// Fetch from OpenExchangeRates API (fallback)
  static Future<double> _fetchFromOpenExchangeRates() async {
    // Using free API endpoint
    final response = await http
        .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
        .timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['rates'] != null && data['rates']['UZS'] != null) {
        final rate = double.parse(data['rates']['UZS'].toString());
        return rate;
      }
    }
    return -1;
  }

  /// Convert USD to UZS
  static double usdToUzs(double usd) {
    return usd * _usdToUzsRate;
  }

  /// Convert UZS to USD
  static double uzsToUsd(double uzs) {
    return uzs / _usdToUzsRate;
  }

  /// Convert from one currency to another
  /// Returns the converted amount
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    if (fromCurrency == 'USD' && toCurrency == 'UZS') return usdToUzs(amount);
    if (fromCurrency == 'UZS' && toCurrency == 'USD') return uzsToUsd(amount);
    return amount;
  }
}
