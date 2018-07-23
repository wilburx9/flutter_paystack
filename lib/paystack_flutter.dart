import 'dart:async';

import 'package:flutter/services.dart';

class PaystackFlutter {
  static const MethodChannel _channel =
      const MethodChannel('paystack_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
