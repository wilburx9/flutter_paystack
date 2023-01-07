import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paystack/src/common/card_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'case.dart';

void main() {
  group("$CardUtils", () {
    group("#isWholeNumberPositive", () {
      final cases = [
        Case(inp: "12", out: true),
        Case(inp: "+9876567", out: false),
        Case(inp: "hgfdfghjk", out: false),
        Case(inp: "KDHJIWUHE", out: false),
        Case(inp: "-1-2-84ufpo", out: false),
        Case(inp: "一些角色", out: false),
        Case(inp: "九十", out: false),
        Case(inp: "девяносто", out: false),
        Case(inp: "09765678987656789876545678987656789876545678", out: true),
        Case(inp: null, out: false),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.isWholeNumberPositive(c.inp);
          expect(c.out, value);
        });
      });
    });

    group("#convertYearTo4Digits", () {
      final cases = [
        Case(inp: 10, out: 2010),
        Case(inp: 100, out: 100),
        Case(inp: 1000, out: 1000),
        Case(inp: 20, out: 2020),
        Case(inp: 2000, out: 2000),
        Case(inp: 94, out: 2094),
        Case(inp: 2020, out: 2020),
        Case(inp: 87656776, out: 87656776),
        Case(inp: 8, out: 2008),
        Case(inp: 0, out: 2000),
        Case(inp: -10, out: -10),
        Case(inp: -0, out: 2000),
        Case(inp: -88, out: -88),
        Case(inp: null, out: 0),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.convertYearTo4Digits(c.inp);
          expect(c.out, value);
        });
      });
    });

    group("#hasYearPassed", () {
      final cases = [
        Case(inp: 10, out: true),
        Case(inp: 100, out: true),
        Case(inp: 1000, out: true),
        Case(inp: 23, out: false),
        Case(inp: 2000, out: true),
        Case(inp: 94, out: false),
        Case(inp: 2024, out: false),
        Case(inp: 87656776, out: false),
        Case(inp: 8, out: true),
        Case(inp: 0, out: true),
        Case(inp: -10, out: true),
        Case(inp: -0, out: true),
        Case(inp: -88, out: true),
        Case(inp: null, out: true),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.hasYearPassed(c.inp);
          expect(c.out, value);
        });
      });
    });

    group("#hasMonthPassed", () {
      final cases = [
        Case(inp: [2027, 10], out: false),
        Case(inp: [10, 0], out: true),
        Case(inp: [0, 0], out: true),
        Case(inp: [1994, 1], out: true),
        Case(inp: [1, 1], out: true),
        Case(inp: [-203, -13], out: true),
        Case(inp: [23, 10], out: false),
        Case(inp: [2027, 05], out: false),
        Case(inp: [null, 05], out: true),
        Case(inp: [24, null], out: true),
        Case(inp: [null, null], out: true),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.hasMonthPassed(c.inp[0], c.inp[1]);
          expect(c.out, value);
        });
      });
    });

    group("#isValidMonth", () {
      final cases = [
        Case(inp: 10, out: true),
        Case(inp: 0, out: false),
        Case(inp: -2, out: false),
        Case(inp: 1, out: true),
        Case(inp: 193873, out: false),
        Case(inp: 8, out: true),
        Case(inp: 012, out: true),
        Case(inp: null, out: false),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.isValidMonth(c.inp);
          expect(c.out, value);
        });
      });
    });

    group("#isNotExpired", () {
      final cases = [
        Case(inp: [2027, 10], out: true),
        Case(inp: [10, 0], out: false),
        Case(inp: [0, 0], out: false),
        Case(inp: [1994, 1], out: false),
        Case(inp: [1, 1], out: false),
        Case(inp: [-203, -13], out: false),
        Case(inp: [24, 10], out: true),
        Case(inp: [2027, 05], out: true),
        Case(inp: [24, null], out: false),
        Case(inp: [null, null], out: false),
        Case(inp: [45, 67], out: false),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.isNotExpired(c.inp[0], c.inp[1]);
          expect(c.out, value);
        });
      });
    });

    group("#getCleanedNumber", () {
      final cases = [
        Case(inp: "poiuytdfghjkkjhb", out: ""),
        Case(inp: "098765tgb098eyr", out: "098765098"),
        Case(inp: "6d8ge8gf7tfhd=-82qgjs9fh7w6ehf8", out: "6887829768"),
        Case(inp: "0", out: "0"),
        Case(inp: "девяносто", out: ""),
        Case(inp: "一些角色", out: ""),
        Case(inp: null, out: ""),
      ];

      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.getCleanedNumber(c.inp);
          expect(c.out, value);
        });
      });
    });

    group("#concatenateCardFields", () {
      final cases = [
        Case(
            inp: PaymentCard(
                number: null, cvc: null, expiryMonth: null, expiryYear: null),
            out: throwsA(TypeMatcher<CardException>())),
        Case(inp: null, out: throwsA(TypeMatcher<CardException>())),
        Case(
            inp: PaymentCard(
                number: "4111111111111111",
                cvc: "123",
                expiryMonth: 12,
                expiryYear: 12),
            out: "4111111111111111*123*12*12"),
        Case(
            inp: PaymentCard(
                number: "5500000000000004",
                cvc: null,
                expiryMonth: 12,
                expiryYear: 12),
            out: "5500000000000004*null*12*12"),
        Case(
            inp: PaymentCard(
                number: "340000000000009",
                cvc: "433",
                expiryMonth: 199,
                expiryYear: null),
            out: "340000000000009*433*199*0"),
        Case(
            inp: PaymentCard(
                number: "340000000000009",
                cvc: "433",
                expiryMonth: null,
                expiryYear: 30),
            out: "340000000000009*433*0*30"),
        Case(
            inp: PaymentCard(
                number: "340000000000009",
                cvc: "433",
                expiryMonth: null,
                expiryYear: null),
            out: "340000000000009*433*0*0"),
      ];

      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.concatenateCardFields;
          if (c.out is String) {
            var v = value(c.inp);
            expect(v, c.out);
          } else {
            expect(() => value(c.inp), c.out);
          }
        });
      });
    });

    group("#getExpiryDate", () {
      final cases = [
        Case(inp: "poiuytdfghjkkjhb", out: [-1, -1]),
        Case(inp: "0/12", out: [0, 12]),
        Case(inp: "13/0", out: [13, 0]),
        Case(inp: "девяносто/носто", out: [-1, -1]),
        Case(inp: "一些角色/12", out: [-1, 12]),
        Case(inp: null, out: [-1, -1]),
        Case(inp: "12/23", out: [12, 23]),
        Case(inp: "-12/-23", out: [-12, -23]),
        Case(inp: "13/", out: [13, -1]),
        Case(inp: "/", out: [-1, -1]),
        Case(inp: "", out: [-1, -1]),
        Case(inp: "12/23/14", out: [12, 14]),
        Case(inp: "1223", out: [1223, -1]),
      ];

      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = CardUtils.getExpiryDate(c.inp);
          expect(c.out, value);
        });
      });
    });
  });
}
