import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/common/utils.dart';
import 'package:flutter_paystack/src/models/card.dart';
import 'package:flutter_paystack/src/models/charge.dart';
import 'package:flutter_paystack/src/models/transaction.dart';
import 'package:flutter_paystack/src/widgets/birthday_widget.dart';
import 'package:flutter_paystack/src/widgets/card_widget.dart';
import 'package:flutter_paystack/src/widgets/otp_widget.dart';
import 'package:flutter_paystack/src/widgets/pin_widget.dart';

abstract class BaseTransactionManager {
  static bool processing = false;
  final Charge charge;
  final BuildContext context;
  final Transaction transaction = Transaction();
  final OnTransactionChange<Transaction> onSuccess;
  final OnTransactionChange<Transaction> beforeValidate;
  final OnTransactionError<Object, Transaction> onError;

  BaseTransactionManager(
      {@required this.charge,
      @required this.context,
      @required this.onSuccess,
      @required this.beforeValidate,
      @required this.onError})
      : assert(context != null, 'context must not be null'),
        assert(charge != null, 'charge must not be null'),
        assert(charge.card != null,
            'please add a card to the charge before ' 'calling chargeCard'),
        assert(beforeValidate != null, 'beforeValidate must not be null'),
        assert(onSuccess != null, 'onSuccess must not be null'),
        assert(onError != null, 'onError must not be null');

  initiate() async {
    if (BaseTransactionManager.processing) {
      throw ProcessingException();
    }
    setProcessingOn();
    await postInitiate();
  }

  sendCharge() {
    try {
      sendChargeOnServer();
    } catch (e) {
      notifyProcessingError(e);
    }
  }

  handleApiResponse(TransactionApiResponse apiResponse);

  _initApiResponse(TransactionApiResponse apiResponse) {
    if (apiResponse == null) {
      apiResponse = TransactionApiResponse.unknownServerResponse();
    }

    transaction.loadFromResponse(apiResponse);

    handleApiResponse(apiResponse);
  }

  handleServerResponse(Future<TransactionApiResponse> future) {
    future
        .then((TransactionApiResponse apiResponse) =>
            _initApiResponse(apiResponse))
        .catchError((e) => notifyProcessingError(e));
  }

  notifyProcessingError(Object e) {
    setProcessingOff();

    if (e is TimeoutException || e is SocketException) {
      e = 'Please  check your internet connection or try again later';
    }
    onError(e, transaction);
  }

  notifyBeforeValidate() {
    if (beforeValidate != null) {
      beforeValidate(transaction);
    }
  }

  setProcessingOff() => processing = false;

  setProcessingOn() => processing = true;

  getCardInfoFrmUI(PaymentCard currentCard) async {
    PaymentCard newCard = await showDialog<PaymentCard>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CardInputWidget(currentCard));

    if (newCard == null || !newCard.isValid()) {
      notifyProcessingError(CardException('Invalid card parameters'));
    } else {
      charge.card = newCard;
      handleCardInput();
    }
  }

  getOtpFrmUI({String message, TransactionApiResponse response}) async {
    assert(message != null || response != null);
    String otp = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new OtpWidget(
            message: message != null
                ? message
                : response.displayText == null || response.displayText.isEmpty
                    ? response.message
                    : response.displayText));

    if (otp != null && otp.isNotEmpty) {
      handleOtpInput(otp, response);
    } else {
      notifyProcessingError(PaystackException("You did not provide an OTP"));
    }
  }

  getAuthFrmUI(String url) async {
    String result =
        await Utils.channel.invokeMethod('getAuthorization', {"authUrl": url});
    TransactionApiResponse apiResponse;
    try {
      Map<String, dynamic> responseMap = json.decode(result);
      apiResponse = TransactionApiResponse.fromMap(responseMap);
    } catch (e) {
      apiResponse = TransactionApiResponse.unknownServerResponse();
    }
    _initApiResponse(apiResponse);
  }

  getPinFrmUI() async {
    String pin = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new PinWidget());

    if (pin != null && pin.length == 4) {
      handlePinInput(pin);
    } else {
      notifyProcessingError(PaystackException("PIN must be exactly 4 digits"));
    }
  }

  getBirthdayFrmUI(TransactionApiResponse response) async {
    String birthday = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new BirthdayWidget(
            message:
                response.displayText == null || response.displayText.isEmpty
                    ? response.message
                    : response.displayText));

    if (birthday != null && birthday.isNotEmpty) {
      handleBirthdayInput(birthday, response);
    } else {
      notifyProcessingError(PaystackException("Date of birth not supplied"));
    }
  }

  void handleCardInput() {}

  void handleOtpInput(String otp, TransactionApiResponse response);

  void handlePinInput(String pin) {}

  postInitiate();

  void handleBirthdayInput(String birthday, TransactionApiResponse response) {}

  void sendChargeOnServer();
}
