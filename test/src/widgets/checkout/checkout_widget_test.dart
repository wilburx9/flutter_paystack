import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paystack/src/widgets/checkout/checkout_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common/widget_builder.dart';

void main() {
  group("$CheckoutWidget", () {
    var charge = Charge()
      ..amount = 20000
      ..currency = "USD"
      ..email = 'customer@email.com';

    group("custom logo", () {
      testWidgets("is supplied", (tester) async {
        final checkoutWidget = buildWidget(
          CheckoutWidget(
            method: CheckoutMethod.card,
            charge: charge,
            fullscreen: false,
            logo: Container(),
          ),
        );

        await tester.pumpWidget(checkoutWidget);

        await tester.pumpAndSettle();

        expect(find.byKey(Key("Logo")), findsOneWidget);
        expect(find.byKey(Key("PaystackBottomIcon")), findsOneWidget);
        expect(find.byKey(Key("PaystackLogo")), findsOneWidget);
        expect(find.byKey(Key("PaystackIcon")), findsNothing);
        expect(find.byIcon(Icons.lock), findsOneWidget);
        expect(find.byKey(Key("SecuredBy")), findsOneWidget);
      });

      testWidgets("is not passed", (tester) async {
        final checkoutWidget = buildWidget(
          CheckoutWidget(
            method: CheckoutMethod.bank,
            charge: charge,
            fullscreen: false,
            logo: null,
          ),
        );

        await tester.pumpWidget(checkoutWidget);

        await tester.pumpAndSettle();

        expect(find.byKey(Key("Logo")), findsNothing);
        expect(find.byKey(Key("PaystackBottomIcon")), findsNothing);
        expect(find.byKey(Key("PaystackIcon")), findsOneWidget);
        expect(find.byKey(Key("PaystackLogo")), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget);
        expect(find.byKey(Key("SecuredBy")), findsOneWidget);
      });
    });

    group("card", () {
      testWidgets("card checkout is displayed for selectable method",
          (tester) async {
        final checkoutWidget = buildWidget(
          CheckoutWidget(
            method: CheckoutMethod.selectable,
            charge: charge,
            fullscreen: false,
            logo: Container(),
          ),
        );

        await tester.pumpWidget(checkoutWidget);
        await tester.pumpAndSettle();
        expect(find.byKey(Key("CardCheckout")), findsOneWidget);
      });

      testWidgets("card checkout is displayed for card method", (tester) async {
        final checkoutWidget = buildWidget(
          CheckoutWidget(
            method: CheckoutMethod.selectable,
            charge: charge,
            fullscreen: false,
            logo: Container(),
          ),
        );

        await tester.pumpWidget(checkoutWidget);
        await tester.pumpAndSettle();
        expect(find.byKey(Key("CardCheckout")), findsOneWidget);
      });

      testWidgets("card checkout is not displayed for bank method",
          (tester) async {
        final checkoutWidget = buildWidget(
          CheckoutWidget(
            method: CheckoutMethod.bank,
            charge: charge,
            fullscreen: false,
            logo: Container(),
          ),
        );

        await tester.pumpWidget(checkoutWidget);
        await tester.pumpAndSettle();
        expect(find.byKey(Key("CardCheckout")), findsNothing);
      });
    });
  });
}
