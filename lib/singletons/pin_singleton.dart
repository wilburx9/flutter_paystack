class PinSingleton {
  var pin = '';

  static final PinSingleton _singleton = PinSingleton._internal();

  factory PinSingleton() {
    return _singleton;
  }

  PinSingleton._internal();
}
