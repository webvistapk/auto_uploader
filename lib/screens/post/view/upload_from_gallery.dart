import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:photo_manager/photo_manager.dart';

class UploadFromGallery extends StatefulWidget {
  @override
  _UploadFromGalleryState createState() => _UploadFromGalleryState();
}

class _UploadFromGalleryState extends State<UploadFromGallery> {
  final ImagePicker _picker = ImagePicker();
  List<AssetEntity> _recentMedia = [];
  List<AssetEntity> _filteredMedia = [];
  List<File> _selectedFiles = [];
  File? _previewFile;
  String _selectedOption = 'Upload';

  @override
  void initState() {
    super.initState();
    _loadRecentMedia();
  }

  Future<void> _loadRecentMedia() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (!state.hasAccess) return;

    final RequestType filterType = _selectedOption == 'Images'
        ? RequestType.image
        : _selectedOption == 'Videos'
            ? RequestType.video
            : RequestType.common;

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: filterType,
    );

    if (albums.isNotEmpty) {
      final recent = await albums.first.getAssetListRange(start: 0, end: 50);
      setState(() {
        _recentMedia = recent;
        _filteredMedia = recent;
      });
    }
  }

  Future<void> _selectFromGallery() async {
    final List<XFile>? files = await _picker.pickMultiImage();
    if (files != null) {
      setState(() {
        _selectedFiles = files.map((xfile) => File(xfile.path)).toList();
        if (_selectedFiles.isNotEmpty) {
          _previewFile = _selectedFiles.last;
        }
      });
    }
  }

  Future<void> _filterMedia() async {
    setState(() {
      if (_selectedOption == 'Images') {
        _filteredMedia = _recentMedia
            .where((asset) => asset.type == AssetType.image)
            .toList();
      } else if (_selectedOption == 'Videos') {
        _filteredMedia = _recentMedia
            .where((asset) => asset.type == AssetType.video)
            .toList();
      } else {
        _filteredMedia = List.from(_recentMedia);
      }
    });

    // Clear selections if they're no longer in filtered list
    final filesToRemove = <File>[];
    for (final file in _selectedFiles) {
      bool exists = false;
      for (final asset in _filteredMedia) {
        final f = await asset.file;
        if (f?.path == file.path) {
          exists = true;
          break;
        }
      }
      if (!exists) filesToRemove.add(file);
    }

    if (filesToRemove.isNotEmpty) {
      setState(() {
        _selectedFiles.removeWhere((file) => filesToRemove.contains(file));
        if (_selectedFiles.isEmpty) {
          _previewFile = null;
        } else if (!_selectedFiles.contains(_previewFile)) {
          _previewFile = _selectedFiles.last;
        }
      });
    }
  }

  Future<void> _handleMediaSelection(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;

    setState(() {
      if (_selectedFiles.any((f) => f.path == file.path)) {
        _selectedFiles.removeWhere((f) => f.path == file.path);
      } else {
        _selectedFiles.add(file);
      }

      if (_selectedFiles.isNotEmpty) {
        _previewFile = _selectedFiles.last;
      } else {
        _previewFile = null;
      }
    });
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.sp),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2.sp,
        mainAxisSpacing: 2.sp,
      ),
      itemCount: _filteredMedia.length,
      itemBuilder: (context, index) {
        final asset = _filteredMedia[index];
        return GestureDetector(
          onTap: () => _handleMediaSelection(asset),
          child: FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(color: Colors.grey[200]);
              }
              return _buildGridItem(asset, snapshot.data!);
            },
          ),
        );
      },
    );
  }

  Widget _buildGridItem(AssetEntity asset, Uint8List thumbnail) {
    final isSelected =
        _selectedFiles.any((f) => f.path.endsWith(asset.title ?? ""));

    return GestureDetector(
      onTap: () => _handleMediaSelection(asset), // Whole container responds
      behavior: HitTestBehavior
          .translucent, // Ensures even empty space registers taps
      child: Container(
        decoration: BoxDecoration(
          border:
              isSelected ? Border.all(color: Colors.blue, width: 2.sp) : null,
        ),
        child: GestureDetector(
          onTap: () => _handleMediaSelection(asset),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(thumbnail, fit: BoxFit.cover),

              if (asset.type == AssetType.video)
                Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white.withOpacity(0.8),
                    size: 24.sp,
                  ),
                ),

              // Checkmark in top-right corner
              Positioned(
                top: 4.sp,
                right: 4.sp,
                child: IgnorePointer(
                  // This prevents the icon container from blocking taps
                  child: Container(
                    width: 20.sp,
                    height: 20.sp,
                    padding: EdgeInsets.all(2.sp),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 1.sp),
                      borderRadius: BorderRadius.circular(4.sp),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Left Cancel Icon (no left padding)
          Padding(
            padding: EdgeInsets.only(left: 0), // No left space
            child: IconButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: Icon(
                Icons.close,
                size: 20.sp,
                color: Color(0xFF444444),
              ),
            ),
          ),

          // Center Dropdown (tight spacing between text and icon)
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedOption,
              icon: Padding(
                padding: EdgeInsets.only(
                    left: 2.sp), // Reduce spacing between text and icon
                child: Icon(Icons.arrow_drop_down, size: 20.sp),
              ),
              isDense: true, // Makes the layout more compact
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              items: ['Upload', 'Images', 'Videos'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue!;
                  _filterMedia();
                });
              },
            ),
          ),

          Text(
            "Next",
            style:
                TextStyle(fontSize: 12, color: Color.fromRGBO(21, 68, 160, 1)),
          )
        ],
      ),
    );
  }

  Future<Widget> _buildPreview() async {
    if (_previewFile == null) {
      return Container(); // Empty container since background is already black
    }

    try {
      final isVideo = _previewFile!.path.endsWith('.mp4') ||
          _previewFile!.path.endsWith('.mov');

      AssetEntity? matchingAsset;
      try {
        matchingAsset = _filteredMedia.firstWhere(
          (a) => a.title == _previewFile!.path.split('/').last,
        );
      } catch (_) {
        matchingAsset = await _findAssetByPath(_previewFile!.path);
      }

      if (matchingAsset == null) {
        return Center(
          child: Text(
            'Preview not available',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      final thumbnail = await matchingAsset.thumbnailDataWithSize(
        const ThumbnailSize(500, 500),
      );

      if (thumbnail == null) {
        return Center(
          child: Text(
            'Error loading thumbnail',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return Stack(
        children: [
          // Black background container
          Container(color: Colors.black),

          // Media content with rounded top corners
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: 8.sp), // Add small top padding
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.sp),
                  topRight: Radius.circular(12.sp),
                ),
                child: Center(
                  child: Image.memory(
                    thumbnail,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Video play icon
          if (isVideo)
            Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 50.sp,
              ),
            ),

          // Navigation arrows
          Positioned(
            left: 16.sp,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white.withOpacity(0.7),
                size: 30.sp,
              ),
            ),
          ),
          Positioned(
            right: 16.sp,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 30.sp,
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Center(
        child: Text(
          'Error loading preview',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Future<AssetEntity?> _findAssetByPath(String path) async {
    for (final asset in _filteredMedia) {
      final file = await asset.file;
      if (file?.path == path) {
        return asset;
      }
    }
    return null;
  }

  Widget _buildPreviewArea() {
    return Container(
      color: Colors.black,
      child: FutureBuilder<Widget>(
        future: _buildPreview(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return snapshot.data ??
              Center(
                child: Text(
                  'Select media to preview',
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '(overlap)',
          style: TextStyle(
            fontSize: 18.sp,
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
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPreviewArea(),
                ),
                _buildFilterRow(),
                Expanded(
                  flex: 3,
                  child: _buildMediaGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
