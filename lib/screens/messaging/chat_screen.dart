import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:mobile/screens/messaging/create_message/new_message_screen.dart';
import 'package:mobile/screens/messaging/message_request_screen.dart';
import 'package:mobile/screens/messaging/widgets/chat_lists.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final UserProfile userProfile;
  ChatScreen({Key? key, required this.userProfile}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedTab = 0; // For top tabs: 0 = All, 1 = Conversations, 2 = Clubs

  // Function to update the selected top tab
  void _onTabChanged(int index) {
    if (mounted)
      setState(() {
        _selectedTab = index;
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      context.read<ChatProvider>().fetchChats();
    });
  }

  // Function to update the selected bottom nav item

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var pro = context.watch<ChatProvider>();
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Account name',
                                style: TextStyle(fontFamily: 'Greycliff CF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down),
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
                          // const Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       'Account name',
                          //       style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 16),
                          //     ),
                          //     Icon(Icons.arrow_drop_down),
                          //   ],
                          // ),
                          // GestureDetector(
                          //     onTap: () {
                          //       Navigator.pop(context);
                          //     },
                          //     child: const Icon(Icons.arrow_back)),
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CupertinoDialogRoute(
                                            builder: (_) => NewMessageScreen(
                                                showCheckbox: false),
                                            context: context));
                                  },
                                  child: const Image(
                                      width: 28,
                                      height: 28,
                                      image: AssetImage(
                                          'assets/images/edit-button.png')),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildTabItem('All', 0),
                                    _buildTabItem('Conversations', 1),
                                    _buildTabItem('Clubs', 2),
                                  ],
                                ),
                                Flexible(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MessageRequestScreen(
                                                    userProfile:
                                                        widget.userProfile,
                                                  )));
                                    },
                                    child: Container(
                                      child: const Text(
                                        'Requests',
                                        style: TextStyle(
                                          color: Colors.blue,fontFamily: 'Greycliff CF',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                      chatProvider: pro,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Builds each tab item with dynamic highlighting
  Widget _buildTabItem(String title, int index) {
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: Padding(
        padding: const EdgeInsets.only(right: 30.0),
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
