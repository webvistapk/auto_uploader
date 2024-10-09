import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _textController = TextEditingController();
  int _selectedIndex = 0;
  // final ImagePicker _picker = ImagePicker(); // For selecting media

  Future<void> _pickImage() async {
    // final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   // Handle image selection
    // }
  }

  Future<void> _pickVideo() async {
    // final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   // Handle video selection
    // }
  }

  Future<void> _openCamera() async {
    // final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    // if (pickedFile != null) {
    //   // Handle camera capture
    // }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_sharp, size: 30),
                  SizedBox(width: 15),
                  Text(
                    "Create post",
                    style:
                        AppTextStyles.poppinsRegular().copyWith(fontSize: 19),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Handle post submission
                    },
                    child: Container(
                      width: size.width * 0.19,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color(0xffD3D3D3),
                      ),
                      child: Center(
                        child: Text(
                          "POST",
                          style: AppTextStyles.poppinsMedium()
                              .copyWith(fontSize: 17, color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        "https://wallpaper.dog/large/20486428.jpg"),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ahsan Khan",
                        style:
                            AppTextStyles.poppinsBold().copyWith(fontSize: 20),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: size.width * 0.33,
                        height: 29,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromARGB(82, 118, 184, 228),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people,
                              color: Color.fromARGB(255, 10, 126, 222),
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Friends',
                              style: AppTextStyles.poppinsRegular().copyWith(
                                  color: Color.fromARGB(255, 10, 126, 222)),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Color.fromARGB(255, 10, 126, 222),
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20, left: 15),
              child: TextField(
                controller: _textController,
                cursorHeight: 40,
                cursorColor: const Color.fromARGB(255, 10, 126, 222),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintText: "What's on your mind?",
                  hintStyle: AppTextStyles.poppinsRegular()
                      .copyWith(fontSize: 23, color: Colors.grey),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null, // Allows for a long text
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle text formatting (if needed)
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.grey, blurRadius: 6)
                        ],
                        gradient: LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.purple,
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Aa",
                          style: AppTextStyles.poppinsBold(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              _pickImage(); // Handle adding photo/video
            } else if (index == 1) {
              // Handle tagging people (implementation can vary)
            } else if (index == 2) {
              _openCamera(); // Handle opening camera
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_album_outlined,
              color: Colors.green,
              size: 30,
            ),
            label: 'Photo/video',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.blueAccent,
              size: 30,
            ),
            label: 'Tag people',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.camera_alt,
              color: Colors.red,
              size: 30,
            ),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.grey,
              size: 30,
            ),
            label: '',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}
