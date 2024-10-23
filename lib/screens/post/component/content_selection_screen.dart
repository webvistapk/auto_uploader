import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/post/widgets/add_post.dart';
import 'package:mobile/screens/post/widgets/image_videos.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package

class ContentSelectionScreen extends StatefulWidget {
  final UserProfile? userProfile;
  const ContentSelectionScreen({Key? key, required this.userProfile})
      : super(key: key);

  @override
  State<ContentSelectionScreen> createState() => _ContentSelectionScreenState();
}

class _ContentSelectionScreenState extends State<ContentSelectionScreen> {
  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _mediaList = [];
  AssetEntity? _selectedMedia;
  AssetPathEntity? _selectedAlbum;
  File? _selectedFile;
  VideoPlayerController? _videoPlayerController;
  bool _isLoadingPreview = false; // Track loading state for preview
  bool _isLoadingMore = false; // To handle loading more assets
  int _currentPage = 0; // For pagination
  final int _pageSize = 100; // Fetch 100 items at a time
  List<File> mediaFiles = [];
  List<bool> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  // Fetch albums and initial media
  Future<void> _fetchAlbums() async {
    _isLoadingPreview = true;
    setState(() {});
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        hasAll: true,
      );

      if (albums.isNotEmpty) {
        _selectedAlbum = albums[0];
        _albums = albums;
        await _fetchMedia(
            _selectedAlbum!, _currentPage); // Fetch media for the first album
        // Automatically select the first media item
        if (_mediaList.isNotEmpty) {
          final file = await _mediaList[0].file;
          _selectedMedia = _mediaList[0];
          _selectedFile = file;
          mediaFiles.add(_selectedFile!);
          final checker = List.filled(_mediaList.length, false);
          selectedFiles.addAll(checker);
          selectedFiles[0] = true;
          _isLoadingPreview = false;
        }
      }

      setState(() {});
    } else {
      PhotoManager.openSetting();
    }
  }

  // Fetch media for a selected album with pagination
  Future<void> _fetchMedia(AssetPathEntity album, int page) async {
    if (_isLoadingMore) return; // Avoid duplicate loads
    _isLoadingMore = true;
    final List<AssetEntity> media =
        await album.getAssetListPaged(page: page, size: _pageSize);
    List<bool> boolean = List.filled(_pageSize, false);
    setState(() {
      _mediaList.addAll(media);

      selectedFiles.addAll(boolean); // Append new media to the list
      _isLoadingMore = false;
      // selectedFiles
      //     .addAll(List.filled(_mediaList.length + selectedFiles.length, false));
    });
  }

  // Load more assets when reaching the end of the grid
  void _loadMoreAssets() async {
    if (!_isLoadingMore) {
      _currentPage++;
      await _fetchMedia(_selectedAlbum!, _currentPage);
    }
  }

  // Widget to build media preview
  Widget _buildMediaPreview(media, selectFile, isloading) {
    if (isloading) {
      // Show shimmer effect while loading
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 200, // Fixed height for preview
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    if (media == null) {
      return const Center(child: Text('Select an image or video'));
    }

    if (media!.type == AssetType.image) {
      return Container(
        height: 300, // Fixed height for image preview
        width: double.infinity,
        child: Image.file(
          File(selectFile!.path),
          fit: BoxFit.cover,
        ),
      );
    } else if (media!.type == AssetType.video) {
      // Only initialize the video controller if it's not already done
      if (_videoPlayerController == null) {
        _videoPlayerController =
            VideoPlayerController.file(File(selectFile!.path))
              ..initialize().then((_) {
                setState(() {}); // Rebuild to show video
                _videoPlayerController!.play();
              }).catchError((error) {
                print("Video playback error: $error");
              });
      }

      return Container(
        height: 300,
        width: double.infinity,
        child: AspectRatio(
            aspectRatio: 1, child: VideoPlayer(_videoPlayerController!)),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Selection'),
        actions: [
          TextButton(
            onPressed: mediaFiles.isNotEmpty
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddPostScreen(
                                mediFiles: mediaFiles,
                                userProfile: widget.userProfile)));
                  }
                : null,
            child: const Text('Next', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 30),
            _isLoadingPreview
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      color: Colors.white,
                    ),
                  )
                : mediaFiles.isEmpty
                    ? Text(
                        "No Files Selected",
                        style: AppTextStyles.poppinsBold(color: Colors.white),
                      )
                    : FileCarousel(files: mediaFiles),
            // _buildMediaPreview(
            //     _selectedMedia, _selectedFile, _isLoadingPreview),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<AssetPathEntity>(
                menuMaxHeight: 400,
                dropdownColor: Colors.grey.shade800,
                isExpanded: true,
                value: _selectedAlbum,
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
                    _selectedAlbum = album;
                    _mediaList.clear(); // Clear current media list
                    _currentPage = 0; // Reset page count
                    _fetchMedia(album!,
                        _currentPage); // Fetch media for the selected album
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
                    _loadMoreAssets(); // Load more assets when scrolled to the bottom
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
                                child: Image.memory(snapshot.data!,
                                    fit: BoxFit.cover),
                              ),
                              if (media.type == AssetType.video)
                                const Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Icon(Icons.play_circle_fill,
                                      color: Colors.white),
                                ),
                              Positioned(
                                // Moved GestureDetector outside the Positioned
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () async {
                                    selectedFiles[index] =
                                        !selectedFiles[index];

                                    setState(() {});
                                    final file = await media.file;
                                    if (selectedFiles[index]) {
                                      setState(() {
                                        _isLoadingPreview = true;
                                      });
                                      // Get the media file
                                      setState(() {
                                        _selectedMedia = media;
                                        _selectedFile = file;
                                        if (_selectedMedia!.type ==
                                            AssetType.video) {
                                          _videoPlayerController?.dispose();
                                          _videoPlayerController = null;
                                        }
                                        mediaFiles.add(
                                            file!); // Add the file to the list
                                        _isLoadingPreview = false;
                                      });
                                      log("MediaFiles added: $mediaFiles");
                                    } else {
                                      setState(() {
                                        _isLoadingPreview = true;
                                      });

                                      // Handle file removal from mediaFiles
                                      if (_selectedMedia != null) {
                                        // Check if _selectedMedia is not null
                                        if (_selectedMedia!.type ==
                                            AssetType.video) {
                                          _videoPlayerController?.dispose();
                                          _videoPlayerController = null;
                                        }
                                        // Remove the file from mediaFiles based on the media reference
                                        mediaFiles.removeWhere((element) =>
                                            element.path == file!.path);

                                        // Reset selected media and file
                                        _selectedMedia = null;
                                        _selectedFile = null;
                                      }

                                      setState(() {
                                        _isLoadingPreview = false;
                                      });

                                      log("MediaFiles removed: $mediaFiles");
                                    }
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
        ),
      ),
    );
  }
}
