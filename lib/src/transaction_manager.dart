import 'dart:async';
import 'dart:convert';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/paystack.dart';
import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/request/charge_request_body.dart';
import 'package:flutter_paystack/src/api/request/validate_request_body.dart';
import 'package:flutter_paystack/src/api/service/api_service.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/ui/pin_input_ui.dart';
import 'package:flutter_paystack/src/ui/card_input_ui.dart';
import 'package:flutter_paystack/src/utils/utils.dart';

class TransactionManager {
  static bool processing = false;
  final Charge _charge;
  final BuildContext _context;
  final Transaction _transaction = Transaction();
  final OnTransactionChange<Transaction> _onSuccess;
  final OnTransactionChange<Transaction> _beforeValidate;
  final OnTransactionError<Object, Transaction> _onError;
  ChargeRequestBody _chargeRequestBody;
  ValidateRequestBody _validateRequestBody;
  ApiService _apiService;
  var _invalidDataSentRetries = 0;

  _handleServerResponse(Future<TransactionApiResponse> future) {
    future
        .then((TransactionApiResponse apiResponse) =>
            _handleApiResponse(apiResponse))
        .catchError((e) => _notifyProcessingError(e));
  }

  TransactionManager(this._charge, this._context, this._beforeValidate,
      this._onSuccess, this._onError) {
    assert(_context != null, 'context must not be null');
    assert(_charge != null, 'charge must not be null');
    assert(
        _charge.card != null,
        'please add a card to the charge before '
        'calling chargeCard');
    assert(_beforeValidate != null, 'beforeValidate must not be null');
    assert(_onSuccess != null, 'onSuccess must not be null');
    assert(_onError != null, 'onError must not be null');
  }

  _initiate() async {
    if (TransactionManager.processing) {
      throw ProcessingException();
    }
    _setProcessingOn();

    _apiService = ApiService();
    _chargeRequestBody = await ChargeRequestBody.getChargeRequestBody(_charge);
    _validateRequestBody = ValidateRequestBody();
  }

  chargeCard() async {
    try {
      if (_charge.card == null || !_charge.card.isValid()) {
        _getCardInfoFrmUI(_charge.card);
      } else {
        await _initiate();
        _sendChargeToServer();
      }
    } catch (e) {
      if (!(e is ProcessingException)) {
        _setProcessingOff();
      }
      _onError(e, _transaction);
    }
  }

  _sendChargeToServer() {
    try {
      _initiateChargeOnServer();
    } catch (e) {
      _notifyProcessingError(e);
    }
  }

  _validate() {
    try {
      _validateChargeOnServer();
    } catch (e) {
      _notifyProcessingError(e);
    }
  }

  _reQuery() {
    try {
      _reQueryChargeOnServer();
    } catch (e) {
      _notifyProcessingError(e);
    }
  }

  _validateChargeOnServer() {
    Map<String, String> params = _validateRequestBody.paramsMap();
    Future<TransactionApiResponse> future = _apiService.validateCharge(params);
    _handleServerResponse(future);
  }

  _reQueryChargeOnServer() {
    Future<TransactionApiResponse> future =
        _apiService.reQueryTransaction(_transaction.id);
    _handleServerResponse(future);
  }

  _initiateChargeOnServer() {
    Future<TransactionApiResponse> future =
        _apiService.charge(_chargeRequestBody.paramsMap());
    _handleServerResponse(future);
  }

