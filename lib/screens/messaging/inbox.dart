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
  final chatName;
  final participantImage;
  InboxScreen(
      {Key? key,
      required this.userProfile,
      required this.chatModel,
      this.chatName,
      this.participantImage})
      : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late ChatController chatController;
  bool isLoading = false;
  int offset = 0;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    chatController = Provider.of<ChatController>(context, listen: false);
    chatController.connectWebSocket(widget.chatModel.id);
    fetching(widget.chatModel.id);

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.minScrollExtent &&
          !isLoading) {
        // Trigger loading more messages when scrolled to the top
        loadMoreMessages();
      }
    });
  }

  Future<void> fetching(int chatID) async {
    try {
      setState(() {
        isLoading = true;
      });
      await chatController.loadMessages(chatID, offset: offset, limit: limit);
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      ToastNotifier.showErrorToast(context, 'Error loading messages: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreMessages() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        offset += limit; // Increase offset to load next set of messages
      });
      await fetching(widget.chatModel.id);
    }
  }

  @override
  void dispose() {
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
            return Stack(
              children: [
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
                                      widget.participantImage ??
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
                                    widget.chatName ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                          ),
                        ],
                      ),
                    ),
                    // Chat List
                    Expanded(
                      child: chatController.isMessageLoading
                          ? Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : chatController.messages.isEmpty
                              ? Center(
                                  child: Text(
                                      "Say Hello ${widget.chatModel.name}"))
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: chatController.messages.length,
                                  itemBuilder: (context, index) {
                                    final message =
                                        chatController.messages[index];
                                    bool isOwnMessage =
                                        message.senderUsername ==
                                            widget.userProfile.username;

                                    final formatDate =
                                        formatDateString(message.createdAt);
                                    final formatTime =
                                        formatDateString(message.createdAt);
                                    if (isOwnMessage) {
                                      return OwnMessage(
                                        text: message.content,
                                        timestampDate: formatDate,
                                        timestampTime: formatTime,
                                        mediaList: message.media,
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
                        try {
                          await chatController.sendMessage(
                              messageController.text.trim(),
                              widget.chatModel.id, []);

                          if (mounted) {
                            setState(() {});
                          }
                          _scrollToBottom();
                        } catch (e) {
                          ToastNotifier.showErrorToast(context, e.toString());
                        }

                        messageController.clear();
                        setState(() {});
                        _scrollToBottom();
                      },
                      chatModel: widget.chatModel,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String formatDateString(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }

  String formatTimeString(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }
}
