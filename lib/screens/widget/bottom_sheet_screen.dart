import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/controller/services/post_manager.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:provider/provider.dart';

class BottomSheetScreen extends StatefulWidget {
  final String postTitle;
  final List<int> peopleTags;
  final List<String> keywordsList;
  final String privacyPost;
  final List<File> mediaFiles;
  final PostProvider pro;
  final UserProfile userProfile;
  BottomSheetScreen(
      {super.key,
      required this.postTitle,
      required this.peopleTags,
      required this.keywordsList,
      required this.privacyPost,
      required this.mediaFiles,
      required this.pro,
      required this.userProfile});

  @override
  State<BottomSheetScreen> createState() => _BottomSheetScreenState();
}

class _BottomSheetScreenState extends State<BottomSheetScreen> {
  String? _selectedValue;
  final TextEditingController _keywordController = TextEditingController();
  List<String> hashtags = [];

  // List of options for the dropdown
  final List<String> options = ['Public', 'Private', 'Followers'];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // Select a random initial value from the options

    _selectedValue = (options..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    bool isFormFilled = true;

    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Confirmation Post",
                  style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 18),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    size: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Updated hashtag display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: hashtags
                    .map((hashtag) => Text(
                          hashtag,
                          style: AppTextStyles.poppinsRegular(),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Choose who can see your post",
                  textAlign: TextAlign.start,
                  style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _selectedValue,
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // Text(
            //   "Add Keywords to Display",
            //   style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 13),
            // ),
            // const SizedBox(height: 10),
            // TextField(
            //   controller: _keywordController,
            //   cursorColor: Colors.black,
            //   maxLines: 4,
            //   onChanged: (text) {
            //     setState(() {
            //       hashtags = extractHashtags(text);
            //     });
            //   },
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(10),
            //       borderSide: BorderSide(color: Colors.grey),
            //     ),
            //     hintText: "#Keyword",
            //     hintStyle: AppTextStyles.poppinsRegular().copyWith(color: Colors.grey),
            //     focusedBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(10),
            //       borderSide: BorderSide(color: Colors.grey),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),

            isLoading
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : GestureDetector(
                    onTap: () async {
                      if (mounted)
                        setState(() {
                          isLoading = true;
                        });
                      final keywords = removeHashFromList(widget.postTitle);
                      if (keywords.isEmpty) {
                        keywords.add('0');
                      }
                      // debugger();
                      final data = await widget.pro.createNewPost(context,
                          postTitle: widget.postTitle,
                          peopleTags: widget.peopleTags,
                          keywordsList: keywords,
                          privacyPost: "followers",
                          mediaFiles: widget.mediaFiles);
                      if (data != null) {
                        ToastNotifier.showSuccessToast(
                            context, "Post Successfully posted!");
                        // if (mounted)
                        setState(() {
                          isLoading = false;
                        });
                        final token = await Prefrences.getAuthToken();
                        Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoDialogRoute(
                                builder: (_) => MainScreen(
                                    userProfile: widget.userProfile,
                                    authToken: token),
                                context: context),
                            (route) => false);
                      } else {
                        // if (mounted)
                        setState(() {
                          isLoading = false;
                        });
                        ToastNotifier.showErrorToast(
                            context, "Something else Missing from Developer");
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isFormFilled ? Colors.red : Colors.grey,
                      ),
                      child: Center(
                        child: Text(
                          "Confirm",
                          style: AppTextStyles.poppinsMedium()
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 30),
            // GestureDetector(
            //   onTap: () => Navigator.of(context).pop(),
            //   child: Container(
            //     height: 50,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       border: Border.all(color: Color.fromARGB(255, 85, 51, 177)),
            //     ),
            //     child: Center(
            //       child: Text(
            //         "Go Back",
            //         style: AppTextStyles.poppinsMedium().copyWith(
            //           color: Color.fromARGB(255, 85, 51, 177),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ));
  }

  List<String> removeHashFromList(String text) {
    final hashtags = extractHashtags(text);
    return hashtags.map((tag) {
      // Check if the string starts with '#', and remove it if present
      return tag.startsWith('#') ? tag.substring(1) : tag;
    }).toList();
  }
}

// Function to show the Bottom Sheet

List<String> extractHashtags(String text) {
  List<String> words = text.split(' ');
  List<String> hashtags = words.where((word) => word.startsWith('#')).toList();
  return hashtags;
}
