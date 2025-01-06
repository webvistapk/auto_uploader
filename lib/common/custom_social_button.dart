import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';

class CustomSocialButton extends StatelessWidget {
  final String textTitle;
  final onPressed;
  const CustomSocialButton(
      {super.key, required this.textTitle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 50,
        margin: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(
            textTitle,
            style: AppTextStyles.poppinsSemiBold(
                fontSize: 16, color: AppColors.grey),
          ),
        ),
      ),
    );
  }
}
