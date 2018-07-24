import 'package:flutter/services.dart';
import 'package:paystack_flutter/paystack_sdk.dart';

class StringUtils {
  static const MethodChannel channel = const MethodChannel('paystack_flutter');

  static bool isEmpty(String value) {
    return value == null || value.length < 1 || value.toLowerCase == "null";
  }

  static bool isValidEmail(String email) {
    String p = r"[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(email);
  }

  /// Return true if the url is an http: url.
  static bool isHttpUrl(String url) {
    return (null != url) &&
        (url.length > 6) &&
        url.substring(0, 7).toLowerCase == 'http://';
  }

  /// Return true if the url is an https: url.
  static bool isHttpsUrl(String url) {
    return (null != url) &&
        (url.length > 7) &&
        url.substring(0, 8).toLowerCase == "https://";
  }


}
