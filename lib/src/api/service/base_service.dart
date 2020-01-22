import 'dart:convert';
import 'dart:io';

import 'package:flutter_paystack/src/common/platform_info.dart';

mixin BaseApiService {
  final Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    HttpHeaders.userAgentHeader: PlatformInfo().userAgent,
    HttpHeaders.acceptHeader: 'application/json',
    'X-Paystack-Build': PlatformInfo().paystackBuild,
    'X-PAYSTACK-USER-AGENT':
        jsonEncode({'lang': Platform.isIOS ? 'objective-c' : 'kotlin'}),
    'bindings_version': Platform.isIOS
        ? '3.0.5' // Latest version of Paystack official iOS SDK
        : '3.0.10', // Latest version of Paystack official Android SDK
    'X-FLUTTER-USER-AGENT': jsonEncode({'version': '1.0.0'})
  };
  final String baseUrl = 'https://standard.paystack.co';
}
