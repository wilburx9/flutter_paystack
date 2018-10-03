import 'dart:convert';

import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/ui/widgets/checkout/bank_checkout.dart';

class BankChargeRequestBody {
  String _email;
  String _amount;
  String _metadata;
  BankAccount _account;
  String birthday;
  String otp;

  BankChargeRequestBody(Charge charge)
      : this._email = charge.email,
        this._amount = charge.amount.toString(),
        this._metadata = charge.metadata,
        this._account = charge.account;

  Map paramsMap() {
    var params = {
      'email': _email,
      'amount': _amount,
      'bank': {
        'code': _account.bank.code,
        'account_number': _account.number,
      }
    };

    if (_metadata != null && _metadata.isNotEmpty) {
      params['metadata'] = jsonEncode(_metadata);
    }
    return params;
  }

  Map<String, String> birthdayParams(String reference) {
    return {'reference': reference, 'birthday': birthday};
  }

  Map<String, String> otpParams(String reference) {
    return {'reference': reference, 'otp': otp};
  }
}
