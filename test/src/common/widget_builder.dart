import 'package:flutter/material.dart';

MaterialApp buildTestWidget(Widget child) {
  return MaterialApp(
    home: Material(
      child: child,
    ),
  );
}
