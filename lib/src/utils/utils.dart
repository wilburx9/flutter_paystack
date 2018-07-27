import 'package:flutter/services.dart';
import 'package:paystack_flutter/src/exceptions.dart';
import 'package:paystack_flutter/paystack_sdk.dart';

class Utils {
  static const MethodChannel channel = const MethodChannel('paystack_flutter');

  static validateSdkInitialized() {
    if (!PaystackSdk.sdkInitialized) {
      throw new PaystackSdkNotInitializedException('Paystack SDK has not been initialized. The SDK has'
          ' to be initialized before use');
    }
  }

  static String hasPublicKey() {
    var publicKey = PaystackSdk.publicKey;
    if(publicKey == null || publicKey.isEmpty) {
      throw PaystackException('No Public key found, please set the Public key.');
    }
    return publicKey;
  }

  static validatePlatformSpecificInfo() {

  }
}