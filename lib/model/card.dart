import 'package:meta/meta.dart';
import 'package:paystack_flutter/my_strings.dart';
import 'package:paystack_flutter/utils/card_utils.dart';
import 'package:paystack_flutter/utils/string_utils.dart';

/// The class for the Payment Card model. Has utility methods for validating
/// the card.
/// TODO: Add doc for initialization
class PaymentCard {
  // List of supported card types
  final List<CardType> cardTypes = [
    _Visa(),
    _MasterCard(),
    _AmericanExpress(),
    _DinersClub(),
    _Discover(),
    _Jcb(),
    _Verve()
  ];

  /// Name on card
  String name;

  /// Card number
  String number;

  /// Card CVV or CVC
  String cvc;

  /// Expiry month
  int expiryMonth;

  /// Expiry year
  int expiryYear;

  /// Bank Address line 1
  String addressLine1;

  /// Bank Address line 2
  String addressLine2;

  /// Bank Address line 3
  String addressLine3;

  /// Bank Address line 4
  String addressLine4;

  /// Postal code of the bank address
  String addressPostCode;

  /// Country of the bank
  String addressCountry;
  String country;

  /// Type of card
  String _type;

  String last4Digits;

  set type(String value) {
    //if type is empty and the number isn't empty
    if (value != null && value.isNotEmpty && number.isNotEmpty) {
      for (var cardType in cardTypes) {
        if (cardType.hasMatch(number)) {
          value = cardType.toString();
          break;
        }
      }
    }
    _type = value;
  }

  PaymentCard(
      {@required this.number,
      @required this.cvc,
      @required this.expiryMonth,
      @required this.expiryYear,
      this.name,
      this.addressLine1,
      this.addressLine2,
      this.addressLine3,
      this.addressLine4,
      this.addressPostCode,
      this.addressCountry,
      this.country}) {
    assert(name == null || name.isNotEmpty, 'Card name ${Strings.emptyStr}');
    assert(addressLine1 == null || addressLine1.isNotEmpty,
        'addressLine1 ${Strings.emptyStr}');
    assert(addressLine2 == null || addressLine2.isNotEmpty,
        'addressLine2 ${Strings.emptyStr}');
    assert(addressLine3 == null || addressLine3.isNotEmpty,
        'addressLine3 ${Strings.emptyStr}');
    assert(addressLine4 == null || addressLine4.isNotEmpty,
        'addressLine4 ${Strings.emptyStr}');
    assert(addressCountry == null || addressCountry.isNotEmpty,
        'addressCountry ${Strings.emptyStr}');
    assert(addressPostCode == null || addressPostCode.isNotEmpty,
        'addressPostCode ${Strings.emptyStr}');
    assert(
        country == null || country.isNotEmpty, 'country ${Strings.emptyStr}');
    this.type = number;
  }

  /// Validates the CVC or CVV of the card
  /// Returns true if the cvc is valid
  bool isValid() {
    return cvc != null && number != null && expiryMonth != null && expiryYear
        != null && validNumber() && CardUtils.validExpiryDate(expiryMonth, expiryYear)
        && validCVC();

  }

  /// Validates the CVC or CVV of a card.
  /// Returns true if CVC is valid and false otherwise
  bool validCVC() {
    if (cvc == null || cvc.trim().isEmpty) return false;

    var cvcValue = cvc.trim();
    bool validLength =
        ((_type == null && cvcValue.length >= 3 && cvcValue.length <= 4) ||
            (CardType.americanExpress == _type && cvcValue.length == 4) ||
            (CardType.americanExpress != _type && cvcValue.length == 3));
    return !(!CardUtils.isWholeNumberPositive(cvcValue) || !validLength);
  }

