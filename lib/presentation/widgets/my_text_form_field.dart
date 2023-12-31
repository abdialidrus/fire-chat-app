import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyTextFormField extends StatefulWidget {
  final String hintText;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Function(String?) validator;
  final TextEditingController? controller;
  final bool autoFocus;
  const MyTextFormField({
    super.key,
    required this.hintText,
    required this.inputType,
    required this.inputAction,
    required this.validator,
    this.controller,
    required this.autoFocus,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool isPasswordField = false;
  bool hidePassword = false;

  @override
  void initState() {
    super.initState();
    isPasswordField = widget.inputType == TextInputType.visiblePassword;
    hidePassword = isPasswordField;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[400],
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword ? UniconsLine.eye_slash : UniconsLine.eye,
                ),
              )
            : null,
      ),
      textInputAction: widget.inputAction,
      obscureText: hidePassword,
      keyboardType: widget.inputType,
      validator: (value) => widget.validator(value),
      autofocus: widget.autoFocus,
    );
  }
}
