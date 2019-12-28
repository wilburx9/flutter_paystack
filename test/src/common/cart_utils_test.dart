import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paystack/src/common/card_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';

void main() {
  group("$CardUtils", () {
    group("#isWholeNumberPositive", () {
      final cases = [
        _Case(inp: "12", out: true),
        _Case(inp: "+9876567", out: false),
        _Case(inp: "hgfdfghjk", out: false),
        _Case(inp: "KDHJIWUHE", out: false),
        _Case(inp: "-1-2-84ufpo", out: false),
        _Case(inp: "一些角色", out: false),
        _Case(inp: "九十", out: false),
        _Case(inp: "девяносто", out: false),
        _Case(inp: "09765678987656789876545678987656789876545678", out: true),
        _Case(inp: null, out: false),
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
        _Case(inp: 10, out: 2010),
        _Case(inp: 100, out: 100),
        _Case(inp: 1000, out: 1000),
        _Case(inp: 20, out: 2020),
        _Case(inp: 2000, out: 2000),
        _Case(inp: 94, out: 2094),
        _Case(inp: 2020, out: 2020),
        _Case(inp: 87656776, out: 87656776),
        _Case(inp: 8, out: 2008),
        _Case(inp: 0, out: 2000),
        _Case(inp: -10, out: -10),
        _Case(inp: -0, out: 2000),
        _Case(inp: -88, out: -88),
        _Case(inp: null, out: 0),
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
        _Case(inp: 10, out: true),
        _Case(inp: 100, out: true),
        _Case(inp: 1000, out: true),
        _Case(inp: 20, out: false),
        _Case(inp: 2000, out: true),
        _Case(inp: 94, out: false),
        _Case(inp: 2020, out: false),
        _Case(inp: 87656776, out: false),
        _Case(inp: 8, out: true),
        _Case(inp: 0, out: true),
        _Case(inp: -10, out: true),
        _Case(inp: -0, out: true),
        _Case(inp: -88, out: true),
        _Case(inp: null, out: true),
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
        _Case(inp: [2020, 10], out: false),
        _Case(inp: [10, 0], out: true),
        _Case(inp: [0, 0], out: true),
        _Case(inp: [1994, 1], out: true),
        _Case(inp: [1, 1], out: true),
        _Case(inp: [-203, -13], out: true),
        _Case(inp: [22, 10], out: false),
        _Case(inp: [2020, 05], out: false),
        _Case(inp: [null, 05], out: true),
        _Case(inp: [24, null], out: true),
        _Case(inp: [null, null], out: true),
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
        _Case(inp: 10, out: true),
        _Case(inp: 0, out: false),
        _Case(inp: -2, out: false),
        _Case(inp: 1, out: true),
        _Case(inp: 193873, out: false),
        _Case(inp: 8, out: true),
        _Case(inp: 012, out: true),
        _Case(inp: null, out: false),
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
        _Case(inp: [2020, 10], out: true),
        _Case(inp: [10, 0], out: false),
        _Case(inp: [0, 0], out: false),
        _Case(inp: [1994, 1], out: false),
        _Case(inp: [1, 1], out: false),
        _Case(inp: [-203, -13], out: false),
        _Case(inp: [22, 10], out: true),
        _Case(inp: [2020, 05], out: true),
        _Case(inp: [24, null], out: false),
        _Case(inp: [null, null], out: false),
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
        _Case(inp: "poiuytdfghjkkjhb", out: ""),
        _Case(inp: "098765tgb098eyr", out: "098765098"),
        _Case(inp: "6d8ge8gf7tfhd=-82qgjs9fh7w6ehf8", out: "6887829768"),
        _Case(inp: "0", out: "0"),
        _Case(inp: "девяносто", out: ""),
        _Case(inp: "一些角色", out: ""),
        _Case(inp: null, out: ""),
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
        _Case(
            inp: PaymentCard(
                number: null, cvc: null, expiryMonth: null, expiryYear: null),
            out: throwsA(TypeMatcher<CardException>())),
        _Case(inp: null, out: throwsA(TypeMatcher<CardException>())),
        _Case(
            inp: PaymentCard(
                number: "4111111111111111",
                cvc: "123",
                expiryMonth: 12,
                expiryYear: 12),
            out: "4111111111111111*123*12*12"),
        _Case(
            inp: PaymentCard(
                number: "5500000000000004",
                cvc: null,
                expiryMonth: 12,
                expiryYear: 12),
            out: "5500000000000004*null*12*12"),
        _Case(
            inp: PaymentCard(
                number: "340000000000009",
                cvc: "433",
                expiryMonth: 199,
                expiryYear: null),
            out: "340000000000009*433*199*0"),
        _Case(
            inp: PaymentCard(
                number: "340000000000009",
                cvc: "433",
                expiryMonth: null,
                expiryYear: 30),
            out: "340000000000009*433*0*30"),
        _Case(
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
        _Case(inp: "poiuytdfghjkkjhb", out: [-1, -1]),
        _Case(inp: "0/12", out: [0, 12]),
        _Case(inp: "13/0", out: [13, 0]),
        _Case(inp: "девяносто/носто", out: [-1, -1]),
        _Case(inp: "一些角色/12", out: [-1, 12]),
        _Case(inp: null, out: [-1, -1]),
        _Case(inp: "12/23", out: [12, 23]),
        _Case(inp: "-12/-23", out: [-12, -23]),
        _Case(inp: "13/", out: [13, -1]),
        _Case(inp: "/", out: [-1, -1]),
        _Case(inp: "", out: [-1, -1]),
        _Case(inp: "12/23/14", out: [12, 14]),
        _Case(inp: "1223", out: [1223, -1]),
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

class _Case {
  dynamic inp;
  dynamic out;

  _Case({@required this.inp, @required this.out});
}
