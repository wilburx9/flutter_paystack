import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/services.dart';

// Former Import from Method Channels
// import 'package:flutter_paystack/src/common/utils.dart';

import 'package:pointycastle/export.dart';

class Cryptom {
  /// String Public Key
  String publickey =
      "MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBANIsL+RHqfkBiKGn/D1y1QnNrMkKzxWP" +
          "2wkeSokw2OJrCI+d6YGJPrHHx+nmb/Qn885/R01Gw6d7M824qofmCvkCAwEAAQ==";

  String encrypt(String plaintext, String publicKey) {
    /// After a lot of research on how to convert the public key [String] to [RSA PUBLIC KEY]
    /// We would have to use PEM Cert Type and the convert it from a PEM to an RSA PUBLIC KEY through basic_utils
    ///
    var pem =
        '-----BEGIN RSA PUBLIC KEY-----\n$publickey\n-----END RSA PUBLIC KEY-----';
    var public = CryptoUtils.rsaPublicKeyFromPem(pem);

    /// Initalizing Cipher
    var cipher = PKCS1Encoding(RSAEngine());
    cipher.init(true, PublicKeyParameter<RSAPublicKey>(public));

    /// Converting into a [Unit8List] from List<int>
    /// Then Encoding into Base64
    Uint8List output =
        cipher.process(Uint8List.fromList(utf8.encode(plaintext)));
    var base64EncodedText = base64Encode(output);
    return base64EncodedText;
  }

  String text(String text) {
    return encrypt(text, publickey);
  }
}

class Crypto {
  static Future<String> encrypt(String data) async {
    var completer = Completer<String>();

    try {
      /// This is commented to prevent conflicts
      // String? result = await Utils.methodChannel
      //     .invokeMethod('getEncryptedData', {"stringData": data});
      String? result = Cryptom().text(data);
      print(result);
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
