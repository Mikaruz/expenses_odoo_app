import 'package:flutter/material.dart';
import 'package:oh_expenses_app/config/config.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? errorText;
  final bool isPassword;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final IconData? icon;

  const CustomTextField({
    super.key,
    required this.label,
    this.onChanged,
    this.onFieldSubmitted,
    this.errorText,
    this.isPassword = false,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.icon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword ? _obscureText : false,
      onChanged: widget.onChanged,
      onSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        label: widget.icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: mutedInkColor),
                  const SizedBox(width: 6),
                  Text(widget.label),
                ],
              )
            : Text(widget.label),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: mutedInkColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: mainColor, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dangerColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dangerColor, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        errorText: widget.errorText,
        filled: true,
        fillColor: receiptColor,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: mutedInkColor,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              )
            : null,
      ),
    );
  }
}
