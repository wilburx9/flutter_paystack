import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/paystack_sdk.dart';

class Utils {
  static const MethodChannel channel = const MethodChannel('flutter_paystack');

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