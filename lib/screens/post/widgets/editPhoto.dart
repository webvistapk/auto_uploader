import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/post/add_post_screen.dart';
import 'package:mobile/screens/post/create_post_screen.dart';
import 'package:mobile/screens/post/widgets/image_videos.dart';
import 'package:sizer/sizer.dart';

class EditPhotoScreen extends StatefulWidget {
  final List<File> mediaFiles;
  final UserProfile? userProfile;

  const EditPhotoScreen({
    super.key,
    required this.mediaFiles,
    required this.userProfile,
  });

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  List<Color> colors1 = [
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.red,
    Colors.pink,
    Colors.orange,
    Colors.yellow,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.brown,
  ];

  int? selectedColorIndex = 0;
  int? selectedFontIndex = 0;
  int currentMediaIndex = 0;

  List<String> font = [
    'Roboto',
    'Courier',
    'Courier New',
    'Times New Roman',
    'Arial',
    'Verdana',
    'Georgia',
    'Tahoma',
    'Helvetica',
    'Monospace',
  ];

  int data1index = 0;
  int data2index = 0;
  String mydata1 = 'Add Title Here';
  String mydata2 = "Add Description Here";
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkcontroller = TextEditingController();

   @override
void initState() {
  super.initState();
  titleController.addListener(_updatePreview);
  descriptionController.addListener(_updatePreview);
}

@override
void dispose() {
  titleController.removeListener(_updatePreview);
  descriptionController.removeListener(_updatePreview);
  super.dispose();
}

void _updatePreview() {
  if (mounted) {
    setState(() {});
  }
}

  Widget _buildFileCarousel() {
    final hasTitleText = titleController.text.isNotEmpty;
  final hasDescriptionText = descriptionController.text.isNotEmpty;
  
  final titleText = hasTitleText ? titleController.text : mydata1;
  final descriptionText = hasDescriptionText ? descriptionController.text : mydata2;
  
  final selectedColor = colors1[selectedColorIndex ?? 0];
  
    return Stack(
      children: [
        Container(
          height: 400,
          //width: 300,
          margin: EdgeInsets.all(0),

          child: widget.mediaFiles.isNotEmpty
              ? FileCarousel(files: widget.mediaFiles)
              : const Center(child: Text('No images available')),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 312, left: 8),
          child: Container(
            height: 80,
            width: 290,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.8),
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: TextStyle(
                  fontFamily: font[selectedFontIndex ?? 0],
                  fontWeight: FontWeight.bold,
                  color: hasTitleText ? selectedColor : Colors.black54, // Gray if empty
                  fontSize: 12,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 2),
              Text(
                descriptionText,
                style: TextStyle(
                  fontFamily: font[selectedFontIndex ?? 0],
                  color: hasDescriptionText ? selectedColor : Colors.black54, // Gray if empty
                  fontSize: 12,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          ),
        ),
      ],
    );
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddPostScreen(
                              userProfile: widget.userProfile,
                              mediFiles: widget.mediaFiles,
                              title: titleController.text.isNotEmpty
                                  ? titleController.text
                                  : null,
                              description: descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                              isfileUploaded: true,
                              titleFontColor:
                                  colorToHex(colors1[selectedColorIndex ?? 0]),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Done',
                        style: AppTextStyles.poppinsBold(
                            color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF1C1C1E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       data1index = (data1index - 1) >= 0
                    //           ? data1index - 1
                    //           : mydata1.length - 1;
                    //     });
                    //   },
                    //   child: const Icon(Icons.arrow_back, color: Colors.white),
                    // ),
                    _buildFileCarousel(),
                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       data1index = (data1index + 1) % mydata1.length;
                    //     });
                    //   },
                    //   child: const Icon(Icons.arrow_forward, color: Colors.white),
                    // ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF2C2C2E)),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 20),
                          Text(
                            'Meta',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 200),
                          Text(
                            'Background',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 30,
                      color: const Color(0xFF2C2C2E),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: font.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedFontIndex = index;
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: CircleAvatar(
                                backgroundColor: selectedFontIndex == index
                                    ? Colors.black
                                    : Colors.black54,
                                child: Text(
                                  'Aa',
                                  style: TextStyle(
                                    fontFamily: font[index],
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 40,
                      color: const Color(0xFF2C2C2E),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: colors1.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedColorIndex = index;
                                });
                              },
                              child: Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                  color: colors1[index],
                                  borderRadius: BorderRadius.circular(5),
                                  border: selectedColorIndex == index
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      color: const Color(0xFF2C2C2E),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 40,
                              color: Colors.white,
                              child: TextField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  hintText: 'Add Title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 40,
                              color: Colors.white,
                              child: TextField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  hintText: 'Add Description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 40,
                              color: Colors.white,
                              child: TextField(
                                controller: linkcontroller,
                                decoration: InputDecoration(
                                  hintText: 'Links',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
