import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class ReelsScreenData extends StatefulWidget {
  // final size;
  const ReelsScreenData({
    Key? key,
    // required this.size,
  }) : super(key: key);
  @override
  _ReelsScreenDataState createState() => _ReelsScreenDataState();
}

class _ReelsScreenDataState extends State<ReelsScreenData> {
  List<AssetEntity> _reelList = [];
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 100; // Fetch smaller pages for faster initial load
  AssetPathEntity? _selectedAlbum;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
    _scrollController.addListener(_scrollListener); // Set up pagination
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlbums() async {
    if (await _requestPermissions()) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
      );

      if (albums.isNotEmpty) {
        _selectedAlbum = albums[0];
        await _fetchReels(_selectedAlbum!, _currentPage);
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<bool> _requestPermissions() async {
    final ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  Future<void> _fetchReels(AssetPathEntity album, int page) async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

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

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore) {
      _loadMoreReels();
    }
  }

  void _loadMoreReels() async {
    _currentPage++;
    await _fetchReels(_selectedAlbum!, _currentPage);
  }

  Widget _buildReelsGrid() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _reelList.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _reelList.length) {
          return _buildShimmerEffect(); // Show shimmer effect while loading more items
        }

        final media = _reelList[index];
        return FutureBuilder<Uint8List?>(
          future: media.thumbnailData, // Get a fast thumbnail
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerEffect();
            }
            if (snapshot.hasData && snapshot.data != null) {
              return _buildReelThumbnail(media, snapshot.data!);
            } else {
              return SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildShimmerEffect(
      // Size size,
      ) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 18, // Example shimmer placeholders
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

  Widget _buildReelThumbnail(AssetEntity media, thumbnailFile) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Image.memory(
          thumbnailFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          color: Colors.black54,
          padding: EdgeInsets.all(4.0),
          child: Text(
            _formatDuration(media.duration),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final String minutes = duration.inMinutes.toString().padLeft(2, '0');
    final String secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return _reelList.isNotEmpty ? _buildReelsGrid() : _buildShimmerEffect();
  }
}
