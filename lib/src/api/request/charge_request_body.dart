import 'package:paystack_flutter/src/api/request/base_request_body.dart';
import 'package:paystack_flutter/src/model/charge.dart';
import 'package:paystack_flutter/paystack_sdk.dart';
import 'package:paystack_flutter/src/utils/card_utils.dart';
import 'package:paystack_flutter/src/utils/crypto.dart';

class ChargeRequestBody extends BaseRequestBody {
  static const String fieldClientData = "clientdata";
  static const String fieldLast4 = "last4";
  static const String fieldAccessCode = "access_code";
  static const String fieldPublicKey = "public_key";
  static const String fieldEmail = "email";
  static const String fieldAmount = "amount";
  static const String fieldReference = "reference";
  static const String fieldSubAccount = "subaccount";
  static const String fieldTransactionCharge = "transaction_charge";
  static const String fieldBearer = "bearer";
  static const String fieldHandle = "handle";
  static const String fieldMetadata = "metadata";
  static const String fieldCurrency = "currency";
  static const String fieldPlan = "plan";

  String _clientData;
  String _last4;
  String _publicKey;
  String _accessCode;
  String _email;
  String _amount;
  String _reference;
  String _subAccount;
  String _transactionCharge;
  String _bearer;
  String _handle;
  String _metadata;
  String _currency;
  String _plan;
  Map<String, String> _additionalParameters;

  ChargeRequestBody(Charge charge) {
    this.setDeviceId();
    this.setClientData(charge);
    this._last4 = charge.card.last4Digits;
    this._publicKey = PaystackSdk.publicKey;
    this._email = charge.email;
    this._amount = charge.amount.toString();
    this._reference = charge.reference;
    this._subAccount = charge.subAccount;
    this._transactionCharge = charge.transactionCharge > 0
        ? charge.transactionCharge.toString()
        : null;
    this._bearer = charge.bearer != null ? _getBearer(charge.bearer) : null;
    this._metadata = charge.metadata;
    this._plan = charge.plan;
    this._currency = charge.currency;
    this._accessCode = charge.accessCode;
    this._additionalParameters = charge.additionalParameters;
  }

  setClientData(Charge charge) async {
    String clientData = await Crypto.encrypt(
        CardUtils.concatenateCardFields(charge.card));
    this._clientData = clientData;
  }

  addPin(String pin) async {
    this._handle = await Crypto.encrypt(pin);
  }

  _getBearer(Bearer bearer) {
    String bearerStr;
    switch (bearer) {
      case Bearer.SubAccount:
        bearerStr = "subaccount";
        break;
      case Bearer.Account:
        bearerStr = "account";
        break;
    }
    return bearerStr;
  }

  @override
  Map<String, String> paramsMap() {
    // set values will override additional params provided
    Map<String, String> params = _additionalParameters;
    params[fieldPublicKey] = _publicKey;
    params[fieldClientData] = _clientData;
    params[fieldLast4] = _last4;
    if (_accessCode != null) {
      params[_accessCode] = _accessCode;
    }
    if (_email != null) {
      params[fieldEmail] = _email;
    }
    if (_amount != null) {
      params[fieldAmount] = _amount;
    }
    if (_handle != null) {
      params[fieldHandle] = _handle;
    }
    if (_reference != null) {
      params[fieldReference] = _reference;
    }
    if (_subAccount != null) {
      params[fieldSubAccount] = _subAccount;
    }
    if (_transactionCharge != null) {
      params[fieldTransactionCharge] = _transactionCharge;
    }
    if (_bearer != null) {
      params[fieldBearer] = _bearer;
    }
    if (_metadata != null) {
      params[fieldMetadata] = _metadata;
    }
    if (_plan != null) {
      params[fieldPlan] = _plan;
    }
    if (_currency != null) {
      params[fieldCurrency] = _currency;
    }
    if (device != null) {
      params[fieldDevice] = device;
    }
    return params;
  }
}
