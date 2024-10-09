import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _textController = TextEditingController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
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
                  style: AppTextStyles.poppinsRegular().copyWith(fontSize: 19),
                ),
                Spacer(),
                Container(
                  child: Center(
                      child: Text(
                    "POST",
                    style: AppTextStyles.poppinsMedium()
                        .copyWith(fontSize: 17, color: Colors.grey),
                  )),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xffD3D3D3),
                  ),
                  width: size.width * 0.19,
                 height: 40,
                )
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 0,
          ),
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
                      style: AppTextStyles.poppinsBold().copyWith(fontSize: 20),
                    ),
                    SizedBox(height: 5),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            color: const Color.fromARGB(255, 10, 126, 222),
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Friends',
                            style: AppTextStyles.poppinsRegular().copyWith(
                                color:
                                    const Color.fromARGB(255, 10, 126, 222)),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_drop_down,
                            color: const Color.fromARGB(255, 10, 126, 222),
                            size: 25,
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color.fromARGB(82, 118, 184, 228),
                      ),
                      width: size.width * 0.33,
                      height: 29,
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
                floatingLabelAlignment: FloatingLabelAlignment.center,
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
              maxLines: null, 
              expands: false, 
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 15,bottom: 20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Text(
                      "Aa",
                      style: AppTextStyles.poppinsBold(color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 6,
                      )
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
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined,color: Colors.green,size: 30,),
            label: 'Photo/video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,color: Colors.blueAccent,size: 30,),
            label: 'Tag people',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt,color: Colors.red,size: 30,),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz,color: Colors.grey,size: 30,),
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
