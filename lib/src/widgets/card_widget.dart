import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/models/card.dart';
import 'package:flutter_paystack/src/widgets/base_widget.dart';
import 'package:flutter_paystack/src/widgets/buttons.dart';
import 'package:flutter_paystack/src/widgets/custom_dialog.dart';
import 'package:flutter_paystack/src/widgets/input/card_input.dart';

class CardInputWidget extends StatefulWidget {
  final PaymentCard? card;

  CardInputWidget(this.card);

  @override
  _CardInputWidgetState createState() {
    return new _CardInputWidgetState();
  }
}

class _CardInputWidgetState extends BaseState<CardInputWidget> {
  @override
  void initState() {
    super.initState();
    confirmationMessage = 'Do you want to cancel card input?';
  }

  @override
  Widget buildChild(BuildContext context) {
    return new CustomAlertDialog(
      content: new SingleChildScrollView(
        child: new Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          alignment: Alignment.center,
          child: new Column(
            children: <Widget>[
              new Text(
                'Please, provide valid card details.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              new SizedBox(
                height: 35.0,
              ),
              new CardInput(
                buttonText: 'Continue',
                card: widget.card,
                onValidated: _onCardValidated,
              ),
              new SizedBox(
                height: 10.0,
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new WhiteButton(
                  onPressed: onCancelPress,
                  text: 'Cancel',
                  flat: true,
                  bold: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCardValidated(PaymentCard? card) {
    Navigator.pop(context, card);
  }
}