  _handleApiResponse(TransactionApiResponse apiResponse) {
    if (apiResponse == null) {
      apiResponse = TransactionApiResponse.unknownServerResponse();
    }

    _transaction.loadFromResponse(apiResponse);

    var status = apiResponse.status.toLowerCase();

    if (status == '1' || status == 'success') {
      _setProcessingOff();
      _onSuccess(_transaction);
      return;
    }

    if (status == '2') {
      _getPinFrmUI();
      return;
    }

    if (status == '3' && apiResponse.hasValidReferenceAndTrans()) {
      _beforeValidate(_transaction);
      _validateRequestBody.trans = apiResponse.trans;
      _getOtpFrmUI(apiResponse.message);
      return;
    }

    if (_transaction.hasStartedOnServer()) {
      if (status == 'requery'.toLowerCase()) {
        _beforeValidate(_transaction);
        new Timer(const Duration(seconds: 5), () {
          _reQuery();
        });
        return;
      }

      if (apiResponse.hasValidAuth() &&
          apiResponse.auth.toLowerCase() == '3DS'.toLowerCase() &&
          apiResponse.hasValidUrl()) {
        _beforeValidate(_transaction);
        _getAuthFrmUI(apiResponse.otpMessage);
        return;
      }

      if (apiResponse.hasValidAuth() &&
          (apiResponse.auth.toLowerCase() == 'otp'.toLowerCase() ||
              apiResponse.auth.toLowerCase() == 'phone') &&
          apiResponse.hasValidOtpMessage()) {
        _beforeValidate(_transaction);
        _validateRequestBody.trans = _transaction.id;
        _getOtpFrmUI(apiResponse.otpMessage);
        return;
      }
    }

    if (status == '0'.toLowerCase() || status == 'error') {
      if (apiResponse.message.toLowerCase() ==
              'Invalid Data Sent'.toLowerCase() &&
          _invalidDataSentRetries < 0) {
        _invalidDataSentRetries++;
        _sendChargeToServer();
        return;
      }

      if (apiResponse.message.toLowerCase() ==
          'Access code has expired'.toLowerCase()) {
        _notifyProcessingError(ExpiredAccessCodeException(apiResponse.message));
        return;
      }

      _notifyProcessingError(ChargeException(apiResponse.message));
      return;
    }

    _notifyProcessingError(PaystackException('Unknown server response'));
  }

  _notifyProcessingError(Object e) {
    _setProcessingOff();
    _onError(e, _transaction);
  }

  _setProcessingOff() {
    TransactionManager.processing = false;
  }

  _setProcessingOn() {
    TransactionManager.processing = true;
  }

  _getCardInfoFrmUI(PaymentCard currentCard) async {
    PaymentCard newCard = await showDialog<PaymentCard>(
        context: _context,
        builder: (BuildContext context) => CardInputUI(currentCard));

    if (newCard == null || !newCard.isValid()) {
      _notifyProcessingError(CardException('Invalid card parameters'));
    } else {
      _charge.card = newCard;
      chargeCard();
    }
  }

  _getPinFrmUI() async {
    String pin = await showDialog<String>(
        context: _context,
        builder: (BuildContext context) => new PinInputUI(
              randomize: true,
              pinLength: 4,
              showIndicatorPlaceholder: true,
              indicatorPadding: 10.0,
              title: 'PIN',
              subHeader: 'To confirm you\'re the owner of this card, please '
                  'enter your card pin.',
            ));

    if (pin != null && pin.length == 4) {
      await _chargeRequestBody.addPin(pin);
      _sendChargeToServer();
    } else {
      _notifyProcessingError(PaystackException("PIN must be exactly 4 digits"));
    }
  }

  _getOtpFrmUI(String message) async {
    // Handle cases of OTP being more than 10 characters. It will
    // automatically keep increasing the length of the max characters just as
    // the official Android version of Paystack is doing it. For now, we'll
    // make the max characters 20. God help us! LOL

    String otp = await showDialog<String>(
        context: _context,
        builder: (BuildContext context) => new PinInputUI(
              randomize: false,
              pinLength: 20,
              showIndicatorPlaceholder: false,
              indicatorPadding: 0.0,
              title: 'OTP',
              subHeader: message,
            ));

    if (otp != null) {
      _validateRequestBody.token = otp;
      _validate();
    } else {
      _notifyProcessingError(PaystackException("You did not provide an OTP"));
    }
  }

  _getAuthFrmUI(String url) async {
    String result =
        await Utils.channel.invokeMethod('getAuthorization', {"authUrl": url});
    TransactionApiResponse apiResponse;
    try {
      Map<String, dynamic> responseMap = json.decode(result);
      apiResponse = TransactionApiResponse.fromMap(responseMap);
    } catch (e) {
      apiResponse = TransactionApiResponse.unknownServerResponse();
    }
    _handleApiResponse(apiResponse);
  }
}
