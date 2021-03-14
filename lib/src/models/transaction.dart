import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';

class Transaction {
  String? _id;
  String? _reference;
  String? _message;

  loadFromResponse(TransactionApiResponse t) {
    if (t.hasValidReferenceAndTrans()) {
      this._reference = t.reference;
      this._id = t.trans;
      this._message = t.message;
    }
  }

  String? get reference => _reference;

  String? get id => _id;

  String get message => _message ?? "";

  bool hasStartedOnServer() {
    return (reference != null) && (id != null);
  }
}
