import 'package:paystack_flutter/src/platform_info.dart';

abstract class BaseRequestBody {
  final fieldDevice = 'device';
  String device;

  Map<String, String> paramsMap();

  setDeviceId() {
    String deviceId = PlatformInfo().deviceId;
    this.device = deviceId;
  }
}
