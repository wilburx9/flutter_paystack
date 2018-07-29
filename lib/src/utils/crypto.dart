import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/utils/utils.dart';

class Crypto {
  static Future<String> encrypt(String data) async {
    var completer = Completer<String>();

    try {
      String result = await Utils.channel
          .invokeMethod('getEncryptedData', {"stringData": data});
      print('Encryption Successful. Result: $result');
      completer.complete(result);
    } on PlatformException catch (e) {
      print('Encryption Failed. Reason: $e');
      completer.completeError(e);
    }

    return completer.future;
  }

  static Future<String> decrypt(String data) async {
    // Well, let's hope we'll never decrypt
    throw UnimplementedError('Decrypt is not supported for now');
  }
}
