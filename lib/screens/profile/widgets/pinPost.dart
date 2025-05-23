import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/profile/widgets/MessageWidget.dart';
import 'package:photo_manager/photo_manager.dart';

void showPinPostSheet(BuildContext context) {
  TabController? _tabController;
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) {
       
      return Padding(
       padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16,
            right: 16,
            top: 16,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
              mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 43.3.sp,
              height: 2,
                      color: Color(0xff989898),
            ),
            Container(
      height: MediaQuery.of(context).size.height * 0.34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: CustomPinImages()
    ),

           
            MessageWidget(chatId: "", postID: "",),
           SizedBox(height: 10,)
          ],
        ),
      );
    },
  );
}


class CustomPinImages extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    // Request permission
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      return;
    }

    // Load assets with corrected filter options
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          // This will order by create date descending (newest first)
          OrderOption(
            type: OrderOptionType.createDate,
            asc: false,
          ),
        ],
      ),
    );

    if (albums.isEmpty) return;

    // Get recent images
    _recentAssets = await albums[0].getAssetListRange(start: 0, end: 50);
    
    // Get other albums if available
    if (albums.length > 1) {
      _galleryAssets = await albums[1].getAssetListRange(start: 0, end: 50);
    }
    if (albums.length > 2) {
      _otherAssets1 = await albums[2].getAssetListRange(start: 0, end: 50);
    }
    if (albums.length > 3) {
      _otherAssets2 = await albums[3].getAssetListRange(start: 0, end: 50);
    }
    if (albums.length > 4) {
      _otherAssets3 = await albums[4].getAssetListRange(start: 0, end: 50);
    }

    setState(() {
      _isLoading = false;
    });
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
          // Navigation Text Buttons
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              children: [
                _buildTabText("Recents", 0),
                SizedBox(width: 54.09.sp),
                _buildTabText("Gallery", 1),
                SizedBox(width: 60.34.sp),
                _buildTabText("Other", 2),
                SizedBox(width: 51.66.sp),
                _buildTabText("Other", 3),
                SizedBox(width: 60.34.sp),
                _buildTabText("Other", 4),
                SizedBox(width: 50.sp),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Color(0xffFF0000),
                    ),
                  ),
                )
              ],
            ),
          ),

          // Content with swipe support
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
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

  Widget _buildTabText(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
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
          return FutureBuilder<Uint8List?>(
            future: assets[index].thumbnailDataWithSize(
              ThumbnailSize(200, 200), // Specify thumbnail size here
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
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
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Icon(
                        Icons.check_box_outline_blank,
                        color: Colors.white,
                        size: 35.46,
                      ),
                    ),
                  ],
                );
              }
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
              );
            },
          );
        },
      ),
    );
  }
}


