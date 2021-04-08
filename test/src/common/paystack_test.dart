import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.wilburt/flutter_paystack');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group("$PaystackPlugin", () {
    test('is properly initialized with passed key', () async {
      var publicKey = Platform.environment["PAYSTACK_TEST_PUBLIC_KEY"] ?? "";
      final plugin = PaystackPlugin();
      await plugin.initialize(publicKey: publicKey);
      expect(publicKey, plugin.publicKey);
    });
  });
}
