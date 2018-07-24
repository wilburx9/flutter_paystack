import 'package:paystack_flutter/transaction.dart';

abstract class TransactionCallback {
  void onSuccess(Transaction transaction);
  void beforeValidate(Transaction transaction);
  void onError(Exception exception, Transaction transaction);
}