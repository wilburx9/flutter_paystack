import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paystack/src/api/service/contracts/cards_service_contract.dart';
import 'package:flutter_paystack/src/common/utils.dart';
import 'package:flutter_paystack/src/widgets/checkout/card_checkout.dart';
import 'package:flutter_paystack/src/widgets/input/card_input.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../common/widget_builder.dart';

class MockedCardService extends Mock implements CardServiceContract {}

void main() {
  group("$CardCheckout", () {
    String publicKey = Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"] ?? "";

    final charge = Charge()
      ..amount = 20000
      ..currency = "USD"
      ..email = 'customer@email.com';

    Utils.setCurrencyFormatter(charge.currency, "en_US");

    final checkoutWidget = buildTestWidget(
      CardCheckout(
        publicKey: publicKey,
        charge: charge,
        service: MockedCardService(),
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

    group("card input", () {
      testWidgets("displayed", (tester) async {
        await tester.pumpWidget(checkoutWidget);

        await tester.pumpAndSettle();

        expect(find.byKey(Key("CardInput")), findsOneWidget);
      });

      testWidgets("displays the correct amount when `hideAmount` is false",
          (tester) async {
        await tester.pumpWidget(checkoutWidget);

        await tester.pumpAndSettle();

        CardInput input = tester.widget(find.byKey(Key("CardInput")));
        expect(input.buttonText, "Pay ${charge.currency} 200.00");
      });

      testWidgets("displays the \"Continue\" when `hideAmount` is true",
          (tester) async {
        await tester.pumpWidget(buildTestWidget(CardCheckout(
          publicKey: publicKey,
          charge: charge,
          service: MockedCardService(),
          onResponse: (v) {},
          onProcessingChange: (v) {},
          onCardChange: (v) {},
          hideAmount: true,
        )));

        await tester.pumpAndSettle();

        CardInput input = tester.widget(find.byKey(Key("CardInput")));
        expect(input.buttonText, "Continue");
      });
    });
  });
}
