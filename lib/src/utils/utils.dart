import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/ui/widgets/checkout/bank_checkout.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Utils {
  static const MethodChannel channel = const MethodChannel('flutter_paystack');

  static AsyncMemoizer banksMemo = new AsyncMemoizer();

  static Future getSupportedBanks() => Utils.banksMemo.runOnce(() async {
        const url =
            'https://api.paystack.co/bank?gateway=emandate&pay_with_bank=true';
        try {
          http.Response response = await http.get(url);
          Map<String, dynamic> body = json.decode(response.body);
          var data = body['data'];
          List<Bank> banks = [];
          for (var bank in data) {
            banks.add(new Bank(bank['name'], bank['code']));
          }
          return banks;
        } catch (e) {
        }
        return null;
      });

  static validateSdkInitialized() {
    if (!PaystackPlugin.sdkInitialized) {
      throw new PaystackSdkNotInitializedException(
          'Paystack SDK has not been initialized. The SDK has'
          ' to be initialized before use');
    }
  }

  static hasPublicKey() {
    var publicKey = PaystackPlugin.publicKey;
    if (publicKey == null || publicKey.isEmpty) {
      throw PaystackException(
          'No Public key found, please set the Public key.');
    }
  }

  static hasSecretKey() {
    var secretKey = PaystackPlugin.secretKey;
    if (secretKey == null || secretKey.isEmpty) {
      throw PaystackException(
          'No Secret key found, please set the Secret key.');
    }
  }

  static String getKeyErrorMsg(String keyType) {
    return 'Invalid $keyType key. You must use a valid $keyType key. Ensure that you '
        'have set a $keyType key. Check http://paystack.co for more';
  }

  static validatePlatformSpecificInfo() {}

  static final _currencyFormatter = new NumberFormat.currency(
      locale: Strings.nigerianLocale, name: 'NGN\u{0020} ');

  static String formatAmount(num amountInKobo) {
    return _currencyFormatter.format((amountInKobo / 100));
  }

  static validateChargeAndKeys(Charge charge) {
    String publicKey = PaystackPlugin.publicKey;
    String secretKey = PaystackPlugin.secretKey;

    if (publicKey == null ||
        publicKey.isEmpty ||
        !publicKey.startsWith("pk_")) {
      throw new AuthenticationException(Utils.getKeyErrorMsg('public'));
    }

    if (secretKey == null ||
        secretKey.isEmpty ||
        !secretKey.startsWith("sk_")) {
      throw new AuthenticationException(Utils.getKeyErrorMsg('secret'));
    }

    if (charge == null) {
      throw new PaystackException('charge must not be null');
    }
    if (charge.amount == null || charge.amount.isNegative) {
      throw new InvalidAmountException(charge.amount);
    }
    if (charge.email == null || charge.email.isEmpty) {
      throw new InvalidEmailException(charge.email);
    }
  }
}
