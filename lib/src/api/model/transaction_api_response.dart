import 'package:flutter_paystack/src/api/model/api_response.dart';

class TransactionApiResponse extends ApiResponse {
  String reference;
  String trans;
  String auth;
  String otpMessage;
  String displayText;

  TransactionApiResponse.unknownServerResponse() {
    status = '0';
    message = 'Unknown server response';
  }

  TransactionApiResponse.fromMap(Map<String, dynamic> map, {String reference}) {
    // Some times the response doesn't return an otp (e.g birthday response) so instead
    // nullifying the reference, let's use the passed response.
    this.reference =
        map.containsKey('reference') ? map['reference'] : reference;
    if (map.containsKey('trans')) {
      trans = map['trans'];
    } else if (map.containsKey('id')) {
      trans = map['id'].toString();
    }
    auth = map['auth'];
    otpMessage = map['otpmessage'];
    status = map['status'];
    message = map['message'];
    displayText = map['display_text'];
  }

  bool hasValidReferenceAndTrans() {
    return (reference != null) && (trans != null);
  }

  bool hasValidUrl() {
    if (otpMessage == null || otpMessage.length == 0) {
      return false;
    }

    return RegExp(r'^https?://', caseSensitive: false).hasMatch(otpMessage);
  }

  bool hasValidOtpMessage() {
    return otpMessage != null;
  }

  bool hasValidAuth() {
    return auth != null;
  }
}