  /// Validates the number of the card
  /// Returns true if the number is valid. Returns false otherwise
  bool validNumber() {
    if (StringUtils.isEmpty(number)) return false;

    // Remove all non digits
    var formattedNumber = number.trim().replaceAll(new RegExp(r'[^0-9]'), '');

    // Verve card needs no other validation except it matched pattern
    if (CardType.patternVerve.hasMatch(formattedNumber)) {
      return true;
    }

    //check if formattedNumber is empty or card isn't a whole positive number or isn't Luhn-valid
    if (StringUtils.isEmpty(formattedNumber) ||
        !CardUtils.isWholeNumberPositive(number) ||
        !_isValidLuhnNumber(number)) return false;

    // check type lengths
    if (CardType.americanExpress == _type) {
      return formattedNumber.length == CardType.maxLengthAmericanExpress;
    } else if (CardType.dinersClub == _type) {
      return formattedNumber.length == CardType.maxLengthDinersClub;
    } else {
      return formattedNumber.length == CardType.maxLengthNormal;
    }
  }

  /// Validates the number against Luhn algorithm https://de.wikipedia.org/wiki/Luhn-Algorithmus#Java
  /// [number]  - number to validate
  /// Returns true if the number is passes the verification.
  bool _isValidLuhnNumber(String number) {
    int sum = 0;
    int length = number.trim().length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      var source = number[length - i - 1];

      // Check if character is digit before parsing it
      if (!((number.codeUnitAt(i) ^ 0x30) <= 9)) {
        return false;
      }
      int digit = int.parse(source);

      // if it's odd, multiply by 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }

    return sum % 10 == 0;
  }

}

abstract class CardType {
  // Card types
  static final String visa = "Visa";
  static final String masterCard = "MasterCard";
  static final String americanExpress = "American Express";
  static final String dinersClub = "Diners Club";
  static final String discover = "Discover";
  static final String jcb = "JCB";
  static final String verve = "VERVE";
  static final String unknown = "Unknown";

  // Length for some cards
  static final int maxLengthNormal = 16;
  static final int maxLengthAmericanExpress = 15;
  static final int maxLengthDinersClub = 14;

  // Regular expressions for supported card types
  //source of these regex patterns http://stackoverflow.com/questions/72768/how-do-you-detect-credit-card-type-based-on-number
  static final RegExp patternVisa = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');
  static final RegExp patternMasterCard = RegExp(
      r'^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$');
  static final RegExp patternAmericanExpress = RegExp(r'^3[47][0-9]{13}$');
  static final RegExp patternDinersClub = RegExp(r'^3(?:0[0-5]|[68][0-9])'
      r'[0-9]{11}$');
  static final RegExp patternJCB = RegExp(r'^(?:2131|1800|35[0-9]{3})'
      r'[0-9]{11}$');
  static final RegExp patternVerve =
      RegExp(r'^((506(0|1))|(507(8|9))|(6500))[0-9]{12,15}$');

  bool hasMatch(String cardNumber);

  @override
  String toString();
}

class _Visa extends CardType {
  @override
  bool hasMatch(String cardNumber) {
    return CardType.patternVisa.hasMatch(cardNumber);
  }

  @override
  String toString() {
    return CardType.visa;
  }
}

class _MasterCard extends CardType {
  @override
  bool hasMatch(String cardNumber) {
    return CardType.patternMasterCard.hasMatch(cardNumber);
  }

  @override
  String toString() {
    return CardType.masterCard;
  }
}

class _AmericanExpress extends CardType {
  @override
  bool hasMatch(String cardNumber) {
    return CardType.patternAmericanExpress.hasMatch(cardNumber);
  }

  @override
  String toString() {
    return CardType.americanExpress;
  }
}

class _DinersClub extends CardType {
  @override
  bool hasMatch(String cardNumber) {
    return CardType.patternDinersClub.hasMatch(cardNumber);
  }

  @override
  String toString() {
    return CardType.dinersClub;
  }
}

class _Discover extends CardType {
  @override
  bool hasMatch(String cardNumber) {
    return CardType.patternDinersClub.hasMatch(cardNumber);
  }

  @override
  String toString() {
    return CardType.discover;
  }
}

class _Jcb extends CardType {
  @override
  bool hasMatch(String cardNumber) {
    return CardType.patternJCB.hasMatch(cardNumber);
  }

  @override
  String toString() {
    return CardType.jcb;
  }
}

class _Verve extends CardType {
  @override
  bool hasMatch(String cardNumber) {
    return CardType.patternVerve.hasMatch(cardNumber);
  }

  @override
  String toString() {
    return CardType.verve;
  }
}
