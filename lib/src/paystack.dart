import 'package:paystack_flutter/src/transaction.dart';

class Paystack {

}

abstract class TransactionCallback {
  void onSuccess(Transaction transaction);
  void beforeValidate(Transaction transaction);
  void onError(Exception exception, Transaction transaction);
}