import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_paystack/src/api/service/contracts/banks_service_contract.dart';
import 'package:flutter_paystack/src/api/service/contracts/cards_service_contract.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/common/utils.dart';
import 'package:flutter_paystack/src/models/card.dart';
import 'package:flutter_paystack/src/models/charge.dart';
import 'package:flutter_paystack/src/models/checkout_response.dart';
import 'package:flutter_paystack/src/widgets/base_widget.dart';
import 'package:flutter_paystack/src/widgets/checkout/bank_checkout.dart';
import 'package:flutter_paystack/src/widgets/checkout/card_checkout.dart';
import 'package:flutter_paystack/src/widgets/checkout/checkout_method.dart';
import 'package:flutter_paystack/src/widgets/common/extensions.dart';
import 'package:flutter_paystack/src/widgets/custom_dialog.dart';
import 'package:flutter_paystack/src/widgets/error_widget.dart';
import 'package:flutter_paystack/src/widgets/sucessful_widget.dart';

const kFullTabHeight = 74.0;

class CheckoutWidget extends StatefulWidget {
  final CheckoutMethod method;
  final Charge charge;
  final bool fullscreen;
  final Widget? logo;
  final bool hideEmail;
  final bool hideAmount;
  final BankServiceContract bankService;
  final CardServiceContract cardsService;
  final String publicKey;

  CheckoutWidget({
    required this.method,
    required this.charge,
    required this.bankService,
    required this.cardsService,
    required this.publicKey,
    this.fullscreen = false,
    this.logo,
    this.hideEmail = false,
    this.hideAmount = false,
  });

  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState(charge);
}

