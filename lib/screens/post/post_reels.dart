import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/post/reels/reels_video_player.dart';
import 'package:mobile/screens/post/add_post_screen.dart';
import 'package:mobile/screens/post/widgets/discard_post.dart';
import 'package:mobile/screens/post/widgets/image_videos.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class PostAndReels extends StatefulWidget {
  final UserProfile? userProfile;
  final token;
  PostAndReels({
    Key? key,
    required this.userProfile,
    this.token,
  }) : super(key: key);

  @override
  _PostAndReelsState createState() => _PostAndReelsState();
}

class _PostAndReelsState extends State<PostAndReels>
    with TickerProviderStateMixin {
  bool _isDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchPostAlbums();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final String minutes = duration.inMinutes.toString().padLeft(2, '0');
    final String secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _showDiscardDialog(BuildContext context) async {
    bool? discard = await showDialog<bool>(
      context: context,
      builder: (context) => const DiscardPostDialog(),
    );

    if (discard == true) {
      // User pressed Yes, discard the post
      print('Discarding post');
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoDialogRoute(
              builder: (_) => MainScreen(
                    userProfile: widget.userProfile!,
                    authToken: widget.token,
                    selectedIndex: 0,
                  ),
              context: context),
          (_) => false);
    } else {
      // User pressed No or dismissed dialog
      print('Keep editing post');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          // var token = await Prefrences.getAuthToken();
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoDialogRoute(
                  builder: (_) => MainScreen(
                      userProfile: widget.userProfile!,
                      authToken: widget.token),
                  context: context),
              (route) => false);
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              '(overlap)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
            elevation: 0.5,
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              // Animated content for tabs
              AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (widget, animation) => SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(1.0, 0.0),
                          end: Offset(0.0, 0.0),
                        ).animate(animation),
                        child: widget,
                      ),
                  child: mediaFiles.isEmpty
                      ? Text(
                          "No Posts Selected",
                          style: AppTextStyles.poppinsBold(color: Colors.white),
                        )
                      : FileCarousel(files: mediaFiles)),
              //const SizedBox(height: 20),
              // Custom TabBar in the body

              Expanded(
                child:
                    // Content for "Posts" tab
                    _isLoadingPostPreview
                        ? buildMediaContent(size, "Posts")
                        : _buildMediaListSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
    });
  }

  /////////////     Post Section /////////////////

  Widget buildMediaContent(Size size, String type) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 12, // Example shimmer placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      ),
    );
  }

  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _mediaList = [];
  AssetEntity? _selectedMedia;
  AssetPathEntity? _selectedPostAlbum;
  File? _selectedFile;
  // VideoPlayerController? _videoPlayerController;
  bool _isLoadingPostPreview = false; // Track loading state for preview
  bool _isLoadingPostMore = false; // To handle loading more assets
  int _currentPostPage = 0; // For pagination
  final int _pagePostSize = 100; // Fetch 100 items at a time
  List<File> mediaFiles = [];
  List<bool> selectedFiles = [];

  // Fetch albums and initial media

  Future<void> _fetchPostAlbums() async {
    _isLoadingPostPreview = true;
    setState(() {});

    // Handle permission based on Android version
    if (await _requestPermissions()) {
      // If permission granted
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        hasAll: true,
      );

      if (albums.isNotEmpty) {
        _selectedPostAlbum = albums[0];
        _albums = albums;
        await _fetchPostMedia(_selectedPostAlbum!,
            _currentPostPage); // Fetch media for the first album

        // Automatically select the first media item
        if (_mediaList.isNotEmpty) {
          final file = await _mediaList[0].file;
          _selectedMedia = _mediaList[0];
          _selectedFile = file;
          // mediaFiles.add(_selectedFile!);

          final checker = List.filled(_mediaList.length, false);
          selectedFiles.addAll(checker);
          // selectedFiles[0] = true;
          _isLoadingPostPreview = false;
        }
      }
      setState(() {});
    } else {
      // If permissions are denied, open settings to manually grant permissions
      PhotoManager.openSetting();
    }
  }

// Function to request appropriate permissions for Android 11 and above

  Future<bool> _requestPermissions() async {
    bool permissions = await Prefrences.getMediaPermission();
    // debugger();
    if (permissions) {
      return true;
    } else {
      String version = await getAndroidVersion() ?? "";
      // final PermissionState state = await PhotoManager.getPermissionState(
      //     requestOption: const PermissionRequestOption(
      //   androidPermission:
      //       AndroidPermission(type: RequestType.common, mediaLocation: true),
      // ));
      // if (state == PermissionState.authorized) {
      //   print('The application has full access permission');
      // } else {
      //   print('The application does not have full access permission');
      // }
      // For Android 13+ (API level 33+), request specific media permissions
      if (Platform.isAndroid && int.parse(version) >= 13) {
        final result = await [
          Permission.photos,
          Permission.videos,
          // Permission.audio,
        ].request();

        if (result[Permission.photos] == PermissionStatus.granted ||
                result[Permission.videos] == PermissionStatus.granted
            // ||
            // result[Permission.audio] == PermissionStatus.granted
            ) {
          await Prefrences.setMediaPermission(true);
          return true;
        }
      }

      // For Android 11 and 12 (API level 30 and 31), request manageExternalStorage
      if (Platform.isAndroid && int.parse(version) >= 11) {
        final result = await Permission.manageExternalStorage.request();
        if (result == PermissionStatus.granted) {
          await Prefrences.setMediaPermission(true);
          return true;
        }
      }

      // For Android 10 and below (API level < 30), request storage permission only
      if (Platform.isAndroid && int.parse(version) < 11) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          await Prefrences.setMediaPermission(true);
          return true;
        }
      }

      // If all checks fail, permissions are denied
      await Prefrences.setMediaPermission(false);
      return false;
    }
  }

