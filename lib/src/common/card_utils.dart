import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/string_utils.dart';
import 'package:flutter_paystack/src/models/card.dart';

class CardUtils {
  static bool isWholeNumberPositive(String? value) {
    if (value == null) {
      return false;
    }

    for (var i = 0; i < value.length; ++i) {
      if (!((value.codeUnitAt(i) ^ 0x30) <= 9)) {
        return false;
      }
    }

    return true;
  }

  /// Returns true if both [year] and [month] has passed.
  /// Please, see the documentation for [hasYearPassed] and [convertYearTo4Digits]
  /// for nuances
  static bool hasMonthPassed(int? year, int? month) {
    if (year == null || month == null) return true;
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool isValidMonth(int? month) {
    return month != null && month > 0 && month < 13;
  }

  /// Returns true if [year] is has passed.
  /// It calls [convertYearTo4Digits] on [year] so two digits year will be
  /// prepended with  "20":
  ///
  ///     var v = hasYearPassed(94);
  ///     print(v); // false because 94 is converted to 2094, and 2094 is in the future
  static bool hasYearPassed(int? year) {
    int fourDigitsYear = convertYearTo4Digits(year)!;
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's year
    return fourDigitsYear < now.year;
  }

  static bool isNotExpired(int? year, int? month) {
    if ((year == null || month == null) || (month > 12 || year > 2999)) {
      return false;
    }
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  /// Convert the two-digit year to four-digit year if necessary
  /// When [year] is in the range of >=0  and < 100, it appends "20" to it:
  ///
  ///     var c = convertYearTo4Digits(10);
  ///     print(c); // 2010;
  ///
  ///     var x = convertYearTo4Digits(1);
  ///     print(x); // 2001
  ///
  /// If the year is not in the specified range above, it returns it as it is:
  ///
  ///     var v = convertYearTo4Digits(2333);
  ///     print(v); // 2333
  static int? convertYearTo4Digits(int? year) {
    if (year == null) return 0;
    if (year < 100 && year >= 0) {
      String prefix = "20";
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  /// Removes non numerical characters from the string
  static String getCleanedNumber(String? text) {
    if (text == null) {
      return '';
    }
    RegExp regExp = new RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  /// Concatenates card number, cvv, month and year using "*" as the separator.
  ///
  /// Note: The card details are not validated.
  static String concatenateCardFields(PaymentCard? card) {
    if (card == null) {
      throw new CardException("Card cannot be null");
    }

    String? number = StringUtils.nullify(card.number);
    String? cvc = StringUtils.nullify(card.cvc);
    int expiryMonth = card.expiryMonth ?? 0;
    int expiryYear = card.expiryYear ?? 0;

    var cardFields = [
      number,
      cvc,
      expiryMonth.toString(),
      expiryYear.toString()
    ];

    if (!StringUtils.isEmpty(number)) {
      return cardFields.join("*");
    } else {
      throw new CardException(
          'Invalid card details: Card number is empty or null');
    }
  }

  /// Accepts a forward-slash("/") separated string and returns a 2 sized int list of
  /// the first number before the "/" and the last number after the "/
  static List<int> getExpiryDate(String? value) {
    if (value == null) return [-1, -1];
    var split = value.split(new RegExp(r'(\/)'));
    var month = int.tryParse(split[0]) ?? -1;
    if (split.length == 1) {
      return [month, -1];
    }
    var year = int.tryParse(split[split.length - 1]) ?? -1;
    return [month, year];
  }
}
