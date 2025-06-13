import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/function/AudioController.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/screens/profile/widgets/AudioRecordingWidget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class MessageWidget extends StatefulWidget {
  final String chatId;
  final String postID;
  const MessageWidget({super.key, required this.chatId, required this.postID});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final TextEditingController _messageController = TextEditingController();
  final AudioController _audioController = AudioController();
  bool _showGallery = false;
  List<File> _files = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _temporaryErrorMessage;

  @override
  void initState() {
    super.initState();
    _audioController.init();
  }

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }

  void _toggleGallery() {
    setState(() => _showGallery = !_showGallery);
  }

  // In your _MessageWidgetState:
Future<void> _startRecording() async {
    try {
      setState(() {
        _files.removeWhere((f) => f.path.endsWith('.m4a'));
      });
      await _audioController.startRecording();
      setState(() {});
    } catch (e) {
      print('Recording error: $e');
      setState(() {});
    }
  }

  Future<void> _stopRecording() async {
    try {
      final audioFile = await _audioController.stopRecording();
      if (audioFile != null) {
        setState(() {
          _files.add(audioFile);
        });
      }
    } catch (e) {
      print('Stop recording error: $e');
    }
    setState(() {});
  }

  Future<void> _deleteRecording() async {
    if (_audioController.isPlaying) {
      await _audioController.audioPlayer.stop();
    }
    setState(() {
      _files.removeWhere((f) => f.path.endsWith('.m4a'));
    });
  }

  Future<void> _sendMessage() async {
    final String messageText = _messageController.text.trim();

    if (messageText.isEmpty && _files.isEmpty) {
      setState(
          () => _temporaryErrorMessage = "Message field must not be empty");
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) setState(() => _temporaryErrorMessage = null);
      });
      return;
    }

    try {
      final response =
          await Provider.of<PostProvider>(context, listen: false).sendChat(
        context,
        widget.chatId,
        widget.postID,
        messageText,
        files: _files, // Now handles both images and audio
      );

      if (response?.statusCode == 201) {
        _messageController.clear();
        setState(() => _files.clear());
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showGallery)
          Container(
            height: MediaQuery.of(context).size.height * 0.34,
            child: Stack(
              children: [
                CustomPinImages(
                  onImagesSelected: (images) {
                    setState(() {
                      _files.removeWhere((file) => !file.path.endsWith('.m4a'));
                      _files.addAll(images);
                    });
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _toggleGallery,
                  ),
                ),
              ],
            ),
          ),
        Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _files.isNotEmpty && _files.any((f) => f.path.endsWith('.m4a'))
                ? AudioWidget(
                    controller: _audioController,
                    audioFile: _files.firstWhere((f) => f.path.endsWith('.m4a')),
                    onDelete: _deleteRecording,
                    showRecordingUI: _audioController.isRecording,
                  )
                : Row(
                    children: [
                      if (!_audioController.isRecording) ...[
                        Image.asset(AppIcons.camera,
                            width: 33.35.sp, height: 33.34.sp),
                        SizedBox(width: 17.31.sp),
                        GestureDetector(
                          onTap: _toggleGallery,
                          child: Image.asset(AppIcons.image,
                              width: 32.83.sp, height: 32.83.sp),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: _temporaryErrorMessage ?? 'Send a message..',
                              hintStyle: TextStyle(
                                fontSize: 24.sp,
                                color: _temporaryErrorMessage != null
                                    ? Colors.red
                                    : const Color(0xff757474),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: AudioWidget(
                            controller: _audioController,
                            audioFile: null,
                            onDelete: _deleteRecording,
                            showRecordingUI: _audioController.isRecording,
                          ),
                        ),
                      GestureDetector(
                        onLongPressStart: (_) => _startRecording(),
                        onLongPressEnd: (_) => _stopRecording(),
                        child: Image.asset(
                          AppIcons.mic,
                          width: 32.sp,
                          color: _files.any((file) => file.path.endsWith('.m4a'))
                              ? Colors.green
                              : null,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _sendMessage,
          child: Container(
            width: 802.sp,
            height: 76.sp,
            decoration: BoxDecoration(
              color: const Color(0xff333232),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                "Send",
                style: TextStyle(fontSize: 24.sp, color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPinImages extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  const CustomPinImages({Key? key, required this.onImagesSelected})
      : super(key: key);

  @override
  _CustomPinImagesState createState() => _CustomPinImagesState();
}

class _CustomPinImagesState extends State<CustomPinImages> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();
  List<AssetEntity> _recentAssets = [];
  List<AssetEntity> _galleryAssets = [];
  List<AssetEntity> _otherAssets1 = [];
  List<AssetEntity> _otherAssets2 = [];
  List<AssetEntity> _otherAssets3 = [];
  bool _isLoading = true;
  List<AssetEntity> _selectedAssets = [];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      ToastNotifier.showErrorToast(context, "Permission denied");
      return;
    }

    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          orders: [OrderOption(type: OrderOptionType.createDate, asc: false)],
        ),
      );

      if (albums.isEmpty) return;

      _recentAssets = await albums[0].getAssetListRange(start: 0, end: 50);
      if (albums.length > 1)
        _galleryAssets = await albums[1].getAssetListRange(start: 0, end: 50);
      if (albums.length > 2)
        _otherAssets1 = await albums[2].getAssetListRange(start: 0, end: 50);
      if (albums.length > 3)
        _otherAssets2 = await albums[3].getAssetListRange(start: 0, end: 50);
      if (albums.length > 4)
        _otherAssets3 = await albums[4].getAssetListRange(start: 0, end: 50);

      setState(() => _isLoading = false);
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Error loading images");
    }
  }

  void _toggleAssetSelection(AssetEntity asset) async {
    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else {
        _selectedAssets.add(asset);
      }
    });

    await _sendSelectedImages();
  }

  Future<void> _sendSelectedImages() async {
    final List<File> imageFiles = [];
    for (final asset in _selectedAssets) {
      final file = await asset.file;
      if (file != null) {
        imageFiles.add(file);
      }
    }
    widget.onImagesSelected(imageFiles);
  }

  Widget _buildTabText(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: _selectedIndex == index ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<AssetEntity> assets) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: assets.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          final asset = assets[index];
          final isSelected = _selectedAssets.contains(asset);

          return GestureDetector(
            onTap: () => _toggleAssetSelection(asset),
            child: FutureBuilder<Uint8List?>(
              future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(color: Colors.grey[200]);
                }

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.memory(
                        snapshot.data!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              children: [
                _buildTabText("Recents", 0),
                SizedBox(width: 54.09.sp),
                _buildTabText("Gallery", 1),
                SizedBox(width: 54.09.sp),
                _buildTabText("Others", 2),
                SizedBox(width: 54.09.sp),
                _buildTabText("Others", 3),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        fontSize: 24.sp, color: const Color(0xFFFF0000)),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _selectedIndex = index),
                    children: [
                      _buildImageGrid(_recentAssets),
                      _buildImageGrid(_galleryAssets),
                      _buildImageGrid(_otherAssets1),
                      _buildImageGrid(_otherAssets2),
                      _buildImageGrid(_otherAssets3),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
