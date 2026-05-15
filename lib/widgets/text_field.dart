import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPasswordField;
  final bool isEnabled;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final bool isNumberOnly;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool filled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? iconColor;
  final double borderRadius;
  final int? maxLines;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.isPasswordField = false,
    this.isEnabled = true,
    this.validator,
    this.prefixIcon,
    this.focusNode,
    this.isNumberOnly = false,
    this.fontSize = 16.0,
    this.padding,
    this.filled = false,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.iconColor,
    this.borderRadius = 15.0,
    this.maxLines,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
      cursorColor: Theme.of(context).colorScheme.onPrimary,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPasswordField ? _isObscured : false,
      keyboardType:
          widget.isNumberOnly ? TextInputType.number : TextInputType.text,
      inputFormatters:
          widget.isNumberOnly ? [FilteringTextInputFormatter.digitsOnly] : [],
      enabled: widget.isEnabled,
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey,
              fontSize: widget.fontSize,
            ),
        contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        filled: widget.filled,
        fillColor: widget.fillColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: widget.borderColor ??
                  const Color.fromARGB(255, 209, 209, 209)),
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? Colors.green,
            width: 2.0,
          ),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: widget.iconColor ?? Colors.grey)
            : null,
        suffixIcon: widget.isPasswordField
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: widget.iconColor ?? Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
      maxLines: widget.maxLines ?? 1,
      style: TextStyle(fontSize: widget.fontSize),
      validator: widget.validator,
    );

    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 6.0),
      child: textField,
    );
  }
}
