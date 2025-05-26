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
    return Selector<ChatProvider, bool>(
      selector: (_, chatProvider) =>
          chatProvider.isLoading && chatProvider.chats.isEmpty,
      builder: (context, isLoading, child) {
        var chatProvider = context.watch<ChatProvider>();

        if (isLoading) {
          // Show loading indicator when fetching data
          return Center(child: CircularProgressIndicator());
        } else {
          // Sort chats by updatedAt descending (newest first)
          final sortedChats = List.of(chatProvider.chats);
          sortedChats.sort((a, b) {
            DateTime aDate = a.updatedAt is DateTime
                ? a.updatedAt
                : DateTime.parse(a.updatedAt.toString());
            DateTime bDate = b.updatedAt is DateTime
                ? b.updatedAt
                : DateTime.parse(b.updatedAt.toString());
            return aDate.compareTo(aDate);
          });

          return Expanded(
            child: sortedChats.isEmpty
                ? const Center(
                    child: Text(
                      "No chats available", // Display message if no chats
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedChats.length,
                    itemBuilder: (context, index) {
                      final chat = sortedChats[index];

                      // Logic to determine chat display details
                      String chatName;
                      String? profileImage;

                      if (chat.isGroup) {
                        chatName = chat.name ?? 'Unknown';
                        profileImage = ''; // Default group image
                      } else {
                        final participant = chat.participants.firstWhere(
                          (participant) =>
                              participant.id != widget.userProfile.id,
                          orElse: () => chat.participants[0],
                        );

                        if (participant != null) {
                          chatName =
                              '${participant.firstName} ${participant.lastName}';
                          profileImage = participant.profileImage;
                        } else {
                          chatName = 'Unknown';
                          profileImage = null;
                        }
                      }

                      final String updateAt = formatMessageDate(
                          chat.updatedAt is DateTime
                              ? chat.updatedAt
                              : DateTime.parse(chat.updatedAt.toString()));

                      return InkWell(
                        onTap: () async {
                          // Navigate to the Inbox screen when a chat is tapped
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InboxScreen(
                                userProfile: widget.userProfile,
                                chatModel: chat,
                                chatName: chatName,
                                participantImage: profileImage,
                              ),
                            ),
                          );

                          // If the user returns from the InboxScreen
                          if (result == true) {
                            chatProvider.markChatAsRead(chat.id);
                          }
                        },
                        child: ListTile(
                          leading: profileImage != null &&
                                  profileImage.isNotEmpty
                              ? CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage(profileImage),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      'assets/icons/profile.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                chatName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              if (chat.unReadMessages)
                                const Icon(
                                  Icons.circle,
                                  color: Colors.blue,
                                  size: 10,
                                ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  child: const Text(
                                    "Welcome to the Message Screen List",
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  chat.updatedAt is DateTime
                                      ? chat.updatedAt.toIso8601String()
                                      : chat.updatedAt.toString(),
                                  style: const TextStyle(
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

  String formatDateTime(String isoDate) {
    // Parse the ISO date string to a DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Format the DateTime to the desired format
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);

    return formattedDate;
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
