import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/service/base_service.dart';
import 'package:flutter_paystack/src/common/platform_info.dart';
import 'package:http/http.dart' as http;

class MobileService extends BaseApiService {
  MobileService()
      : super(baseUrl: 'https://standard.paystack.co', headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.userAgentHeader: PlatformInfo().userAgent,
          HttpHeaders.acceptHeader: 'application/json',
          'X-Paystack-Build': PlatformInfo().paystackBuild,
          'X-PAYSTACK-USER-AGENT':
              jsonEncode({'lang': Platform.isIOS ? 'objective-c' : 'kotlin'}),
          'bindings_version': Platform.isIOS
              ? '3.0.5' // Latest version of Paystack official iOS SDK
              : '3.0.10', // Latest version of Paystack official Android SDK
          'X-FLUTTER-USER-AGENT': jsonEncode({'version': '0.9.3'})
        });

  // Mobile Charge
  Future<TransactionApiResponse> chargeCard(Map<String, String> fields) async {
    var url = '$baseUrl/charge/mobile_charge';
    var completer = Completer<TransactionApiResponse>();

    try {
      http.Response response =
          await http.post(url, body: fields, headers: headers);
      var body = response.body;

      var statusCode = response.statusCode;

      if (statusCode == HttpStatus.ok) {
        Map<String, dynamic> responseBody = json.decode(body);
        completer.complete(TransactionApiResponse.fromMap(responseBody));
      } else {
        completer.completeError('charge transaction failed with status code: '
            '$statusCode and response: $body');
      }
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<TransactionApiResponse> validateCharge(
      Map<String, String> fields) async {
    var url = '$baseUrl/charge/validate';

    var completer = Completer<TransactionApiResponse>();
    try {
      http.Response response =
          await http.post(url, body: fields, headers: headers);
      var body = response.body;

      var statusCode = response.statusCode;
      if (statusCode == HttpStatus.ok) {
        Map<String, dynamic> responseBody = json.decode(body);
        completer.complete(TransactionApiResponse.fromMap(responseBody));
      } else {
        completer.completeError('validate charge transaction failed with '
            'status code: $statusCode and response: $body');
      }
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<TransactionApiResponse> reQueryTransaction(String trans) async {
    var url = '$baseUrl/requery/$trans';
    var completer = Completer<TransactionApiResponse>();
    try {
      http.Response response = await http.get(url, headers: headers);
      var body = response.body;
      var statusCode = response.statusCode;
      if (statusCode == HttpStatus.ok) {
        Map<String, dynamic> responseBody = json.decode(body);
        completer.complete(TransactionApiResponse.fromMap(responseBody));
      } else {
        completer.completeError('requery transaction failed with status code: '
            '$statusCode and response: $body');
      }
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }
}
