import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/widgets/base_widget.dart';

class CustomAnimatedWidget extends StatelessWidget {
  final CurvedAnimation _animation;
  final Widget child;

  CustomAnimatedWidget(
      {required this.child, required AnimationController controller})
      : _animation = new CurvedAnimation(
          parent: controller,
          curve: Curves.fastOutSlowIn,
        );

  final Tween<Offset> slideTween =
      Tween(begin: const Offset(0.0, 0.02), end: Offset.zero);
  final Tween<double> scaleTween = Tween(begin: 1.04, end: 1.0);

  @override
  Widget build(BuildContext context) {
    return new FadeTransition(
      opacity: _animation,
      child: new SlideTransition(
        position: slideTween.animate(_animation),
        child: new ScaleTransition(
          scale: scaleTween.animate(_animation),
          child: new Container(
            margin: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
            child: new SafeArea(top: false, bottom: false, child: child),
          ),
        ),
      ),
    );
  }
}

abstract class BaseAnimatedState<T extends StatefulWidget> extends BaseState<T>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    alwaysPop = true;
    controller = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    return CustomAnimatedWidget(
      controller: controller,
      child: buildAnimatedChild(),
    );
  }

  Widget buildAnimatedChild();
}
