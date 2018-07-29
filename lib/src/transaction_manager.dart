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
  final TransactionCallback _transactionCallback;
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

  TransactionManager(this._charge, this._transactionCallback, this._context) {
    assert(_context != null, 'context must not be null');
    assert(_charge != null, 'charge must not be null');
    assert(
        _charge.card != null,
        'please add a card to the charge before '
        'calling chargeCard');
    assert(_transactionCallback != null,
        'transactionCallback must not be ' 'null');
  }

  _initiate() async {
    print("Started _initiate");
    if (TransactionManager.processing) {
      throw ProcessingException();
    }
    _setProcessingOn();
    print('Tansaction Manager: _initiate: 1');
    _apiService = ApiService();
    print('Tansaction Manager: _initiate: 2');
    _chargeRequestBody = await ChargeRequestBody.getChargeRequestBody(_charge);
    print('Tansaction Manager: _initiate: 3');
    _validateRequestBody = ValidateRequestBody();
    print('Tansaction Manager: _initiate: 4');
  }

  chargeCard() async {
    print("chargeCard Entered");
    try {
      print('chargeCard Started If');
      if (_charge.card == null || !_charge.card.isValid()) {
        print('chargeCard True');
        _getCardInfoFrmUI(_charge.card);
      } else {
        print("chargeCard Is Flase");
        await _initiate();
        print("chargeCard IS False 2");
        _sendChargeToServer();
      }
      print("chargeCard End If");
    } catch (e) {
      print(
          'Something went wrong while charging card. Reason: ${e.toString()}');
      if (!(e is ProcessingException)) {
        _setProcessingOff();
      }
      _transactionCallback.onError(e, _transaction);
    }
  }

  _sendChargeToServer() {
    print('Started _sendChargeToServer');
    try {
      _initiateChargeOnServer();
    } catch (e) {
      print('Something went wrong while sending charge to server. '
          'Reason: ${e.toString()}');
      _notifyProcessingError(e);
    }
  }

  _validate() {
    try {
      _validateChargeOnServer();
    } catch (e) {
      print('Something went wrong while validating. Reason ${e.toString()}');
      _notifyProcessingError(e);
    }
  }

  _reQuery() {
    try {
      _reQueryChargeOnServer();
    } catch (e) {
      print('Something went wrong while reQuering ${e.toString()}');
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
      _transactionCallback.onSuccess(_transaction);
      return;
    }

    if (status == '2') {
      _getPinFrmUI();
      return;
    }

    if (status == '3' && apiResponse.hasValidReferenceAndTrans()) {
      _transactionCallback.beforeValidate(_transaction);
      _validateRequestBody.trans = apiResponse.trans;
      _getOtpFrmUI(apiResponse.message);
      return;
    }

    if (_transaction.hasStartedOnServer()) {
      if (status == 'requery'.toLowerCase()) {
        _transactionCallback.beforeValidate(_transaction);
        new Timer(const Duration(seconds: 5), () {
          _reQuery();
        });
        return;
      }


      if (apiResponse.hasValidAuth() &&
          apiResponse.auth.toLowerCase() == '3DS'.toLowerCase() &&
          apiResponse.hasValidUrl()) {
        _transactionCallback.beforeValidate(_transaction);
        _getAuthFrmUI(apiResponse.otpMessage);
        return;
      }

      print('Gotten Here ----------- 3');

      if (apiResponse.hasValidAuth() &&
          (apiResponse.auth.toLowerCase() == 'otp'.toLowerCase() ||
              apiResponse.auth.toLowerCase() == 'phone') &&
          apiResponse.hasValidOtpMessage()) {
        _transactionCallback.beforeValidate(_transaction);
        _validateRequestBody.trans = _transaction.id;
        _getOtpFrmUI(apiResponse.otpMessage);
        return;
      }
    }
    print('Gotten Here ----------- 4');
    if (status == '0'.toLowerCase() || status == 'error') {
      if (apiResponse.message.toLowerCase() ==
              'Invalid Data Sent'.toLowerCase() &&
          _invalidDataSentRetries < 0) {
        _invalidDataSentRetries++;
        _sendChargeToServer();
        return;
      }
      print('Gotten Here ----------- 5');

      if (apiResponse.message.toLowerCase() ==
          'Access code has expired'.toLowerCase()) {
        _notifyProcessingError(ExpiredAccessCodeException(apiResponse.message));
        return;
      }

      print('Gotten Here ----------- 6');
      _notifyProcessingError(ChargeException(apiResponse.message));
      return;
    }

    print('Gotten Here ----------- 7');
    _notifyProcessingError(PaystackException('Unknown server response'));
  }

  _notifyProcessingError(Object e) {
    _setProcessingOff();
    _transactionCallback.onError(e, _transaction);
  }

  _setProcessingOff() {
    TransactionManager.processing = false;
  }

  _setProcessingOn() {
    TransactionManager.processing = true;
  }

  _getCardInfoFrmUI(PaymentCard currentCard) async {
    PaymentCard newCard = await Navigator.push(
        _context,
        new MaterialPageRoute<PaymentCard>(
          builder: (BuildContext context) => CardInputUI(currentCard),
          fullscreenDialog: true,
        ));

    if (newCard == null || !newCard.isValid()) {
      _notifyProcessingError(CardException('Invalid card parameters'));
    } else {
      _charge.card = newCard;
      chargeCard();
    }
  }

  _getPinFrmUI() async {
    String pin = await Navigator.push(
        _context,
        new MaterialPageRoute<String>(
          builder: (BuildContext context) => new PinInputUI(
                randomize: true,
                pinLength: 4,
                showIndicatorPlaceholder: true,
                indicatorPadding: 10.0,
                title: 'PIN',
                subHeader: 'To confirm you\'re the owner of this card, please '
                    'enter your card pin.',
              ),
          fullscreenDialog: true,
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

    String otp = await Navigator.push(
        _context,
        new MaterialPageRoute<String>(
          builder: (BuildContext context) => new PinInputUI(
            randomize: false,
            pinLength: 20,
            showIndicatorPlaceholder: false,
            indicatorPadding: 0.0,
            title: 'OTP',
            subHeader: message,
          ),
          fullscreenDialog: true,
        ));

    if (otp != null) {
      _validateRequestBody.token = otp;
      _validate();
    } else {
      _notifyProcessingError(PaystackException("You did not provide an OTP"));
    }
  }

  _getAuthFrmUI(String url) async {
    print('Want to get authorization from');
    String result = await Utils.channel
        .invokeMethod('getAuthorization', {"authUrl": url});
    TransactionApiResponse apiResponse;
    try {
      Map<String, dynamic> responseMap = json.decode(result);
      apiResponse = TransactionApiResponse.fromMap(responseMap);
      print('API response = $responseMap');
    } catch (e) {
      print('Error occured during authentication. Error ${e.toString()}');
      apiResponse = TransactionApiResponse.unknownServerResponse();
    }
    _handleApiResponse(apiResponse);
  }
}
