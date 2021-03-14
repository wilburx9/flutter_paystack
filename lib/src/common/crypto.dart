import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/common/utils.dart';

class Crypto {
  static Future<String> encrypt(String data) async {
    var completer = Completer<String>();

    try {
      String? result = await Utils.methodChannel
          .invokeMethod('getEncryptedData', {"stringData": data});
      completer.complete(result);
    } on PlatformException catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  static Future<String> decrypt(String data) async {
    // Well, let's hope we'll never decrypt
    throw UnimplementedError('Decrypt is not supported for now');
  }
}
