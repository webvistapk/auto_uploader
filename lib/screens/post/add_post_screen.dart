import 'dart:convert';
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
import 'package:mobile/screens/post/new_post_now.dart';
import 'package:mobile/screens/post/pool/add_pools.dart';
import 'package:mobile/screens/post/widgets/custom_option_tile.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'component/add_location_screen.dart';
import 'component/multi_select_options.dart'; // Add video player package for video handling
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class AddPostScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final List<File> mediFiles;
  // final type;

  const AddPostScreen({
    super.key,
    required this.userProfile,
    required this.mediFiles,
    // required this.type,
  });

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

String postType = "post";

class _AddPostScreenState extends State<AddPostScreen> {
  // Store filtered items for searching
  TextEditingController titleController = TextEditingController();
  VideoPlayerController? _videoController;

  List<int> selectedTagUsers = [];

  @override
  void initState() {
    super.initState();
    context.read<PostProvider>();
    postType = "post";
    _getCurrentLocation();
    // Initialize video controller if it's a video
    if (widget.mediFiles != null && widget.mediFiles.isNotEmpty) {
      File mediaFile = widget.mediFiles[mediaFileIndex()];
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
    return 0; // Change this to widget.mediFiles.length - 1 to show the last media file
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
    List<String>? result = await showModalBottomSheet(
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

  List<String> interactionSheetOptions = ["Comments"];

  void showInteractionsSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => MultiSelectBottomSheet(
        initialSelectedOptions: interactionSheetOptions,
        finalOptions: [
          {'label': 'Comments', 'value': 'comments', 'count': ''},
          {'label': 'Polls', 'value': 'polls', 'count': ''},
        ],
      ),
    );

    if (result != null) {
      log("Selected Options: $result");
      setState(() {
        interactionSheetOptions = result;
      });
    }
  }

  void showPostTypeSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => SingleSelectOptionsSheet(
        initialValues: [postType],
        finalValueList: [
          {'label': 'Post', 'value': 'post', 'count': '5000 posts'},
          {
            'label': 'Discourse',
            'value': 'discourse',
            'count': '5000 discourse'
          },
          {'label': 'Reel', 'value': 'reel', 'count': '1200 reels'},
        ],
        titile: "Settings",
      ),
    );

