import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/request/bank_charge_request_body.dart';
import 'package:flutter_paystack/src/api/service/contracts/banks_service_contract.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/models/charge.dart';
import 'package:flutter_paystack/src/models/transaction.dart';
import 'package:flutter_paystack/src/transaction/base_transaction_manager.dart';

class BankTransactionManager extends BaseTransactionManager {
  BankChargeRequestBody chargeRequestBody;
  final BankServiceContract service;

  BankTransactionManager({
    @required this.service,
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
  }

  @override
  void sendChargeOnServer() {
    _getTransactionId();
  }

  _getTransactionId() async {
    String id = await service.getTransactionId(chargeRequestBody.accessCode);
    if (id == null || id.isEmpty) {
      notifyProcessingError('Unable to verify access code');
      return;
    }

    chargeRequestBody.transactionId = id;
    _chargeAccount();
  }

  _chargeAccount() {
    Future<TransactionApiResponse> future =
        service.chargeBank(chargeRequestBody);
    handleServerResponse(future);
  }

  void _sendTokenToServer() {
    Future<TransactionApiResponse> future = service.validateToken(
        chargeRequestBody, chargeRequestBody.tokenParams());
    handleServerResponse(future);
  }

  @override
  handleApiResponse(TransactionApiResponse response) {
    var auth = response.auth;

    if (response.status == 'success') {
      setProcessingOff();
      onSuccess(transaction);
      return;
    }

    if (auth == 'failed' || auth == 'timeout') {
      notifyProcessingError(new ChargeException(response.message));
      return;
    }

    if (auth == 'birthday') {
      getBirthdayFrmUI(response);
      return;
    }

    if (auth == 'payment_token' || auth == 'registration_token') {
      getOtpFrmUI(response: response);
      return;
    }

    notifyProcessingError(
        PaystackException(response.message ?? Strings.unKnownResponse));
  }

  @override
  void handleOtpInput(String token, TransactionApiResponse response) {
    chargeRequestBody.token = token;
    _sendTokenToServer();
  }

  @override
  void handleBirthdayInput(String birthday, TransactionApiResponse response) {
    chargeRequestBody.birthday = birthday;
    _chargeAccount();
  }
}
