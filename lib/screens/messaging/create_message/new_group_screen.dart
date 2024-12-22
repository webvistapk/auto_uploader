import 'package:flutter/material.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/post/tag_people.dart';
import 'package:mobile/screens/messaging/create_message/widget/profile_tile_widget.dart';

class NewGroupScreen extends StatefulWidget {
  final bool showCheckbox; // Pass this value to control checkbox visibility
  final List<TagUser> allItems;
  const NewGroupScreen(
      {super.key, required this.showCheckbox, required this.allItems});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  List<TagUser> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<TagUser> _selectedUsers = {}; // Track selected users

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(widget.allItems);
      });
    } else {
      setState(() {
        _filteredItems = widget.allItems.where((item) {
          return item.firstName.toLowerCase().contains(query.toLowerCase()) ||
              item.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _toggleSelection(TagUser user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.allItems;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'New Group Chat',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "End to end Encryption: Off",
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Group Name (optional)",
                  labelStyle: TextStyle(color: Colors.black45, fontSize: 16),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 5),
              child: Divider(),
            ),
            // Search Bar
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  onChanged: (value) {
                    _filterItems(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Suggested',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        "No friends found",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final user = _filteredItems[index];
                        return ProfileTile(
                          profileImage: user.profileImage,
                          displayName: '${user.firstName} ${user.lastName}',
                          username: user.username,
                          showCheckbox: widget.showCheckbox,
                          isChecked:
                              _selectedUsers.contains(user), // External state
                          onPressedTile: () {
                            print("Tapped on ${user.username}");
                          },
                          onChecked: (isChecked) {
                            setState(() {
                              if (isChecked) {
                                _selectedUsers.add(user);
                              } else {
                                _selectedUsers.remove(user);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          onPressed: () {
            if (_selectedUsers.length > 1) {
              print("Create Group Chat");
            } else if (_selectedUsers.length == 1) {
              print("Create New Message");
            }
          },
          child: Text(
            _selectedUsers.length > 1
                ? "Create Group Chat"
                : "Create New Message",
            style: AppStyles.buttonTextStyle,
          ),
        ),
      ),
    );
  }
}
