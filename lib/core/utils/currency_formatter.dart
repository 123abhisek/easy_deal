import 'package:intl/intl.dart';

class CurrencyHelper {
  CurrencyHelper._();

  static String format(num? amount) {
    if (amount == null) return 'Price on Request';
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static String formatCompact(num? amount) {
    if (amount == null || amount <= 0) return 'Price on Request';
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹${cr.toStringAsFixed(cr % 1 == 0 ? 0 : 2)} Cr';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      return '₹${lakh.toStringAsFixed(lakh % 1 == 0 ? 0 : 2)} Lakh';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      return '₹${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)} K';
    }
    return '₹$amount';
  }

  static String toWords(num? amount) {
    if (amount == null || amount <= 0) return '';
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹ ${cr.toStringAsFixed(2)} Crores';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      return '₹ ${lakh.toStringAsFixed(2)} Lakhs';
    } else if (amount >= 1000) {
      final thousand = amount / 1000;
      return '₹ ${thousand.toStringAsFixed(1)} Thousands';
    }
    return '₹ ${amount.toStringAsFixed(0)}';
  }
}
