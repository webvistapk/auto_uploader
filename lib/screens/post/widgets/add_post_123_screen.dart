import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class AddPost123Screen extends StatefulWidget {
  const AddPost123Screen({super.key});

  @override
  _AddPost123ScreenState createState() => _AddPost123ScreenState();
}

class _AddPost123ScreenState extends State<AddPost123Screen> {
  List<Map<String, String>> _allItems = []; // Store all items with names and images
  List<Map<String, String>> _filteredItems = []; // Store filtered items for searching
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  TextSpan _richText = const TextSpan();

  bool onlymeSelected = false;
  bool clubselectionSelected = false;
  bool followersSelected = false;
  bool everyoneSelected = false;

  @override
  void initState() {
    super.initState();
    _initializeItems();
    _controller.addListener(_parseHashtags);
  }

  void _initializeItems() {
    // Initialize with some dummy data for demonstration
    _allItems = [
      {
        'name': 'John Doe',
        'username': '@johndoe',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Jane Smith',
        'username': '@janesmith',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Alice Johnson',
        'username': '@alicejohnson',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'John Doe',
        'username': '@johndoe',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Jane Smith',
        'username': '@janesmith',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Alice Johnson',
        'username': '@alicejohnson',
        'image': 'https://via.placeholder.com/150',
      },
    ];
    _filteredItems = List.from(_allItems); // Initialize filtered list
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(_allItems);
      });
    } else {
      setState(() {
        _filteredItems = _allItems.where((item) {
          return item['name']!.toLowerCase().contains(query.toLowerCase()) ||
              item['username']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _parseHashtags() {
    final text = _controller.text;
    final words = text.split(RegExp(r'\s+'));
    final List<TextSpan> spans = [];

    for (var word in words) {
      if (word.startsWith('#')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: TextStyle(color: Colors.blue), // Blue for hashtags
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: TextStyle(color: Colors.black), // Black for regular text
          ),
        );
      }
    }

    setState(() {
      _richText = TextSpan(children: spans);
    });
  }

  void _showTagPeopleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 325,
          child: Padding(
            padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    const SizedBox(),
                    Text(
                      "Tag People",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      iconSize: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  cursorColor: Colors.grey,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    _filterItems(value); // Call filter function
                  },
                ),
                const SizedBox(height: 10),
                if (_filteredItems.isEmpty)
                  SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          "Not Friend here",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )),
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Dismiss the dialog when a tile is tapped
                          Navigator.of(context).pop();
                          // You can handle the selection here, if needed
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                _filteredItems[index]['image']!, // Get image from the map
                              ),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _filteredItems[index]['name']!, // Full name
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    _filteredItems[index]['username']!, // Username
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row with Close Button
                  Padding(
                    padding: const EdgeInsets.only(top: 15, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Text(
                          "Privacy",
                          style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 18),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  // Privacy options with checkboxes
                  Column(
                    children: [
                      CheckboxListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Public", style: AppTextStyles.poppinsMedium()),
                            Text("Description", style: AppTextStyles.poppinsRegular().copyWith(fontSize: 12)),
                          ],
                        ),
                        activeColor: Colors.red,
                        value: onlymeSelected,
                        onChanged: (value) {
                          setState(() {
                            onlymeSelected = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Club Selection", style: AppTextStyles.poppinsMedium()),
                            Text("Description", style: AppTextStyles.poppinsRegular().copyWith(fontSize: 12)),
                          ],
                        ),
                        activeColor: Colors.red,
                        value: clubselectionSelected,
                        onChanged: (value) {
                          setState(() {
                            clubselectionSelected = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Followers", style: AppTextStyles.poppinsMedium()),
                            Text("Description", style: AppTextStyles.poppinsRegular().copyWith(fontSize: 12)),
                          ],
                        ),
                        activeColor: Colors.red,
                        value: followersSelected,
                        onChanged: (value) {
                          setState(() {
                            followersSelected = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Everyone", style: AppTextStyles.poppinsMedium()),
                            Text("Description", style: AppTextStyles.poppinsRegular().copyWith(fontSize: 12)),
                          ],
                        ),
                        activeColor: Colors.red,
                        value: everyoneSelected,
                        onChanged: (value) {
                          setState(() {
                            everyoneSelected = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_parseHashtags);
    _controller.dispose();
    _textController.dispose(); // Dispose of the text controller for search
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Icon(Icons.arrow_back_ios),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTAVcRd4_ZtcbX0hSjBOL8DouuhmYIYt5HkTXKwMBJruRglUnhM78J8h2NatkBNfSmLSzQ&usqp=CAU",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Stack(
                      children: [
                        // RichText(
                        //   text: _richText,
                        // ),
                        TextField(
                          controller: _controller,
                          cursorColor: Colors.red,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintMaxLines: 4,
                            hintText:
                                "Describe your post here, add hashtags, mention or anything else that compels you.",
                            hintStyle: AppTextStyles.poppinsRegular()
                                .copyWith(color: Colors.black, fontSize: 13),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          // style: TextStyle(
                          //   color: Colors.transparent,
                          //   height: 1.25,
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
             
              ],
            ),
          ),
          Divider(color: Color(0xffD3D3D3)),
          // Location Section
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, size: 25),
                SizedBox(width: 10),
                Text(
                  "Location",
                  style: AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 17),
              ],
            ),
          ),
          // Tag People Section
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showTagPeopleBottomSheet(context);
                  },
                  child: Icon(Icons.people_outline_outlined, size: 25),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _showTagPeopleBottomSheet(context);
                  },
                  child: Text(
                    "Tags people",
                    style: AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 17),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showPrivacyBottomSheet(context);
                  },
                  child: Icon(Icons.public_outlined, size: 25),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _showPrivacyBottomSheet(context);
                  },
                  child: Text(
                    "Privacy",
                    style: AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                  ),
                ),
                SizedBox(width: 5),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 17)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                Icon(Icons.bubble_chart_outlined, size: 25),
                SizedBox(width: 10),
                Text(
                  "Interactions",
                  style: AppTextStyles.poppinsRegular().copyWith(fontSize: 14),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 17),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, size: 20, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    "Post",
                    style: AppTextStyles.poppinsMedium()
                        .copyWith(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
