import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/widgets/common/my_colors.dart';

class CustomTheme extends Theme {
  CustomTheme({@required Widget child})
      : super(
            child: child,
            data: new ThemeData(
                primaryColor: MyColors.navyBlue,
                cursorColor: MyColors.green,
                backgroundColor: MyColors.navyBlue,
                accentTextTheme: const TextTheme(
                    body2: const TextStyle(color: Colors.white)),
                accentColor: MyColors.green));
}
