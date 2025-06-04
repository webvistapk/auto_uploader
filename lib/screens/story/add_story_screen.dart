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
import 'package:mobile/screens/post/component/single_select_options.dart';
import 'package:mobile/screens/post/component/tag_option_sheet.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/post/widgets/image_videos.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // Add video player package for video handling

class AddStoryScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final List<File>? mediFiles;

  const AddStoryScreen({
    super.key,
    required this.userProfile,
    required this.mediFiles,
  });

  @override
  _AddStoryScreenState createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  // Store filtered items for searching
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

  List<String> privacyPolicy = ["public"];

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
    List<String> result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => SingleSelectOptionsSheet(
          initialValues: privacyPolicy,
          finalValueList: [
            {
              'label': 'Followers',
              'value': 'followers',
              'count': '${widget.userProfile?.followers_count} people'
            },
            {'label': 'Public', 'value': 'public', 'count': 'Every people'},
            {
              'label': 'Following',
              'value': 'following',
              'count': '${widget.userProfile?.following_count} people'
            },
          ]),
    );

    if (result != null) {
      setState(() {
        privacyPolicy = result; // Update the parent state with the new value
      });
    }

    print('Updated Policy : $privacyPolicy');
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
            "Story Sharing",
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
                  FileCarousel(files: widget.mediFiles!),
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

                    log("Medias: ${widget.mediFiles}");
                    log("Tag User id: $selectedTagUsers");
                    log("Privacy Policy: $privacyPolicy");
                    {
                      final response = await pro.createNewStory(context,
                          peopleTags: selectedTagUsers,
                          privacyPost: privacyPolicy,
                          mediaFiles: widget.mediFiles!);

                      if (response != null) {
                        //ToastNotifier.showSuccessToast(
                        // context, "Story Successfully Shared!");
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
                        //ToastNotifier.showErrorToast(
                        // context, "Something went wrong. Try again.");
                      }
                    }
                  },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, size: 20, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    "Share now",
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
}
