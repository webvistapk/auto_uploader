import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/post/widgets/add_post_screen.dart';

class CreatePostScreen extends StatefulWidget {
  UserProfile? userProfile;
  CreatePostScreen({super.key, this.userProfile});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(AppUtils.testImage),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userProfile!.firstName! +
                                ' ' +
                                widget.userProfile!.lastName!,
                            style: AppTextStyles.poppinsBold()
                                .copyWith(fontSize: 20),
                          ),
                          // SizedBox(height: 5),
                          // Container(
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Icon(
                          //         Icons.people,
                          //         color: const Color.fromARGB(255, 10, 126, 222),
                          //         size: 18,
                          //       ),
                          //       SizedBox(width: 5),
                          //       Text(
                          //         'Friends',
                          //         style: AppTextStyles.poppinsRegular().copyWith(
                          //             color:
                          //                 const Color.fromARGB(255, 10, 126, 222)),
                          //       ),
                          //       SizedBox(width: 5),
                          //       Icon(
                          //         Icons.arrow_drop_down,
                          //         color: const Color.fromARGB(255, 10, 126, 222),
                          //         size: 25,
                          //       ),
                          //     ],
                          //   ),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(5),
                          //     color: Color.fromARGB(82, 118, 184, 228),
                          //   ),
                          //   width: 150,
                          //   height: 29,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Share Your Story with the World!",
                  style: AppTextStyles.poppinsBold(color: AppColors.red),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Express yourself, inspire others, and make your voice heard. Start by creating a post that reflects your thoughts, ideas, or experiences!",
                  style: AppTextStyles.poppinsRegular(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    margin: EdgeInsets.all(20),
                    child: Image.asset('assets/createPost.gif')),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                CupertinoDialogRoute(
                                    builder: (_) => AddPostScreen(),
                                    context: context));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Create Post',
                              style: AppTextStyles.poppinsMedium(
                                  color: AppColors.whiteColor)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
