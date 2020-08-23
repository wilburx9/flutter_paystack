import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugins.wilburt/flutter_paystack');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group("$Utils", () {
    group("#validateSdkInitialized", () {
      test(
          "throws PaystackSdkNotInitializedException when PaystackPlugin is not initialized",
          () {
        expect(() => Utils.validateSdkInitialized(),
            throwsA(TypeMatcher<PaystackSdkNotInitializedException>()));
      });

      test("returns normally when PaystackPlugin is initialized", () async {
        await PaystackPlugin.initialize(
            publicKey: Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"]);
        expect(() => Utils.validateSdkInitialized(), returnsNormally);
        PaystackPlugin.dispose();
      });
    });

    group("#getKeyErrorMsg", () {
      test("returns a string with keyType", () {
        final keyType = "public";
        expect(Utils.getKeyErrorMsg(keyType), contains(keyType));
      });
    });

    group("#formatAmount", () {
      test("throws Error when currency formatter is not set", () {
        expect(() => Utils.formatAmount(100), throwsA(TypeMatcher<String>()));
      });

      test("returns normally when currency formatter has been set", () {
        Utils.setCurrencyFormatter(Strings.ngn, Strings.nigerianLocale);
        expect(() => Utils.formatAmount(100), returnsNormally);
      });
    });

    group("#validateChargeAndKey", () {
      test(
          "throws PaystackSdkNotInitializedException when called with null charge and PaystackPlugin is not initialized",
          () {
        expect(() => Utils.validateChargeAndKey(null),
            throwsA(TypeMatcher<PaystackSdkNotInitializedException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws PaystackSdkNotInitializedException when called with charge and PaystackPlugin is not initialized",
          () {
        expect(() {
          var charge = Charge()
            ..email = "email@e.co"
            ..amount = 100;
          return Utils.validateChargeAndKey(charge);
        }, throwsA(TypeMatcher<PaystackSdkNotInitializedException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws AuthenticationException when called with null charge and PaystackPlugin is initialized with invalid key",
          () async {
        await PaystackPlugin.initialize(publicKey: "ytryuiuyuiuyfg");
        expect(() => Utils.validateChargeAndKey(null),
            throwsA(TypeMatcher<AuthenticationException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws AuthenticationException when called with charge and PaystackPlugin is initialized with invalid key",
          () async {
        await PaystackPlugin.initialize(publicKey: "ytryuiuyuiuyfg");
        var charge = Charge()
          ..email = "email@e.co"
          ..amount = 100;
        expect(() => Utils.validateChargeAndKey(charge),
            throwsA(TypeMatcher<AuthenticationException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws PaystackException when called with null charge and PaystackPlugin is initialized with valid key",
          () async {
        await PaystackPlugin.initialize(
            publicKey: Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"]);
        expect(() => Utils.validateChargeAndKey(null),
            throwsA(TypeMatcher<PaystackException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws InvalidAmountException when called with null amount and PaystackPlugin is initialized with valid key",
          () async {
        await PaystackPlugin.initialize(
            publicKey: Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"]);
        expect(() => Utils.validateChargeAndKey(Charge()..email = "you@u.com"),
            throwsA(TypeMatcher<InvalidAmountException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws InvalidAmountException when called with negative amount and PaystackPlugin is initialized with valid key",
          () async {
        await PaystackPlugin.initialize(
            publicKey: Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"]);
        expect(() {
          var charge = Charge()
            ..email = "you@u.com"
            ..amount = -10;
          return Utils.validateChargeAndKey(charge);
        }, throwsA(TypeMatcher<InvalidAmountException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws InvalidAmountException when called with valid amount, null email and PaystackPlugin is initialized with valid key",
          () async {
        await PaystackPlugin.initialize(
            publicKey: Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"]);
        expect(() {
          var charge = Charge()..amount = 10;
          return Utils.validateChargeAndKey(charge);
        }, throwsA(TypeMatcher<InvalidEmailException>()));
        PaystackPlugin.dispose();
      });

      test(
          "throws InvalidAmountException when called with valid amount, invalid email and PaystackPlugin is initialized with valid key",
          () async {
        await PaystackPlugin.initialize(
            publicKey: Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"]);
        var charge = Charge()
          ..amount = 10
          ..email = "8yu";
        expect(() => Utils.validateChargeAndKey(charge),
            throwsA(TypeMatcher<InvalidEmailException>()));
        PaystackPlugin.dispose();
      });

      test(
          "returns normally when called with valid charge and PaystackPlugin is initialized with valid key",
          () async {
        await PaystackPlugin.initialize(
            publicKey: Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"]);
        var charge = Charge()
          ..amount = 10
          ..email = "8yu@h.go";
        expect(() => Utils.validateChargeAndKey(charge), returnsNormally);
        PaystackPlugin.dispose();
      });
    });
  });
}
