import 'package:flutter_paystack/src/common/card_utils.dart';
import 'package:flutter_paystack/src/common/string_utils.dart';

/// The class for the Payment Card model. Has utility methods for validating
/// the card.
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
  String? name;

  /// Card number
  String? _number;

  /// Card CVV or CVC
  String? _cvc;

  /// Expiry month
  int? expiryMonth = 0;

  /// Expiry year
  int? expiryYear = 0;

  /// Bank Address line 1
  String? addressLine1;

  /// Bank Address line 2
  String? addressLine2;

  /// Bank Address line 3
  String? addressLine3;

  /// Bank Address line 4
  String? addressLine4;

  /// Postal code of the bank address
  String? addressPostalCode;

  /// Country of the bank
  String? addressCountry;

  String? country;

  /// Type of card
  String? _type;

  String? _last4Digits;

  set type(String? value) => _type = value;

  String? get number => _number;

  String? get last4Digits => _last4Digits;

  String? get type {
    // If type is empty and the number isn't empty
    if (StringUtils.isEmpty(_type)) {
      if (!StringUtils.isEmpty(number)) {
        for (var cardType in cardTypes) {
          if (cardType.hasFullMatch(number)) {
            return cardType.toString();
          }
        }
      }
      return CardType.unknown;
    }
    return _type;
  }

  // Get the card type by matching the starting characters against the Issuer
  // Identification Number (IIN)
  String getTypeForIIN(String? cardNumber) {
    // If type is empty and the number isn't empty
    if (!StringUtils.isEmpty(cardNumber)) {
      for (var cardType in cardTypes) {
        if (cardType.hasStartingMatch(cardNumber)) {
          return cardType.toString();
        }
      }
      return CardType.unknown;
    }
    return CardType.unknown;
  }

  set number(String? value) {
    _number = CardUtils.getCleanedNumber(value);
    if (number!.length == 4) {
      _last4Digits = number;
    } else if (number!.length > 4) {
      _last4Digits = number!.substring(number!.length - 4);
    } else {
      // whatever is appropriate in this case
      _last4Digits = number;
    }
  }

  nullifyNumber() {
    _number = null;
  }

  String? get cvc => _cvc;

  set cvc(String? value) {
    _cvc = CardUtils.getCleanedNumber(value);
  }

  PaymentCard(
      {required String? number,
      required String? cvc,
      required this.expiryMonth,
      required this.expiryYear,
      String? name,
      String? addressLine1,
      String? addressLine2,
      String? addressLine3,
      String? addressLine4,
      String? addressPostCode,
      String? addressCountry,
      String? country}) {
    this.number = number;
    this.cvc = cvc;
    this.name = StringUtils.nullify(name);
    this.addressLine1 = StringUtils.nullify(addressLine1);
    this.addressLine2 = StringUtils.nullify(addressLine2);
    this.addressLine3 = StringUtils.nullify(addressLine3);
    this.addressLine4 = StringUtils.nullify(addressLine4);
    this.addressCountry = StringUtils.nullify(addressCountry);
    this.addressPostalCode = StringUtils.nullify(addressPostalCode);

    this.country = StringUtils.nullify(country);
    this.type = type;
  }

  PaymentCard.empty() {
    this.expiryYear = 0;
    this.expiryMonth = 0;
    this._number = null;
    this.cvc = null;
  }

  /// Validates the CVC or CVV of the card
  /// Returns true if the cvc is valid
  bool isValid() {
    return cvc != null &&
        number != null &&
        expiryMonth != null &&
        expiryYear != null &&
        validNumber(null) &&
        CardUtils.isNotExpired(expiryYear, expiryMonth) &&
        validCVC(null);
  }

  /// Validates the CVC or CVV of a card.
  /// Returns true if CVC is valid and false otherwise
  bool validCVC(String? cardCvc) {
    cardCvc ??= this.cvc;

    if (cardCvc == null || cardCvc.trim().isEmpty) return false;

    var cvcValue = cardCvc.trim();
    bool validLength =
        ((_type == null && cvcValue.length >= 3 && cvcValue.length <= 4) ||
            (CardType.americanExpress == _type && cvcValue.length == 4) ||
            (CardType.americanExpress != _type && cvcValue.length == 3));
    return (CardUtils.isWholeNumberPositive(cvcValue) && validLength);
  }

  /// Validates the number of the card
  /// Returns true if the number is valid. Returns false otherwise
  bool validNumber(String? cardNumber) {
    if (cardNumber == null) {
      cardNumber = this.number;
    }
    if (StringUtils.isEmpty(cardNumber)) return false;

    // Remove all non digits
    var formattedNumber =
        cardNumber!.trim().replaceAll(new RegExp(r'[^0-9]'), '');

    // Verve card needs no other validation except it matched pattern
    if (CardType.fullPatternVerve.hasMatch(formattedNumber)) {
      return true;
    }

    //check if formattedNumber is empty or card isn't a whole positive number or isn't Luhn-valid
    if (StringUtils.isEmpty(formattedNumber) ||
        !CardUtils.isWholeNumberPositive(cardNumber) ||
        !_isValidLuhnNumber(cardNumber)) return false;

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

  @override
  String toString() {
    return 'PaymentCard{_cvc: $_cvc, expiryMonth: $expiryMonth, expiryYear: '
        '$expiryYear, _type: $_type, _last4Digits: $_last4Digits , _number: '
        '$_number}';
  }
}

