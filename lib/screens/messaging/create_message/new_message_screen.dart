import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  bool isCreateLoading = false;

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
        return Stack(
          children: [
            pro.isLoading
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
                                child: const Icon(Icons.group,
                                    color: Colors.black),
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
                          'Friends',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                  ),
            // Loading Spinner and Dim Background
            if (isCreateLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: SpinKitCircle(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  ),
                ),
              ),
          ],
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
    // Directly navigate to the message screen without pop-up
    setState(() {
      // Show loading indicator while the process is happening
      isCreateLoading = true;
    });

    // Call your API function to create a new chat here
    _createNewChat(user);
  }

  void _createNewChat(TagUser user) {
    // Call the chat creation function and pass user details
    context
        .read<ChatController>()
        .createNewChat(context,
            name: user.firstName + ' ' + user.lastName,
            participants: [user.id],
            isGroup: false)
        .then((_) {
      // After chat creation is successful, hide the loading spinner
      setState(() {
        isCreateLoading = false;
      });
      // Optionally navigate to the newly created chat screen or show success message
    }).catchError((e) {
      // Handle error
      setState(() {
        isCreateLoading = false;
      });
      // Show error message if needed
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
