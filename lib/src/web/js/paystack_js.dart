@JS()
library paystack_js;

import 'package:flutter/material.dart';
import "package:js/js.dart";

@JS('PaystackPop')
class PaystackPop {
  @JS('setup')
  external static Handler setup(SetupData data);
}

@JS()
@anonymous
class Handler {
  external void openIframe();
}

@JS()
@anonymous
class SetupData {
  external factory SetupData({
    required String key,
    required String email,
    required int amount,
    required String ref,
    VoidCallback? onClose,
    PaystackCallback? callback,
  });

  external String key;
  external String email;
  external int amount;
  external String ref;
  external VoidCallback onClose;
  external PaystackCallback callback;
}

@JS()
@anonymous
class ChargeResponse {
  external String get message;

  external String get reference;

  external String get response;

  external String get status;
}

typedef PaystackCallback(ChargeResponse response);

Handler setup(SetupData data) {
  return PaystackPop.setup(data);
}
