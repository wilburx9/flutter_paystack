import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/widgets/input/base_field.dart';

class AccountField extends BaseTextField {
  AccountField({required FormFieldSetter<String> onSaved})
      : super(
          labelText: 'Bank Account Number(10 digits)',
          validator: _validate,
          onSaved: onSaved,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            new LengthLimitingTextInputFormatter(10),
          ],
        );

  static String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return Strings.invalidAcc;
    return value.length == 10 ? null : Strings.invalidAcc;
  }
}
