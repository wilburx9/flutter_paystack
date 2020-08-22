import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/common/string_utils.dart';
import 'package:flutter_paystack/src/models/charge.dart';
import 'package:intl/intl.dart';

class Utils {
  static const MethodChannel channel = const MethodChannel('plugins.wilburt/flutter_paystack');

  static validateSdkInitialized() {
    if (!PaystackPlugin.sdkInitialized) {
      throw new PaystackSdkNotInitializedException(
          'Paystack SDK has not been initialized. The SDK has'
          ' to be initialized before use');
    }
  }

  static String getKeyErrorMsg(String keyType) {
    return 'Invalid $keyType key. You must use a valid $keyType key. Ensure that you '
        'have set a $keyType key. Check http://paystack.co for more';
  }

  static NumberFormat _currencyFormatter;

  static setCurrencyFormatter(String currency, String locale) =>
      _currencyFormatter =
          NumberFormat.currency(locale: locale, name: '$currency\u{0020}');

  static String formatAmount(num amountInBase) {
    if (_currencyFormatter == null) throw "Currency formatter not initalized.";
    return _currencyFormatter.format((amountInBase / 100));
  }

  static validateChargeAndKey(Charge charge) {
    String publicKey = PaystackPlugin.publicKey;

    if (publicKey == null ||
        publicKey.isEmpty ||
        !publicKey.startsWith("pk_")) {
      throw new AuthenticationException(Utils.getKeyErrorMsg('public'));
    }

    if (charge == null) {
      throw new PaystackException('charge must not be null');
    }
    if (charge.amount == null || charge.amount.isNegative) {
      throw new InvalidAmountException(charge.amount);
    }
    if (!StringUtils.isValidEmail(charge.email)) {
      throw new InvalidEmailException(charge.email);
    }
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