// Helper function to get Android version
  Future<String?> getAndroidVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release; // e.g., "11", "12"
    }
    return null;
  }

  // Fetch media for a selected album with pagination
  Future<void> _fetchPostMedia(AssetPathEntity album, int page) async {
    if (_isLoadingPostMore) return; // Avoid duplicate loads
    _isLoadingPostMore = true;
    final List<AssetEntity> media =
        await album.getAssetListPaged(page: page, size: _pagePostSize);
    List<bool> boolean = List.filled(_pagePostSize, false);
    setState(() {
      _mediaList.addAll(media);

      selectedFiles.addAll(boolean); // Append new media to the list
      _isLoadingPostMore = false;
      // selectedFiles
      //     .addAll(List.filled(_mediaList.length + selectedFiles.length, false));
    });
  }

  // Load more assets when reaching the end of the grid
  void _loadMorePostAssets() async {
    if (!_isLoadingPostMore) {
      _currentPostPage++;
      await _fetchPostMedia(_selectedPostAlbum!, _currentPostPage);
    }
  }

  // Widget to build media preview

  final ImagePicker _picker = ImagePicker();
  // bool _isDropdownVisible = false;

  Widget _buildMediaListSection(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(
      children: [
        // Filter row with dropdown and buttons
        _buildFilterRow(),

        const SizedBox(height: 8),

        // Grid thumbnails with spacing and rounded corners + circle background behind check icon
        Expanded(
          flex: 2,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                _loadMorePostAssets(); // Load more assets when scrolled to the bottom
              }
              return false;
            },
            child: GridView.builder(
  itemCount: _mediaList.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemBuilder: (context, index) {
    final media = _mediaList[index];

    return FutureBuilder<Uint8List?>(
      future: media.thumbnailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return GestureDetector(
            onTap: () async {  // Moved the onTap to the whole container
              // Toggle selection state
              selectedFiles[index] = !selectedFiles[index];

              // Get the media file asynchronously
              final file = await media.file;

              // Start updating UI state
              setState(() {
                _isLoadingPostPreview = true; // Start loading indicator
              });

              if (selectedFiles[index]) {
                // If selected, add the file to mediaFiles
                if (file != null) {
                  mediaFiles.add(file);
                }
              } else {
                // If deselected, remove the file from mediaFiles
                if (file != null) {
                  mediaFiles.removeWhere(
                      (element) => element.path == file.path);
                }
              }

              // Stop loading indicator
              setState(() {
                _isLoadingPostPreview = false;
              });
            },
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20)),
                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                ),
                if (media.type == AssetType.video)
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(Icons.play_circle_fill,
                        color: Colors.white),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selectedFiles[index]
                          ? Colors.blue
                          : Colors.transparent,
                      border: Border.all(
                        color: selectedFiles[index]
                            ? Colors.blue
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: selectedFiles[index]
                        ? Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
    );
  },
)
         
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Container(
      height: 60,
      width: double.infinity,
      margin: EdgeInsets.all(0),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _showDiscardDialog(context),
            icon: Icon(
              Icons.cancel,
              size: 20,
              color: Color.fromRGBO(68, 68, 68, 1),
            ),
          ),
          Container(
            width: 60, // This will constrain the total width
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Makes the row take minimum space
              children: [
                Expanded(
                  child: DropdownButton<AssetPathEntity>(
                    menuMaxHeight: 400,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    value: _selectedPostAlbum,
                    iconEnabledColor: Colors.black,
                    underline: SizedBox.shrink(),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    items: _albums
                        .map((album) => DropdownMenuItem(
                              value: album,
                              child: Text(
                                album.name,
                                style: TextStyle(
                                  fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                overflow:
                                    TextOverflow.ellipsis, // Handle long text
                              ),
                            ))
                        .toList(),
                    onChanged: (album) {
                      setState(() {
                        _selectedPostAlbum = album;
                        _mediaList.clear();
                        _currentPostPage = 0;
                        _fetchPostMedia(album!, _currentPostPage);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: mediaFiles.isNotEmpty
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddPostScreen(
                                  mediFiles: mediaFiles,
                                  userProfile: widget.userProfile,
                                  // type: "post",
                                )));
                  }
                : null,
            child: Text('Next',
                style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: Color.fromRGBO(21, 68, 160, 1),
                )),
          ),
        ],
      ),
    );
  }
}
