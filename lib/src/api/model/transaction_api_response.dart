import 'package:flutter_paystack/src/api/model/api_response.dart';

class TransactionApiResponse extends ApiResponse {
  String? reference;
  String? trans;
  String? auth;
  String? otpMessage;
  String? displayText;

  TransactionApiResponse.unknownServerResponse() {
    status = '0';
    message = 'Unknown server response';
  }

  TransactionApiResponse.fromMap(Map<String, dynamic> map) {
    this.reference = map['reference'];
    if (map.containsKey('trans')) {
      trans = map['trans'];
    } else if (map.containsKey('id')) {
      trans = map['id'].toString();
    }
    auth = map['auth'];
    otpMessage = map['otpmessage'];
    status = map['status'];
    message = map['message'];
    displayText =
        !map.containsKey('display_text') ? message : map['display_text'];

    if (status != null) {
      status = status!.toLowerCase();
    }

    if (auth != null) {
      auth = auth!.toLowerCase();
    }
  }

  TransactionApiResponse.fromAccessCodeVerification(Map<String, dynamic> map) {
    var data = map['data'];
    trans = data['id'].toString();
    status = data['transaction_status'];
    message = map['message'];
  }

  bool hasValidReferenceAndTrans() {
    return (reference != null) && (trans != null);
  }

  bool hasValidUrl() {
    if (otpMessage == null || otpMessage!.length == 0) {
      return false;
    }

    return RegExp(r'^https?://', caseSensitive: false).hasMatch(otpMessage!);
  }

  bool hasValidOtpMessage() {
    return otpMessage != null;
  }

  bool hasValidAuth() {
    return auth != null;
  }

  @override
  String toString() {
    return 'TransactionApiResponse{reference: $reference, trans: $trans, auth: $auth, '
        'otpMessage: $otpMessage, displayText: $displayText, message: $message, '
        'status: $status}';
  }
}
