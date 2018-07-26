import 'package:paystack_flutter/src/api/model/api_response.dart';
import 'package:paystack_flutter/src/utils/string_utils.dart';

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
    reference = map['reference'];
    trans = map['trans'];
    auth = map['auth'];
    otpMessage = map['otpmessage'];
    status = map['status'];
    message = map['message'];
  }

  bool hasValidReferenceAndTrans() {
    return (reference != null) && (trans != null);
  }

  bool hasValidUrl() {
    return otpMessage != null &&
        (StringUtils.isHttpUrl(otpMessage) ||
        StringUtils.isHttpsUrl(otpMessage));
  }

  bool hasValidOtpMessage() {
    return otpMessage != null;
  }

  bool hasValidAuth() {
    return auth != null;
  }
}
