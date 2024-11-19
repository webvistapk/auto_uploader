import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessageRequestScreen extends StatefulWidget {
  const MessageRequestScreen({super.key});

  @override
  State<MessageRequestScreen> createState() => _MessageRequestScreenState();
}

class _MessageRequestScreenState extends State<MessageRequestScreen> {
  int _selectedTab = 0; // For top tabs: 0 = All, 1 = Conversations, 2 = Clubs
  int _selectedBottomNav = 0; // For Bottom Navigation
  int _selectedIndex = 0; // This will track the selected container

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
                                'Message Request',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTabItem('All', 0),
                              _buildTabItem('Conversations', 1),
                              _buildTabItem('Clubs', 2),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Add chat list or other components below
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customContainer('Hidden', 0),
                        customContainer('Date Posted', 1),
                        customContainer('Promotions', 2),
                      ],
                    ),
                    ChatList(),
                  ],
                ),
              ),
              // Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNavigationBar(
                  backgroundColor: Colors.black,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.grey,
                  currentIndex: _selectedBottomNav,
                  onTap: _onBottomNavTapped,
                  items: [
                    BottomNavigationBarItem(
                      backgroundColor: Colors.black.withOpacity(0.8),
                      icon: Icon(Icons.home),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: "",
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

  Widget customContainer(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index on tap
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _selectedIndex == index
                ? Colors.lightBlue.withOpacity(0.6)
                : Colors.grey.withOpacity(0.3), // Light blue background if selected
          ),
          child: Text(
            title,
            style: TextStyle(
                // fontWeight: _selectedIndex == index
                //     ? FontWeight.bold
                //     : FontWeight.normal, // Bold if selected
                color: _selectedIndex == index ? Colors.blue : Colors.black,
                fontSize: 14 // Dark blue text if selected
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
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

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
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
          );
        },
      ),
    );
  }
}
