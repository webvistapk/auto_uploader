import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/controller/chat_controller.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';
import 'package:mobile/screens/messaging/widgets/input_message.dart';

import 'package:provider/provider.dart';
import 'model/chat_model.dart';
import 'widgets/build_user_messaging.dart';
import 'widgets/own_message.dart';

class InboxScreen extends StatefulWidget {
  final UserProfile userProfile;
  final ChatModel chatModel;
  InboxScreen({Key? key, required this.userProfile, required this.chatModel})
      : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final chatController = Provider.of<ChatController>(context, listen: false);

    // Fetch previous messages and set up WebSocket
    fetching(widget.chatModel.id);

    // Scroll to the bottom once messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.addListener(() {
        _scrollToBottom();
      });
    });
  }

  fetching(chatID) async {
    final chatController = Provider.of<ChatController>(context, listen: false);

    chatController.connectWebSocket(chatID);
    await chatController.loadMessages(chatID);
  }

  @override
  void dispose() {
    final chatController = Provider.of<ChatController>(context, listen: false);
    chatController.disconnect(); // Close WebSocket connection
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<ChatController>(
          builder: (context, chatController, child) {
            return Stack(children: [
              Column(
                children: [
                  Material(
                    elevation: 0.3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Image(
                                  width: 28,
                                  height: 28,
                                  image: NetworkImage(
                                    widget.userProfile.profileUrl ??
                                        "https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-image-182145777.jpg",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.chatModel.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Text(
                                //   'user_name',
                                //   style: TextStyle(
                                //       color: Colors.grey, fontSize: 12),
                                // ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.phone,
                                    size: 18,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey)),
                                child: const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.video_call,
                                      size: 18,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                  // Chat List
                  Expanded(
                    child: chatController.messages.isEmpty
                        ? Center(child: CircularProgressIndicator.adaptive())
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: chatController.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatController.messages[index];
                              bool isOwnMessage =
                                  message.sender == widget.userProfile.id;

                              final formatDate =
                                  formatDateString(message.createdAt);
                              if (isOwnMessage) {
                                return OwnMessage(
                                  text: message.content,
                                  timestamp: formatDate,
                                );
                              } else {
                                return buildUserMessage(
                                  timestamp: formatDate,
                                  userProfile: widget.userProfile,
                                  messageModel: message,
                                );
                              }
                            },
                          ),
                  ),
                  // Input Field
                  ChatInputField(
                    messageController: messageController,
                    onPressedSend: () async {
                      final chatController =
                          Provider.of<ChatController>(context, listen: false);

                      try {
                        // Send the message via the API and then add it to the UI
                        await chatController.sendMessage(
                            messageController.text.trim(),
                            widget.chatModel.id,
                            widget.userProfile.username);

                        // Add the new message to the messages list manually
                        chatController.messages.add(
                          MessageModel(
                            sender: widget.userProfile.id,
                            content: messageController.text.trim(),
                            createdAt: DateTime.now().toIso8601String(),
                            id: widget.userProfile.id,
                            senderUsername: widget.userProfile.username!,
                          ),
                        );
                        _scrollToBottom();
                      } catch (e) {
                        ToastNotifier.showErrorToast(context, e.toString());
                      }

                      // Clear the input field and update the UI
                      messageController.clear();
                      setState(() {});
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
            ]);
          },
        ),
      ),
    );
  }

  String formatDateString(String dateString) {
    try {
      // Parse the input string into a DateTime object
      DateTime dateTime = DateTime.parse(dateString);

      // Define the format you want (e.g., "yyyy-MM-dd HH:mm:ss")
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

      // Format the DateTime object to the specified format
      return formatter.format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }
}
