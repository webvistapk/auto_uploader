import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/messaging/controller/chat_controller.dart';
import 'package:mobile/screens/messaging/widgets/input_message.dart';
import 'package:mobile/screens/messaging/widgets/post_message/post_message_widget.dart';
import 'package:provider/provider.dart';
import 'model/chat_model.dart';
import 'widgets/build_user_messaging.dart';
import 'widgets/own_message.dart';

class InboxScreen extends StatefulWidget {
  final UserProfile userProfile;
  final ChatModel chatModel;
  final String? chatName;
  final String? participantImage;
  bool isCreated;
  bool isNotification;

  InboxScreen(
      {Key? key,
      this.isCreated = false,
      required this.userProfile,
      required this.chatModel,
      this.chatName,
      this.participantImage,
      this.isNotification = false})
      : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatController? chatController;
  bool isLoading = false;
  int offset = 0;
  final int limit = 10;
  bool moreLoading = false;

  @override
  void initState() {
    super.initState();
    chatController = Provider.of<ChatController>(context, listen: false);
    chatController?.connectWebSocket(widget.chatModel.id);
    fetching(widget.chatModel.id);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.minScrollExtent &&
          !isLoading) {
        loadMoreMessages();
      }
    });
  }

  Future<void> fetching(int chatID) async {
    setState(() => isLoading = true);
    await chatController?.loadMessages(chatID, offset: offset, limit: limit);
    setState(() {
      isLoading = false;
      if (mounted) _scrollToBottom();
    });
  }

  Future<void> loadMoreMessages() async {
    if (!moreLoading) {
      setState(() => moreLoading = true);
      final double previousScrollHeight =
          _scrollController.position.maxScrollExtent;
      offset += limit;
      await chatController?.loadMessages(widget.chatModel.id,
          offset: offset, limit: limit);
      setState(() => moreLoading = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final double newScrollHeight =
              _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(newScrollHeight - previousScrollHeight);
        }
      });
    }
  }

  @override
  void dispose() {
    chatController?.disconnect();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String formatDateString(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(dateString));
    } catch (e) {
      debugPrint("Error parsing date: $e");
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isCreated || widget.isNotification) {
          final authToken = await Prefrences.getAuthToken();
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (_) => MainScreen(
                userProfile: widget.userProfile,
                authToken: authToken,
                selectedIndex: 3,
              ),
            ),
          );
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Consumer<ChatController>(
            builder: (context, chatController, child) {
              return Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: chatController.isMessageLoading &&
                                chatController.messages.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : chatController.messages.isEmpty
                                ? Center(child: Text("Say Hello"))
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: chatController.messages.length,
                                    itemBuilder: (context, index) {
                                      final message =
                                          chatController.messages[index];
                                      return message.senderUsername ==
                                                  widget.userProfile.username &&
                                              message.post != null
                                          ? PostMessageWidget(
                                              text: message.content,
                                              timestampDate: formatDateString(
                                                  message.createdAt),
                                              timestampTime: formatDateString(
                                                  message.createdAt),
                                              mediaList: message.media,
                                              post: message.post,
                                              isUser: true,
                                            )
                                          : message.senderUsername ==
                                                  widget.userProfile.username
                                              ? OwnMessage(
                                                  text: message.content,
                                                  timestampDate:
                                                      formatDateString(
                                                          message.createdAt),
                                                  timestampTime:
                                                      formatDateString(
                                                          message.createdAt),
                                                  mediaList: message.media,
                                                )
                                              :
                                              //  message.post != null
                                              //     ? PostMessageWidget(
                                              //         text: message.content,
                                              //         timestampDate:
                                              //             formatDateString(
                                              //                 message
                                              //                     .createdAt),
                                              //         timestampTime:
                                              //             formatDateString(
                                              //                 message
                                              //                     .createdAt),
                                              //         mediaList: message.media,
                                              //         post: message.post,
                                              //         isUser: false,
                                              //       )
                                              //     :
                                              buildUserMessage(
                                                  post: message.post,
                                                  timestamp: formatDateString(
                                                      message.createdAt),
                                                  userProfile:
                                                      widget.userProfile,
                                                  messageModel: message,
                                                );
                                    },
                                  ),
                      ),
                      ChatInputField(
                        messageController: messageController,
                        onPressedSend: () async {
                          try {
                            await chatController.sendMessage(
                              messageController.text.trim(),
                              widget.chatModel.id,
                              [],
                            );
                            setState(() => messageController.clear());
                            Future.delayed(
                                Duration(milliseconds: 300), _scrollToBottom);
                          } catch (_) {}
                        },
                        chatModel: widget.chatModel,
                        onCameraChat: () {
                          Future.delayed(
                              Duration(milliseconds: 300), _scrollToBottom);
                        },
                        chatController: chatController,
                      ),
                    ],
                  ),
                  if (moreLoading)
                    Positioned(
                      top: 30,
                      left: 0,
                      right: 0,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Material(
      elevation: 0.3,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (widget.isCreated || widget.isNotification) {
                final authToken = await Prefrences.getAuthToken();
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => MainScreen(
                      userProfile: widget.userProfile,
                      authToken: authToken,
                      selectedIndex: 3,
                    ),
                  ),
                );
              } else {
                Navigator.pop(context, true);
              }
            },
          ),
          CircleAvatar(
            backgroundImage: widget.participantImage != null &&
                    widget.participantImage!.isNotEmpty
                ? NetworkImage(
                    widget.participantImage!,
                  )
                : AssetImage('assets/icons/profile.png') as ImageProvider,
          ),
          SizedBox(width: 10),
          Text(widget.chatName ?? widget.chatModel.participants[0].username,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
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
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
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
    );
  }
}
