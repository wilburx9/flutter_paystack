import 'package:flutter_paystack/src/common/platform_info.dart';

abstract class BaseRequestBody {
  final fieldDevice = 'device';
  String? _device;

  BaseRequestBody() {
    _setDeviceId();
  }

  Map<String, String?> paramsMap();

  String? get device => _device;

  _setDeviceId() {
    String deviceId = PlatformInfo().deviceId ?? '';
    this._device = deviceId;
  }
}
