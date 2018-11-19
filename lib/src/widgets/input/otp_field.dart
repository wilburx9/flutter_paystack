import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/widgets/common/my_colors.dart';

class OtpField extends TextFormField {
  OtpField({FormFieldSetter<String> onSaved})
      : super(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 25.0,
            letterSpacing: 15.0,
          ),
          autofocus: true,
          inputFormatters: [
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          maxLines: 1,
          onSaved: onSaved,
          validator: (String value) => value.isEmpty ? 'Enter OTP' : null,
          obscureText: false,
          decoration: new InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            hintText: 'OTP',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
            contentPadding: const EdgeInsets.all(10.0),
            enabledBorder: const OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: const OutlineInputBorder(
                borderSide:
                    const BorderSide(color: MyColors.lightBlue, width: 1.0)),
          ),
        );
}
