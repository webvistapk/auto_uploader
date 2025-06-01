import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class CompanyOverViewScreen extends StatelessWidget {
  const CompanyOverViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size * 1;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Overview", style: AppTextStyles.poppinsBold()),
          const SizedBox(height: 10),
          Container(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    "About",
                    style: AppTextStyles.poppinsMedium(),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                    style: AppTextStyles.poppinsRegular(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Website",
                    style: AppTextStyles.poppinsMedium(),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "www.website.com",
                    style: AppTextStyles.poppinsRegular(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Page Creation",
                    style: AppTextStyles.poppinsMedium(),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "January 17th/2024",
                    style: AppTextStyles.poppinsRegular(),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Industry",
                    style: AppTextStyles.poppinsMedium(),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Financial Services",
                    style: AppTextStyles.poppinsRegular(),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Company Size",
                    style: AppTextStyles.poppinsMedium(),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "100-250",
                    style: AppTextStyles.poppinsRegular(),
                  ),
                ],
              ),
            ),
            margin: EdgeInsets.all(1),
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            width: double.infinity,
          ),
          SizedBox(height: size.height <= 700 ? 10 : 15),
          Text(
            "Locations",
            style: AppTextStyles.poppinsMedium(),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
