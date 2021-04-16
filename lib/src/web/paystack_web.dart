import 'dart:async';

import 'package:flutter_paystack/flutter_paystack.dart';

import 'js/js_stub.dart' if (dart.library.js) 'package:js/js.dart';
import 'js/paystack_stub.dart' if (dart.library.js) 'js/paystack_js.dart';

class PaystackWeb {
  Future<CheckoutResponse> checkout(Charge charge, String key) async {
    final completer = Completer<CheckoutResponse>();

    final handler = setup(
      SetupData(
        key: key,
        email: charge.email!,
        amount: charge.amount,
        ref: charge.reference!,
        onClose: allowInterop(
          () {
            completer.complete(CheckoutResponse.defaults());
          },
        ),
        callback: allowInterop((response) {
          completer.complete(
            CheckoutResponse(
              message: response.message,
              reference: response.reference,
              status: response.status == 'success',
              method: CheckoutMethod.card,
              verify: true,
              card: charge.card ?? PaymentCard.empty(),
            ),
          );
        }),
      ),
    );

    handler.openIframe();

    return completer.future;
  }
}
