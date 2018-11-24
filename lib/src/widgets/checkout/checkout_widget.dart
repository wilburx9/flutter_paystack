import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_paystack/src/model/checkout_response.dart';
import 'package:flutter_paystack/src/model/card.dart';
import 'package:flutter_paystack/src/model/charge.dart';
import 'package:flutter_paystack/src/common/paystack.dart';
import 'package:flutter_paystack/src/widgets/common/my_colors.dart';
import 'package:flutter_paystack/src/widgets/base_widget.dart';
import 'package:flutter_paystack/src/widgets/checkout/bank_checkout.dart';
import 'package:flutter_paystack/src/widgets/checkout/card_checkout.dart';
import 'package:flutter_paystack/src/widgets/checkout/checkout_method.dart';
import 'package:flutter_paystack/src/widgets/custom_dialog.dart';
import 'package:flutter_paystack/src/widgets/error_widget.dart';
import 'package:flutter_paystack/src/widgets/sucessful_widget.dart';
import 'package:flutter_paystack/src/common/utils.dart';

const kFullTabHeight = 74.0;

class CheckoutWidget extends StatefulWidget {
  final CheckoutMethod method;
  final Charge charge;
  final bool fullscreen;

  CheckoutWidget(
      {@required this.method,
      @required this.charge,
      @required this.fullscreen});

  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState(charge);
}

class _CheckoutWidgetState extends BaseState<CheckoutWidget>
    with TickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const tabBorderRadius = BorderRadius.all(Radius.circular(4.0));
  final Charge _charge;
  String _accessCode;
  var _currentIndex = 0;
  var _showTabs = true;
  String _paymentError;
  bool _paymentSuccessful = false;
  TabController _tabController;
  List<MethodItem> _methodWidgets;
  double _tabHeight = kFullTabHeight;
  AnimationController _animationController;
  CheckoutResponse _response;

  _CheckoutWidgetState(this._charge);

  @override
  void initState() {
    super.initState();
    _initMethods();
    _currentIndex = _getCurrentTab();
    _showTabs = widget.method == CheckoutMethod.selectable ? true : false;
    _tabController = new TabController(
        vsync: this,
        length: _methodWidgets.length,
        initialIndex: _currentIndex);
    _tabController.addListener(_indexChange);
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
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    return new CustomAlertDialog(
      key: _scaffoldKey,
      expanded: true,
      fullscreen: widget.fullscreen,
      titlePadding: EdgeInsets.all(0.0),
      onCancelPress: onCancelPress,
      title: _buildTitle(),
      content: new Container(
        child: new SingleChildScrollView(
          child: new Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: _showProcessingError()
                  ? _buildErrorWidget()
                  : _paymentSuccessful
                      ? _buildSuccessfulWidget()
                      : _methodWidgets[_currentIndex].child),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    var amountAndAmount = new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        _charge.email != null
            ? new Text(
                _charge.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12.0),
              )
            : new Container(),
        _charge.amount == null || _charge.amount.isNegative
            ? new Container()
            : new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Pay',
                    style:
                        const TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                  new SizedBox(
                    width: 5.0,
                  ),
                  new Flexible(
                      child: new Text(Utils.formatAmount(_charge.amount),
                          style: const TextStyle(
                              fontSize: 15.0,
                              color: MyColors.green,
                              fontWeight: FontWeight.w500)))
                ],
              )
      ],
    );
    var checkoutMethods = _showTabs
        ? new AnimatedSize(
            duration: const Duration(milliseconds: 300),
            vsync: this,
            curve: Curves.fastOutSlowIn,
            child: new Container(
              color: Colors.grey.withOpacity(0.1),
              height: _tabHeight,
              alignment: Alignment.center,
              child: new TabBar(
                controller: _tabController,
                isScrollable: true,
                unselectedLabelColor: Colors.black54,
                labelColor: MyColors.green,
                labelStyle:
                    new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                indicator: new ShapeDecoration(
                  shape: const RoundedRectangleBorder(
                        borderRadius: tabBorderRadius,
                        side: BorderSide(
                          color: MyColors.green,
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
          )
        : new Container();

    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container(
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Image.asset('assets/images/paystack_logo.png',
                  width: 25.0, package: 'flutter_paystack'),
              new SizedBox(
                width: 50.0,
              ),
              new Expanded(child: amountAndAmount),
            ],
          ),
        ),
        checkoutMethods
      ],
    );
  }

  void _indexChange() {
    setState(() {
      _currentIndex = _tabController.index;
      // Update the checkout here just in case the user terminates the transaction
      // forcefully by tapping the close icon
    });
  }

  void _initMethods() {
    _methodWidgets = [
      new MethodItem(
          text: 'Card',
          icon: Icons.credit_card,
          child: new CardCheckout(
            charge: _charge,
            onProcessingChange: _onProcessingChange,
            onResponse: _onPaymentResponse,
            accessCode: _accessCode,
            onInitialized: (String accessCode) {
              _accessCode = accessCode;
            },
            onCardChange: (PaymentCard card) {
              _charge.card.number = card.number;
              _charge.card.cvc = card.cvc;
              _charge.card.expiryMonth = card.expiryMonth;
              _charge.card.expiryYear = card.expiryYear;
            },
          )),
      new MethodItem(
          text: 'Bank',
          icon: Icons.account_balance,
          child: new BankCheckout(
            charge: _charge,
            onResponse: _onPaymentResponse,
            onProcessingChange: _onProcessingChange,
          ))
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
    return !(_paymentError == null || _paymentError.isEmpty);
  }

  void _onPaymentResponse(CheckoutResponse response) {
    _response = response;
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

  void _onPaymentError(String value) {
    setState(() {
      _paymentError = value;
      _paymentSuccessful = false;
      _onProcessingChange(false);
    });
  }

  int _getCurrentTab() {
    int checkedTab;
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
    _initMethods();
    void _resetShowTabs() {
      _response = null; // Reset the response
      _showTabs = widget.method == CheckoutMethod.selectable ? true : false;
    }

    return new ErrorWidget(
      text: _paymentError,
      method: widget.method,
      vSync: this,
      payWithBank: () {
        setState(() {
          _resetShowTabs();
          _onPaymentError(null);
          _charge.card = new PaymentCard.empty();
          _tabController.index = 1;
          _paymentError = null;
        });
      },
      tryAnotherCard: () {
        setState(() {
          _resetShowTabs();
          _onPaymentError(null);
          _charge.card = new PaymentCard.empty();
          _tabController.index = 0;
        });
      },
      startOverWithCard: () {
        _resetShowTabs();
        _onPaymentError(null);
        _tabController.index = 0;
      },
    );
  }

  Widget _buildSuccessfulWidget() => new SuccessfulWidget(
        amount: _charge.amount,
        onCountdownComplete: () => Navigator.of(context).pop(_response),
      );

  @override
  getPopReturnValue() {
    return _getResponse();
  }

  CheckoutResponse _getResponse() {
    CheckoutResponse response = _response;
    if (response == null) {
      response = CheckoutResponse.defaults();
      response.method =
          _tabController.index == 0 ? CheckoutMethod.card : CheckoutMethod.bank;
    }
    return response;
  }
}

typedef void OnResponse<CheckoutResponse>(CheckoutResponse response);
