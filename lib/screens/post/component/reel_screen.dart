import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  List<AssetEntity> _mediaList = [];
  List<AssetEntity> _reelList = [];
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 100;

  AssetPathEntity? _selectedAlbum;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    if (await _requestPermissions()) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
      );

      if (albums.isNotEmpty) {
        _selectedAlbum = albums[0];
        // _albums = albums;
        await _fetchReels(
            _selectedAlbum!, _currentPage); // Fetch reels from the first album
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<bool> _requestPermissions() async {
    final ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  // Fetch videos for reels based on 60 seconds duration or less
  Future<void> _fetchReels(AssetPathEntity album, int page) async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    final List<AssetEntity> media =
        await album.getAssetListPaged(page: page, size: _pageSize);
    final List<AssetEntity> filteredReels = media
        .where((media) => media.type == AssetType.video && media.duration <= 60)
        .toList();

    setState(() {
      _reelList.addAll(filteredReels);
      _isLoadingMore = false;
    });
  }

  // Load more reels when reaching the end of the list
  void _loadMoreReels() async {
    if (!_isLoadingMore) {
      _currentPage++;
      await _fetchReels(_selectedAlbum!, _currentPage);
    }
  }

  // Build reels list view
  Widget _buildReelsList() {
    return ListView.builder(
      itemCount: _reelList.length,
      itemBuilder: (context, index) {
        final media = _reelList[index];
        return FutureBuilder<File?>(
          future: media.file,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasData && snapshot.data != null) {
              return _buildReelPreview(snapshot.data!);
            } else {
              return SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildReelPreview(File videoFile) {
    VideoPlayerController videoController =
        VideoPlayerController.file(videoFile)
          ..initialize().then((_) {
            setState(() {}); // Update to show video preview
          });

    return Container(
      height: 300,
      child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: VideoPlayer(videoController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _reelList.isNotEmpty
        ? _buildReelsList()
        : Center(child: Text("No reels found"));
  }
}
