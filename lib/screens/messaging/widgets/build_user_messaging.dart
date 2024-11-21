import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';

class buildUserMessage extends StatelessWidget {
  final String timestamp;
  final UserProfile userProfile;
  final MessageModel messageModel;
  const buildUserMessage(
      {super.key,
      required this.timestamp,
      required this.userProfile,
      required this.messageModel});

  @override
  Widget build(BuildContext context) {
    return _buildUserMessage(messageModel);
  }

  Widget _buildUserMessage(MessageModel messageModel) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timestamp,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // User Image
              SizedBox(
                width: 35, // Fixed width
                height: 35, // Fixed height
                child: ClipOval(
                  // Ensures the image is circular
                  child: Image.network(
                    userProfile.profileUrl ??
                        "https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-image-182145777.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                  width: 4), // Spacing between the image and the message bubble
              // Message Bubble
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 4, right: 30, top: 3, bottom: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    messageModel.content,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true, // Allows text to wrap to the next line
                    overflow: TextOverflow.visible, // Prevents text truncation
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
