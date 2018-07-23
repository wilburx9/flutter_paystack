import 'package:paystack_flutter/model/card.dart';

class CardSingleton {
  PaymentCard card;

  static final CardSingleton _singleton = CardSingleton._internal();

  factory CardSingleton() {
    return _singleton;
  }

  CardSingleton._internal();
}