class _CheckoutWidgetState extends BaseState<CheckoutWidget>
    with TickerProviderStateMixin {
  static const tabBorderRadius = BorderRadius.all(Radius.circular(4.0));
  final Charge _charge;
  int? _currentIndex = 0;
  var _showTabs = true;
  String? _paymentError;
  bool _paymentSuccessful = false;
  TabController? _tabController;
  late List<MethodItem> _methodWidgets;
  double _tabHeight = kFullTabHeight;
  late AnimationController _animationController;
  CheckoutResponse? _response;

  _CheckoutWidgetState(this._charge);

  @override
  void initState() {
    super.initState();
    _init();
    _initPaymentMethods();
    _currentIndex = _getCurrentTab();
    _showTabs = widget.method == CheckoutMethod.selectable ? true : false;
    _tabController = new TabController(
        vsync: this,
        length: _methodWidgets.length,
        initialIndex: _currentIndex!);
    _tabController!.addListener(_indexChange);
    _animationController = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (_charge.card == null) {
      _charge.card = PaymentCard.empty();
    }
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    var securedWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.lock, size: 10),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 3),
              child: Text(
                "Secured by",
                key: Key("SecuredBy"),
                style: TextStyle(fontSize: 10),
              ),
            )
          ],
        ),
        SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.logo != null)
              Padding(
                padding: EdgeInsetsDirectional.only(end: 3),
                child: Image.asset(
                  'assets/images/paystack_icon.png',
                  key: Key("PaystackBottomIcon"),
                  package: 'flutter_paystack',
                  height: 16,
                ),
              ),
            Image.asset(
              'assets/images/paystack.png',
              key: Key("PaystackLogo"),
              package: 'flutter_paystack',
              height: 15,
            )
          ],
        )
      ],
    );
    return new CustomAlertDialog(
      expanded: true,
      fullscreen: widget.fullscreen,
      titlePadding: EdgeInsets.all(0.0),
      onCancelPress: onCancelPress,
      title: _buildTitle(),
      content: new Container(
        child: new SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: new Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                child: Column(
                  children: <Widget>[
                    _showProcessingError()
                        ? _buildErrorWidget()
                        : _paymentSuccessful
                            ? _buildSuccessfulWidget()
                            : _methodWidgets[_currentIndex!].child,
                    SizedBox(height: 20),
                    securedWidget
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final accentColor = context.colorScheme().secondary;
    var emailAndAmount = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!widget.hideEmail && _charge.email != null)
          Text(
            _charge.email!,
            key: Key("ChargeEmail"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: context.textTheme().bodySmall?.color, fontSize: 12.0),
          ),
        if (!widget.hideAmount && !_charge.amount.isNegative)
          Row(
            key: Key("DisplayAmount"),
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pay',
                style: TextStyle(
                    fontSize: 14.0, color: context.textTheme().headlineLarge?.color),
              ),
              SizedBox(
                width: 5.0,
              ),
              Flexible(
                  child: Text(Utils.formatAmount(_charge.amount),
                      style: TextStyle(
                          fontSize: 15.0,
                          color: context.textTheme().headlineSmall?.color,
                          fontWeight: FontWeight.bold)))
            ],
          )
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.logo == null)
                Image.asset(
                  'assets/images/paystack_icon.png',
                  key: Key("PaystackIcon"),
                  package: 'flutter_paystack',
                  width: 25,
                )
              else
                SizedBox(
                  key: Key("Logo"),
                  child: widget.logo,
                ),
              new SizedBox(
                width: 50,
              ),
              new Expanded(child: emailAndAmount),
            ],
          ),
        ),
        if (_showTabs) buildCheckoutMethods(accentColor)
      ],
    );
  }

  Widget buildCheckoutMethods(Color accentColor) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: new Container(
        color: context.colorScheme().background.withOpacity(0.5),
        height: _tabHeight,
        alignment: Alignment.center,
        child: new TabBar(
          controller: _tabController,
          isScrollable: true,
          unselectedLabelColor: context.colorScheme().onBackground,
          labelColor: accentColor,
          labelStyle:
              new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          indicator: new ShapeDecoration(
            shape: RoundedRectangleBorder(
                  borderRadius: tabBorderRadius,
                  side: BorderSide(
                    color: accentColor,
                    width: 1.0,
                  ),
                ) +
                const RoundedRectangleBorder(
                  borderRadius: tabBorderRadius,
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 6.0,
                  ),
                ),
          ),
          tabs: _methodWidgets.map<Tab>((MethodItem m) {
            return new Tab(
              text: m.text,
              icon: new Icon(
                m.icon,
                size: 24.0,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _indexChange() {
    setState(() {
      _currentIndex = _tabController!.index;
      // Update the checkout here just in case the user terminates the transaction
      // forcefully by tapping the close icon
    });
  }

  void _initPaymentMethods() {
    _methodWidgets = [
      new MethodItem(
          text: 'Card',
          icon: Icons.credit_card,
          child: new CardCheckout(
            key: Key("CardCheckout"),
            publicKey: widget.publicKey,
            service: widget.cardsService,
            charge: _charge,
            onProcessingChange: _onProcessingChange,
            onResponse: _onPaymentResponse,
            hideAmount: widget.hideAmount,
            onCardChange: (PaymentCard? card) {
              if (card == null) return;
              _charge.card!.number = card.number;
              _charge.card!.cvc = card.cvc;
              _charge.card!.expiryMonth = card.expiryMonth;
              _charge.card!.expiryYear = card.expiryYear;
            },
          )),
      new MethodItem(
        text: 'Bank',
        icon: Icons.account_balance,
        child: new BankCheckout(
          publicKey: widget.publicKey,
          charge: _charge,
          service: widget.bankService,
          onResponse: _onPaymentResponse,
          onProcessingChange: _onProcessingChange,
        ),
      )
    ];
  }

  void _onProcessingChange(bool processing) {
    setState(() {
      _tabHeight = processing || _paymentSuccessful || _showProcessingError()
          ? 0.0
          : kFullTabHeight;
      processing = processing;
    });
  }

  _showProcessingError() {
    return !(_paymentError == null || _paymentError!.isEmpty);
  }

  void _onPaymentResponse(CheckoutResponse response) {
    _response = response;
    if (!mounted) return;
    if (response.status == true) {
      _onPaymentSuccess();
    } else {
      _onPaymentError(response.message);
    }
  }

  void _onPaymentSuccess() {
    setState(() {
      _paymentSuccessful = true;
      _paymentError = null;
      _onProcessingChange(false);
    });
  }

  void _onPaymentError(String? value) {
    setState(() {
      _paymentError = value;
      _paymentSuccessful = false;
      _onProcessingChange(false);
    });
  }

  int? _getCurrentTab() {
    int? checkedTab;
    switch (widget.method) {
      case CheckoutMethod.selectable:
      case CheckoutMethod.card:
        checkedTab = 0;
        break;
      case CheckoutMethod.bank:
        checkedTab = 1;
        break;
    }
    return checkedTab;
  }

  Widget _buildErrorWidget() {
    _initPaymentMethods();
    void _resetShowTabs() {
      _response = null; // Reset the response
      _showTabs = widget.method == CheckoutMethod.selectable ? true : false;
    }

    return new ErrorWidget(
      text: _paymentError,
      method: widget.method,
      isCardPayment: _charge.card!.isValid(),
      vSync: this,
      payWithBank: () {
        setState(() {
          _resetShowTabs();
          _onPaymentError(null);
          _charge.card = new PaymentCard.empty();
          _tabController!.index = 1;
          _paymentError = null;
        });
      },
      tryAnotherCard: () {
        setState(() {
          _resetShowTabs();
          _onPaymentError(null);
          _charge.card = new PaymentCard.empty();
          _tabController!.index = 0;
        });
      },
      startOverWithCard: () {
        _resetShowTabs();
        _onPaymentError(null);
        _tabController!.index = 0;
      },
    );
  }

  Widget _buildSuccessfulWidget() => new SuccessfulWidget(
        amount: _charge.amount,
        onCountdownComplete: () {
          if (_response!.card != null) {
            _response!.card!.nullifyNumber();
          }
         Navigator.of(context).pop(_response);
        },
      );

  @override
  getPopReturnValue() {
    return _getResponse();
  }

  CheckoutResponse _getResponse() {
    CheckoutResponse? response = _response;
    if (response == null) {
      response = CheckoutResponse.defaults();
      response.method = _tabController!.index == 0
          ? CheckoutMethod.card
          : CheckoutMethod.bank;
    }
    if (response.card != null) {
      response.card!.nullifyNumber();
    }
    return response;
  }

  _init() {
    Utils.setCurrencyFormatter(_charge.currency, _charge.locale);
  }
}

typedef void OnResponse<CheckoutResponse>(CheckoutResponse response);
