import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/common/app_text_styles.dart';

class CustomPasswordScreen extends StatefulWidget {
  final onPressed;
  final controller;
  bool obsecure;
  String title;
  CustomPasswordScreen(
      {super.key,
      required this.onPressed,
      required this.controller,
      required this.obsecure,
      required this.title});

  @override
  State<CustomPasswordScreen> createState() => _CustomPasswordScreenState();
}

class _CustomPasswordScreenState extends State<CustomPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        Text(widget.title, style: AppTextStyles.poppinsBold()),
        const SizedBox(
          height: 50,
        ),
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter the password";
            }
            return null;
          },
          controller: widget.controller,
          decoration: AppStyles.inputDecoration.copyWith(
            labelText: 'Password',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  widget.obsecure = !(widget.obsecure);
                });
              },
              child: Icon(
                widget.obsecure ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
          obscureText: !widget.obsecure,
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Next',
                    style: AppTextStyles.poppinsMedium(
                        color: AppColors.whiteColor)),
              ),
            ),
          ],
        )
      ],
    );
  }
}
