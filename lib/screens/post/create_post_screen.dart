import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/post/component/content_selection_screen.dart';
import 'package:mobile/screens/post/component/reel_screen.dart';
import 'package:mobile/screens/post/post_reels.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';

class CreatePostScreen extends StatefulWidget {
  UserProfile? userProfile;
  final token;
  CreatePostScreen({super.key, this.userProfile, this.token});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return
        // ReelsScreenData();
        PostAndReels(
      userProfile: widget.userProfile,
      token: widget.token,
    );
    // AddPostScreen(userProfile: widget.userProfile, mediFiles: []);
    //     ContentSelectionScreen(
    //   userProfile: widget.userProfile,
    //   token: widget.token,
    // );
  }
}
