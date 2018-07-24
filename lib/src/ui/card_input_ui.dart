import 'dart:io';

import 'package:flutter/material.dart' hide Card;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:paystack_flutter/src/model/card.dart' hide CardType;
import 'package:paystack_flutter/src/my_strings.dart';
import 'package:paystack_flutter/src/singletons.dart';
import 'package:paystack_flutter/src/utils/card_utils.dart';
import 'package:paystack_flutter/src/ui/input_formatters.dart';

class CardInputUI extends StatefulWidget {
  final PaymentCard currentCard;

  CardInputUI(this.currentCard);

  @override
  _CardInputUIState createState() => new _CardInputUIState();
}

class _CardInputUIState extends State<CardInputUI> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  TextEditingController numberController;
  var _card = Card();
  var _autoValidate = false;

  @override
  void initState() {
    super.initState();
    numberController = new TextEditingController(
        text: widget.currentCard != null && widget.currentCard.number != null
            ? widget.currentCard.number
            : null);
    _card.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          backgroundColor: Colors.lightBlue[900],
          title: new Text('Card Details'),
        ),
        body: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: new Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: new ListView(
                children: <Widget>[
                  new SizedBox(
                    height: 20.0,
                  ),
                  new Text('Please provide valid card details'),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(19),
                      new CardNumberInputFormatter()
                    ],
                    controller: numberController,
                    decoration: new InputDecoration(
                      border: const UnderlineInputBorder(),
                      icon: getCardIcon(_card.type),
                      hintText: 'What number is written on card?',
                      labelText: 'Number',
                    ),
                    onSaved: (String value) {
                      _card.number = getCleanedNumber(value);
                    },
                    validator: validateCardNum,
                  ),
                  new SizedBox(
                    height: 30.0,
                  ),
                  new TextFormField(
                    initialValue: widget.currentCard != null &&
                            widget.currentCard.cvc != null
                        ? widget.currentCard.cvc
                        : null,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: new InputDecoration(
                      border: const UnderlineInputBorder(),
                      icon: new Image.asset(
                        'assets/images/card_cvv.png',
                        width: 30.0,
                        color: Colors.grey[600],
                      ),
                      hintText: 'Number behind the card',
                      labelText: 'CVC',
                    ),
                    validator: validateCVC,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _card.cvc = int.parse(value);
                    },
                  ),
                  new SizedBox(
                    height: 30.0,
                  ),
                  new TextFormField(
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(4),
                      new CardMonthInputFormatter()
                    ],
                    initialValue: _getInitialExpiryMonth(widget.currentCard),
                    decoration: new InputDecoration(
                      border: const UnderlineInputBorder(),
                      icon: new Image.asset(
                        'assets/images/calender.png',
                        width: 30.0,
                        color: Colors.grey[600],
                      ),
                      hintText: 'MM/YY',
                      labelText: 'Expiry Date',
                    ),
                    validator: validateDate,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      List<int> expiryDate = getExpiryDate(value);
                      _card.month = expiryDate[0];
                      _card.year = expiryDate[1];
                    },
                  ),
                  new SizedBox(
                    height: 50.0,
                  ),
                  new Container(
                    alignment: Alignment.center,
                    child: _getActionButtons(),
                  )
                ],
              )),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = getCleanedNumber(numberController.text);
    CardType cardType = getCardTypeFrmNumber(input);
    setState(() {
      this._card.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
      _showInSnackBar('Please fix the errors in red before proceeding.');
    } else {
      form.save();
      var paymentCard = PaymentCard(
          number: _card.number,
          cvc: _card.cvc.toString(),
          expiryMonth: _card.month,
          expiryYear: _card.year);
      Navigator.pop(context, paymentCard);
    }
  }

  void _cancelInputs() {
    Navigator.pop(context, null);
  }

  Widget _getActionButtons() {
    if (Platform.isAndroid) {
      return new Column(
        children: <Widget>[
          new CupertinoButton(
            onPressed: _validateInputs,
            color: CupertinoColors.activeBlue,
            child: const Text(
              Strings.continue_,
            ),
          ),
          new SizedBox(
            height: 20.0,
          ),
          new CupertinoButton(
            onPressed: _cancelInputs,
            color: CupertinoColors.destructiveRed,
            child: const Text(
              Strings.cancel,
            ),
          )
        ],
      );
    } else {
      var border = RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(5.0)),
      );
      const padding =
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0);
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new FlatButton(
            onPressed: _cancelInputs,
            color: Colors.red,
            shape: border,
            padding: padding,
            textColor: Colors.white,
            child: new Text(
              Strings.cancel.toUpperCase(),
              style: const TextStyle(fontSize: 17.0),
            ),
          ),
          new SizedBox(
            height: 20.0,
          ),
          new FlatButton(
            onPressed: _validateInputs,
            color: Colors.lightBlue[900],
            shape: border,
            padding: padding,
            textColor: Colors.white,
            child: new Text(
              Strings.continue_.toUpperCase(),
              style: const TextStyle(fontSize: 17.0),
            ),
          ),
        ],
      );
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: 3),
    ));
  }

  String validateCVC(String value) {
    if (value == null || value.trim().isEmpty) return Strings.fieldReq;

    var cvcValue = value.trim();
    bool validLength = ((_card.type == CardType.Others &&
            cvcValue.length >= 3 &&
            cvcValue.length <= 4) ||
        (CardType.AmericanExpress == _card.type && cvcValue.length == 4) ||
        (CardType.AmericanExpress != _card.type && cvcValue.length == 3));
    bool validCVC =
        !(!CardUtils.isWholeNumberPositive(cvcValue) || !validLength);

    return validCVC ? null : 'CVV is invalid';
  }

  String validateDate(String value) {
    if (value.isEmpty) {
      return Strings.fieldReq;
    }

    int year;
    int month;
    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(new RegExp(r'(\/)'))) {
      var split = value.split(new RegExp(r'(\/)'));
      // The value before the slash is the month while the value to right of
      // it is the year.
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if ((month < 1) || (month > 12)) {
      // A valid month is between 1 (January) and 12 (December)
      return 'Expiry month is invalid';
    }

    var fourDigitsYear = CardUtils.convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      // We are assuming a valid should be between 1 and 2099.
      // Note that, it's valid doesn't mean that it has not expired.
      return 'Expiry year is invalid';
    }

    if (!CardUtils.validExpiryDate(month, year)) {
      return "Card has expired";
    }
    return null;
  }

  /// With the card number with Luhn Algorithm
  /// https://en.wikipedia.org/wiki/Luhn_algorithm
  String validateCardNum(String input) {
    if (input.isEmpty) {
      return Strings.fieldReq;
    }

    input = getCleanedNumber(input);

    if (input.length < 8) {
      return Strings.numberIsInvalid;
    }

    int sum = 0;
    int length = input.trim().length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      var source = input[length - i - 1];

      // Check if character is digit before parsing it
      if (!((input.codeUnitAt(i) ^ 0x30) <= 9)) {
        return Strings.numberIsInvalid;
      }
      int digit = int.parse(source);

      // if it's odd, multiply by 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }

    if (sum % 10 == 0) {
      return null;
    }

    return Strings.numberIsInvalid;
  }

  String getCleanedNumber(String text) {
    RegExp regExp = new RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  Widget getCardIcon(CardType cardType) {
    String img = "";
    Icon icon;
    switch (cardType) {
      case CardType.Master:
        img = 'mastercard.png';
        break;
      case CardType.Visa:
        img = 'visa.png';
        break;
      case CardType.Verve:
        img = 'verve.png';
        break;
      case CardType.AmericanExpress:
        img = 'american_express.png';
        break;
      case CardType.Discover:
        img = 'discover.png';
        break;
      case CardType.DinersClub:
        img = 'dinners_club.png';
        break;
      case CardType.Jcb:
        img = 'jcb.png';
        break;
      case CardType.Others:
        icon = new Icon(
          Icons.credit_card,
          size: 30.0,
          color: Colors.grey[600],
        );
        break;
      case CardType.Invalid:
        icon = new Icon(
          Icons.warning,
          size: 30.0,
          color: Colors.grey[600],
        );
        break;
    }
    Widget widget;
    if (img.isNotEmpty) {
      widget = new Image.asset(
        'assets/images/$img',
        width: 30.0,
      );
    } else {
      widget = icon;
    }
    return widget;
  }

  CardType getCardTypeFrmNumber(String input) {
    CardType cardType;
    if (input.startsWith(new RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.Master;
    } else if (input.startsWith(new RegExp(r'[4]'))) {
      cardType = CardType.Visa;
    } else if (input
        .startsWith(new RegExp(r'((506(0|1))|(507(8|9))|(6500))'))) {
      cardType = CardType.Verve;
    } else if (input.startsWith(new RegExp(r'((34)|(37))'))) {
      cardType = CardType.AmericanExpress;
    } else if (input.startsWith(new RegExp(r'((6[45])|(6011))'))) {
      cardType = CardType.Discover;
    } else if (input
        .startsWith(new RegExp(r'((30[0-5])|(3[89])|(36)|(3095))'))) {
      cardType = CardType.DinersClub;
    } else if (input.startsWith(new RegExp(r'(352[89]|35[3-8][0-9])'))) {
      cardType = CardType.Jcb;
    } else if (input.length <= 8) {
      cardType = CardType.Others;
    } else {
      cardType = CardType.Invalid;
    }
    return cardType;
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(new RegExp(r'(\/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  String _getInitialExpiryMonth(PaymentCard card) {
    if (card == null) {
      return null;
    }
    if (card.expiryYear == null || card.expiryMonth == null) {
      return null;
    } else {
      return '${card.expiryMonth}/${card.expiryYear}';
    }
  }
}

enum CardType {
  Master,
  Visa,
  Verve,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
  Others,
  Invalid
}

class Card {
  CardType type;
  String number;
  String name;
  int month;
  int year;
  int cvc;

  Card({this.type, this.number, this.name, this.month, this.year, this.cvc});

  @override
  String toString() {
    return '[Type: $type, Number: $number, Name: $name, Month: $month, Year: $year, CVC: $cvc]';
  }
}
