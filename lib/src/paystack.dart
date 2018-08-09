import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/platform_info.dart';
import 'package:flutter_paystack/src/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/transaction_manager.dart';
import 'package:flutter_paystack/src/utils/utils.dart';

class PaystackPlugin {
  static bool _sdkInitialized = false;
  static String _publicKey;

  PaystackPlugin._();

  static Future<PaystackPlugin> initialize({@required String publicKey}) async {
    assert(() {
      if (publicKey == null || publicKey.isEmpty) {
        throw new PaystackException('publicKey cannot be null or empty');
      }
      return true;
    }());
    //do all the init work here

    var completer = Completer<PaystackPlugin>();

    //check if sdk is actually initialized
    if (sdkInitialized) {
      completer.complete(PaystackPlugin._());
    } else {
      _publicKey = publicKey;

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
        completer.complete(PaystackPlugin._());
      } on PlatformException catch (e) {
        completer.completeError(e);
      }
    }
    return completer.future;
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

  static chargeCard(BuildContext context,
      {@required Charge charge,
      @required OnTransactionChange<Transaction> beforeValidate,
      @required OnTransactionChange<Transaction> onSuccess,
      @required OnTransactionError<Object, Transaction> onError}) {
    assert(context != null, 'context must not be null');

    _performChecks();

    // Construct new paystack object
    Paystack paystack = Paystack.withPublicKey(publicKey);

    // Create token
    paystack.chargeCard(context, charge,
        beforeValidate: beforeValidate, onSuccess: onSuccess, onError: onError);
  }
}

class Paystack {
  String _publicKey;

  Paystack() {
    // Validate sdk initialized
    Utils.validateSdkInitialized();
  }

  Paystack.withPublicKey(String publicKey) {
    this.publicKey = publicKey;
  }

  /// Sets the public key
  /// [publicKey] - App Developer's public key
  set publicKey(String publicKey) {
    // Validate public key
    _validatePublicKey(publicKey);
    _publicKey = publicKey;
  }

  _validatePublicKey(String publicKey) {
    //check for null value, and length and starts with pk_
    if (publicKey == null ||
        publicKey.length < 1 ||
        !publicKey.startsWith("pk_")) {
      throw new AuthenticationException(
          'Invalid public key. To create a token, you must use a valid public key.\nEnsure that you have set a public key.\nCheck http://paystack.co for more');
    }
  }

  chargeCard(BuildContext context, Charge charge,
      {@required OnTransactionChange<Transaction> beforeValidate,
      @required OnTransactionChange<Transaction> onSuccess,
      @required OnTransactionError<Object, Transaction> onError}) {
    _chargeCard(
        context, charge, _publicKey, beforeValidate, onSuccess, onError);
  }

  _chargeCard(
      BuildContext context,
      Charge charge,
      String publicKey,
      OnTransactionChange<Transaction> beforeValidate,
      OnTransactionChange<Transaction> onSuccess,
      OnTransactionError<Object, Transaction> onError) {
    //check for the needed data, if absent, send an exception through the tokenCallback;
    try {
      //validate public key
      _validatePublicKey(publicKey);

      TransactionManager transactionManager = new TransactionManager(
          charge, context, beforeValidate, onSuccess, onError);

      transactionManager.chargeCard();
    } catch (e) {
      assert(onError != null);
      onError(e, null);
    }
  }
}

typedef void OnTransactionChange<Transaction>(Transaction transaction);
typedef void OnTransactionError<Object, Transaction>(
    Object e, Transaction transaction);
