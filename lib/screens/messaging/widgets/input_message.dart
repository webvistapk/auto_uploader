import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({Key? key}) : super(key: key);

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  TextEditingController messageController = TextEditingController();
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
              // Handle emoji selection
            },
          ),

          // TextField
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 5, // Allow multiline input
            ),
          ),

          // Attachments Button
          IconButton(
            icon: const Icon(
              Icons.attach_file,
              color: Colors.grey,
            ),
            onPressed: () {
              // Handle attachment
            },
          ),

          // Camera Button
          IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.grey,
            ),
            onPressed: () {
              // Handle camera action
            },
          ),

          // Send Button
          messageController.text.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Handle send message
                    },
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_voice_sharp,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Handle send message
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
