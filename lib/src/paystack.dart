import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/exceptions.dart';
import 'package:flutter_paystack/src/transaction_manager.dart';
import 'package:flutter_paystack/src/utils/utils.dart';

class Paystack {
  String _publicKey;

  Paystack() {
    // Validate sdk initialized
    Utils.validateSdkInitialized();
  }

  Paystack.withPublicKey(String publicKey) {
    this.publicKey = publicKey;
  }

  /// Sets the public key
  /// [publicKey] - App Developer's public key
  set publicKey(String publicKey) {
    // Validate public key
    _validatePublicKey(publicKey);
    _publicKey = publicKey;
  }

  _validatePublicKey(String publicKey) {
    //check for null value, and length and starts with pk_
    if (publicKey == null ||
        publicKey.length < 1 ||
        !publicKey.startsWith("pk_")) {
      throw new AuthenticationException(
          'Invalid public key. To create a token, you must use a valid public key.\nEnsure that you have set a public key.\nCheck http://paystack.co for more');
    }
  }

  chargeCard(BuildContext context, Charge charge,
      TransactionCallback transactionCallback) {
    _chargeCard(context, charge, _publicKey, transactionCallback);
  }

  _chargeCard(BuildContext context, Charge charge, String publicKey,
      TransactionCallback transactionCallback) {
    //check for the needed data, if absent, send an exception through the tokenCallback;
    try {
      //validate public key
      _validatePublicKey(publicKey);

      TransactionManager transactionManager =
          new TransactionManager(charge, transactionCallback, context);

      transactionManager.chargeCard();
    } catch (e) {
      print('Something went wrong while charging card in Paystack class. '
          'Reason ${e.toString()}');
      assert(transactionCallback != null);
      transactionCallback.onError(e, null);
    }
  }
}


// TODO: Use typedef
abstract class TransactionCallback {
  onSuccess(Transaction transaction);

  beforeValidate(Transaction transaction);

  onError(Object e, Transaction transaction);
}
