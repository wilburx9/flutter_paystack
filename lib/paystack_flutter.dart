import 'dart:async';

import 'package:flutter/services.dart';

class PaystackFlutter {
  static const MethodChannel channel =
      const MethodChannel('paystack_flutter');

  static Future<String> get platformVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
