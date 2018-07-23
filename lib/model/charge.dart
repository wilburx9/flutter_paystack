import 'package:paystack_flutter/model/card.dart';
import 'package:paystack_flutter/utils/string_utils.dart';

class Charge {
  PaymentCard card;
  String _email;
  String _accessCode;
  int _amount = -1;
  Map<String, dynamic> _metadata = {};
  List<Map<String, dynamic>> _customFields = [];
  bool _hasMeta = false;
  Map<String, String> _additionalParameters = {};
  int _transactionCharge;
  String _subAccount;
  String _reference;
  Bearer _bearer;
  String _currency;
  String _plan;
  bool _localStarted = false;
  bool _remoteStarted = false;

  _beforeLocalSet(String fieldName) {
    assert(
        !_remoteStarted,
        'You cannot set $fieldName after specifying an '
        'access code');
    _localStarted = true;
  }

  _beforeRemoteSet() {
    assert(
        !_localStarted,
        'You can not set access code when providing '
        'transaction parameters');
    _remoteStarted = true;
  }

  Charge() {
    this._metadata['custom_fields'] = this._customFields;
  }

  addParameter(String key, String value) {
    _beforeLocalSet(key);
    this._additionalParameters[key] = value;
  }

  Map<String, String> get additionalParameters => _additionalParameters;


  String get accessCode => _accessCode;

  set accessCode(String value) {
    _beforeLocalSet(value);
    _accessCode = value;
  }

  String get plan => _plan;

  set plan(String value) {
    _beforeLocalSet('plan');
    _plan = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _beforeLocalSet('currency');
    _currency = value;
  }

  String get reference => _reference;

  set reference(String value) {
    _beforeLocalSet('subaccount');
    _reference = value;
  }

  int get transactionCharge => _transactionCharge;

  set transactionCharge(int value) {
    _beforeLocalSet('transaction charge');
    _transactionCharge = value;
  }

  Bearer get bearer => _bearer;

  set bearer(Bearer value) {
    _beforeLocalSet('bearer');
    _bearer = value;
  }

  String get subAccount => _subAccount;

  set subAccount(String value) {
    _beforeLocalSet('subaccount');
    _subAccount = value;
  }

  putStringMetadata(String name, String value) {
    _beforeLocalSet('metadata');
    this._metadata[name] = value;
    this._hasMeta = true;
  }

  putMapMetadata(String name, Map<String, dynamic> value) {
    _beforeLocalSet('metadata');
    this._metadata[name] = value;
    this._hasMeta = true;
  }

  putCustomField(String displayName, String value) {
    _beforeLocalSet('custom field');
    var customMap = {
      'value': value,
      'display_name': displayName,
      'variable_name':
          displayName.toLowerCase().replaceAll(new RegExp(r'[^a-z0-9 ]'), "_")
    };
    this._customFields.add(customMap);
    this._hasMeta = true;
  }

  String get metadata {
    if (!_hasMeta) {
      return null;
    }

    return _metadata.toString();
  }

  String get email => _email;

  set email(String value) {
    _beforeLocalSet('email');
    if (!StringUtils.isValidEmail(value)) {
      throw '$value is not a valid email';
    }
    _email = email;
  }

  int get amount => _amount;

  set amount(int value) {
    _beforeLocalSet('amount');
    if (amount <= 0)
      throw '$value is not a valid amount. only positive non-zero values are allowed.';
    _amount = value;
  }
}

enum Bearer {
  Account,
  SubAccount,
}
