import 'package:flutter/material.dart';

class CustomContinueButton extends StatelessWidget {
  final String buttonText;
  final onPressed;
  final bool isPressed;
  const CustomContinueButton(
      {super.key,
      required this.buttonText,
      required this.onPressed,
      required this.isPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isPressed ? Color(0xfa35373D) : Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isPressed ? onPressed : () {},
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            color: isPressed ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
