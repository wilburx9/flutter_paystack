class TransactionData {
  TransactionData({
    this.id,
    this.domain,
    this.status,
    this.reference,
    this.amount,
    this.message,
    this.gatewayResponse,
    this.dataPaidAt,
    this.dataCreatedAt,
    this.channel,
    this.currency,
    this.ipAddress,
    this.metadata,
    this.log,
    this.fees,
    this.feesSplit,
    this.authorization,
    this.customer,
    this.plan,
    this.orderId,
    this.paidAt,
    this.createdAt,
    this.requestedAmount,
    this.transactionDate,
    this.planObject,
    this.subaccount,
  });

  int? id;
  String? domain;
  String? status;
  String? reference;
  num? amount;
  dynamic message;
  String? gatewayResponse;
  DateTime? dataPaidAt;
  DateTime? dataCreatedAt;
  String? channel;
  String? currency;
  String? ipAddress;
  int? metadata;
  Log? log;
  int? fees;
  FeesSplit? feesSplit;
  Authorization? authorization;
  Customer? customer;
  dynamic plan;
  dynamic orderId;
  DateTime? paidAt;
  DateTime? createdAt;
  int? requestedAmount;
  DateTime? transactionDate;
  PlanObject? planObject;
  Subaccount? subaccount;

  factory TransactionData.fromJson(Map<String, dynamic> json) =>
      TransactionData(
        id: json["id"],
        domain: json["domain"],
        status: json["status"],
        reference: json["reference"],
        amount: json["amount"],
        message: json["message"],
        gatewayResponse: json["gateway_response"],
        dataPaidAt: DateTime.parse(json["paid_at"] ?? ""),
        dataCreatedAt: DateTime.parse(json["created_at"] ?? ""),
        channel: json["channel"],
        currency: json["currency"],
        ipAddress: json["ip_address"],
        metadata: json["metadata"],
        log: Log.fromJson(json["log"] ?? {}),
        fees: json["fees"],
        feesSplit: json["fees_split"] == null
            ? null
            : FeesSplit.fromJson(json["fees_split"]),
        authorization: json["authorization"] == null
            ? null
            : Authorization.fromJson(json["authorization"]),
        customer: json["customer"] == null
            ? null
            : Customer.fromJson(json["customer"]),
        plan: json["plan"],
        orderId: json["order_id"],
        paidAt: DateTime.parse(json["paidAt"] ?? ""),
        createdAt: DateTime.parse(json["createdAt"] ?? ""),
        requestedAmount: json["requested_amount"],
        transactionDate: DateTime.parse(json["transaction_date"] ?? ""),
        planObject: json["plan_object"] == null
            ? null
            : PlanObject.fromJson(json["plan_object"]),
        subaccount: json["subaccount"] == null
            ? null
            : Subaccount.fromJson(json["subaccount"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "domain": domain,
        "status": status,
        "reference": reference,
        "amount": amount,
        "message": message,
        "gateway_response": gatewayResponse,
        "paid_at": dataPaidAt?.toIso8601String(),
        "created_at": dataCreatedAt?.toIso8601String(),
        "channel": channel,
        "currency": currency,
        "ip_address": ipAddress,
        "metadata": metadata,
        "log": log?.toJson(),
        "fees": fees,
        "fees_split": feesSplit?.toJson(),
        "authorization": authorization?.toJson(),
        "customer": customer?.toJson(),
        "plan": plan,
        "order_id": orderId,
        "paidAt": paidAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "requested_amount": requestedAmount,
        "transaction_date": transactionDate?.toIso8601String(),
        "plan_object": planObject?.toJson(),
        "subaccount": subaccount?.toJson(),
      };
}

class Authorization {
  Authorization({
    this.authorizationCode,
    this.bin,
    this.last4,
    this.expMonth,
    this.expYear,
    this.channel,
    this.cardType,
    this.bank,
    this.countryCode,
    this.brand,
    this.reusable,
    this.signature,
    this.accountName,
  });

  String? authorizationCode;
  String? bin;
  String? last4;
  String? expMonth;
  String? expYear;
  String? channel;
  String? cardType;
  String? bank;
  String? countryCode;
  String? brand;
  bool? reusable;
  String? signature;
  String? accountName;

  factory Authorization.fromJson(Map<String, dynamic> json) => Authorization(
        authorizationCode: json["authorization_code"],
        bin: json["bin"],
        last4: json["last4"],
        expMonth: json["exp_month"],
        expYear: json["exp_year"],
        channel: json["channel"],
        cardType: json["card_type"],
        bank: json["bank"],
        countryCode: json["country_code"],
        brand: json["brand"],
        reusable: json["reusable"],
        signature: json["signature"],
        accountName: json["account_name"],
      );

  Map<String, dynamic> toJson() => {
        "authorization_code": authorizationCode,
        "bin": bin,
        "last4": last4,
        "exp_month": expMonth,
        "exp_year": expYear,
        "channel": channel,
        "card_type": cardType,
        "bank": bank,
        "country_code": countryCode,
        "brand": brand,
        "reusable": reusable,
        "signature": signature,
        "account_name": accountName,
      };
}

class Customer {
  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.customerCode,
    this.phone,
    this.metadata,
    this.riskAction,
  });

  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? customerCode;
  dynamic phone;
  dynamic metadata;
  String? riskAction;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        customerCode: json["customer_code"],
        phone: json["phone"],
        metadata: json["metadata"],
        riskAction: json["risk_action"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "customer_code": customerCode,
        "phone": phone,
        "metadata": metadata,
        "risk_action": riskAction,
      };
}

