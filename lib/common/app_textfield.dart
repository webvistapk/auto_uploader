import 'package:flutter/material.dart';

class CustomAppTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool enabled;
  final int maxLines;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final EdgeInsets contentPadding;

  const CustomAppTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.enabled = true,
    this.maxLines = 1,
    this.hintText = "",
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 15,
      horizontal: 10,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              enabled: enabled,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: hintText,
              hintStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              contentPadding: contentPadding,
              suffixIcon: suffixIcon,
            ),
            maxLines: maxLines,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
