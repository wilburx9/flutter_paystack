import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/common/string_utils.dart';

const cardConcatenateValue = '*';

class CardUtils {
  static bool isWholeNumberPositive(String value) {
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

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool isValidMonth(int month) {
    return (month > 0) && (month < 13);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's
    // year
    return fourDigitsYear < now.year;
  }

  static bool isNotExpired(int year, int month) {
    if (month > 12 || year > 2999) {
      return false;
    }
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  /// Convert the two-digit year to four-digit year if necessary
  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static String getCleanedNumber(String text) {
    if (text == null) {
      return '';
    }
    RegExp regExp = new RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  /// Checks if the card has expired.
  /// Returns true if the card has expired; false otherwise
  static bool validExpiryDate(int expiryMonth, int expiryYear) {
    return !(expiryMonth == null || expiryYear == null) &&
        isNotExpired(expiryYear, expiryMonth);
  }

  static String concatenateCardFields(PaymentCard card) {
    if (card == null) {
      throw new CardException("Card cannot be null");
    }

    String number = StringUtils.nullify(card.number);
    String cvc = StringUtils.nullify(card.cvc);
    int expiryMonth = card.expiryMonth;
    int expiryYear = card.expiryYear;

    String cardString;
    var cardFields = [
      number,
      cvc,
      expiryMonth.toString(),
      expiryYear.toString()
    ];

    if (!StringUtils.isEmpty(number)) {
      for (int i = 0; i < cardFields.length; i++) {
        if (i == 0 && cardFields.length > 1) {
          cardString = '${cardFields[i]}$cardConcatenateValue';
        } else if (i == cardFields.length - 1) {
          cardString += cardFields[i];
        } else {
          cardString = '$cardString${cardFields[i]}$cardConcatenateValue';
        }
      }
      return cardString;
    } else {
      throw new CardException(
          'Invalid card details: Card number is empty or null');
    }
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(new RegExp(r'(\/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }
}
