import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/common/utils.dart';
import 'package:flutter_paystack/src/widgets/animated_widget.dart';
import 'package:flutter_paystack/src/widgets/common/extensions.dart';

class SuccessfulWidget extends StatefulWidget {
  final int amount;
  final VoidCallback onCountdownComplete;

  SuccessfulWidget({required this.amount, required this.onCountdownComplete});

  @override
  _SuccessfulWidgetState createState() {
    return new _SuccessfulWidgetState();
  }
}

class _SuccessfulWidgetState extends State<SuccessfulWidget>
    with TickerProviderStateMixin {
  final sizedBox = const SizedBox(height: 20.0);
  late AnimationController _mainController;
  late AnimationController _opacityController;
  late Animation<double> _opacity;

  static const int kStartValue = 4;
  late AnimationController _countdownController;
  late Animation _countdownAnim;

  @override
  void initState() {
    super.initState();
    _mainController = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _mainController.forward();

    _countdownController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: kStartValue),
    );
    _countdownController.addListener(() => setState(() {}));
    _countdownAnim =
        new StepTween(begin: kStartValue, end: 0).animate(_countdownController);

    _opacityController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opacity =
        new CurvedAnimation(parent: _opacityController, curve: Curves.linear)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _opacityController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _opacityController.forward();
            }
          });

    WidgetsBinding.instance.addPostFrameCallback((_) => _startCountdown());
  }

  @override
  void dispose() {
    _mainController.dispose();
    _countdownController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sceondaryColor = context.colorScheme().secondary;
    return new Container(
      child: new CustomAnimatedWidget(
        controller: _mainController,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            sizedBox,
            new Image.asset(
              'assets/images/successful.png',
              color: sceondaryColor,
              width: 50.0,
              package: 'flutter_paystack',
            ),
            sizedBox,
            Text(
              'Payment Successful',
              style: TextStyle(
                color: context.textTheme().titleLarge?.color,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
            new SizedBox(
              height: 5.0,
            ),
            widget.amount.isNegative
                ? new Container()
                : new Text('You paid ${Utils.formatAmount(widget.amount)}',
                    style: TextStyle(
                      color: context.textTheme().titleLarge?.color,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                    )),
            sizedBox,
            new FadeTransition(
              opacity: _opacity,
              child: new Text(
                _countdownAnim.value.toString(),
                style: TextStyle(
                    color: sceondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
            ),
            new SizedBox(
              height: 30.0,
            )
          ],
        ),
      ),
    );
  }

  void _startCountdown() {
    if (_countdownController.isAnimating ||
        _countdownController.isCompleted ||
        !mounted) {
      return;
    }
    _countdownController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        widget.onCountdownComplete();
      }
    });
    _countdownController.forward();
    _opacityController.forward();
  }
}
