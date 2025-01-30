import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final maxLength;
  final validator;
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return maxLength != null
        ? TextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator != null
                ? validator
                : (val) {
                    if (val!.isEmpty) {
                      return "Please enter $hintText";
                    }
                    return null;
                  },
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            maxLength: maxLength,
          )
        : TextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator != null
                ? validator
                : (val) {
                    if (val!.isEmpty) {
                      return "Please fill the field";
                    }
                    return null;
                  },
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          );
  }
}
