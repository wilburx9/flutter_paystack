import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/service/base_service.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/paystack.dart';
import 'package:http/http.dart' as http;

class WebService extends BaseApiService {
  WebService()
      : super(baseUrl: 'https://api.paystack.co/charge', headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${PaystackPlugin.secretKey}',
          HttpHeaders.cacheControlHeader: 'no-cache',
          HttpHeaders.acceptHeader: 'application/json',
        });

  Future<TransactionApiResponse> chargeBank(Map<String, dynamic> fields) async {
    var url = baseUrl;
    headers[HttpHeaders.contentTypeHeader] = 'application/json';
    return _getChargeFuture(url, fields: jsonEncode(fields));
  }

  Future<TransactionApiResponse> sendBirthday(
      Map<String, String> fields) async {
    headers.remove(HttpHeaders.contentTypeHeader);
    var url = '$baseUrl/submit_birthday';
    return _getChargeFuture(url,
        fields: fields, reference: fields['reference']);
  }

  Future<TransactionApiResponse> sendOtp(Map<String, String> fields) async {
    headers.remove(HttpHeaders.contentTypeHeader);
    var url = '$baseUrl/submit_otp';
    return _getChargeFuture(url, fields: fields);
  }

  Future<TransactionApiResponse> checkPending(String reference) async {
    headers.remove(HttpHeaders.contentTypeHeader);
    var url = '$baseUrl/$reference';
    var completer = Completer<TransactionApiResponse>();

    try {
      http.Response response = await http.get(url, headers: headers);
      return _getResponseFuture(response, completer);
    } catch (e, stacktrace) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<TransactionApiResponse> _getChargeFuture(String url,
      {var fields, String reference}) async {
    var completer = Completer<TransactionApiResponse>();

    try {
      http.Response response =
          await http.post(url, body: fields, headers: headers);
      return _getResponseFuture(response, completer, reference: reference);
    } catch (e, stacktrace) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<TransactionApiResponse> _getResponseFuture(
      http.Response response, Completer<TransactionApiResponse> completer,
      {String reference}) {
    var body = response.body;
    
    Map<String, dynamic> responseBody = json.decode(body);

    var statusCode = response.statusCode;

    if (statusCode == HttpStatus.ok) {
      completer.complete(TransactionApiResponse.fromMap(
        responseBody['data'],
        reference: reference,
      ));
    } else {
      String message;
      if (responseBody.containsKey('data') &&
          (responseBody['data'] as Map).containsKey('message')) {
        message = responseBody['data']['message'];
      } else {
        message = responseBody['message'];
      }
      completer.completeError(new ChargeException(message));
    }
    return completer.future;
  }
}
