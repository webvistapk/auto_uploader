import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/inbox.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:provider/provider.dart'; // Import the provider

class ChatList extends StatefulWidget {
  final UserProfile userProfile;
  final ChatProvider chatProvider;

  ChatList({Key? key, required this.userProfile, required this.chatProvider})
      : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading) {
          // Show loading indicator when fetching data
          return Center(child: CircularProgressIndicator());
        } else {
          // Show list of chats if loading is false
          return Expanded(
            child: chatProvider.chats.isEmpty
                ? Center(
                    child: Text(
                      "No chats available", // Display message if no chats
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: chatProvider.chats.length,
                    itemBuilder: (context, index) {
                      final chat = chatProvider.chats[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to the Inbox screen when a chat is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InboxScreen(
                                userProfile: widget.userProfile,
                                chatModel: chat,
                              ),
                            ),
                          );
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
                                chat.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    chat.time,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.blue,
                                    size: 10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                chat.message,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text(
                                  "2:17:22", // Replace with the timestamp if available
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10),
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
      },
    );
  }
}
