import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/request/bank_charge_request_body.dart';
import 'package:flutter_paystack/src/models/bank.dart';

abstract class BankServiceContract {
  Future<String?> getTransactionId(String? accessCode);

  Future<TransactionApiResponse> chargeBank(BankChargeRequestBody? requestBody);

  Future<TransactionApiResponse> validateToken(
      BankChargeRequestBody? requestBody, Map<String, String?> fields);

  Future<List<Bank>?>? fetchSupportedBanks();
}
