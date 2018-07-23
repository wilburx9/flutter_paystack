class OtpSingleton {
  var otp = '';
  var otpMessage = '';
  static final OtpSingleton _singleton = OtpSingleton._internal();

  factory OtpSingleton() {
    return _singleton;
  }

  OtpSingleton._internal();
}