import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post/tags/tags_provider.dart';
import 'package:mobile/models/post/tag_people.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/messaging/controller/chat_controller.dart';
import 'package:mobile/screens/messaging/create_message/new_group_screen.dart';
import 'package:mobile/screens/messaging/create_message/widget/profile_tile_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NewMessageScreen extends StatefulWidget {
  final bool showCheckbox;
  const NewMessageScreen({
    Key? key,
    required this.showCheckbox,
  }) : super(key: key);

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  List<TagUser> _allItems = [];
  List<TagUser> _filteredItems = [];

  final TextEditingController _searchController = TextEditingController();

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          return item.firstName.toLowerCase().contains(query.toLowerCase()) ||
              item.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() async {
    var pro = context.read<TagsProvider>();
    final futureUser = await UserPreferences().getCurrentUser();
    var tagUsers = await pro.getTagUsersList(futureUser!);

    setState(() {
      _allItems = tagUsers.toSet().toList();
      _filteredItems = List.from(_allItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Builder(builder: (context) {
        var pro = context.watch<TagsProvider>();
        return pro.isLoading
            ? _buildShimmerEffect()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Row(
                      children: [
                        const Text(
                          "To:",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          height: 40,
                          width: size.width * 0.7,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(8),
                              hintText: 'Search',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            onChanged: _filterItems,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Create Group Chat Tile
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoDialogRoute(
                            builder: (_) => NewGroupScreen(
                              showCheckbox: true,
                              allItems: _allItems,
                            ),
                            context: context,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.group, color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Create group chat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Suggested Header
                    const Text(
                      'Suggested',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // List of User Profiles
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? const Center(
                              child: Text(
                                "No friends found",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                TagUser currentUser = _filteredItems[index];
                                return ProfileTile(
                                  profileImage: currentUser.profileImage,
                                  displayName: currentUser.firstName +
                                      ' ' +
                                      currentUser.lastName,
                                  username: currentUser.username,
                                  showCheckbox: widget.showCheckbox,
                                  onPressedTile: () {
                                    _handleTileTap(currentUser);
                                  },
                                  isChecked: false,
                                  onChecked: (bool value) {},
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
            ),
            title: Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
            subtitle: Container(
              width: double.infinity,
              height: 12,
              color: Colors.grey[300],
            ),
          );
        },
      ),
    );
  }

  void _handleTileTap(TagUser user) {
    showDialog(
        context: context,
        builder: (context) {
          return Builder(builder: (context) {
            var pro = context.watch<ChatController>();
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: user.profileImage == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Do you want to create a new chat with ${user.firstName}?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),

                // Create Chat Button
                pro.isLoading
                    ? CircularProgressIndicator.adaptive()
                    : ElevatedButton(
                        onPressed: () {
                          // Navigator.pop(context); // Close the dialog first
                          // Call the API function to create a new chat
                          _createNewChat(user); // Implement this function
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            "Create Chat",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            );
          });
        });
  }

  void _createNewChat(TagUser user) {
    // Call your API function here
    context.read<ChatController>().createNewChat(context,
        name: user.firstName + ' ' + user.lastName,
        participants: [user.id],
        isGroup: false);
    print("Creating chat with ${user.firstName} ${user.lastName}");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
