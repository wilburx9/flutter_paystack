import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/case.dart';

void main() {
  group("$PaymentCard", () {
    group("#type", () {
      final cases = [
        Case(inp: null, out: CardType.unknown),
        Case(inp: "9765478765567656765", out: CardType.unknown),
        Case(inp: "4111111111111111", out: CardType.visa),
        Case(inp: "4222 22222 2222", out: CardType.visa),
        Case(inp: "5500000000000004", out: CardType.masterCard),
        Case(inp: "3400 0000 0000 009", out: CardType.americanExpress),
        Case(inp: "30000000000004", out: CardType.dinersClub),
        Case(inp: "6011000000000004", out: CardType.discover),
        Case(inp: "3530111333300000", out: CardType.jcb),
        Case(inp: "5060666666666666666", out: CardType.verve),
        Case(
          desc: "doesn't return verve type for Ameerican Express number",
          inp: "378282246310005",
          out: isNot(equals(CardType.verve)),
        ),
        Case(
          desc: "returns Unknown for empty number",
          inp: "",
          out: CardType.unknown,
        ),
      ];
      cases.forEach((c) {
        test(c.desc ?? "returns ${c.out} for ${c.inp}", () {
          final value = PaymentCard.empty()..number = c.inp;
          expect(value.type, c.out);
        });
      });
    });

    group("#getTypeForIIN", () {
      final cases = [
        Case(inp: null, out: CardType.unknown),
        Case(inp: "", out: CardType.unknown),
        Case(inp: "000", out: CardType.unknown),
        Case(inp: "4", out: CardType.visa),
        Case(inp: "4", out: CardType.visa),
        Case(inp: "55", out: CardType.masterCard),
        Case(inp: "51", out: CardType.masterCard),
        Case(inp: "3782", out: CardType.americanExpress),
        Case(inp: "305", out: CardType.dinersClub),
        Case(inp: "6011", out: CardType.discover),
        Case(inp: "3561", out: CardType.jcb),
        Case(inp: "5060", out: CardType.verve),
        Case(inp: "506 0", out: CardType.verve),
        Case(
            desc: "doesn't return Ameerican Express type for VISA number",
            inp: "4",
            out: isNot(equals(CardType.americanExpress))),
      ];
      cases.forEach((c) {
        test(c.desc ?? "returns ${c.out} for ${c.inp}", () {
          final value = PaymentCard.empty()..number = c.inp;
          expect(value.getTypeForIIN(value.number), c.out);
        });
      });
    });

    group("#number", () {
      final cases = [
        Case(inp: "4 22 22222 2222 2", out: "2222"),
        Case(
            desc:
                "setting empty space as card number doesn't generate empty last4Digits",
            inp: "       ",
            out: ""),
        Case(inp: "12", out: "12"),
        Case(inp: "1298", out: "1298"),
        Case(inp: "976 5478 765567656 765", out: "6765"),
        Case(inp: "5060666666666666666", out: "6666"),
        Case(inp: "随机你，等等", out: ""),
        Case(
            desc:
                "setting 340000000000009 as card number doesn't generate 7688 as last4Digits",
            inp: "340000000000009",
            out: isNot(equals("7688"))),
      ];
      cases.forEach((c) {
        test(
            c.desc ??
                "setting ${c.inp} as card number generates ${c.out} as last4Digits",
            () {
          final value = PaymentCard.empty()..number = c.inp;
          expect(value.last4Digits, c.out);
        });
      });
    });

    group("#number", () {
      final cases = [
        Case(inp: "4222 22 22 2222 2", out: "4222222222222"),
        Case(inp: "5060666666666666666", out: "5060666666666666666"),
        Case(inp: "3YSHHjj40000B000000A009", out: "340000000000009"),
        Case(inp: "随机你，等等", out: ""),
        Case(inp: "随机你，等等124", out: "124"),
      ];
      cases.forEach((c) {
        test("${c.inp} is cleaned and assigned as ${c.out}", () {
          final value = PaymentCard.empty()..number = c.inp;
          expect(value.number, c.out);
        });
      });
    });

    group("#cvv", () {
      final cases = [
        Case(inp: "123", out: "123"),
        Case(inp: "așa", out: ""),
        Case(inp: "8777等等", out: "8777"),
        Case(inp: "9 11 1", out: "9111"),
        Case(inp: "随机你，等等124", out: "124"),
        Case(
            desc: "какая is not assigned as какая",
            inp: "какая",
            out: isNot(equals("какая"))),
      ];
      cases.forEach((c) {
        test(c.desc ?? "${c.inp} is cleaned and assigned as ${c.out}", () {
          final value = PaymentCard.empty()..cvc = c.inp;
          expect(value.cvc, c.out);
        });
      });
    });

    group("#isValid", () {
      final cases = [
        Case(desc: "empty details", inp: PaymentCard.empty(), out: false),
        Case(
            desc: "null details",
            inp: PaymentCard(
                number: null, cvc: null, expiryMonth: null, expiryYear: null),
            out: false),
        Case(
            desc: "empty details",
            inp:
                PaymentCard(number: "", cvc: "", expiryMonth: 0, expiryYear: 0),
            out: false),
        Case(
            desc: "invalid number and other valid details",
            inp: PaymentCard(
                number: "9876567876567",
                cvc: "123",
                expiryMonth: 12,
                expiryYear: 12),
            out: false),
        Case(
            desc: "invalid cvv and other valid details",
            inp: PaymentCard(
                number: "4111111111111111",
                cvc: "12333",
                expiryMonth: 12,
                expiryYear: 12),
            out: false),
        Case(
            desc: "invalid month and other valid details",
            inp: PaymentCard(
                number: "4111111111111111",
                cvc: "123",
                expiryMonth: 90,
                expiryYear: 12),
            out: false),
        Case(
            desc: "negative month and other valid details",
            inp: PaymentCard(
                number: "6011000000000004",
                cvc: "123",
                expiryMonth: -9,
                expiryYear: 12),
            out: false),
        Case(
            desc: "negative year and other valid details",
            inp: PaymentCard(
                number: "4111111111111111",
                cvc: "123",
                expiryMonth: -9,
                expiryYear: -2020),
            out: false),
        Case(
            desc: "four digit year and other valid details",
            inp: PaymentCard(
                number: "4111111111111111",
                cvc: "123",
                expiryMonth: 09,
                expiryYear: 2027),
            out: true),
        Case(
            desc: "expired card",
            inp: PaymentCard(
                number: "4111111111111111",
                cvc: "123",
                expiryMonth: 09,
                expiryYear: 2002),
            out: false),
        Case(
            desc: "valid card",
            inp: PaymentCard(
                number: "6011000000000004",
                cvc: "123",
                expiryMonth: 09,
                expiryYear: 27),
            out: true),
      ];

      cases.forEach((c) {
        test("returns ${c.out} for ${c.desc}", () {
          var valid = c.inp.isValid();
          expect(valid, c.out);
        });
      });
    });

    group("#validCVC", () {
      final cases = [
        Case(
            desc: "returns false for empty cvv",
            inp: PaymentCard.empty()..cvc = "",
            out: false),
        Case(
            desc: "returns false for empty cvv",
            inp: PaymentCard.empty()..cvc = null,
            out: false),
        Case(
            desc: "returns false for two character length cvv",
            inp: PaymentCard.empty()..cvc = "12",
            out: false),
        Case(
            desc: "returns false for alphanumeric characters",
            inp: PaymentCard.empty()..cvc = "A9ri12499",
            out: false),
        Case(
            desc: "returns true for 3 character length cvv",
            inp: PaymentCard.empty()..cvc = "123",
            out: true),
        Case(
            desc:
                "returns false for 3 character length cvv American Express cards",
            inp: PaymentCard.empty()
              ..type = CardType.americanExpress
              ..cvc = "123",
            out: false),
      ];
      cases.forEach((c) {
        test("returns ${c.out} for ${c.inp}", () {
          var valid = c.inp.validCVC(null);
          expect(valid, c.out);
        });
      });
    });
  });
}
