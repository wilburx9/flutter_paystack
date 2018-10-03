import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/src/ui/my_colors.dart';

class BaseTextField extends TextFormField {
  BaseTextField({
    Widget suffix,
    String labelText,
    String hintText,
    List<TextInputFormatter> inputFormatters,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
    TextEditingController controller,
    String initialValue,
  }) : super(
            controller: controller,
            inputFormatters: inputFormatters,
            onSaved: onSaved,
            validator: validator,
            maxLines: 1,
            initialValue: initialValue,
            keyboardType: TextInputType.number,
            decoration: new InputDecoration(
                border: OutlineInputBorder(),
                labelText: labelText,
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
                suffixIcon: suffix == null
                    ? null
                    : new Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                        child: suffix,
                      ),
                errorStyle: const TextStyle(fontSize: 12.0),
                errorMaxLines: 3,
                isDense: true,
                enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 0.5)),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: MyColors.green, width: 1.0)),
                hintText: hintText,
                suffixStyle: TextStyle(color: Colors.green)));

  @override
  createState() {
    return super.createState();
  }
}
