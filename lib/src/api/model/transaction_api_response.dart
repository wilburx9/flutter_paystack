import 'package:flutter_paystack/src/api/model/api_response.dart';
import 'package:flutter_paystack/src/utils/string_utils.dart';

class TransactionApiResponse extends ApiResponse {
  String reference;
  String trans;
  String auth;
  String otpMessage;

  TransactionApiResponse.unknownServerResponse() {
    status = '0';
    message = 'Unknown server response';
  }

  TransactionApiResponse.fromMap(Map<String, dynamic> map) {
    reference = map.containsKey('reference') ? map['reference'] : null;
    trans = map.containsKey('trans') ? map['trans'] : null;
    auth = map.containsKey('auth') ? map['auth'] : null;
    otpMessage = map.containsKey('otpmessage') ? map['otpmessage'] : null;
    status = map.containsKey('status') ? map['status'] : null;
    message = map.containsKey('message') ? map['message'] : null;
  }

  bool hasValidReferenceAndTrans() {
    return (reference != null) && (trans != null);
  }

  bool hasValidUrl() {
    print('Valid URL? Message = $otpMessage');
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
