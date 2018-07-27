import 'package:flutter/material.dart';
import 'package:paystack_flutter/paystack_sdk.dart';

var paystackPublicKey = '{YOUR_PAYSTACK_PUBLIC_KEY}';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primaryColor:  Colors.lightBlue[900],
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}
