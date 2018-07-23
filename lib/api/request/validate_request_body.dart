import 'package:paystack_flutter/api/request/base_request_body.dart';

class ValidateRequestBody extends BaseRequestBody {
  String _fieldTrans = 'trans';
  String _fieldToken = 'token';
  String _trans;
  String _token;

  ValidateRequestBody() {
    this.setDeviceId();
  }

  @override
  Map<String, String> paramsMap() {
    Map<String, String> params = {_fieldTrans: _trans, _fieldToken: _token};
    if (device != null) {
      params[fieldDevice] = device;
    }
    return params;
  }
}
