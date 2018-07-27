import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paystack_flutter/src/model/charge.dart';
import 'package:paystack_flutter/src/paystack.dart';
import 'package:paystack_flutter/src/utils/utils.dart';
import 'package:paystack_flutter/src/platform_info.dart';
import 'package:flutter/services.dart';
import 'package:paystack_flutter/src/exceptions.dart';

// Expose the following files
export 'package:paystack_flutter/src/model/card.dart';
export 'package:paystack_flutter/src/paystack.dart' hide Paystack;
export 'package:paystack_flutter/src/model/charge.dart';
export 'package:paystack_flutter/src/transaction.dart';
export 'package:paystack_flutter/src/exceptions.dart' hide PaystackException;

class PaystackSdk {
  static bool _sdkInitialized = false;
  static String _publicKey;


  PaystackSdk._();

  static Future<PaystackSdk> initialize({@required String publicKey}) async {
    assert(() {
      if (publicKey == null || publicKey.isEmpty) {
        throw new PaystackException(
            'publicKey cannot be null or empty');
      }
      return true;
    }());
    //do all the init work here

    var completer = Completer<PaystackSdk>();

    //check if sdk is actually initialized
    if (sdkInitialized) {
      completer.complete(PaystackSdk._());
    } else {
      _publicKey = publicKey;

      // Using cascade notation to build the platform specific info
      try {
        String userAgent = await Utils.channel.invokeMethod('getUserAgent');
        String paystackBuild =
            await Utils.channel.invokeMethod('getVersionCode');
        String deviceId = await Utils.channel.invokeMethod('getDeviceId');
        var platformInfo = PlatformInfo()
          ..userAgent = userAgent
          ..paystackBuild = paystackBuild
          ..deviceId = deviceId;

        print('Platform Info ${platformInfo.toString()}');

        _sdkInitialized = true;
        completer.complete(PaystackSdk._());

      } on PlatformException catch (e) {
        print('An error occured while initializing Paystck: ${e.toString()}');
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
      {Charge charge, TransactionCallback transactionCallback}) {
    assert(context != null, 'context must not be null');

    _performChecks();

    // Construct new paystack object
    Paystack paystack = Paystack.withPublicKey(publicKey);

    // Create token
    paystack.chargeCard(context, charge, transactionCallback);
  }
}
