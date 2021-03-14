import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/models/bank.dart';
import 'package:flutter_paystack/src/models/card.dart';

class CheckoutResponse {
  /// A user readable message. If the transaction was not successful, this returns the
  /// cause of the error.
  String message;

  /// The card used for the payment. Will be null if the customer didn't use card
  /// payment
  PaymentCard? card;

  /// The bank account used for the payment. Will be null if the customer didn't use
  /// bank account as a means of  payment
  BankAccount? account;

  /// Transaction reference. Might be null for failed transaction transactions
  String? reference;

  /// The status of the transaction. A successful response returns true and false
  /// otherwise
  bool status;

  /// The means of payment. It may return [CheckoutMethod.bank] or [CheckoutMethod.card]
  CheckoutMethod method;

  /// If the transaction should be verified. See https://developers.paystack.co/v2.0/reference#verify-transaction.
  /// This is usually false for transactions that didn't reach Paystack before terminating
  ///
  /// It might return true regardless whether a transaction fails or not.
  bool verify;

  CheckoutResponse.defaults()
      : message = Strings.userTerminated,
        status = false,
        verify = false,
        method = CheckoutMethod.selectable;

  CheckoutResponse(
      {required this.message,
      required this.reference,
      required this.status,
      required this.method,
      required this.verify,
      this.card,
      this.account})
      : assert(card != null || account != null);

  @override
  String toString() {
    return 'CheckoutResponse{message: $message, card: $card, account: $account, reference: $reference, status: $status, method: $method, verify: $verify}';
  }
}
