import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';

class Transaction {
  String _id;
  String _reference;

  loadFromResponse(TransactionApiResponse t) {
    if (t.hasValidReferenceAndTrans()) {
      this._reference = t.reference;
      this._id = t.trans;
    }
  }

  String get reference => _reference;

  String get id => _id;

  bool hasStartedOnServer() {
    return (reference != null) && (id != null);
  }
}
