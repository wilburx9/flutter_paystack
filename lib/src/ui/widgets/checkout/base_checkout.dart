import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/model/checkout_response.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/paystack.dart';
import 'package:flutter_paystack/src/transaction.dart';
import 'package:flutter_paystack/src/ui/widgets/animated_widget.dart';
import 'package:flutter_paystack/src/ui/widgets/checkout/bank_checkout.dart';
import 'package:flutter_paystack/src/ui/widgets/checkout/checkout_widget.dart';
import 'package:http/http.dart' as http;

abstract class BaseCheckoutMethodState<T extends StatefulWidget>
    extends BaseAnimatedState<T> {
  final OnResponse<CheckoutResponse> onResponse;
  final CheckoutMethod _method;

  BaseCheckoutMethodState(this.onResponse, this._method);

  void handleAllError(String message, String reference,
      {PaymentCard card, BankAccount account}) {
    if (!mounted) {
      return;
    }
    if (message == null) {
      message = Strings.sthWentWrong;
    }

    print('Transaction error. Reference = $reference');
    onResponse(new CheckoutResponse(
        message: message,
        reference: reference,
        status: false,
        method: _method,
        card: card,
        account: account));
  }

  void verifyPaymentFromPaystack(Transaction transaction,
      {PaymentCard card, BankAccount account}) async {
    var reference = transaction.reference;
    String url = 'https://api.paystack.co/transaction/verify/$reference';

    print("Verifying Transaction. Url = $url");

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer ${PaystackPlugin.secretKey}',
    };

    try {
      http.Response response = await http.get(url, headers: headers);
      if (!mounted) {
        return;
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      print('Verify From Paystack = $responseData');
      String message = responseData['message'];

      var statusCode = response.statusCode;

      if (statusCode == HttpStatus.ok) {
        Map<String, dynamic> data = responseData['data'];
        String message = data['gateway_response'];
        String status = data['status'];

        if (status.toLowerCase() == 'success') {
          onResponse(new CheckoutResponse(
              message: message,
              reference: reference,
              status: true,
              method: _method,
              card: card,
              account: account));
        } else {
          handleAllError(message, reference, card: card, account: account);
        }
      } else {
        handleAllError(message, reference, card: card, account: account);
      }
    } catch (e) {
      print('Error while verifying = $e');
      String message;
      if (e is PaystackException) {
        message = e.message;
      }
      handleAllError(message, reference, card: card, account: account);
    }
  }
}
