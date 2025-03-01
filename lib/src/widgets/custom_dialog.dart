import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/widgets/common/extensions.dart';

/// This is a modification of [AlertDialog]. A lot of modifications was made. The goal is
/// to retain the dialog feel and look while adding the close IconButton
class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    Key? key,
    this.title,
    this.titlePadding,
    this.onCancelPress,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10.0),
    this.expanded = false,
    this.fullscreen = false,
    required this.content,
  }) : super(key: key);

  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;
  final Widget content;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onCancelPress;
  final bool expanded;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (title != null && titlePadding != null) {
      children.add(new Padding(
        padding: titlePadding!,
        child: new DefaultTextStyle(
          style: context.textTheme().titleLarge!,
          child: new Semantics(child: title, namesRoute: true),
        ),
      ));
    }

    children.add(new Flexible(
      child: new Padding(
        padding: contentPadding,
        child: new DefaultTextStyle(
          style: context.textTheme().titleMedium!,
          child: content,
        ),
      ),
    ));

    return buildContent(context, children);
  }

  Widget buildContent(context, List<Widget> children) {
    Widget widget;
    if (fullscreen) {
      widget = new Material(
        child: new Container(
            child: onCancelPress == null
                ? new Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 20.0,
                    ),
                    child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children),
                  )
                : new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Align(
                        alignment: Alignment.topRight,
                        child: new IconButton(
                          icon: new Icon(Icons.close),
                          onPressed: onCancelPress,
                          color: Colors.black54,
                          padding: const EdgeInsets.all(15.0),
                          iconSize: 30.0,
                        ),
                      ),
                      new Expanded(
                          child: new Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: new Column(
                          children: children,
                        ),
                      ))
                    ],
                  )),
      );
    } else {
      var body = new Material(
        type: MaterialType.card,
        borderRadius: new BorderRadius.circular(10.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
      var child = new IntrinsicWidth(
        child: onCancelPress == null
            ? body
            : new Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.all(10.0),
                    child: new IconButton(
                        highlightColor: Colors.white54,
                        splashColor: Colors.white54,
                        color: Colors.white,
                        iconSize: 30.0,
                        padding: const EdgeInsets.all(3.0),
                        icon: const Icon(
                          Icons.cancel,
                        ),
                        onPressed: onCancelPress),
                  ),
                  new Flexible(child: body),
                ],
              ),
      );
      widget = new CustomDialog(child: child, expanded: expanded);
    }
    return widget;
  }
}

/// This is a modification of [Dialog]. The only modification is increasing the
/// elevation and changing the Material type.
class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.child,
    required this.expanded,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
  }) : super(key: key);

  final Widget child;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return new AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: new MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: new Center(
          child: new ConstrainedBox(
            constraints: new BoxConstraints(
                minWidth: expanded
                    ? math.min(
                        (MediaQuery.of(context).size.width - 40.0), 332.0)
                    : 280.0),
            child: new Material(
              elevation: 50.0,
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
