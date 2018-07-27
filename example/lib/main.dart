import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paystack_flutter/paystack_sdk.dart';
import 'package:flutter/services.dart';

var paystackPublicKey = '{YOUR_PAYSTACK_PUBLIC_KEY}';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Paystack Example',
      theme: new ThemeData(
        primaryColor: Colors.lightBlue[900],
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var whiteText = const TextStyle(color: Colors.white);
  String _reference = 'No transaction yet';
  String _error = '';
  String _backendMessage = '';
  String cardNumber;
  String cvv;
  int expiryMonth;
  int expiryYear;

  @override
  void initState() {
    PaystackSdk.initialize(publicKey: paystackPublicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var screenWidth = size.width;
    var screenHeight = size.height;
    var appBar = new AppBar(
      title: new Text('Paystack Example'),
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: new Container(
        color: new Color(0xFF1C3A4B),
        child: new Column(
          children: <Widget>[
            new Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              width: double.infinity,
              height: ((screenHeight / 2) - appBar.preferredSize.height),
              child: new Form(
                key: _formKey,
                child: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new SizedBox(
                        height: 5.0,
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            width: screenWidth / 1.7,
                            child: new TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'Card number',
                              ),
                              onSaved: (String value) => cardNumber = value,
                            ),
                          ),
                          new SizedBox(
                            width: 30.0,
                          ),
                          new Container(
                              width: screenWidth / 5,
                              child: new TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  new LengthLimitingTextInputFormatter(4)
                                ],
                                decoration: const InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    labelText: 'CVV'),
                                onSaved: (String value) => cvv = value,
                              ))
                        ],
                      ),
                      new SizedBox(
                        height: 20.0,
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            width: screenWidth / 5,
                            child: new TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                new LengthLimitingTextInputFormatter(2)
                              ],
                              decoration: const InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'MM',
                              ),
                              onSaved: (String value) =>
                                  expiryMonth = int.parse(value),
                            ),
                          ),
                          new SizedBox(
                            width: 30.0,
                          ),
                          new Container(
                              width: screenWidth / 5,
                              child: new TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  new LengthLimitingTextInputFormatter(4)
                                ],
                                decoration: const InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    labelText: 'YYYY'),
                                onSaved: (String value) =>
                                    expiryYear = int.parse(value),
                              )),
                        ],
                      ),
                      new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new SizedBox(
                            height: 40.0,
                          ),
                          _getPlatformButton('Charge Card (Init From Server)',
                              _chargeInitFrmServer()),
                          new SizedBox(
                            height: 10.0,
                          ),
                          _getPlatformButton('Charge Card (Init From App)',
                              chargeInitFrmApp()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            new Container(
              width: double.infinity,
              height: screenHeight / 2.35, // Can't 2.0
              child: new Container(
                margin: const EdgeInsets.only(top: 15.0),
                padding: const EdgeInsets.all(20.0),
                child: new SingleChildScrollView(child: new ListBody(
                  children: <Widget>[
                    new Text(
                      _reference,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    new SizedBox(height: 20.0),
                    new Text(
                      _error,
                      style: whiteText,
                    ),
                    new SizedBox(
                      height: 20.0,
                    ),
                    new Text(
                      _backendMessage,
                      style: whiteText,
                    )
                  ],
                ),),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getPlatformButton(String string, Function function) {
    Widget widget;
    if (Platform.isIOS) {
      widget = new CupertinoButton(
        onPressed: () => function,
        color: CupertinoColors.activeBlue,
        child: new Text(
          string,
        ),
      );
    } else {
      widget = new RaisedButton(
        onPressed: () => function,
        color: Colors.lightBlue[900],
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: new Text(
          string.toUpperCase(),
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    }
    return widget;
  }

  _chargeInitFrmServer() {}

  chargeInitFrmApp() {}
}
