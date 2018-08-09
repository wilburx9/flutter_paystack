import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/platform_info.dart';

class ApiService {
  static const baseUrl = 'https://standard.paystack.co';
  Map<String, String> headers = {};

  ApiService() {
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    headers['User-Agent'] = PlatformInfo().userAgent;
    headers['X-Paystack-Build'] = PlatformInfo().paystackBuild;
    headers['Accept'] = 'application/json';
  }

  Future<TransactionApiResponse> charge(Map<String, String> fields) async {
    var url = '$baseUrl/charge/mobile_charge';
    var completer = Completer<TransactionApiResponse>();

    try {
      http.Response response =
          await http.post(url, body: fields, headers: headers);
      var body = response.body;

      var statusCode = response.statusCode;

      if (statusCode == HttpStatus.OK) {
        Map<String, dynamic> responseBody = json.decode(body);
        completer.complete(TransactionApiResponse.fromMap(responseBody));
      } else {
        completer.completeError('charge transaction failed with status code: '
            '$statusCode and response: $body');
      }
    } catch (e) {
      completer.completeError('charge transaction failed error: $e');
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
      if (statusCode == HttpStatus.OK) {
        Map<String, dynamic> responseBody = json.decode(body);
        completer.complete(TransactionApiResponse.fromMap(responseBody));
      } else {
        completer.completeError('validate charge transaction failed with '
            'status code: $statusCode and response: $body');
      }
    } catch (e) {
      completer.completeError('validate charge transaction failed error: $e');
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
      if (statusCode == HttpStatus.OK) {
        Map<String, dynamic> responseBody = json.decode(body);
        completer.complete(TransactionApiResponse.fromMap(responseBody));
      } else {
        completer.completeError('requery transaction failed with status code: '
            '$statusCode and response: $body');
      }
    } catch (e) {
      completer.completeError('requery transaction failed error: $e');
    }

    return completer.future;
  }
}
