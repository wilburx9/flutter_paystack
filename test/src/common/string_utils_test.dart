import 'package:flutter_paystack/src/common/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'case.dart';

void main() {
  group("$StringUtils", () {
    group("#isEmpty", () {
      final cases = [
        Case(inp: "876jje", out: false),
        Case(inp: "@", out: false),
        Case(inp: "12344323", out: false),
        Case(inp: "null", out: true),
        Case(inp: null, out: true),
        Case(inp: "娱乐", out: false),
        Case(inp: "развлекательная", out: false),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = StringUtils.isEmpty(c.inp);
          expect(c.out, value);
        });
      });
    });

    group("#isValidEmail", () {
      final cases = [
        Case(inp: "email", out: false),
        Case(inp: "@", out: false),
        Case(inp: ".com", out: false),
        Case(inp: "email@.com", out: false),
        Case(inp: "email@host.com", out: true),
        Case(inp: "ema-il@host-h.com", out: true),
        Case(inp: "e_mail@host-j.gov", out: true),
        Case(inp: "asdf@adsf.adsf", out: true),
        Case(inp: "развлекательная@adsf.adsf", out: false),
        Case(inp: "1234444", out: false),
        Case(inp: "null", out: false),
        Case(inp: null, out: false),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = StringUtils.isValidEmail(c.inp);
          expect(c.out, value);
        });
      });
    });

    group("#nullify", () {
      final cases = [
        Case(inp: "you", out: "you"),
        Case(inp: "развлекательная", out: "развлекательная"),
        Case(inp: "娱乐", out: "娱乐"),
        Case(inp: "", out: null),
        Case(inp: '', out: null),
        Case(inp: null, out: isNot(equals("q"))),
      ];
      cases.forEach((c) {
        test("${c.inp} returns ${c.out}", () {
          final value = StringUtils.nullify(c.inp);
          expect(value, c.out);
        });
      });
    });
  });
}
