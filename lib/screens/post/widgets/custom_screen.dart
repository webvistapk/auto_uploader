import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/screens/post/component/reel_screen.dart';
import 'package:shimmer/shimmer.dart';

class PostAndReels extends StatefulWidget {
  @override
  _PostAndReelsState createState() => _PostAndReelsState();
}

class _PostAndReelsState extends State<PostAndReels>
    with SingleTickerProviderStateMixin {
  bool _isDropdownVisible = false;
  List<dynamic> mediaFiles = [];
  bool _isLoadingPreview = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                      leading: Icon(Icons.camera_alt, color: Colors.blueAccent),
                      title: Text('Take Photo'),
                      onTap: _toggleDropdown,
                    ),
                    ListTile(
                      leading: Icon(Icons.videocam, color: Colors.blueAccent),
                      title: Text('Record Video'),
                      onTap: _toggleDropdown,
                    ),
                  ],
                ),
              ),
            FloatingActionButton(
              onPressed: _toggleDropdown,
              child: Icon(_isDropdownVisible ? Icons.close : Icons.camera_alt),
              backgroundColor: Colors.blueAccent,
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            const SizedBox(height: 20),
            // Shimmer effect for the large container at the top
            Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Container(
                height: size.height * 0.4,
                width: size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Custom TabBar in the body
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
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
                children: [
                  // Content for "Posts" tab
                  buildMediaContent(size, "Posts"),
                  // Content for "Reels" tab
                  ReelsScreenData(
                    size: size,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
    });
  }

  Widget buildMediaContent(Size size, String type) {
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
}
