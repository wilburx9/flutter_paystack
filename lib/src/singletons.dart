import 'package:paystack_flutter/src/model/card.dart';

class AuthSingleton {
  var responseMap =
      '{\"status\":\"requery\",\"message\":\"Reaffirm Transaction Status on Server\"}';
  var url = '';

  static final AuthSingleton _singleton = AuthSingleton._internal();

  factory AuthSingleton() {
    return _singleton;
  }

  AuthSingleton._internal();
}

class CardSingleton {
  PaymentCard card;

  static final CardSingleton _singleton = CardSingleton._internal();

  factory CardSingleton() {
    return _singleton;
  }

  CardSingleton._internal();
}

class OtpSingleton {
  var otp = '';
  var otpMessage = '';
  static final OtpSingleton _singleton = OtpSingleton._internal();

  factory OtpSingleton() {
    return _singleton;
  }

  OtpSingleton._internal();
}

class PinSingleton {
  var pin = '';

  static final PinSingleton _singleton = PinSingleton._internal();

  factory PinSingleton() {
    return _singleton;
  }

  PinSingleton._internal();
}
