import 'package:paystack_flutter/api/model/api_response.dart';
import 'package:paystack_flutter/utils/string_utils.dart';

class TransactionApiResponse extends ApiResponse {
  String response;
  String trans;
  String auth;
  String otpMessage;

  TransactionApiResponse.unknownServerResponse() {
    status = '0';
    message = 'Unknown server response';
  }

  TransactionApiResponse.fromMap(Map<String, dynamic> map) {
    response = map['reference'];
    trans = map['trans'];
    auth = map['auth'];
    otpMessage = map['otpmessage'];
    status = map['status'];
    message = map['message'];
  }

  bool hasValidReferenceAndTrans() {
    return (response != null) && (trans != null);
  }

  bool hasValidUrl() {
    return otpMessage != null &&
        StringUtils.isHttpUrl(otpMessage) &&
        StringUtils.isHttpsUrl(otpMessage);
  }

  bool hasValidOtpMessage() {
    return otpMessage != null;
  }

  bool hasValidAuth() {
    return auth != null;
  }
}
