import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:paystack_flutter/src/utils/string_utils.dart';

export 'package:paystack_flutter/src/model/card.dart';
export 'package:paystack_flutter/src/paystack.dart' hide Paystack;

class PaystackSdk {
  static bool _sdkInitialized;
  static String _publicKey;


  PaystackSdk.initialize();

  static bool get sdkInitialized => _sdkInitialized;

  static String get publicKey => _publicKey;

  static Future<String> get platformVersion async {
    final String version = await StringUtils.channel.invokeMethod
      ('getPlatformVersion');
    return version;
  }
}
