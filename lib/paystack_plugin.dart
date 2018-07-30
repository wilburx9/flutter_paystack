import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/paystack.dart';
import 'package:flutter_paystack/src/transaction.dart';
import 'package:flutter_paystack/src/utils/utils.dart';
import 'package:flutter_paystack/src/platform_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/exceptions.dart';

// Expose the following files
export 'package:flutter_paystack/src/model/card.dart';
export 'package:flutter_paystack/src/paystack.dart' hide Paystack;
export 'package:flutter_paystack/src/model/charge.dart';
export 'package:flutter_paystack/src/transaction.dart';
export 'package:flutter_paystack/src/exceptions.dart' hide PaystackException;

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
