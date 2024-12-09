import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/inbox.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';
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

                      // Logic to determine chat display details
                      String chatName;
                      String? profileImage;

                      if (chat.isGroup) {
                        chatName = chat.name ?? 'Unknown';
                        profileImage =
                            'https://images.pexels.com/photos/940585/pexels-photo-940585.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'; // Default group image
                      } else {
                        final participant = chat.participants.firstWhere(
                          (participant) =>
                              participant.id != widget.userProfile.id,
                        );
                        chatName =
                            '${participant.firstName} ${participant.lastName}';
                        profileImage = participant.profileImage ??
                            'https://images.pexels.com/photos/940585/pexels-photo-940585.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'; // Default group image
                      }
                      final String updateAt = formatMessageDate(chat.updatedAt);
                      return InkWell(
                        onTap: () {
                          // Navigate to the Inbox screen when a chat is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InboxScreen(
                                  userProfile: widget.userProfile,
                                  chatModel: chat,
                                  chatName: chatName,
                                  participantImage: profileImage),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(profileImage),
                            radius: 20,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                chatName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Text(
                                  //   chat.createdAt.toIso8601String(),
                                  //   style: const TextStyle(
                                  //       color: Colors.grey, fontSize: 12),
                                  // ),
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
                              Flexible(
                                child: Container(
                                  child: Text(
                                    "Welcome to the Message Screen List",
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text(
                                  chat.updatedAt
                                      .toIso8601String(), // Replace with the timestamp if available
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

  String formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.isAfter(today)) {
      // Today: Show time (HH:mm)
      return DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.isAfter(yesterday)) {
      // Yesterday
      return "Yesterday";
    } else if (now.difference(dateTime).inDays < 7) {
      // This week: Show day name
      return DateFormat('EEEE').format(dateTime); // e.g., "Monday"
    } else {
      // Older: Show date (MM/dd/yyyy or dd/MM/yyyy based on locale)
      return DateFormat.yMd().format(dateTime); // e.g., "12/3/2024"
    }
  }
}
