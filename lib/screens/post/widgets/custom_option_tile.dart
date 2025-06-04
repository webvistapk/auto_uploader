import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class CustomOptionTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const CustomOptionTile({
    Key? key,
    required this.iconPath,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Image.asset(iconPath, height: 30),
          title: Text(
            title,
            style: AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              color: Color(0xfa2B2B2B), size: 18),
        ),
        const Divider(color: Color(0xffD3D3D3)),
      ],
    );
  }
}
