import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final TextEditingController messageController;
  final onPressedSend;
  InputField(
      {super.key, required this.messageController, this.onPressedSend});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(() {
      setState(() {}); // Rebuild the widget when text changes
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
              // Handle emoji selection (Use a package like emoji_picker_flutter)
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
              // Handle attachment (file picker or gallery)
            },
          ),

          // Camera Button
          IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.grey,
            ),
            onPressed: () {
              // Handle camera action (open camera or photo picker)
            },
          ),

          // Send Button or Voice Button
          widget.messageController.text.isNotEmpty
              ? buildSendButton(widget.onPressedSend)
              : buildVoiceButton(),
        ],
      ),
    );
  }

  // Send Button
  Widget buildSendButton(onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: onPressed),
    );
  }

  // Voice Input Button
  Widget buildVoiceButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.keyboard_voice_sharp, color: Colors.white),
        onPressed: () {
          // Handle voice input (start recording)
        },
      ),
    );
  }

  // Emoji Picker (can be enhanced with a package)
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
            itemCount: 100, // A basic example, can be replaced with emojis
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Add the emoji to the text input field
                  widget.messageController.text += '😊'; // Example emoji
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(
                    '😊',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}