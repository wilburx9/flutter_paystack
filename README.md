# Paystack Plugin for Flutter

[![pub package](https://img.shields.io/pub/v/flutter_paystack.svg)](https://pub.dartlang.org/packages/flutter_paystack)

A Flutter plugin for making payments via Paystack Payment Gateway. Completely supports Android and iOS.

## Installation
To use this plugin, add `flutter_paystack` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Then initialize the plugin preferably in the `initState` of your widget.

``` dart
import 'package:flutter_paystack/flutter_paystack.dart'

class PaymentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  var paystackPublicKey = '[YOUR_PAYSTACK_PUBLIC_KEY]';

  @override
  void initState() {
    PaystackPlugin.initialize(publicKey: paystackPublicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Return your widgets
  }
}
```

No other configuration required - the plugin should work out of the box.

## Making Payments

You can choose to initialize the payment locally or via Paystack's backend.

### 1. Initialize Via Paystack (Recommended)
1.a. This starts by making a HTTP POST request to `https://api.paystack.co/transaction/initialize`
with the amount(in kobo), reference, etc in the request body and your paystack secret key in request header.
The request looks like this:

``` dart
// Required imports
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

  initTransaction() async {
    var url = 'https://api.paystack.co/transaction/initialize';

    Map<String, String> headers = {
      'Authorization': 'Bearer $[YOUR_PAYSTACK_SECRET_KEY]',
      'Content-Type': 'application/json'
    };

    Map<String, String> body = {
      'reference': '[YOUR_GENERATED_REFERENCE]',
      'amount': 500000.toString(),
      'email': 'user@email.com'
    };

    http.Response response =
        await http.post(url, body: body, headers: headers);
    // Charge card
    _chargeCard(response.body);
  }
```
Please check the [official documentation](https://developers.paystack.co/reference#initialize-a-transaction) for the full details of payment initialization.

1.b If everything goes well, the initialization request returns a response with an `access_code`.
You can then create a `Charge` object with the access code and card details. The `charge` is in turn passed to the ` PaystackPlugin.chargeCard()` function for payment:

```dart
  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: cardNumber,
      cvc: cvv,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
    );

    // Using Cascade notation (similar to Java's builder pattern)
//    return PaymentCard(
//        number: cardNumber,
//        cvc: cvv,
//        expiryMonth: expiryMonth,
//        expiryYear: expiryYear)
//      ..name = 'Segun Chukwuma Adamu'
//      ..country = 'Nigeria'
//      ..addressLine1 = 'Ikeja, Lagos'
//      ..addressPostalCode = '100001';

    // Using optional parameters
//    return PaymentCard(
//        number: cardNumber,
//        cvc: cvv,
//        expiryMonth: expiryMonth,
//        expiryYear: expiryYear,
//        name: 'Ismail Adebola Emeka',
//        addressCountry: 'Nigeria',
//        addressLine1: '90, Nnebisi Road, Asaba, Deleta State');
  }

  _chargeCard(http.Response response) {
    Map<String, dynamic> responseBody = json.decode(response.body);
    var charge = Charge()
      ..accessCode = responseBody['access_code']
      ..card = _getCardFromUI();

    PaystackPlugin.chargeCard(context,
        charge: charge,
        beforeValidate: (transaction) => handleBeforeValidate(transaction),
        onSuccess: (transaction) => handleOnSuccess(transaction),
        onError: (error, transaction) => handleOnError(error, transaction));
  }

  handleBeforeValidate(Transaction transaction) {
    // This is called only before requesting OTP
    // Save reference so you may send to server if error occurs with OTP
  }

  handleOnError(Object e, Transaction transaction) {
    // If an access code has expired, simply ask your server for a new one
    // and restart the charge instead of displaying error
  }


  handleOnSuccess(Transaction transaction) {
    // This is called only after transaction is successful
  }
```



### 2. Initialize Locally
Just send the payment details to  `PaystackPlugin.chargeCard`
```dart
      // Set transaction params directly in app (note that these params
      // are only used if an access_code is not set. In debug mode,
      // setting them after setting an access code would throw an error
      Charge charge = Charge();
      charge.card = _getCardFromUI();
      charge
        ..amount = 2000
        ..email = 'user@email.com'
        ..reference = _getReference()
        ..putCustomField('Charged From', 'Flutter PLUGIN');
      _chargeCard();
```


## Validating Card Details
You are expected to build the UI for your users to enter their payment details.
For easier validation, wrap the **TextFormField**s inside a **Form** widget. Please check this article on
[validating forms on Flutter](https://medium.freecodecamp.org/how-to-validate-forms-and-user-input-the-easy-way-using-flutter-e301a1531165)
if this is new to you.

You can validate the fields with these methods:
#### card.validNumber
This method helps to perform a check if the card number is valid.

#### card.validCVC
Method that checks if the card security code is valid.

#### card.validExpiryDate
Method checks if the expiry date (combination of year and month) is valid.

#### card.isValid
Method to check if the card is valid. Always do this check, before charging the card.


#### card.getType
This method returns an estimate of the string representation of the card type(issuer).


## chargeCard
Charging with the **PaystackPlugin** is quite straightforward. It requires the following arguments.
1. `context`: your UI **BuildContext**. It's used by the plugin for showing dialogs for the user to take a required action, e.g inputting OTP.
2. `charge`: You provide the payment details (`PaymentCard`, `amount` `email` etc) to an instance of the `Charge` object.
3. `beforeValidate`: Pre-validation callback.
4. `onSuccess`: callbacks for a successful payment.
4. `onError`: callback for when an error occurs in the transaction. Provides you with a reference to the error object.


## Verifying Transactions
This is quite easy. Just send a HTTP GET request to `https://api.paystack.co/transaction/verify/$[TRANSACTION_REFERENCE]`.
Please, check the  [official documentaion](https://developers.paystack.co/reference#verifying-transactions) on verifying transactions.

## Testing your implementation
Paystack provides tons of [payment cards](https://developers.paystack.co/docs/test-cards) for testing.

## Running Example project
For help getting started with Flutter, view the online [documentation](https://flutter.io/).

An [example project](https://github.com/wilburt/flutter_paystack/tree/master/example) has been provided in this plugin.
Clone this repo and navigate to the **example** folder. Open it with a supported IDE or execute `flutter run` from that folder in terminal.

## Contributing, Issues and Bug Reports
The project is open to public contribution. Please feel very free to contribute.
Experienced an issue or want to report a bug? Please, [report it here](https://github.com/wilburt/flutter_paystack/issues). Remember to be descriptive.

## Credits
Thanks to the authors of Paystack [iOS](https://github.com/PaystackHQ/paystack-ios) and [Android](https://github.com/PaystackHQ/paystack-android) SDKS. I leveraged on their work to bring this plugin to fruition.

