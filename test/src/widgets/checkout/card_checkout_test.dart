import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paystack/src/common/utils.dart';
import 'package:flutter_paystack/src/widgets/checkout/card_checkout.dart';
import 'package:flutter_paystack/src/widgets/checkout/checkout_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common/widget_builder.dart';

void main() {
  group("$CheckoutWidget", () {
    final charge = Charge()
      ..amount = 20000
      ..currency = "USD"
      ..email = 'customer@email.com';

    Utils.setCurrencyFormatter(charge.currency, "en_US");

    final checkoutWidget = buildWidget(
      CardCheckout(
        charge: charge,
        onResponse: (v) {},
        onProcessingChange: (v) {},
        onCardChange: (v) {},
      ),
    );

    group("input instruction", () {
      testWidgets("displayed", (tester) async {
        await tester.pumpWidget(checkoutWidget);

        await tester.pumpAndSettle();

        expect(find.byKey(Key("InstructionKey")), findsOneWidget);
      });
    });

    group("input instruction", () {
      testWidgets("displayed", (tester) async {
        await tester.pumpWidget(checkoutWidget);

        await tester.pumpAndSettle();

        expect(find.byKey(Key("CardInput")), findsOneWidget);
      });

      testWidgets("displays the correct amount", (tester) async {
        await tester.pumpWidget(checkoutWidget);

        await tester.pumpAndSettle();

        expect(find.text("Pay ${charge.currency} 200.00"), findsOneWidget);
      });
    });
  });
}
