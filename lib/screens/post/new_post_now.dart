import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:provider/provider.dart';

class NewPostNow extends StatefulWidget {
  final String postField; // Title of the post
  final List<int> peopleTags; // List of tagged users
  final List<String> keywordsList; // List of keywords
  final String privacyPost; // Privacy policy (e.g., Public, Private)
  final List<File> mediaFiles; // List of media files
  final List<String> interactions; // Interaction options
  final UserProfile userProfile;
  const NewPostNow({
    super.key,
    required this.postField,
    required this.peopleTags,
    required this.keywordsList,
    required this.privacyPost,
    required this.mediaFiles,
    required this.interactions,
    required this.userProfile,
  });
  @override
  _NewPostNowState createState() => _NewPostNowState();
}

class _NewPostNowState extends State<NewPostNow> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PostProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Builder(builder: (context) {
        var pro = context.watch<PostProvider>();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Post Title',
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Post Title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Post Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Post Description is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Logic to handle post submission
                      setState(() {
                        isLoading = true;
                      });
                      final title = _titleController.text.trim();
                      final description = _descriptionController.text.trim();

                      print("Post Title: $title");
                      print("Post Description: $description");

                      final response = await pro.createNewPost(context,
                          postField: widget.postField,
                          peopleTags: widget.peopleTags,
                          keywordsList: widget.keywordsList,
                          privacyPost: widget.privacyPost,
                          mediaFiles: widget.mediaFiles,
                          postTitle: title,
                          postDescription: description,
                          interactions: widget.interactions);

                      if (response != null) {
                        ToastNotifier.showSuccessToast(
                            context, "Post Successfully posted!");
                        setState(() {
                          isLoading = false;
                        });
                        _titleController.clear();
                        _descriptionController.clear();
                        final token = await Prefrences.getAuthToken();
                        Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoDialogRoute(
                                builder: (_) => MainScreen(
                                    userProfile: widget.userProfile!,
                                    authToken: token),
                                context: context),
                            (route) => false);
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        ToastNotifier.showErrorToast(
                            context, "Network Problem. Try again.");
                      }
                      // Clear fields after submission

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Post submitted successfully!')),
                      );
                    }

                    // Handle button press logic here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets
                        .zero, // Remove default padding for custom styling
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red, // Default color for the button
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: isLoading
                          ? [
                              CircularProgressIndicator.adaptive(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ]
                          : [
                              Icon(
                                Icons
                                    .arrow_upward, // Default icon for the button
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Post Now", // Default text for the button
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
  // else if (widget.type == "post") {
                    //   if (titleController.text.isEmpty) {
                    //     setState(() {
                    //       isLoading = false;
                    //     });
                    //     ToastNotifier.showErrorToast(
                    //         context, "Post Title / Descritption is required!");
                    //   } else {
                    //     final response = await pro.createNewPost(context,
                    //         postTitle: titleController.text.trim(),
                    //         peopleTags: selectedTagUsers,
                    //         keywordsList: keywords,
                    //         privacyPost: privacyPolicy,
                    //         mediaFiles: widget.mediFiles!,
                    //         interactions: interactionSheetOptions);

                    //     if (response != null) {
                    //       ToastNotifier.showSuccessToast(
                    //           context, "Post Successfully posted!");
                    //       setState(() {
                    //         isLoading = false;
                    //       });
                    //       final token = await Prefrences.getAuthToken();
                    //       Navigator.pushAndRemoveUntil(
                    //           context,
                    //           CupertinoDialogRoute(
                    //               builder: (_) => MainScreen(
                    //                   userProfile: widget.userProfile!,
                    //                   authToken: token),
                    //               context: context),
                    //           (route) => false);
                    //     } else {
                    //       setState(() {
                    //         isLoading = false;
                    //       });
                    //       ToastNotifier.showErrorToast(
                    //           context, "Network Problem. Try again.");
                    //     }
                    //   }
                    // } 
