import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/chat_lists.dart';

class MessageRequestScreen extends StatefulWidget {
  final UserProfile userProfile;
  const MessageRequestScreen({super.key, required this.userProfile});

  @override
  State<MessageRequestScreen> createState() => _MessageRequestScreenState();
}

class _MessageRequestScreenState extends State<MessageRequestScreen> {
  int _selectedTab = 0;
  // For top tabs: 0 = All, 1 = Conversations, 2 = Clubs
  int _selectedIndex = 0; // This will track the selected container

  // Function to update the selected top tab
  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ChatProvider>().fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var pro = context.watch<ChatProvider>();
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
            
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back)),
                const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Message Request',
                                    style: TextStyle(fontFamily: 'Greycliff CF',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                              SizedBox()
              ],
            ),
                          centerTitle: true,
          ),
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
                          
                          // InkWell(
                          //     onTap: () {
                          //       Navigator.pop(context);
                          //     },
                          //     child: const Icon(Icons.arrow_back)),
        
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
                    ChatList(
                      userProfile: widget.userProfile,
                      chatProvider: pro,
                    ),
                  ],
                ),
              ),
              // Bottom Navigation Bar
            ],
          ),
        ),
      );
    });
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
                : Colors.grey
                    .withOpacity(0.3), // Light blue background if selected
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
          style: TextStyle(fontFamily: 'Greycliff CF',
            fontWeight:
                _selectedTab == index ? FontWeight.bold : FontWeight.normal,
            color: _selectedTab == index ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}
