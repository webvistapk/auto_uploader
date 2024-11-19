import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/inbox.dart';
import 'package:mobile/screens/messaging/message_request_screen.dart';

class ChatScreen extends StatefulWidget {
  final UserProfile userProfile;
  ChatScreen({Key? key, required this.userProfile}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedTab = 0; // For top tabs: 0 = All, 1 = Conversations, 2 = Clubs
  int _selectedBottomNav = 0; // For Bottom Navigation

  // Function to update the selected top tab
  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  // Function to update the selected bottom nav item
  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedBottomNav = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Material(
                      elevation: 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Account name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          const Icon(Icons.arrow_back),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 30, top: 5, bottom: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 36,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.blue),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(
                                            Icons.search_rounded,
                                            color: Colors.grey),
                                        hintText: 'Search',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                      ),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 25),
                                const Image(
                                    width: 28,
                                    height: 28,
                                    image: AssetImage(
                                        'assets/images/edit-button.png'))
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildTabItem('All', 0),
                                    _buildTabItem('Conversations', 1),
                                    _buildTabItem('Clubs', 2),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Add action for Requests tab if needed
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MessageRequestScreen()));
                                    },
                                    child: const Text(
                                      'Requests',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Add chat list or other components below
                        ],
                      ),
                    ),
                    ChatList(
                      userProfile: widget.userProfile,
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

  // Builds each tab item with dynamic highlighting
  Widget _buildTabItem(String title, int index) {
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: Padding(
        padding: const EdgeInsets.only(right: 30.0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight:
                _selectedTab == index ? FontWeight.bold : FontWeight.normal,
            color: _selectedTab == index ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class ChatList extends StatefulWidget {
  final UserProfile userProfile;
  ChatList({Key? key, required this.userProfile}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InboxScreen(
                            userProfile: widget.userProfile,
                          )));
            },
            child: ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://images.pexels.com/photos/940585/pexels-photo-940585.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                radius: 20,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    index % 2 == 0 ? "Username" : "Group Name",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Column(
                    children: [
                      Text(
                        "5:10 PM",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Icon(
                        Icons.circle,
                        color: Colors.blue,
                        size: 10,
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: const Row(
                children: [
                  Text(
                    "The message goes here",
                    style: TextStyle(fontSize: 12),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      "2:17:22",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
