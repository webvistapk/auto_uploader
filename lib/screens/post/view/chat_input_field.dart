import 'package:flutter/material.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';

class ChatInputFieldNoMedia extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback? onPressedSend;
  final ChatModel chatModel;

  const ChatInputFieldNoMedia({
    super.key,
    required this.messageController,
    this.onPressedSend,
    required this.chatModel,
  });

  @override
  State<ChatInputFieldNoMedia> createState() => _ChatInputFieldNoMediaState();
}

class _ChatInputFieldNoMediaState extends State<ChatInputFieldNoMedia> {
  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Emoji Button
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.grey,
            ),
            onPressed: () {
              showEmojiPicker(context);
            },
          ),

          // TextField
          Expanded(
            child: TextField(
              controller: widget.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),

          // Send or Voice Input Button
          widget.messageController.text.isNotEmpty
              ? buildSendButton(widget.onPressedSend)
              : buildVoiceButton(),
        ],
      ),
    );
  }

  Widget buildSendButton(VoidCallback? onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget buildVoiceButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.keyboard_voice_sharp, color: Colors.white),
        onPressed: () {
          // Voice input handler here
        },
      ),
    );
  }

  void showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 100,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  widget.messageController.text += '😊';
                  Navigator.pop(context);
                },
                child: const Center(
                  child: Text('😊', style: TextStyle(fontSize: 28)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
