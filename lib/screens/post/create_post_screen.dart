import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/post/component/content_selection_screen.dart';
import 'package:mobile/screens/post/widgets/add_post.dart';
import 'package:mobile/screens/post/widgets/add_post_screen.dart';
import 'package:mobile/screens/post/widgets/custom_screen.dart';

class CreatePostScreen extends StatefulWidget {
  UserProfile? userProfile;
  final token;
  CreatePostScreen({super.key, this.userProfile, this.token});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  void initState() {
    super.initState();
    // Delay the navigation to allow the initial build process to complete
    Future.delayed(Duration.zero, () {
      navigateToScreen(context);
    });
  }

  void navigateToScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => PostAndReels()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(), // Display a loader or placeholder
    );
    // AddPostScreen(userProfile: widget.userProfile, mediFiles: []);
    //     ContentSelectionScreen(
    //   userProfile: widget.userProfile,
    //   token: widget.token,
    // );
  }
}
