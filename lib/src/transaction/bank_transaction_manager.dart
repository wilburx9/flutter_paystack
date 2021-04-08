import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/request/bank_charge_request_body.dart';
import 'package:flutter_paystack/src/api/service/contracts/banks_service_contract.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/models/charge.dart';
import 'package:flutter_paystack/src/models/checkout_response.dart';
import 'package:flutter_paystack/src/transaction/base_transaction_manager.dart';

class BankTransactionManager extends BaseTransactionManager {
  BankChargeRequestBody? chargeRequestBody;
  final BankServiceContract service;

  BankTransactionManager(
      {required this.service,
      required Charge charge,
      required BuildContext context,
      required String publicKey})
      : super(charge: charge, context: context, publicKey: publicKey);

  Future<CheckoutResponse> chargeBank() async {
    await initiate();
    return sendCharge();
  }

  @override
  postInitiate() {
    chargeRequestBody = new BankChargeRequestBody(charge);
  }

  @override
  Future<CheckoutResponse> sendChargeOnServer() {
    return _getTransactionId();
  }

  Future<CheckoutResponse> _getTransactionId() async {
    String? id = await service.getTransactionId(chargeRequestBody!.accessCode);
    if (id == null || id.isEmpty) {
      return notifyProcessingError('Unable to verify access code');
    }

    chargeRequestBody!.transactionId = id;
    return _chargeAccount();
  }

  Future<CheckoutResponse> _chargeAccount() {
    Future<TransactionApiResponse> future =
        service.chargeBank(chargeRequestBody);
    return handleServerResponse(future);
  }

  Future<CheckoutResponse> _sendTokenToServer() {
    Future<TransactionApiResponse> future = service.validateToken(
        chargeRequestBody, chargeRequestBody!.tokenParams());
    return handleServerResponse(future);
  }

  @override
  Future<CheckoutResponse> handleApiResponse(
      TransactionApiResponse response) async {
    var auth = response.auth;

    if (response.status == 'success') {
      setProcessingOff();
      return onSuccess(transaction);
    }

    if (auth == 'failed' || auth == 'timeout') {
      return notifyProcessingError(new ChargeException(response.message));
    }

    if (auth == 'birthday') {
      return getBirthdayFrmUI(response);
    }

    if (auth == 'payment_token' || auth == 'registration_token') {
      return getOtpFrmUI(response: response);
    }

    return notifyProcessingError(
        PaystackException(response.message ?? Strings.unKnownResponse));
  }

  @override
  Future<CheckoutResponse> handleOtpInput(
      String token, TransactionApiResponse? response) {
    chargeRequestBody!.token = token;
    return _sendTokenToServer();
  }

  @override
  Future<CheckoutResponse> handleBirthdayInput(
      String birthday, TransactionApiResponse response) {
    chargeRequestBody!.birthday = birthday;
    return _chargeAccount();
  }

  @override
  CheckoutMethod checkoutMethod() => CheckoutMethod.bank;
}
