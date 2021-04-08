import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Utils {
  static const MethodChannel methodChannel =
      const MethodChannel('plugins.wilburt/flutter_paystack');

  static String getKeyErrorMsg(String keyType) {
    return 'Invalid $keyType key. You must use a valid $keyType key. Ensure that you '
        'have set a $keyType key. Check http://paystack.co for more';
  }

  static NumberFormat? _currencyFormatter;

  static setCurrencyFormatter(String? currency, String? locale) =>
      _currencyFormatter =
          NumberFormat.currency(locale: locale, name: '$currency\u{0020}');

  static String formatAmount(num amountInBase) {
    if (_currencyFormatter == null) throw "Currency formatter not initialized.";
    return _currencyFormatter!.format((amountInBase / 100));
  }

  /// Add double spaces after every 4th character
  static String addSpaces(String text) {
    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }
    return buffer.toString();
  }
}
