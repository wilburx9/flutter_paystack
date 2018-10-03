import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/request/web_charge_request_body.dart';
import 'package:flutter_paystack/src/api/service/web_service.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/paystack.dart';
import 'package:flutter_paystack/src/transaction.dart';
import 'package:flutter_paystack/src/transaction/base_transaction_manager.dart';

class WebTransactionManager extends BaseTransactionManager {
  BankChargeRequestBody chargeRequestBody;
  WebService service;

  WebTransactionManager({
    @required Charge charge,
    @required BuildContext context,
    @required OnTransactionChange<Transaction> onSuccess,
    @required OnTransactionError<Object, Transaction> onError,
    @required OnTransactionChange<Transaction> beforeValidate,
  }) : super(
          charge: charge,
          context: context,
          onSuccess: onSuccess,
          onError: onError,
          beforeValidate: beforeValidate,
        );

  chargeBank() async {
    await initiate();
    sendCharge();
  }

  @override
  postInitiate() {
    chargeRequestBody = new BankChargeRequestBody(charge);
    service = new WebService();
  }

  @override
  void sendChargeOnServer() {
    Future<TransactionApiResponse> future =
        service.chargeBank(chargeRequestBody.paramsMap());
    handleServerResponse(future);
  }

  _sendBirthdayToServer(String reference) {
    Future<TransactionApiResponse> future =
        service.sendBirthday(chargeRequestBody.birthdayParams(reference));
    handleServerResponse(future);
  }

  void _sendOtpToServer(String reference) {
    Future<TransactionApiResponse> future =
        service.sendOtp(chargeRequestBody.otpParams(reference));
    handleServerResponse(future);
  }

  void _checkPending(String reference) {
    Future<TransactionApiResponse> future = service.checkPending(reference);
    handleServerResponse(future);
  }

  @override
  handleApiResponse(TransactionApiResponse response, String status) {
    if (status == 'success') {
      setProcessingOff();
      onSuccess(transaction);
      return;
    }

    if (status == 'failed' || status == 'timeout') {
      notifyProcessingError(new ChargeException(response.message));
      return;
    }

    if (status == 'send_birthday') {
      getBirthdayFrmUI(response);
      return;
    }

    if (status == 'send_otp') {
      getOtpFrmUI(response: response);
      return;
    }

    if (status == 'pending') {
      new Timer(const Duration(seconds: 12), () {
        _checkPending(response.reference);
      });
      return;
    }

    notifyProcessingError(PaystackException('Unknown server response'));
  }

  @override
  void handleOtpInput(String otp, TransactionApiResponse response) {
    chargeRequestBody.otp = otp;
    _sendOtpToServer(response.reference);
  }

  @override
  void handleBirthdayInput(String birthday, TransactionApiResponse response) {
    chargeRequestBody.birthday = birthday;
    _sendBirthdayToServer(response.reference);
  }
}
