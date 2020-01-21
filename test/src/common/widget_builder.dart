import 'package:flutter/material.dart';

MaterialApp buildWidget(Widget child) {
  return MaterialApp(
    home: Material(
      child: child,
    ),
  );
}
