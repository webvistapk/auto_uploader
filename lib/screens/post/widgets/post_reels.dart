import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/post/reels/reels_video_player.dart';
import 'package:mobile/screens/post/widgets/add_post.dart';
import 'package:mobile/screens/post/widgets/image_videos.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class PostAndReels extends StatefulWidget {
  final UserProfile? userProfile;
  final token;
  const PostAndReels({Key? key, required this.userProfile, this.token})
      : super(key: key);

  @override
  _PostAndReelsState createState() => _PostAndReelsState();
}

class _PostAndReelsState extends State<PostAndReels>
    with TickerProviderStateMixin {
  bool _isDropdownVisible = false;
  List<AssetEntity> _reelList = [];
  bool _isLoadingReelPreview = false;
  bool _isLoadingReelMore = false;
  int _currentReelPage = 0;
  final int _pageReelSize = 100; // Fetch smaller pages for faster initial load
  AssetPathEntity? _selectedReelAlbum;
  ScrollController _scrollReelController = ScrollController();
  int? _selectedReelIndex; // Store selected index for single selection
  AnimationController? _animationReelController;
  late TabController _tabController;
  bool isPost = false;
  bool isReel = false;
  List<File> selectedReel = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchPostAlbums();
    _fetchReelAlbums();
    _scrollReelController.addListener(_scrollListener);
    _animationReelController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    isPost = true;
  }

  @override
  void dispose() {
    _scrollReelController.dispose();
    _animationReelController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchReelAlbums() async {
    _isLoadingReelPreview = true;
    setState(() {});
    if (await _requestPermissions()) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
      );

      if (albums.isNotEmpty) {
        _selectedReelAlbum = albums[0];
        await _fetchReels(_selectedReelAlbum!, _currentReelPage);
        _isLoadingReelPreview = false;
        setState(() {});
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> _fetchReels(AssetPathEntity album, int page) async {
    if (_isLoadingReelMore) return;
    setState(() {
      _isLoadingReelMore = true;
    });

    final List<AssetEntity> media =
        await album.getAssetListPaged(page: page, size: _pageReelSize);
    final List<AssetEntity> filteredReels = media
        .where((media) => media.type == AssetType.video && media.duration <= 60)
        .toList();

    setState(() {
      _reelList.addAll(filteredReels);
      _isLoadingReelMore = false;
    });
    _animationReelController?.forward(from: 0.0);
  }

  void _scrollListener() {
    if (_scrollReelController.position.pixels >=
            _scrollReelController.position.maxScrollExtent - 100 &&
        !_isLoadingReelMore) {
      _loadMoreReels();
    }
  }

  void _loadMoreReels() async {
    _currentReelPage++;
    await _fetchReels(_selectedReelAlbum!, _currentReelPage);
  }

  void _handleTabSelection() {
    setState(() {
      isPost = _tabController.index == 0;
      isReel = _tabController.index == 1;
    });
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final String minutes = duration.inMinutes.toString().padLeft(2, '0');
    final String secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
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
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.black,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isDropdownVisible)
                  Container(
                    width: size.width * .60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              Icon(Icons.camera_alt, color: Colors.blueAccent),
                          title: Text('Take Photo'),
                          onTap: _toggleDropdown,
                        ),
                        ListTile(
                          leading:
                              Icon(Icons.videocam, color: Colors.blueAccent),
                          title: Text('Record Video'),
                          onTap: _toggleDropdown,
                        ),
                      ],
                    ),
                  ),
                FloatingActionButton(
                  onPressed: _toggleDropdown,
                  child:
                      Icon(_isDropdownVisible ? Icons.close : Icons.camera_alt),
                  backgroundColor: Colors.blueAccent,
                ),
              ],
            ),
            appBar: AppBar(
              title: const Text('Content Selection'),
              actions: [
                TextButton(
                  onPressed: _tabController.index == 0
                      ? mediaFiles.isNotEmpty
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AddPostScreen(
                                            mediFiles: _tabController.index == 0
                                                ? mediaFiles
                                                : selectedReel,
                                            userProfile: widget.userProfile,
                                            type: _tabController.index == 0
                                                ? "post"
                                                : "reel",
                                          )));
                            }
                          : null
                      : selectedReel.isNotEmpty
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AddPostScreen(
                                            mediFiles: _tabController.index == 0
                                                ? mediaFiles
                                                : selectedReel,
                                            userProfile: widget.userProfile,
                                            type: _tabController.index == 0
                                                ? "post"
                                                : "reel",
                                          )));
                            }
                          : null,
                  child:
                      const Text('Next', style: TextStyle(color: Colors.blue)),
                ),
              ],
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
                  child: isPost
                      ? mediaFiles.isEmpty
                          ? Text(
                              "No Posts Selected",
                              style: AppTextStyles.poppinsBold(
                                  color: Colors.white),
                            )
                          : FileCarousel(files: mediaFiles)
                      : selectedReel.isEmpty
                          ? Text(
                              "No Reel Selected",
                              style: AppTextStyles.poppinsBold(
                                  color: Colors.white),
                            )
                          : ReelsVideoPlayer(
                              key: ValueKey(selectedReel[0]
                                  .path), // Add key to force rebuild
                              videoFile: selectedReel[0],
                            ),
                ),
                const SizedBox(height: 20),
                // Custom TabBar in the body
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    dividerColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        child: Container(
                          width: 200,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              'Posts',
                              style: AppTextStyles.poppinsSemiBold(
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          width: 200,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              'Reels',
                              style: AppTextStyles.poppinsSemiBold(
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Content for "Posts" tab
                      _isLoadingPostPreview
                          ? buildMediaContent(size, "Posts")
                          : _buildMediaListSection(context),
                      // Content for "Reels" tab
                      _isLoadingReelPreview
                          ? buildMediaContent(size, "Reels")
                          : _buildReelsGrid(),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildReelsGrid() {
    return AnimatedOpacity(
      opacity: _isLoadingPostPreview ? 0.5 : 1.0,
      duration: Duration(milliseconds: 500),
      child: GridView.builder(
        controller: _scrollReelController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemCount: _reelList.length + (_isLoadingPostMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _reelList.length) {
            return buildMediaContent(MediaQuery.of(context).size, "Reels");
          }
          final media = _reelList[index];
          return FutureBuilder<Uint8List?>(
            future: media.thumbnailData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return GestureDetector(
                  onTap: () async {
                    try {
                      final file = await media.file;

                      if (file != null) {
                        // Clear previous selection and add the new file
                        setState(() {
                          selectedReel.clear(); // Clear the previous selection
                          selectedReel.add(file); // Add the newly selected file
                          _selectedReelIndex = index; // Set the selected index
                          isReel = true; // Set view mode to "Reel"
                          isPost = false; // Disable "Post" view mode
                        });

                        log("File Path : ${selectedReel[0]}");
                      }
                    } catch (e) {
                      log("File Path : $e");
                    }
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      border: _selectedReelIndex == index
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[800],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            color: Colors.black54,
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              _formatDuration(media.duration),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        },
      ),
    );
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

    if (permissions) {
      return true;
    } else {
      final ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth) {
        await Prefrences.setMediaPermission(true);
        return true; // Permission is granted
      }

      // Special handling for Android 11 and above
      if (await Permission.storage.isDenied ||
          await Permission.photos.isDenied) {
        // Request storage and media permissions
        final result = await [
          Permission.storage,
          Permission.photos, // This handles the photo access permission
        ].request();

        if (result[Permission.storage] == PermissionStatus.granted &&
            result[Permission.photos] == PermissionStatus.granted) {
          await Prefrences.setMediaPermission(true);
          return true;
        }
      }

      // Android 11+ specific permission for managing external storage
      if (await Permission.manageExternalStorage.isDenied) {
        final result = await Permission.manageExternalStorage.request();
        if (result == PermissionStatus.granted) {
          await Prefrences.setMediaPermission(true);
          return true;
        }
      }

      await Prefrences.setMediaPermission(false);

      return false; // Permissions denied
    }
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

  Future<void> _openCamera(bool isPhoto) async {
    // Request camera permission
    PermissionStatus permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      // Check if the user wants to capture a photo or record a video
      final XFile? file = await (isPhoto
          ? _picker.pickImage(source: ImageSource.camera)
          : _picker.pickVideo(source: ImageSource.camera));

      if (file != null) {
        File data = File(file.path);
        mediaFiles.add(data);
        print('File path: ${file.path}');
        setState(() {});
      }
    } else if (permissionStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission is required')),
      );
    } else if (permissionStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

// A new widget for dropdown and media list
  Widget _buildMediaListSection(BuildContext context) {
    var size = MediaQuery.of(context).size * 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<AssetPathEntity>(
            menuMaxHeight: 400,
            dropdownColor: Colors.grey.shade800,
            isExpanded: true,
            value: _selectedPostAlbum,
            items: _albums
                .map((album) => DropdownMenuItem(
                      value: album,
                      child: Text(
                        album.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
                      ),
                    ))
                .toList(),
            onChanged: (album) {
              setState(() {
                _selectedPostAlbum = album;
                _mediaList.clear(); // Clear current media list
                _currentPostPage = 0; // Reset page count
                _fetchPostMedia(album!,
                    _currentPostPage); // Fetch media for the selected album
              });
            },
          ),
        ),
        const SizedBox(height: 16),
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
                      return Stack(
                        children: [
                          Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20)),
                            child:
                                Image.memory(snapshot.data!, fit: BoxFit.cover),
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
                            child: GestureDetector(
                              onTap: () async {
                                // Toggle selection state
                                selectedFiles[index] = !selectedFiles[index];

                                // Get the media file asynchronously
                                final file = await media.file;

                                // Start updating UI state
                                setState(() {
                                  _isLoadingPostPreview =
                                      true; // Start loading indicator
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
                              child: Icon(
                                Icons.check_box,
                                color: selectedFiles[index]
                                    ? Colors.blue
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
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
            ),
          ),
        ),
      ],
    );
  }
}
