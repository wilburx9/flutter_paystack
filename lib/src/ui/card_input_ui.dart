import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/my_strings.dart';
import 'package:flutter_paystack/src/ui/input_formatters.dart';
import 'package:flutter_paystack/src/utils/card_utils.dart';

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
  var _card =
      PaymentCard(number: null, cvc: null, expiryMonth: null, expiryYear: null);

  @override
  void initState() {
    super.initState();
    _card.type = CardType.unknown;
    numberController = new TextEditingController();
    numberController.addListener(_getCardTypeFrmNumber);
    numberController.text =
        widget.currentCard != null && widget.currentCard.number != null
            ? widget.currentCard.number
            : null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Card Details'),
        ),
        body: new Container(
          padding: const EdgeInsets.all(30.0),
          child: new Form(
              key: _formKey,
              onWillPop: _onWillPop,
              autovalidate: true,
              child: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new SizedBox(
                      height: 30.0,
                    ),
                    new Text(
                      'Please provide valid card details',
                      style: const TextStyle(fontSize: 18.0),
                    ),
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
                        icon: getCardIcon(),
                        hintText: 'What number is written on card?',
                        labelText: 'Number',
                      ),
                      onSaved: (String value) {
                        _card.number = CardUtils.getCleanedNumber(value);
                      },
                      validator: validateCardNum,
                    ),
                    new SizedBox(
                      height: 30.0,
                    ),
                    new TextFormField(
                      initialValue: widget.currentCard != null &&
                              widget.currentCard.cvc != null
                          ? widget.currentCard.cvc.toString()
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
                          package: 'flutter_paystack',
                        ),
                        hintText: 'Number behind the card',
                        labelText: 'CVC',
                      ),
                      validator: validateCVC,
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        _card.cvc = value;
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
                          package: 'flutter_paystack',
                        ),
                        hintText: 'MM/YY',
                        labelText: 'Expiry Date',
                      ),
                      validator: validateDate,
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        List<int> expiryDate = getExpiryDate(value);
                        _card.expiryMonth = expiryDate[0];
                        _card.expiryYear = expiryDate[1];
                      },
                    ),
                    new SizedBox(
                      height: 50.0,
                    ),
                    new Container(
                      width: double.infinity,
                      child: Platform.isIOS
                          ? new CupertinoButton(
                              onPressed: _validateInputs,
                              color: CupertinoColors.activeBlue,
                              child: const Text(
                                Strings.continue_,
                              ),
                            )
                          : new FlatButton(
                              onPressed: _validateInputs,
                              color: Colors.lightBlue[900],
                              shape: const RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                    const Radius.circular(5.0)),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              textColor: Colors.white,
                              child: new Text(
                                Strings.continue_.toUpperCase(),
                                style: const TextStyle(fontSize: 17.0),
                              ),
                            ),
                    )
                  ],
                ),
              )),
        ));
  }

  Future<bool> _onWillPop() async {
    var text = const Text(
      'Do you want to cancel?',
    );
    return Platform.isIOS
        ? await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return new CupertinoAlertDialog(
                  title: text,
                  actions: <Widget>[
                    new CupertinoDialogAction(
                      child: const Text('Yes'),
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.pop(context, true); // Returning true to
                        // _onWillPop will pop again.
                      },
                    ),
                    new CupertinoDialogAction(
                      child: const Text('No'),
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.pop(context,
                            false); // Pops the confirmation dialog but not the page.
                      },
                    ),
                  ],
                );
              },
            ) ??
            false
        : await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  content: text,
                  actions: <Widget>[
                    new FlatButton(
                        child: const Text('NO'),
                        onPressed: () {
                          Navigator.of(context).pop(
                              false); // Pops the confirmation dialog but not the page.
                        }),
                    new FlatButton(
                        child: const Text('YES'),
                        onPressed: () {
                          Navigator.of(context).pop(
                              true); // Returning true to _onWillPop will pop again.
                        })
                  ],
                );
              },
            ) ??
            false;
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    String cardType = _card.getTypeForIIN(input);
    setState(() {
      this._card.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      var paymentCard = PaymentCard(
          number: _card.number,
          cvc: _card.cvc.toString(),
          expiryMonth: _card.expiryMonth,
          expiryYear: _card.expiryYear);
      Navigator.pop(context, paymentCard);
    }
  }

  String validateCVC(String value) {
    if (value == null || value.trim().isEmpty) return Strings.fieldReq;

    return _card.validCVC(value) ? null : 'CVV is invalid';
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

  String validateCardNum(String input) {
    if (input.isEmpty) {
      return Strings.fieldReq;
    }

    input = CardUtils.getCleanedNumber(input);

    return _card.validNumber(input) ? null : Strings.numberIsInvalid;
  }

  Widget getCardIcon() {
    String img = "";
    Icon icon;
    switch (_card.type) {
      case CardType.masterCard:
        img = 'mastercard.png';
        break;
      case CardType.visa:
        img = 'visa.png';
        break;
      case CardType.verve:
        img = 'verve.png';
        break;
      case CardType.americanExpress:
        img = 'american_express.png';
        break;
      case CardType.discover:
        img = 'discover.png';
        break;
      case CardType.dinersClub:
        img = 'dinners_club.png';
        break;
      case CardType.jcb:
        img = 'jcb.png';
        break;
      case CardType.unknown:
        icon = new Icon(
          Icons.credit_card,
          size: 30.0,
          color: Colors.grey[600],
        );
        break;
    }
    Widget widget;
    if (img.isNotEmpty) {
      widget = new Image.asset('assets/images/$img',
          width: 30.0, package: 'flutter_paystack');
    } else {
      widget = icon;
    }
    return widget;
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
