import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/common/card_utils.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/models/card.dart';
import 'package:flutter_paystack/src/widgets/common/input_formatters.dart';
import 'package:flutter_paystack/src/widgets/input/base_field.dart';

class DateField extends BaseTextField {
  DateField({
    Key? key,
    required PaymentCard? card,
    required FormFieldSetter<String> onSaved,
  }) : super(
          key: key,
          labelText: 'CARD EXPIRY',
          hintText: 'MM/YY',
          validator: validateDate,
          initialValue: _getInitialExpiryMonth(card),
          onSaved: onSaved,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            new LengthLimitingTextInputFormatter(4),
            new CardMonthInputFormatter()
          ],
        );

  static String? _getInitialExpiryMonth(PaymentCard? card) {
    if (card == null) {
      return null;
    }
    if (card.expiryYear == null ||
        card.expiryMonth == null ||
        card.expiryYear == 0 ||
        card.expiryMonth == 0) {
      return null;
    } else {
      return '${card.expiryMonth}/${card.expiryYear}';
    }
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.invalidExpiry;
    }

    int year;
    int month;
    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(new RegExp(r'(/)'))) {
      final date = CardUtils.getExpiryDate(value);
      month = date[0];
      year = date[1];
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if (!CardUtils.isNotExpired(year, month)) {
      return Strings.invalidExpiry;
    }
    return null;
  }
}
