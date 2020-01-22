import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/models/bank.dart';
import 'package:flutter_paystack/src/models/card.dart';
import 'package:flutter_paystack/src/models/checkout_response.dart';
import 'package:flutter_paystack/src/widgets/animated_widget.dart';
import 'package:flutter_paystack/src/widgets/checkout/checkout_widget.dart';

abstract class BaseCheckoutMethodState<T extends StatefulWidget>
    extends BaseAnimatedState<T> {
  final OnResponse<CheckoutResponse> onResponse;
  final CheckoutMethod _method;

  BaseCheckoutMethodState(this.onResponse, this._method);

  void handleAllError(String message, String reference, bool verify,
      {PaymentCard card, BankAccount account}) {
    if (!mounted) {
      return;
    }
    if (message == null) {
      message = Strings.sthWentWrong;
    }

    onResponse(new CheckoutResponse(
        message: message,
        reference: reference,
        status: false,
        method: _method,
        card: card,
        account: account,
        verify: verify));
  }

  CheckoutMethod get method => _method;
}
