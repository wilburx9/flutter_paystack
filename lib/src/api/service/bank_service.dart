import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/request/bank_charge_request_body.dart';
import 'package:flutter_paystack/src/api/service/base_service.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:http/http.dart' as http;

class BankService extends BaseApiService {
  Future<String> getTransactionId(String accessCode) async {
    var url =
        'https://api.paystack.co/transaction/verify_access_code/$accessCode';
    try {
      http.Response response = await http.get(url);
      Map responseBody = jsonDecode(response.body);
      bool status = responseBody['status'];
      if (response.statusCode == HttpStatus.ok && status) {
        return responseBody['data']['id'].toString();
      }
    } catch (e) {}
    return null;
  }

  Future<TransactionApiResponse> chargeBank(
      BankChargeRequestBody requestBody) async {
    var url =
        '$baseUrl/bank/charge_account/${requestBody.account.bank.id}/${requestBody.transactionId}';
    return _getChargeFuture(url, fields: requestBody.paramsMap());
  }

  Future<TransactionApiResponse> validateToken(
      BankChargeRequestBody requestBody, Map<String, String> fields) async {
    var url =
        '$baseUrl/bank/validate_token/${requestBody.account.bank.id}/${requestBody.transactionId}';
    return _getChargeFuture(url, fields: fields);
  }

  Future<TransactionApiResponse> _getChargeFuture(String url,
      {var fields}) async {
    http.Response response =
        await http.post(url, body: fields, headers: headers);
    return _getResponseFuture(response);
  }

  TransactionApiResponse _getResponseFuture(http.Response response) {
    var body = response.body;

    Map<String, dynamic> responseBody = json.decode(body);

    var statusCode = response.statusCode;

    if (statusCode == HttpStatus.ok) {
      return TransactionApiResponse.fromMap(responseBody);
    } else {
      throw new ChargeException(Strings.unKnownResponse);
    }
  }
}
