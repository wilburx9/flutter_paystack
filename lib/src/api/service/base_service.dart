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
    'bindings_version': "1.3.0+1", // TODO: Update for every new versions
    'X-FLUTTER-USER-AGENT': jsonEncode({'version': '1.0.0'})
  };
  final String baseUrl = 'https://standard.paystack.co';
}
