import 'package:flutter/material.dart';

Handler setup(SetupData data) {
  throw UnimplementedError();
}

abstract class Handler {
  void openIframe();
}

class SetupData {
  final String? key;
  final String? email;
  final int amount;
  final String? ref;

  final VoidCallback? onClose;
  final PaystackCallback? callback;

  SetupData({
    required this.key,
    required this.email,
    required this.amount,
    required this.ref,
    this.onClose,
    this.callback,
  });
}

abstract class ChargeResponse {
  String get message;

  String get reference;

  String get response;

  String get status;
}

typedef PaystackCallback(ChargeResponse response);
