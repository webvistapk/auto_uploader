import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_size.dart';

import '../../../common/app_colors.dart';

class profile_info extends StatefulWidget {
  const profile_info({super.key});

  @override
  State<profile_info> createState() => _profile_infoState();
}
String message="Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before the final";
int experienceLength=3;
int educationLength=1;
class _profile_infoState extends State<profile_info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              //About Container
              aboutContainer(),

              //Experience Container
              experienceContainer(),

              //Education Container
              educationContainer()
            ],
          ),
        ),
      ),
    );
  }



//About Container
  Widget aboutContainer() {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: paragraph*0.35,vertical: paragraph*0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(
                color: AppColors.greyColor, fontSize: paragraph * 0.65),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.lightGrey,
                      blurRadius: 2,
                      offset: Offset(1, 4),
                      spreadRadius: 1
                  )
                ]),
            child: Text(
              message,
              style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: paragraph * 0.35,
                  fontWeight: FontWeight.normal),
            ),
          )
        ],
      ),
    );
  }

  // Experience Container
  Widget experienceContainer() {
    return Container(
      width: double.infinity, // Full width
      padding: EdgeInsets.symmetric(horizontal: paragraph * 0.35, vertical: paragraph * 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Experience",
            style: TextStyle(color: AppColors.greyColor, fontSize: paragraph * 0.65),
          ),
          SizedBox(height: 10),
          Container(
            //padding: EdgeInsets.symmetric(horizontal: paragraph * 0.35),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightGrey,
                  blurRadius: 2,
                  offset: Offset(1, 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: experienceLength,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: paragraph*0.35),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric( horizontal: paragraph*0.35),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: paragraph * 0.75,
                            backgroundImage: AssetImage("assets/tellus.webp"),
                          ),
                          const SizedBox(width: 40),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Flutter Developer",
                                  style: TextStyle(color: AppColors.greyColor, fontSize: paragraph * 0.50),
                                ),
                                Text(
                                  "Web Vista",
                                  style: TextStyle(color: AppColors.darkGrey, fontSize: paragraph * 0.40),
                                ),
                                Text(
                                  "12 Jan 2024 - 2 Oct 2024",
                                  style: TextStyle(color: AppColors.lightGrey, fontSize: paragraph * 0.35),
                                ),
                                Text(
                                  "Karachi, Sindh",
                                  style: TextStyle(color: AppColors.darkGrey, fontSize: paragraph * 0.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    if (index != experienceLength- 1)
                      Divider(
                        color: AppColors.lightGrey, // Customize your divider color
                        thickness: 1,
                        height: 2,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


// Education Container
  Widget educationContainer() {
    return Container(
      width: double.infinity, // Full width
      padding: EdgeInsets.symmetric(horizontal: paragraph * 0.35, vertical: paragraph * 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Experience",
            style: TextStyle(color: AppColors.greyColor, fontSize: paragraph * 0.65),
          ),
          SizedBox(height: 10),
          Container(
            //padding: EdgeInsets.symmetric(horizontal: paragraph * 0.35),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightGrey,
                  blurRadius: 2,
                  offset: Offset(1, 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: 1,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: paragraph*0.35),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric( horizontal: paragraph*0.35),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: paragraph * 0.75,
                            backgroundImage: AssetImage("assets/tellus.webp"),
                          ),
                          const SizedBox(width: 40),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "QUEST Nawabshah",
                                  style: TextStyle(color: AppColors.greyColor, fontSize: paragraph * 0.50),
                                ),
                                Text(
                                  "BSc Information Technology",
                                  style: TextStyle(color: AppColors.darkGrey, fontSize: paragraph * 0.40),
                                ),
                                Text(
                                  "5 Sept 2019 - 2 Oct 2023",
                                  style: TextStyle(color: AppColors.lightGrey, fontSize: paragraph * 0.35),
                                ),
                                Text(
                                  "CGPA 3.65%",
                                  style: TextStyle(color: AppColors.darkGrey, fontSize: paragraph * 0.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}