class FeesSplit {
  FeesSplit({
    this.paystack,
    this.integration,
    this.subaccount,
    this.params,
  });

  int? paystack;
  int? integration;
  int? subaccount;
  Params? params;

  factory FeesSplit.fromJson(Map<String, dynamic> json) => FeesSplit(
        paystack: json["paystack"],
        integration: json["integration"],
        subaccount: json["subaccount"],
        params: json["params"] == null ? null : Params.fromJson(json["params"]),
      );

  Map<String, dynamic> toJson() => {
        "paystack": paystack,
        "integration": integration,
        "subaccount": subaccount,
        "params": params?.toJson(),
      };
}

class Params {
  Params({
    this.bearer,
    this.transactionCharge,
    this.percentageCharge,
  });

  String? bearer;
  String? transactionCharge;
  String? percentageCharge;

  factory Params.fromJson(Map<String, dynamic> json) => Params(
        bearer: json["bearer"],
        transactionCharge: json["transaction_charge"],
        percentageCharge: json["percentage_charge"],
      );

  Map<String, dynamic> toJson() => {
        "bearer": bearer,
        "transaction_charge": transactionCharge,
        "percentage_charge": percentageCharge,
      };
}

class Log {
  Log({
    this.startTime,
    this.timeSpent,
    this.attempts,
    this.errors,
    this.success,
    this.mobile,
    this.input,
    this.history,
  });

  int? startTime;
  int? timeSpent;
  int? attempts;
  int? errors;
  bool? success;
  bool? mobile;
  List<dynamic>? input;
  List<History>? history;

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        startTime: json["start_time"],
        timeSpent: json["time_spent"],
        attempts: json["attempts"],
        errors: json["errors"],
        success: json["success"],
        mobile: json["mobile"],
        input: json["mobile"] == null
            ? null
            : List<dynamic>.from(json["input"].map((x) => x)),
        history: json["history"] == null
            ? null
            : List<History>.from(
                json["history"].map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "start_time": startTime,
        "time_spent": timeSpent,
        "attempts": attempts,
        "errors": errors,
        "success": success,
        "mobile": mobile,
        "input": List<dynamic>.from(input!.map((x) => x)),
        "history": List<dynamic>.from(history!.map((x) => x.toJson())),
      };
}

class History {
  History({
    this.type,
    this.message,
    this.time,
  });

  String? type;
  String? message;
  int? time;

  factory History.fromJson(Map<String, dynamic> json) => History(
        type: json["type"],
        message: json["message"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "message": message,
        "time": time,
      };
}

class PlanObject {
  PlanObject();

  factory PlanObject.fromJson(Map<String, dynamic> json) => PlanObject();

  Map<String, dynamic> toJson() => {};
}

class Subaccount {
  Subaccount({
    this.id,
    this.subaccountCode,
    this.businessName,
    this.description,
    this.primaryContactName,
    this.primaryContactEmail,
    this.primaryContactPhone,
    this.metadata,
    this.percentageCharge,
    this.settlementBank,
    this.accountNumber,
  });

  int? id;
  String? subaccountCode;
  String? businessName;
  String? description;
  String? primaryContactName;
  String? primaryContactEmail;
  String? primaryContactPhone;
  dynamic metadata;
  double? percentageCharge;
  String? settlementBank;
  String? accountNumber;

  factory Subaccount.fromJson(Map<String, dynamic> json) => Subaccount(
        id: json["id"],
        subaccountCode: json["subaccount_code"],
        businessName: json["business_name"],
        description: json["description"],
        primaryContactName: json["primary_contact_name"],
        primaryContactEmail: json["primary_contact_email"],
        primaryContactPhone: json["primary_contact_phone"],
        metadata: json["metadata"],
        percentageCharge: json["percentage_charge"] == null
            ? null
            : json["percentage_charge"].toDouble(),
        settlementBank: json["settlement_bank"],
        accountNumber: json["account_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subaccount_code": subaccountCode,
        "business_name": businessName,
        "description": description,
        "primary_contact_name": primaryContactName,
        "primary_contact_email": primaryContactEmail,
        "primary_contact_phone": primaryContactPhone,
        "metadata": metadata,
        "percentage_charge": percentageCharge,
        "settlement_bank": settlementBank,
        "account_number": accountNumber,
      };
}