    if (result != null) {
      log("Selected Options: $result");
      setState(() {
        postType = result[0].toLowerCase();
      });
    }
  }

  List<String> dmRepliesOptions = ["public"];
  List<String> dmCommentOptions = ["public"];

  void showDmRepliesSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => MultiSelectBottomSheet(
        initialSelectedOptions: dmRepliesOptions,
        finalOptions: [
          {
            'label': 'Friends Only',
            'value': 'friends',
            'count': 'only people you followback message'
          },
          {
            'label': 'Anyone',
            'value': 'public',
            'count': 'Anyone can direct message'
          },
          {'label': 'Off', 'value': 'off', 'count': ''},
        ],
      ),
    );

    if (result != null) {
      log("Selected Options: $result");
      setState(() {
        dmRepliesOptions = result;
      });
    }
  }

  void showDmCommentsSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => MultiSelectBottomSheet(
        initialSelectedOptions: dmCommentOptions,
        finalOptions: [
          {
            'label': 'Friends Only',
            'value': 'friends',
            'count': 'only people you followback message'
          },
          {
            'label': 'Anyone',
            'value': 'public',
            'count': 'Anyone can direct message'
          },
          {'label': 'Off', 'value': 'off', 'count': ''},
        ],
      ),
    );

    if (result != null) {
      log("Selected Options: $result");
      setState(() {
        dmCommentOptions = result;
      });
    }
  }

  bool isLoading = false;
  String _location = "Fetching location...";

  Future<void> _getCurrentLocation() async {
    setState(() {
      _location = "Fetching location...";
    });
    try {
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled == false) {
        setState(() {
          _location = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Location permissions are permanently denied.";
        });
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _getAddressFromLatLng(position.latitude, position.longitude);
      // setState(() {
      //   _location =
      //       "Lat: ${position.latitude}, Lon: ${position.longitude}"; // Format as needed
      // });
    } catch (e) {
      setState(() {
        _location = "Error fetching location: $e";
      });
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Location Data: $data');
        String address = data['address']['city'] +
            ',' +
            data['address']['state'] +
            ',' +
            data['address']['country'];
        print("Address: $address");
        setState(() {
          _location = address;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _selectNewLocation() async {
    // Navigate to a location picker (use a package or implement Google Maps)
    // For simplicity, simulate new location selection
    String selectedLocation = "New Location: Lat 25.0, Lon 55.0";
    setState(() {
      _location = selectedLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    var pro = context.watch<PostProvider>();
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          foregroundColor: Color(0xfaF6F7F7),
          backgroundColor: Color(0xfaF6F7F7),
          leading: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Color(0xfa2B2B2B),
            ),
          ),
          // leadingWidth: 100,
        ),
        body: Stack(
          children: [
            Container(
              color: Color(0xfaF6F7F7),
            ),
            SingleChildScrollView(
              child: Container(
                color: Color(0xfaF6F7F7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(),
                            Text(
                              postType == 'reel' ? 'Reel Posting...' : "Post",
                              style: AppTextStyles.poppinsBold(),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(),
                          ]),
                    ),
                    Divider(),
                    widget.mediFiles == null || widget.mediFiles.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextField(
                              controller: titleController,
                              cursorColor: Colors.red,
                              textInputAction: TextInputAction.done,
                              maxLines: 5,
                              style: AppTextStyles.poppinsRegular(fontSize: 25),
                              decoration: InputDecoration(
                                hintText: 'Start Typing for Post...',
                                hintStyle:
                                    AppTextStyles.poppinsRegular().copyWith(
                                  color: Colors.black45,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        :
                        // postType == 'reel'
                        //     ? Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Container(
                        //             height: 250,
                        //             width: 300,
                        //             child: _buildMediaWidget(),
                        //           ),
                        //         ],
                        //       )
                        //     :
                        Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 150,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: Colors.grey[300],
                                  ),
                                  child: _buildMediaWidget(),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: TextField(
                                      controller: titleController,
                                      cursorColor: Colors.red,
                                      textInputAction: TextInputAction.done,
                                      style: AppTextStyles.poppinsRegular()
                                          .copyWith(
                                        color: Color(0xfa807E7E),
                                        fontSize: 13,
                                      ),
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        hintMaxLines: 4,
                                        hintText: postType == "post"
                                            ? "Describe your post here, add hashtags, mention or anything else that compels you."
                                            : "Describe your reel here, add hashtags, mention or anything else that compels you.",
                                        hintStyle:
                                            AppTextStyles.poppinsRegular()
                                                .copyWith(
                                          color: Color(0xfa807E7E),
                                          fontSize: 13,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Divider(color: Color(0xffD3D3D3)),
                    CustomOptionTile(
                      iconPath: "assets/icons/location.png",
                      title: "Add Location",
                      onTap: () => navigateToAddLocationScreen(context),
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/tag.png",
                      title: "Tag People",
                      onTap: () => _showTagPeopleBottomSheet(context),
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/privacy.png",
                      title: "Privacy",
                      onTap: () => _showPrivacyBottomSheet(context),
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/interaction.png",
                      title: "Interactions",
                      onTap: () => showInteractionsSheet(context),
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/collaborator.png",
                      title: "Add collaborators",
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/audience.png",
                      title: "Audience",
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/dm_replies.png",
                      title: "Direct Replies",
                      onTap: () => showDmRepliesSheet(context),
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/dm_comment.png",
                      title: "Direct Comments",
                      onTap: () => showDmCommentsSheet(context),
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/engagement.png",
                      title: "Engagement",
                    ),
                    CustomOptionTile(
                      iconPath: "assets/icons/setting.png",
                      title: "Advanced Settings",
                      onTap: () => showPostTypeSheet(context),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                child: const Center(
                  child: SpinKitCircle(
                    color: Colors.blue,
                    size: 60.0,
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Container(
            height: 110,
            child: Column(
              children: [
                GestureDetector(
                  onTap: isLoading
                      ? () {}
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          print(titleController.text);
                          final keywords =
                              removeHashFromList(titleController.text);

                          if (keywords.isEmpty) {
                            keywords.add('0');
                          }

                          log("Medias: ${widget.mediFiles}");
                          log("Keywords: $keywords");
                          log("Tag User id: $selectedTagUsers");
                          log("Privacy Policy: $privacyPolicy");
                          log("Post Type: $postType");
                          log("Interactions: $interactionSheetOptions");

                          if (interactionSheetOptions.contains('polls') &&
                              widget.mediFiles.isNotEmpty) {
                            if (titleController.text.isEmpty) {
                              setState(() {
                                isLoading = false;
                              });
                              //ToastNotifier.showErrorToast(
                              // context, "Post  is required!");
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.push(
                                  context,
                                  CupertinoDialogRoute(
                                      builder: (_) => NewPostNow(
                                            postField:
                                                titleController.text.trim(),
                                            peopleTags: selectedTagUsers,
                                            keywordsList: keywords,
                                            privacyPost: privacyPolicy,
                                            mediaFiles: widget.mediFiles,
                                            interactions:
                                                interactionSheetOptions,
                                            dmReplies: dmRepliesOptions,
                                            dmComments: dmRepliesOptions,
                                            userProfile: widget.userProfile!,
                                            isPoll: true,
                                            location: _location,
                                          ),
                                      context: context));
                            }
                          } else if (widget.mediFiles.isEmpty &&
                              interactionSheetOptions.contains('Polls')) {
                            if (titleController.text.isEmpty) {
                              setState(() {
                                isLoading = false;
                              });
                              //ToastNotifier.showErrorToast(
                              // context, "Post Title / Descritption is required!");
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.push(
                                  context,
                                  CupertinoDialogRoute(
                                      builder: (_) => AddPollScreen(
                                            postField:
                                                titleController.text.trim(),
                                            selectedTagUsers: selectedTagUsers,
                                            keywordList: keywords,
                                            privacyPolicy: privacyPolicy,
                                            mediaFiles: widget.mediFiles,
                                            userProfile: widget.userProfile!,
                                            interactions:
                                                interactionSheetOptions,
                                            dmReplies: dmRepliesOptions,
                                            dmComments: dmRepliesOptions,
                                            location: _location,
                                          ),
                                      context: context));
                            }
                          } else if (widget.mediFiles.isNotEmpty &&
                              interactionSheetOptions.contains('Polls') ==
                                  false) {
                            if (titleController.text.isEmpty) {
                              setState(() {
                                isLoading = false;
                              });
                              ToastNotifier.showErrorToast(
                                  context, "Describe your post please!");
                            } else {
                              if (postType == 'reel') {
                                final response = await pro.createNewReel(
                                    context,
                                    postField: titleController.text.trim(),
                                    peopleTags: selectedTagUsers,
                                    keywordsList: keywords,
                                    privacyPost: privacyPolicy,
                                    mediaFiles: widget.mediFiles,
                                    description: titleController.text.trim());

                                if (response != null) {
                                  //ToastNotifier.showSuccessToast(
                                  // context, "Reel Successfully posted!");
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
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.push(
                                    context,
                                    CupertinoDialogRoute(
                                        builder: (_) => NewPostNow(
                                              postField:
                                                  titleController.text.trim(),
                                              peopleTags: selectedTagUsers,
                                              keywordsList: keywords,
                                              privacyPost: privacyPolicy,
                                              mediaFiles: widget.mediFiles,
                                              interactions:
                                                  interactionSheetOptions,
                                              userProfile: widget.userProfile!,
                                              isPoll: false,
                                              location: _location,
                                              dmReplies: dmRepliesOptions,
                                              dmComments: dmRepliesOptions,
                                            ),
                                        context: context));
                              }
                            }
                          } else if (widget.mediFiles.isEmpty &&
                              interactionSheetOptions.contains('Polls') ==
                                  false) {
                            if (titleController.text.isEmpty) {
                              setState(() {
                                isLoading = false;
                              });

                              //ToastNotifier.showErrorToast(
                              // context, "Post Title / Descritption is required!");
                            } else {
                              final response = await pro.createNewPost(context,
                                  postField: titleController.text.trim(),
                                  peopleTags: selectedTagUsers,
                                  keywordsList: keywords,
                                  privacyPost: privacyPolicy,
                                  mediaFiles: widget.mediFiles,
                                  interactions: interactionSheetOptions,
                                  dmReplies: dmRepliesOptions,
                                  dmComments: dmRepliesOptions,
                                  location: _location);

                              if (response != null) {
                                //ToastNotifier.showSuccessToast(
                                // context, "Post Successfully posted!");
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
                                // context, "Network Problem. Try again.");
                              }
                            }
                          }
                        },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            interactionSheetOptions.contains('Polls')
                                ? Icons.next_plan_outlined
                                : Icons.arrow_upward,
                            size: 20,
                            color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          interactionSheetOptions
                                      .any((element) => element == 'Polls') &&
                                  postType == 'post'
                              ? "Next"
                              : "Post",
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
                        color: isLoading ? Colors.grey : Color(0xfa161616)),
                  ),
                ),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      "Save to Draft",
                      style: TextStyle(
                          color: Color(0xfa161616),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(BuildContext context, Widget icon, String title) {
    return InkWell(
      onTap: () {
        // Navigate or open option page
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            icon,
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void navigateToAddLocationScreen(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque:
          false, // so the previous screen can be slightly visible (optional)
      pageBuilder: (context, animation, secondaryAnimation) =>
          AddLocationPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // start from bottom
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ));
  }

// Widget to build media display (either image or video)
  Widget _buildMediaWidget() {
    if (widget.mediFiles == null || widget.mediFiles.isEmpty) {
      return Center(child: Text("No media"));
    }

    File mediaFile = widget.mediFiles[mediaFileIndex()];
    final borderRadius = BorderRadius.circular(20);

    if (isVideo(mediaFile)) {
      // Display video
      return Stack(
        alignment: Alignment.center,
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            ClipRRect(
              borderRadius: borderRadius,
              child: AspectRatio(
                aspectRatio: 1,
                child: VideoPlayer(_videoController!),
              ),
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
                    Icons.play_arrow,
                    size: 60,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.pause,
                    size: 60,
                    color: Colors.white,
                  ),
          ),
        ],
      );
    } else {
      // Display image
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(mediaFile, fit: BoxFit.cover),
      );
    }
  }

  // Widget _buildMediaWidget() {
  //   if (widget.mediFiles == null || widget.mediFiles.isEmpty) {
  //     return Center(child: Text("No media"));
  //   }

  //   File mediaFile = widget.mediFiles[mediaFileIndex()];
  //   if (isVideo(mediaFile)) {
  //     // Display video
  //     return Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         if (_videoController != null && _videoController!.value.isInitialized)
  //           AspectRatio(
  //             aspectRatio: 1,
  //             child: VideoPlayer(_videoController!),
  //           )
  //         else
  //           Center(child: CircularProgressIndicator()),
  //         GestureDetector(
  //           onTap: () {
  //             if (_videoController!.value.isPlaying) {
  //               _videoController!.pause();
  //             } else {
  //               _videoController!.play();
  //             }
  //             setState(() {
  //               // Toggle play/pause state
  //             });
  //           },
  //           child: !_videoController!.value.isPlaying
  //               ? Icon(
  //                   Icons.play_arrow,
  //                   size: 60,
  //                   color: Colors.white,
  //                 )
  //               : Icon(
  //                   Icons.pause,
  //                   size: 60,
  //                   color: Colors.white,
  //                 ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     // Display image
  //     return Image.file(mediaFile, fit: BoxFit.cover);
  //   }
  // }

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
