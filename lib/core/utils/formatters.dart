import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 0,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 0,
  );

  static String formatCurrency(num? amount, {bool compact = false}) {
    if (amount == null) return r'$0';
    final rounded = amount.round();
    if (compact && rounded >= 1000) {
      return _compactCurrencyFormat.format(rounded);
    }
    return _currencyFormat.format(rounded);
  }

  static String formatCarat(num? carat) {
    if (carat == null) return '0.00 Carat';
    return '${carat.toStringAsFixed(2)} Carat';
  }

  static String cleanString(String? text) {
    if (text == null) return '-';
    final cleaned = text.trim();
    return cleaned.isEmpty ? '-' : cleaned;
  }

  static bool isValidUrl(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'null' ||
        trimmed.toLowerCase() == 'n/a' ||
        trimmed.toLowerCase() == 'none' ||
        trimmed.toLowerCase() == 'undefined' ||
        trimmed == '0') {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority &&
        uri.host.isNotEmpty;
  }
}
