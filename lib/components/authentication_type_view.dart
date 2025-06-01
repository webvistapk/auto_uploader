import 'package:flutter/material.dart';
import 'package:mobile/components/authentication_type_item.dart';

class AuthenticationTypeView extends StatelessWidget {
  const AuthenticationTypeView({
    Key? key,
    required this.onTap,
    required this.isActive,
  }) : super(key: key);

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Color(0xffdcdedc),
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AuthenticationTypeItem(
            text: 'Personal',
            isActive: !isActive,
            onTap: onTap,
          ),
          AuthenticationTypeItem(
            text: 'Company',
            isActive: isActive,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
