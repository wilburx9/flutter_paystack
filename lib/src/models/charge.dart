import 'dart:convert';

import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/models/bank.dart';
import 'package:flutter_paystack/src/models/card.dart';

class Charge {
  PaymentCard? card;

  /// The email of the customer
  String? email;
  BankAccount? _account;

  /// Amount to pay in base currency. Must be a valid positive number
  int amount = 0;
  Map<String, dynamic>? _metadata;
  List<Map<String, dynamic>>? _customFields;
  bool _hasMeta = false;
  Map<String, String?>? _additionalParameters;

  /// The locale used for formatting amount in the UI prompt. Defaults to [Strings.nigerianLocale]
  String? locale;
  String? accessCode;
  String? plan;
  String? reference;

  /// ISO 4217 payment currency code (e.g USD). Defaults to [Strings.ngn].
  ///
  /// If you're setting this value, also set [locale] for better formatting.
  String? currency;
  int? transactionCharge;

  /// Who bears Paystack charges? [Bearer.Account] or [Bearer.SubAccount]
  Bearer? bearer;

  String? subAccount;

  Charge() {
    this._metadata = {};
    this.amount = -1;
    this._additionalParameters = {};
    this._customFields = [];
    this._metadata!['custom_fields'] = this._customFields;
    this.locale = Strings.nigerianLocale;
    this.currency = Strings.ngn;
  }

  addParameter(String key, String value) {
    this._additionalParameters![key] = value;
  }

  Map<String, String?>? get additionalParameters => _additionalParameters;

  BankAccount? get account => _account;

  set account(BankAccount? value) {
    if (value == null) {
      // Precaution to avoid setting of this field outside the library
      throw new PaystackException('account cannot be null');
    }
    _account = value;
  }

  putMetaData(String name, dynamic value) {
    this._metadata![name] = value;
    this._hasMeta = true;
  }

  putCustomField(String displayName, String value) {
    var customMap = {
      'value': value,
      'display_name': displayName,
      'variable_name':
          displayName.toLowerCase().replaceAll(new RegExp(r'[^a-z0-9 ]'), "_")
    };
    this._customFields!.add(customMap);
    this._hasMeta = true;
  }

  String? get metadata {
    if (!_hasMeta) {
      return null;
    }

    return jsonEncode(_metadata);
  }
}

enum Bearer {
  Account,
  SubAccount,
}
