import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/paystack.dart';
import 'package:flutter_paystack/src/ui/widgets/checkout/bank_checkout.dart';
import 'package:meta/meta.dart';

class CheckoutResponse {
  /// A user readable message. If the transaction was successful, this returns the
  /// cause of the error.
  String message;
  /// The card used for the payment. Will return null if the customer didn't use card
  /// payment
  PaymentCard card;
  /// The bank account used for the payment. Will return null if the customer didn't use
  /// bank account as a means of  payment
  BankAccount account;
  /// Transaction reference. Might return null for failed transaction transactions
  String reference;
  /// The status of the transaction. A successful response returns true and false
  /// otherwise
  bool status;
  /// The means of payment. It may return [CheckoutMethod.bank] or [CheckoutMethod.card]
  CheckoutMethod method;

  CheckoutResponse.defaults() {
    message = Strings.userTerminated;
    card = null;
    account = null;
    reference = null;
    status = false;
    method = null;
  }

  CheckoutResponse(
      {@required this.message,
      @required this.reference,
      @required this.status,
      @required this.method,
      @required this.card,
      @required this.account});

  @override
  String toString() {
    return '[Message: $message, \nCard: $card, \nAccount: $account, '
        '\nReference: $reference, \nMethod: $method, \nStatus: $status]';
  }
}
