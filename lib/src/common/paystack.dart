import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/platform_info.dart';
import 'package:flutter_paystack/src/common/transaction.dart';
import 'package:flutter_paystack/src/common/utils.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/model/checkout_response.dart';
import 'package:flutter_paystack/src/transaction/card_transaction_manager.dart';
import 'package:flutter_paystack/src/widgets/checkout/checkout_widget.dart';

class PaystackPlugin {
  static bool _sdkInitialized = false;
  static String _publicKey;

  PaystackPlugin._();

  /// Initialize the Paystack object. It should be called as early as possible
  /// (preferably in initState() of the Widget.
  ///
  /// [publicKey] - your paystack public key. This is mandatory
  ///
  /// use [checkout] and you want this plugin to initialize the transaction for you.
  /// Please check [checkout] for more information
  ///
  static Future<PaystackPlugin> initialize({@required String publicKey}) async {
    assert(() {
      if (publicKey == null || publicKey.isEmpty) {
        throw new PaystackException('publicKey cannot be null or empty');
      }
      return true;
    }());

    // do all the init work here

    //check if sdk is actually initialized
    if (sdkInitialized) {
      return PaystackPlugin._();
    } else {
      _publicKey = publicKey;

      // If private key is not null, it implies that checkout will be used.
      // Hence, let's get the list of supported banks. We won't wait for the result. If it
      // completes successfully, fine. If it fails, we'll retry in BankCheckout
      Utils.getSupportedBanks();

      // Using cascade notation to build the platform specific info
      try {
        String userAgent = await Utils.channel.invokeMethod('getUserAgent');
        String paystackBuild =
            await Utils.channel.invokeMethod('getVersionCode');
        String deviceId = await Utils.channel.invokeMethod('getDeviceId');
        PlatformInfo()
          ..userAgent = userAgent
          ..paystackBuild = paystackBuild
          ..deviceId = deviceId;

        _sdkInitialized = true;
        return PaystackPlugin._();
      } on PlatformException {
        rethrow;
      }
    }
  }

  static bool get sdkInitialized => _sdkInitialized;

  static String get publicKey {
    // Validate that the sdk has been initialized
    Utils.validateSdkInitialized();
    return _publicKey;
  }

  static void _performChecks() {
    //validate that sdk has been initialized
    Utils.validateSdkInitialized();

    //validate public keys
    Utils.hasPublicKey();
  }

  /// Make payment by chargingg the user's card
  ///
  /// [context] - the widgets BuildContext
  ///
  /// [charge] - the charge object.
  ///
  /// [beforeValidate] - Called before validation
  ///
  /// [onSuccess] - Called when the payment is completes successfully
  ///
  /// [onError] - Called when the payment completes with an unrecoverable error
  static chargeCard(BuildContext context,
      {@required Charge charge,
      @required OnTransactionChange<Transaction> beforeValidate,
      @required OnTransactionChange<Transaction> onSuccess,
      @required OnTransactionError<Object, Transaction> onError}) {
    assert(context != null, 'context must not be null');

    _performChecks();

    Paystack(publicKey).chargeCard(
        context: context,
        charge: charge,
        beforeValidate: beforeValidate,
        onSuccess: onSuccess,
        onError: onError);
  }

  /// Make payment using Paystack's checkout form. The plugin will handle the whole
  /// processes involved.
  ///
  /// [context] - the widget's BuildContext
  ///
  /// [charge] - the charge object.
  ///
  /// [method] - The payment method to use(card, bank). It defaults to
  /// [CheckoutMethod.selectable] to allow the user to select. For [CheckoutMethod.bank]
  ///  or [CheckoutMethod.selectable], it is
  /// required that you supply an access code to the [Charge] object passed to [charge].
  /// For [CheckoutMethod.card], though not recommended, passing a reference to the
  /// [Charge] object will do just fine.
  ///
  /// Notes:
  ///
  /// * You can also pass the [PaymentCard] object and we'll use it to prepopulate the
  /// card  fields if card payment is being used
  ///
  /// [fullscreen] - Whether to display the payment in a full screen dialog or not
  ///
  /// [logo] - The widget to display at the top left of the payment prompt. Defaults to an Image widget with Paystack's logo.
  static Future<CheckoutResponse> checkout(
    BuildContext context, {
    @required Charge charge,
    CheckoutMethod method = CheckoutMethod.selectable,
    bool fullscreen = false,
    Widget logo,
  }) async {
    assert(context != null, 'context must not be null');
    assert(
        method != null,
        'method must not be null. You can pass CheckoutMethod.selectable if you want '
        'the user '
        'to select the checkout option');
    assert(fullscreen != null, 'fillscreen must not be null');
    return Paystack(publicKey).checkout(
      context,
      charge: charge,
      method: method,
      fullscreen: fullscreen,
      logo: logo,
    );
  }
}

class Paystack {
  String _publicKey;

  Paystack(this._publicKey);

  chargeCard(
      {@required BuildContext context,
      @required Charge charge,
      @required OnTransactionChange<Transaction> beforeValidate,
      @required OnTransactionChange<Transaction> onSuccess,
      @required OnTransactionError<Object, Transaction> onError}) {
    try {
      //check for null value, and length and starts with pk_
      if (_publicKey == null ||
          _publicKey.isEmpty ||
          !_publicKey.startsWith("pk_")) {
        throw new AuthenticationException(Utils.getKeyErrorMsg('public'));
      }

      new CardTransactionManager(
              charge: charge,
              context: context,
              beforeValidate: beforeValidate,
              onSuccess: onSuccess,
              onError: onError)
          .chargeCard();
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      assert(onError != null);
      onError(e, null);
    }
  }

  Future<CheckoutResponse> checkout(
    BuildContext context, {
    @required Charge charge,
    @required CheckoutMethod method,
    @required bool fullscreen,
    Widget logo,
  }) async {
    assert(() {
      Utils.validateChargeAndKey(charge);
      switch (method) {
        case CheckoutMethod.card:
          if (charge.accessCode == null && charge.reference == null) {
            throw new ChargeException(Strings.noAccessCodeReference);
          }
          break;
        case CheckoutMethod.bank:
        case CheckoutMethod.selectable:
          if (charge.accessCode == null) {
            throw new ChargeException('Pass an accesscode');
          }
          break;
      }
      return true;
    }());

    CheckoutResponse response = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new CheckoutWidget(
              method: method,
              charge: charge,
              fullscreen: fullscreen,
              logo: logo,
            ));
    return response == null ? CheckoutResponse.defaults() : response;
  }
}

typedef void OnTransactionChange<Transaction>(Transaction transaction);
typedef void OnTransactionError<Object, Transaction>(
    Object e, Transaction transaction);

enum CheckoutMethod { card, bank, selectable }
