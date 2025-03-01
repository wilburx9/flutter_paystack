import 'package:flutter/material.dart';
import 'package:flutter_paystack/src/widgets/base_widget.dart';
import 'package:flutter_paystack/src/widgets/common/extensions.dart';
import 'package:flutter_paystack/src/widgets/custom_dialog.dart';
import 'package:flutter_paystack/src/widgets/input/otp_field.dart';

import 'buttons.dart';

class OtpWidget extends StatefulWidget {
  final String? message;

  OtpWidget({required this.message});

  @override
  _OtpWidgetState createState() => _OtpWidgetState();
}

class _OtpWidgetState extends BaseState<OtpWidget> {
  var _formKey = new GlobalKey<FormState>();
  var _autoValidate = AutovalidateMode.disabled;
  String? _otp;
  var heightBox = const SizedBox(height: 20.0);

  @override
  Widget buildChild(BuildContext context) {
    return new CustomAlertDialog(
      content: new SingleChildScrollView(
        child: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: new Form(
            key: _formKey,
            autovalidateMode: _autoValidate,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/images/otp.png',
                    width: 30.0, package: 'flutter_paystack'),
                heightBox,
                new Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    fontWeight: FontWeight.w500,
                    color: context.textTheme().titleLarge?.color,
                    fontSize: 15.0,
                  ),
                ),
                heightBox,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: new OtpField(
                    onSaved: (String? value) => _otp = value,
                    borderColor: context.colorScheme().secondary,
                  ),
                ),
                heightBox,
                new AccentButton(
                  onPressed: _validateInputs,
                  text: 'Authorize',
                ),
                heightBox,
                new WhiteButton(
                  onPressed: onCancelPress,
                  text: 'Cancel',
                  flat: true,
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateInputs() {
    FocusScope.of(context).requestFocus(new FocusNode());
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      Navigator.of(context).pop(_otp);
    } else {
      setState(() {
        _autoValidate = AutovalidateMode.disabled;
      });
    }
  }
}
