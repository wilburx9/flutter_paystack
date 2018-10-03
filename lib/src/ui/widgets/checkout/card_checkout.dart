import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/api/request/mobile_request_body.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/model/checkout_response.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/paystack.dart';
import 'package:flutter_paystack/src/transaction.dart';
import 'package:flutter_paystack/src/transaction/mobile_transaction_manager.dart';
import 'package:flutter_paystack/src/ui/widgets/checkout/base_checkout.dart';
import 'package:flutter_paystack/src/ui/widgets/checkout/checkout_widget.dart';
import 'package:flutter_paystack/src/ui/widgets/input/card_input.dart';
import 'package:flutter_paystack/src/utils/utils.dart';
import 'package:http/http.dart' as http;

class CardCheckout extends StatefulWidget {
  final Charge charge;
  final OnResponse<CheckoutResponse> onResponse;
  final ValueChanged<bool> onProcessingChange;
  final ValueChanged<PaymentCard> onCardChange;
  final ValueChanged<String> onInitialized;
  final String accessCode;

  CardCheckout({
    @required this.charge,
    @required this.onResponse,
    @required this.onProcessingChange,
    @required this.onCardChange,
    @required this.onInitialized,
    @required this.accessCode,
  });

  @override
  _CardCheckoutState createState() =>
      _CardCheckoutState(charge, accessCode, onResponse);
}

class _CardCheckoutState extends BaseCheckoutMethodState<CardCheckout> {
  final Charge _charge;
  String _accessCode;

  _CardCheckoutState(
      this._charge, this._accessCode, OnResponse<CheckoutResponse> onResponse)
      : super(onResponse, CheckoutMethod.card);

  @override
  Widget buildAnimatedChild() {
    var amountText = _charge.amount == null || _charge.amount.isNegative
        ? ''
        : Utils.formatAmount(_charge.amount);

    return new Container(
      alignment: Alignment.center,
      child: new Column(
        children: <Widget>[
          new Text(
            'Enter your card details to pay',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          new SizedBox(
            height: 20.0,
          ),
          new CardInput(
            text: 'Pay $amountText',
            card: _charge.card,
            onValidated: _onCardValidated,
          ),
        ],
      ),
    );
  }

  void _onCardValidated(PaymentCard card) {
    print('_onCardValidated AccessCode = $_accessCode');
    _charge.card = card;
    widget.onCardChange(_charge.card);
    widget.onProcessingChange(true);
    if (_accessCode != null && _accessCode.isNotEmpty) {
      Charge charge = new Charge()
        ..accessCode = _accessCode
        ..card = _charge.card;
      _chargeCard(charge);
    } else if (_canInitialize()) {
      _initializePayment();
    } else if (_charge.accessCode != null && _charge.accessCode.isNotEmpty) {
      _chargeCard(_charge);
    } else {
      // This should never happen. Validation has already been done in [PaystackPlugin .checkout]
      throw new ChargeException(Strings.noAccessCodeReference);
    }
  }

  bool _canInitialize() {
    return _charge.reference != null;
  }

  _validateReference() {
    //check for null value, and length and starts with pk_
    if (_charge.reference == null || _charge.reference.isEmpty) {
      throw new PaystackException(
          'Payment reference cannot be null or empty. If you '
          'don\' want the plugin to initialize the transaction, then don\'t pass a '
          'private key in ${PaystackPlugin.initialize}');
    }
  }

  void _initializePayment() async {
    _validateReference();

    print('Initialize Payment ');

    var url = 'https://api.paystack.co/transaction/initialize';

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer ${PaystackPlugin.secretKey}',
    };

    Map<String, String> body = {
      'reference': _charge.reference,
      'amount': _charge.amount.toString(),
      'email': _charge.email,
      'channel': jsonEncode(['card']),
    };

    if (_charge.metadata != null) {
      body['metadata'] = _charge.metadata;
    }

    if (_charge.subAccount != null) {
      body['subaccount'] = _charge.subAccount;
    }

    if (_charge.transactionCharge != null && _charge.transactionCharge > 0) {
      body['transaction_charge'] = _charge.transactionCharge.toString();
    }

    if (_charge.bearer != null) {
      body['bearer'] = ChargeRequestBody.getBearer(_charge.bearer);
    }

    try {
      http.Response response =
          await http.post(url, body: body, headers: headers);
      if (!mounted) {
        return;
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      print('Initialize payment $responseData');
      bool status = responseData['status'];

      if (status) {
        String accessCode = responseData['data']['access_code'];
        print('Sending access code = $accessCode');
        this._accessCode = accessCode;
        Charge charge = new Charge()
          ..accessCode = accessCode
          ..card = _charge.card;

        print('Sending access code_____________ = $accessCode');
        widget.onInitialized(accessCode);

        _chargeCard(charge);
      } else {
        handleError(responseData['message'], _charge.reference);
      }
    } catch (e) {
      print(e);
      String message;
      if (e is PaystackException) {
        message = e.message;
      }
      handleError(message, _charge.reference);
    }
  }

  void _chargeCard(Charge charge) {
    print('Charge card reference =  ${charge.reference}');
    handleBeforeValidate(Transaction transaction) {
      // Do nothing
    }

    handleOnError(Object e, Transaction transaction) {
      if (!mounted) {
        return;
      }
      if (e is ExpiredAccessCodeException) {
        print('License has expired');
        Charge charge = new Charge()
          ..accessCode = _accessCode
          ..card = _charge.card;
        _chargeCard(charge);
        return;
      }

      print('Card payment Error $e');
      if (transaction.reference != null && !(e is PaystackException)) {
        verifyPaymentFromPaystack(transaction, card: _charge.card);
      } else {
        String message = e.toString();
        handleError(message, transaction.reference);
      }
    }

    handleOnSuccess(Transaction transaction) {
      if (!mounted) {
        return;
      }
      verifyPaymentFromPaystack(transaction, card: _charge.card);
    }

    new MobileTransactionManager(
            charge: charge,
            context: context,
            beforeValidate: (transaction) => handleBeforeValidate(transaction),
            onSuccess: (transaction) => handleOnSuccess(transaction),
            onError: (error, transaction) => handleOnError(error, transaction))
        .chargeCard();
  }

  void handleError(String message, String reference) {
    handleAllError(message, reference, card: _charge.card);
  }
}
