import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/request/card_request_body.dart';
import 'package:flutter_paystack/src/api/request/validate_request_body.dart';
import 'package:flutter_paystack/src/api/service/contracts/cards_service_contract.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/models/charge.dart';
import 'package:flutter_paystack/src/models/checkout_response.dart';
import 'package:flutter_paystack/src/transaction/base_transaction_manager.dart';

class CardTransactionManager extends BaseTransactionManager {
  late ValidateRequestBody validateRequestBody;
  late CardRequestBody chargeRequestBody;
  final CardServiceContract service;
  var _invalidDataSentRetries = 0;

  CardTransactionManager(
      {required Charge charge,
      required this.service,
      required BuildContext context,
      required String publicKey})
      : assert(charge.card != null,
            'please add a card to the charge before ' 'calling chargeCard'),
        super(charge: charge, context: context, publicKey: publicKey);

  @override
  postInitiate() async {
    chargeRequestBody =
        await CardRequestBody.getChargeRequestBody(publicKey, charge);
    validateRequestBody = ValidateRequestBody();
  }

  Future<CheckoutResponse> chargeCard() async {
    try {
      if (charge.card == null || !charge.card!.isValid()) {
        return getCardInfoFrmUI(charge.card);
      } else {
        await initiate();
        return sendCharge();
      }
    } catch (e) {
      if (!(e is ProcessingException)) {
        setProcessingOff();
      }
      return CheckoutResponse(
          message: e.toString(),
          reference: transaction.reference,
          status: false,
          card: charge.card?..nullifyNumber(),
          method: CheckoutMethod.card,
          verify: !(e is PaystackException));
    }
  }

  Future<CheckoutResponse> _validate() async {
    try {
      return _validateChargeOnServer();
    } catch (e) {
      return notifyProcessingError(e);
    }
  }

  Future<CheckoutResponse> _reQuery() async {
    try {
      return _reQueryChargeOnServer();
    } catch (e) {
      return notifyProcessingError(e);
    }
  }

  Future<CheckoutResponse> _validateChargeOnServer() {
    Map<String, String?> params = validateRequestBody.paramsMap();
    Future<TransactionApiResponse> future = service.validateCharge(params);
    return handleServerResponse(future);
  }

  Future<CheckoutResponse> _reQueryChargeOnServer() {
    Future<TransactionApiResponse> future =
        service.reQueryTransaction(transaction.id);
    return handleServerResponse(future);
  }

  @override
  Future<CheckoutResponse> sendChargeOnServer() {
    Future<TransactionApiResponse> future =
        service.chargeCard(chargeRequestBody.paramsMap());
    return handleServerResponse(future);
  }

  @override
  Future<CheckoutResponse> handleApiResponse(
      TransactionApiResponse apiResponse) async {
    var status = apiResponse.status;
    if (status == '1' || status == 'success') {
      setProcessingOff();
      return onSuccess(transaction);
    }

    if (status == '2') {
      return getPinFrmUI();
    }

    if (status == '3' && apiResponse.hasValidReferenceAndTrans()) {
      validateRequestBody.trans = apiResponse.trans;
      return getOtpFrmUI(message: apiResponse.message);
    }

    if (transaction.hasStartedOnServer()) {
      if (status == 'requery') {
        await Future.delayed(const Duration(seconds: 5));
        return _reQuery();
      }

      if (apiResponse.hasValidAuth() &&
          apiResponse.auth!.toLowerCase() == '3DS'.toLowerCase() &&
          apiResponse.hasValidUrl()) {
        return getAuthFrmUI(apiResponse.otpMessage);
      }

      if (apiResponse.hasValidAuth() &&
          (apiResponse.auth!.toLowerCase() == 'otp' ||
              apiResponse.auth!.toLowerCase() == 'phone') &&
          apiResponse.hasValidOtpMessage()) {
        validateRequestBody.trans = transaction.id;
        return getOtpFrmUI(message: apiResponse.otpMessage);
      }
    }

    if (status == '0'.toLowerCase() || status == 'error') {
      if (apiResponse.message!.toLowerCase() ==
              'Invalid Data Sent'.toLowerCase() &&
          _invalidDataSentRetries < 0) {
        _invalidDataSentRetries++;
        return chargeCard();
      }

      if (apiResponse.message!.toLowerCase() ==
          'Access code has expired'.toLowerCase()) {
        return sendCharge();
      }

      return notifyProcessingError(ChargeException(apiResponse.message));
    }

    return notifyProcessingError(PaystackException(Strings.unKnownResponse));
  }

  @override
  Future<CheckoutResponse> handleCardInput() {
    return chargeCard();
  }

  @override
  Future<CheckoutResponse> handleOtpInput(
      String otp, TransactionApiResponse? response) {
    validateRequestBody.token = otp;
    return _validate();
  }

  @override
  Future<CheckoutResponse> handlePinInput(String pin) async {
    await chargeRequestBody.addPin(pin);
    return sendCharge();
  }

  @override
  CheckoutMethod checkoutMethod() => CheckoutMethod.card;
}
