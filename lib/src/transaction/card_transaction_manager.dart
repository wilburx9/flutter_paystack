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
import 'package:flutter_paystack/src/models/transaction.dart';
import 'package:flutter_paystack/src/transaction/base_transaction_manager.dart';

class CardTransactionManager extends BaseTransactionManager {
  ValidateRequestBody validateRequestBody;
  CardRequestBody chargeRequestBody;
  final CardServiceContract service;
  var _invalidDataSentRetries = 0;

  CardTransactionManager({
    @required Charge charge,
    @required this.service,
    @required BuildContext context,
    @required OnTransactionChange<Transaction> onSuccess,
    @required OnTransactionError<Object, Transaction> onError,
    @required OnTransactionChange<Transaction> beforeValidate,
  }) : super(
            charge: charge,
            context: context,
            onSuccess: onSuccess,
            onError: onError,
            beforeValidate: beforeValidate);

  @override
  postInitiate() async {
    chargeRequestBody = await CardRequestBody.getChargeRequestBody(charge);
    validateRequestBody = ValidateRequestBody();
  }

  chargeCard() async {
    try {
      if (charge.card == null || !charge.card.isValid()) {
        getCardInfoFrmUI(charge.card);
      } else {
        await initiate();
        sendCharge();
      }
    } catch (e) {
      if (!(e is ProcessingException)) {
        setProcessingOff();
      }
      onError(e, transaction);
    }
  }

  _validate() {
    try {
      _validateChargeOnServer();
    } catch (e) {
      notifyProcessingError(e);
    }
  }

  _reQuery() {
    try {
      _reQueryChargeOnServer();
    } catch (e) {
      notifyProcessingError(e);
    }
  }

  _validateChargeOnServer() {
    Map<String, String> params = validateRequestBody.paramsMap();
    Future<TransactionApiResponse> future = service.validateCharge(params);
    handleServerResponse(future);
  }

  _reQueryChargeOnServer() {
    Future<TransactionApiResponse> future =
        service.reQueryTransaction(transaction.id);
    handleServerResponse(future);
  }

  @override
  sendChargeOnServer() {
    Future<TransactionApiResponse> future =
        service.chargeCard(chargeRequestBody.paramsMap());
    handleServerResponse(future);
  }

  @override
  handleApiResponse(TransactionApiResponse apiResponse) {
    var status = apiResponse.status;
    if (status == '1' || status == 'success') {
      setProcessingOff();
      onSuccess(transaction);
      return;
    }

    if (status == '2') {
      getPinFrmUI();
      return;
    }

    if (status == '3' && apiResponse.hasValidReferenceAndTrans()) {
      notifyBeforeValidate();
      validateRequestBody.trans = apiResponse.trans;
      getOtpFrmUI(message: apiResponse.message);
      return;
    }

    if (transaction.hasStartedOnServer()) {
      if (status == 'requery') {
        notifyBeforeValidate();
        new Timer(const Duration(seconds: 5), () {
          _reQuery();
        });
        return;
      }

      if (apiResponse.hasValidAuth() &&
          apiResponse.auth.toLowerCase() == '3DS'.toLowerCase() &&
          apiResponse.hasValidUrl()) {
        notifyBeforeValidate();
        getAuthFrmUI(apiResponse.otpMessage);
        return;
      }

      if (apiResponse.hasValidAuth() &&
          (apiResponse.auth.toLowerCase() == 'otp' ||
              apiResponse.auth.toLowerCase() == 'phone') &&
          apiResponse.hasValidOtpMessage()) {
        notifyBeforeValidate();
        validateRequestBody.trans = transaction.id;
        getOtpFrmUI(message: apiResponse.otpMessage);
        return;
      }
    }

    if (status == '0'.toLowerCase() || status == 'error') {
      if (apiResponse.message.toLowerCase() ==
              'Invalid Data Sent'.toLowerCase() &&
          _invalidDataSentRetries < 0) {
        _invalidDataSentRetries++;
        sendCharge();
        return;
      }

      if (apiResponse.message.toLowerCase() ==
          'Access code has expired'.toLowerCase()) {
        notifyProcessingError(ExpiredAccessCodeException(apiResponse.message));
        return;
      }

      notifyProcessingError(ChargeException(apiResponse.message));
      return;
    }

    notifyProcessingError(PaystackException(Strings.unKnownResponse));
  }

  @override
  void handleCardInput() {
    chargeCard();
  }

  @override
  void handleOtpInput(String otp, TransactionApiResponse response) {
    validateRequestBody.token = otp;
    _validate();
  }

  @override
  void handlePinInput(String pin) async {
    await chargeRequestBody.addPin(pin);
    sendCharge();
  }
}
