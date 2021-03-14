/// Holds data that's different on Android and iOS
class PlatformInfo {
  static String? _userAgent;
  static String? _paystackBuild;
  static String? _deviceId;

  static final PlatformInfo _platformSpecificInfo =
      new PlatformInfo._internal();

  factory PlatformInfo() {
    return _platformSpecificInfo;
  }

  PlatformInfo._internal();

  set userAgent(String? value) => _userAgent = value;

  set paystackBuild(String? value) => _paystackBuild = value;

  set deviceId(String? value) => _deviceId = value;

  String? get userAgent {
    _validateValue(_userAgent);
    return _userAgent;
  }

  String? get paystackBuild {
    _validateValue(_paystackBuild);
    return _paystackBuild;
  }

  String? get deviceId {
    _validateValue(_deviceId);
    return _deviceId;
  }

  _validateValue(String? value) {
    if (value == null || value.isEmpty) {
      throw Exception('Has you initialized Paystack SDK?');
    }
  }

  @override
  String toString() {
    return '[userAgent = $userAgent, paystackBuild = $paystackBuild, deviceId = $deviceId]';
  }
}
