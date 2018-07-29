import 'package:flutter_paystack/src/platform_info.dart';

abstract class BaseRequestBody {

  final fieldDevice = 'device';
  String _device;

  Map<String, String> paramsMap();


  String get device => _device;

  setDeviceId() {
    String deviceId = PlatformInfo().deviceId;
    this._device = deviceId;
  }
}
