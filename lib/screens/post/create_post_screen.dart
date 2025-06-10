import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/post/view/upload_from_gallery.dart';

class CreatePostScreen extends StatefulWidget {
  UserProfile? userProfile;
  final token;
  final bool isChatCamera;
  CreatePostScreen({
    super.key,
    this.userProfile,
    this.token,
    required this.isChatCamera,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return
        // ReelsScreenData();
        UploadFromGallery(
      userProfile: widget.userProfile,
      token: widget.token,
      isChatCamera: widget.isChatCamera,
    );
    // AddPostScreen(userProfile: widget.userProfile, mediFiles: []);
    //     ContentSelectionScreen(
    //   userProfile: widget.userProfile,
    //   token: widget.token,
    // );
  }
}
