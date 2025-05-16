import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/profile/widgets/MessageWidget.dart';

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

           
            MessageWidget(chatId: "",),
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
  int _selectedIndex = 0; // Track selected tab
  PageController _pageController = PageController();

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
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabText("Recents", 0),
                 SizedBox(width: 54.09.sp,),
                _buildTabText("Other", 1),
                SizedBox(width: 60.34.sp,),
                _buildTabText("Other", 2),
                SizedBox(width: 51.66.sp,),
                _buildTabText("Other", 3),
                SizedBox(width: 60.34.sp,),
                _buildTabText("Other", 4),
                SizedBox(width: 50.sp,),
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",style: TextStyle(
                    fontSize: 24.sp,
                    color: Color(0xffFF0000)
                  ),),
                )
              ],
            ),
          ),

          // Content with swipe support
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                _buildImageGrid(), // Recents
                _buildOtherTab(),
                _buildOtherTab(),
                _buildOtherTab(),
                _buildOtherTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build navigation text buttons
  Widget _buildTabText(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
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

  // Image Grid for Recents tab
  Widget _buildImageGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: 6, // Example image count
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  AppUtils.userImage, // Replace with actual image URL
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.check_box_outline_blank, color: Colors.white, size: 35.46.sp),
              ),
            ],
          );
        },
      ),
    );
  }

  // Placeholder for Other Tabs
  Widget _buildOtherTab() {
    return Center(
      child: Text(
        "Other",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}


