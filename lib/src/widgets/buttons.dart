import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/widgets/common/extensions.dart';

class WhiteButton extends _BaseButton {
  final bool flat;
  final IconData? iconData;
  final bool bold;

  WhiteButton({
    required VoidCallback? onPressed,
    String? text,
    Widget? child,
    this.flat = false,
    this.bold = true,
    this.iconData,
  }) : super(
          onPressed: onPressed,
          showProgress: false,
          text: text,
          child: child,
          iconData: iconData,
          textStyle: new TextStyle(
              fontSize: 14.0,
              color: Colors.black87.withOpacity(0.8),
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          color: Colors.white,
          borderSide: flat
              ? BorderSide.none
              : const BorderSide(color: Colors.grey, width: 0.5),
        );
}

class AccentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool showProgress;

  AccentButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.showProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      onPressed: onPressed,
      showProgress: showProgress,
      color: context.colorScheme().secondary,
      borderSide: BorderSide.none,
      textStyle: const TextStyle(
          fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),
      text: text,
    );
  }
}

class _BaseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final bool showProgress;
  final TextStyle textStyle;
  final Color color;
  final BorderSide borderSide;
  final IconData? iconData;
  final Widget? child;

  _BaseButton({
    required this.onPressed,
    required this.showProgress,
    required this.text,
    required this.textStyle,
    required this.color,
    required this.borderSide,
    this.iconData,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = const BorderRadius.all(Radius.circular(5.0));
    var textWidget;
    if (text != null) {
      textWidget = new Text(
        text!,
        textAlign: TextAlign.center,
        style: textStyle,
      );
    }
    return new Container(
        width: double.infinity,
        height: 50.0,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          borderRadius: borderRadius,
          color: color,
        ),
        child: new Container(
          width: double.infinity,
          height: double.infinity,
          child: new TextButton(
              onPressed: showProgress ? null : onPressed,
              child: showProgress
                  ? new Container(
                      width: 20.0,
                      height: 20.0,
                      child: new CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : iconData == null
                      ? child == null
                          ? textWidget
                          : child!
                      : new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Icon(
                              iconData,
                              color: textStyle.color!.withOpacity(0.5),
                            ),
                            const SizedBox(width: 2.0),
                            textWidget,
                          ],
                        )),
        ));
  }
}