abstract class CardType {
  // Card types
  static const String visa = "Visa";
  static const String masterCard = "MasterCard";
  static const String americanExpress = "American Express";
  static const String dinersClub = "Diners Club";
  static const String discover = "Discover";
  static const String jcb = "JCB";
  static const String verve = "VERVE";
  static const String unknown = "Unknown";

  // Length for some cards
  static final int maxLengthNormal = 16;
  static final int maxLengthAmericanExpress = 15;
  static final int maxLengthDinersClub = 14;

  // Regular expressions to match complete numbers of the card
  //source of these regex patterns http://stackoverflow.com/questions/72768/how-do-you-detect-credit-card-type-based-on-number
  static final fullPatternVisa = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');
  static final fullPatternMasterCard = RegExp(
      r'^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$');
  static final fullPatternAmericanExpress = RegExp(r'^3[47][0-9]{13}$');
  static final fullPatternDinersClub = RegExp(r'^3(?:0[0-5]|[68][0-9])'
      r'[0-9]{11}$');
  static final fullPatternDiscover = RegExp(r'^6(?:011|5[0-9]{2})[0-9]{12}$');
  static final fullPatternJCB = RegExp(r'^(?:2131|1800|35[0-9]{3})'
      r'[0-9]{11}$');
  static final fullPatternVerve =
      RegExp(r'^((506(0|1))|(507(8|9))|(6500))[0-9]{12,15}$');

  // Regular expression to match starting characters (aka issuer
  // identification number (IIN)) of the card
  // Source https://en.wikipedia.org/wiki/Payment_card_number
  static final startingPatternVisa = RegExp(r'[4]');
  static final startingPatternMasterCard = RegExp(
      r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))');
  static final startingPatternAmericanExpress = RegExp(r'((34)|(37))');
  static final startingPatternDinersClub =
      RegExp(r'((30[0-5])|(3[89])|(36)|(3095))');
  static final startingPatternJCB =
      RegExp(r'(2131)|(1800)(352[89])|(35[3-8]*[0-9])');
  static final startingPatternVerve = RegExp(r'((506(0|1))|(507(8|9))|(6500))');
  static final startingPatternDiscover = RegExp(r'((6[45])|(6011))');

  bool hasFullMatch(String? cardNumber);

  bool hasStartingMatch(String? cardNumber);

  @override
  String toString();
}

class _Visa extends CardType {
  @override
  bool hasFullMatch(String? cardNumber) {
    return CardType.fullPatternVisa.hasMatch(cardNumber!);
  }

  @override
  bool hasStartingMatch(String? cardNumber) {
    return cardNumber!.startsWith(CardType.startingPatternVisa);
  }

  @override
  String toString() {
    return CardType.visa;
  }
}

class _MasterCard extends CardType {
  @override
  bool hasFullMatch(String? cardNumber) {
    return CardType.fullPatternMasterCard.hasMatch(cardNumber!);
  }

  @override
  bool hasStartingMatch(String? cardNumber) {
    return cardNumber!.startsWith(CardType.startingPatternMasterCard);
  }

  @override
  String toString() {
    return CardType.masterCard;
  }
}

class _AmericanExpress extends CardType {
  @override
  bool hasFullMatch(String? cardNumber) {
    return CardType.fullPatternAmericanExpress.hasMatch(cardNumber!);
  }

  @override
  bool hasStartingMatch(String? cardNumber) {
    return cardNumber!.startsWith(CardType.startingPatternAmericanExpress);
  }

  @override
  String toString() {
    return CardType.americanExpress;
  }
}

class _DinersClub extends CardType {
  @override
  bool hasFullMatch(String? cardNumber) {
    return CardType.fullPatternDinersClub.hasMatch(cardNumber!);
  }

  @override
  bool hasStartingMatch(String? cardNumber) {
    return cardNumber!.startsWith(CardType.startingPatternDinersClub);
  }

  @override
  String toString() {
    return CardType.dinersClub;
  }
}

class _Discover extends CardType {
  @override
  bool hasFullMatch(String? cardNumber) {
    return CardType.fullPatternDiscover.hasMatch(cardNumber!);
  }

  @override
  bool hasStartingMatch(String? cardNumber) {
    return cardNumber!.startsWith(CardType.startingPatternDiscover);
  }

  @override
  String toString() {
    return CardType.discover;
  }
}

class _Jcb extends CardType {
  @override
  bool hasFullMatch(String? cardNumber) {
    return CardType.fullPatternJCB.hasMatch(cardNumber!);
  }

  @override
  bool hasStartingMatch(String? cardNumber) {
    return cardNumber!.startsWith(CardType.startingPatternJCB);
  }

  @override
  String toString() {
    return CardType.jcb;
  }
}

class _Verve extends CardType {
  @override
  bool hasFullMatch(String? cardNumber) {
    return CardType.fullPatternVerve.hasMatch(cardNumber!);
  }

  @override
  bool hasStartingMatch(String? cardNumber) {
    return cardNumber!.startsWith(CardType.startingPatternVerve);
  }

  @override
  String toString() {
    return CardType.verve;
  }
}
