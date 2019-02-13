import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/model/checkout_response.dart';
import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/common/transaction.dart';
import 'package:flutter_paystack/src/transaction/bank_transaction_manager.dart';
import 'package:flutter_paystack/src/widgets/common/my_colors.dart';
import 'package:flutter_paystack/src/widgets/buttons.dart';
import 'package:flutter_paystack/src/widgets/checkout/base_checkout.dart';
import 'package:flutter_paystack/src/widgets/checkout/checkout_widget.dart';
import 'package:flutter_paystack/src/widgets/input/account_field.dart';
import 'package:flutter_paystack/src/common/utils.dart';

class BankCheckout extends StatefulWidget {
  final Charge charge;
  final OnResponse<CheckoutResponse> onResponse;
  final ValueChanged<bool> onProcessingChange;

  BankCheckout({
    @required this.charge,
    @required this.onResponse,
    @required this.onProcessingChange,
  });

  @override
  _BankCheckoutState createState() => _BankCheckoutState(onResponse);
}

class _BankCheckoutState extends BaseCheckoutMethodState<BankCheckout> {
  var _formKey = new GlobalKey<FormState>();
  AnimationController _controller;
  Animation<double> _animation;
  var _autoValidate = false;
  Future _futureBanks;
  Bank _currentBank;
  BankAccount _account;
  var _loading = false;

  _BankCheckoutState(OnResponse<CheckoutResponse> onResponse)
      : super(onResponse, CheckoutMethod.bank);

  @override
  void initState() {
    _futureBanks = Utils.getSupportedBanks();
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = new Tween(begin: 0.7, end: 1.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
    _animation.addListener(_rebuild);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget buildAnimatedChild() {
    return Container(
      alignment: Alignment.center,
      child: new FutureBuilder(
        future: _futureBanks,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget widget;
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              widget = new Center(
                child: new Container(
                  width: 50.0,
                  height: 50.0,
                  margin: const EdgeInsets.symmetric(vertical: 30.0),
                  child: new Theme(
                      data: Theme.of(context)
                          .copyWith(accentColor: MyColors.green),
                      child: new CircularProgressIndicator(
                        strokeWidth: 3.0,
                      )),
                ),
              );
              break;
            case ConnectionState.done:
              widget = snapshot.hasData
                  ? _getCompleteUI(snapshot.data)
                  : retryButton();
              break;
            default:
              widget = retryButton();
              break;
          }
          return widget;
        },
      ),
    );
  }

  Widget _getCompleteUI(List<Bank> banks) {
    var container = new Container();
    return new Container(
      child: new Form(
        autovalidate: _autoValidate,
        key: _formKey,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new SizedBox(
              height: 10.0,
            ),
            _currentBank == null
                ? new Icon(
                    Icons.account_balance,
                    color: Colors.black,
                    size: 35.0,
                  )
                : container,
            _currentBank == null
                ? new SizedBox(
                    height: 20.0,
                  )
                : container,
            new Text(
              _currentBank == null
                  ? 'Choose your bank to start the payment'
                  : 'Enter your acccount number',
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                  color: Colors.black),
            ),
            new SizedBox(
              height: 20.0,
            ),
            new DropdownButtonHideUnderline(
                child: new InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 0.5)),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: MyColors.green, width: 1.0)),
                hintText: 'Tap here to choose',
              ),
              isEmpty: _currentBank == null,
              child: new DropdownButton<Bank>(
                value: _currentBank,
                isDense: true,
                onChanged: (Bank newValue) {
                  setState(() {
                    _currentBank = newValue;
                    _controller.forward();
                  });
                },
                items: banks.map((Bank value) {
                  return new DropdownMenuItem<Bank>(
                    value: value,
                    child: new Text(value.name),
                  );
                }).toList(),
              ),
            )),
            new ScaleTransition(
              scale: _animation,
              child: _currentBank == null
                  ? container
                  : new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new SizedBox(
                          height: 15.0,
                        ),
                        new AccountField(
                            onSaved: (String value) => _account =
                                new BankAccount(_currentBank, value)),
                        new SizedBox(
                          height: 20.0,
                        ),
                        new GreenButton(
                            onPressed: _validateInputs,
                            showProgress: _loading,
                            text: 'Verify Account')
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateInputs() {
    FocusScope.of(context).requestFocus(new FocusNode());
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      widget.charge.account = _account;
      widget.onProcessingChange(true);
      setState(() => _loading = true);
      _chargeAccount();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  void _chargeAccount() {
    handleBeforeValidate(Transaction transaction) {
      // Do nothing
    }

    handleOnError(Object e, Transaction transaction) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      String message = e.toString();
      if (transaction.reference != null) {
        handleAllError(message, transaction.reference, true, account: _account);
      } else {
        handleAllError(message, transaction.reference, false,
            account: _account);
      }
    }

    handleOnSuccess(Transaction transaction) {
      if (!mounted) {
        return;
      }
      onResponse(new CheckoutResponse(
        message: transaction.message,
        reference: transaction.reference,
        status: true,
        method: method,
        account: _account,
        verify: true,
      ));
    }

    new BankTransactionManager(
            charge: widget.charge,
            context: context,
            onSuccess: handleOnSuccess,
            onError: handleOnError,
            beforeValidate: handleBeforeValidate)
        .chargeBank();
  }

  Widget retryButton() {
    Utils.banksMemo = null;
    Utils.banksMemo = new AsyncMemoizer();
    _futureBanks = Utils.getSupportedBanks();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: new GreenButton(
          onPressed: () => setState(() {}),
          showProgress: false,
          text: 'Display banks'),
    );
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }
}

class Bank {
  String name;
  int id;

  Bank(this.name, this.id);

  @override
  String toString() {
    return 'Bank{name: $name, id: $id}';
  }
}

class BankAccount {
  Bank bank;
  String number;

  BankAccount(this.bank, this.number);

  bool isValid() {
    if (number == null || number.length < 10) {
      return false;
    }

    if (bank == null || bank.id == null) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'BankAccount{bank: $bank, number: $number}';
  }
}
