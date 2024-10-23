import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/post/component/privacy_option_sheet.dart';
import 'package:mobile/screens/post/component/tag_option_sheet.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // Add video player package for video handling

class AddPostScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final List<File>? mediFiles;
  const AddPostScreen(
      {super.key, required this.userProfile, required this.mediFiles});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  // Store filtered items for searching
  TextEditingController titleController = TextEditingController();
  VideoPlayerController? _videoController;

  List<int> selectedTagUsers = [];

  @override
  void initState() {
    super.initState();
    context.read<PostProvider>();
    // Initialize video controller if it's a video
    if (widget.mediFiles != null && widget.mediFiles!.isNotEmpty) {
      File mediaFile = widget.mediFiles![mediaFileIndex()];
      if (isVideo(mediaFile)) {
        _videoController = VideoPlayerController.file(mediaFile)
          ..initialize().then((_) {
            setState(() {}); // Update the UI when the video is ready
          });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    _videoController?.dispose(); // Dispose of the video controller
    super.dispose();
  }

  // Method to determine if a file is a video
  bool isVideo(File file) {
    return file.path.endsWith('.mp4') || file.path.endsWith('.mov');
  }

  // Choose to show the first or last media file
  int mediaFileIndex() {
    return 0; // Change this to widget.mediFiles!.length - 1 to show the last media file
  }

  String privacyPolicy = "public";

  void _showTagPeopleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TagBottomSheet(
          selectedTagUser: selectedTagUsers,
        );
      },
    );
  }

  void _showPrivacyBottomSheet(BuildContext context) async {
    // Example current privacy value
    final updatedPrivacy = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => PrivacyOptionsSheet(privacyPolicy: privacyPolicy),
    );

    if (updatedPrivacy != null) {
      print('Updated privacy: $updatedPrivacy');
      privacyPolicy = updatedPrivacy;
      setState(() {}); // You can use the updated privacy here
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var pro = context.watch<PostProvider>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
          ),
          centerTitle: true,
          title: Text(
            "Post",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[300],
                          ),
                          child:
                              _buildMediaWidget(), // Replace with media preview (image or video)
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: titleController,
                                  cursorColor: Colors.red,
                                  textInputAction: TextInputAction.done,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintMaxLines: 4,
                                    hintText:
                                        "Describe your post here, add hashtags, mention or anything else that compels you.",
                                    hintStyle:
                                        AppTextStyles.poppinsRegular().copyWith(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Color(0xffD3D3D3)),
                  ListTile(
                    leading: Icon(Icons.location_on_rounded, size: 25),
                    title: Text(
                      "Location",
                      style:
                          AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.grey, size: 17),
                  ),
                  ListTile(
                    onTap: () {
                      _showTagPeopleBottomSheet(context);
                    },
                    leading: Icon(Icons.people_outline_outlined, size: 25),
                    title: Text(
                      "Tags People",
                      style:
                          AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.grey, size: 17),
                  ),
                  ListTile(
                    onTap: () {
                      _showPrivacyBottomSheet(context);
                    },
                    leading: Icon(Icons.public_outlined, size: 25),
                    title: Text(
                      "Privacy",
                      style:
                          AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.grey, size: 17),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: Icon(Icons.bubble_chart_outlined, size: 25),
                    title: Text(
                      "Interactions",
                      style:
                          AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.grey.shade300, size: 17),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // Show loading spinner when isLoading is true
            if (isLoading)
              Container(
                // color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: SpinKitCircle(
                    color: Colors.blue,
                    size: 60.0,
                  ),
                ),
              )
            else
              SizedBox()
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: GestureDetector(
            onTap: isLoading
                ? () {}
                : () async {
                    setState(() {
                      isLoading = true;
                    });

                    print(titleController.text);
                    final keywords = removeHashFromList(titleController.text);

                    if (keywords.isEmpty) {
                      keywords.add('0');
                    }
                    log("Medias: ${widget.mediFiles}");
                    log("Keywords: $keywords");
                    log("Tag User id: $selectedTagUsers");
                    log("Privacy Policy: $privacyPolicy");

                    final response = await pro.createNewPost(context,
                        postTitle: titleController.text.trim(),
                        peopleTags: selectedTagUsers,
                        keywordsList: keywords,
                        privacyPost: privacyPolicy,
                        mediaFiles: widget.mediFiles!);

                    if (response != null) {
                      ToastNotifier.showSuccessToast(
                          context, "Post Successfully posted!");
                      setState(() {
                        isLoading = false;
                      });
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
                          context, "Something went wrong. Try again.");
                    }
                  },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, size: 20, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    "Post",
                    style: AppTextStyles.poppinsMedium().copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isLoading ? Colors.grey : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

// Widget to build media display (either image or video)
  Widget _buildMediaWidget() {
    if (widget.mediFiles == null || widget.mediFiles!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(child: Text("No media")),
      );
    }

    File mediaFile = widget.mediFiles![mediaFileIndex()];
    if (isVideo(mediaFile)) {
      // Display video
      return Stack(
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            AspectRatio(
              aspectRatio: 1,
              child: VideoPlayer(_videoController!),
            )
          else
            Center(child: CircularProgressIndicator()),
          GestureDetector(
            onTap: () {
              if (_videoController!.value.isPlaying) {
                _videoController!.pause();
              } else {
                _videoController!.play();
              }
              setState(() {
                // Toggle play/pause state
              });
            },
            child: !_videoController!.value.isPlaying
                ? Icon(
                    Icons.play_circle_outline,
                    size: 60,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.play_disabled,
                    size: 60,
                    color: Colors.white,
                  ),
          ),
        ],
      );
    } else {
      // Display image
      return Image.file(mediaFile, fit: BoxFit.cover);
    }
  }

// Function to extract hashtags and remove the '#' symbol from each
  List<String> removeHashFromList(String text) {
    // Extract hashtags from the text
    final hashtags = extractHashtags(text);

    // Remove '#' from each hashtag
    return hashtags.map((tag) {
      return tag.startsWith('#') ? tag.substring(1) : tag;
    }).toList();
  }

// Function to extract hashtags from the text
  List<String> extractHashtags(String text) {
    // Split the text into words and filter those that start with '#'
    List<String> words = text.split(' ');
    List<String> hashtags =
        words.where((word) => word.startsWith('#')).toList();
    return hashtags;
  }
}

// Function to show the Bottom Sheet



