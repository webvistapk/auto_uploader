import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/messaging/widgets/input_message.dart';

class InboxScreen extends StatefulWidget {
  final UserProfile userProfile;
  InboxScreen({Key? key, required this.userProfile}) : super(key: key);
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String? replyMessage;

  var image =
      "https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-image-182145777.jpg";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
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
                            child: const Icon(Icons.arrow_back)),
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
                                  widget.userProfile.profileUrl ?? image),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Claudia Jones',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'user_name',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
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
                    )
                  ],
                ),
              ),
              // Chat List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildUserMessage(
                        "Lorem ipsum dolor sit ametLorem ipsum dolor sit ameLorem ipsum dolor sit ameLorem ipsum dolor sit ameLorem ipsum dolor ..."),
                    _buildOwnMessage(
                        "Lorem ipsum dolor sit ametLorem ipsum dolor sit ametLorem ipsum dolor amet..."), // Sent message

                    repliedStory(
                        'Lorem ipsum dolor sit ametLorem ipsum dolor sit ametLorem ipsum dolor amet...'),
                    repliedmessage('Replying woulf like this'),
                    _buildOwnMessage(
                        "Lorem ipsum dolor sit ametLorem ipsum dolor sit ametLorem ipsum dolor amet..."),
                  ],
                ),
              ),

              // Input Field
              // Input Field
              ChatInputField()
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "03/28/23 4:58 AM",
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
                    widget.userProfile.profileUrl ?? image,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    text,
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

  // Method to build the sender's (own) message bubble (left-aligned)
  Widget _buildOwnMessage(String text) {
    return Align(
      alignment: Alignment.centerRight, // Align to the right
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Align items to the end
        children: [
          // Timestamp
          const Text(
            "03/28/23 4:58 AM",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Push everything to the right
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Message Bubble
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(left: 55, right: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 103, 207, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true, // Allows text to wrap to the next line
                    overflow: TextOverflow.visible, // Prevents text truncation
                  ),
                ),
              ),
              const SizedBox(
                  width: 4), // Spacing between the message bubble and the image
            ],
          ),
          const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'sent',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ))
        ],
      ),
    );
  }

  Widget repliedStory(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User Image
          SizedBox(
            width: 35, // Fixed width
            height: 35, // Fixed height
            child: ClipOval(
              // Ensures the image is circular
              child: Image.network(
                widget.userProfile.profileUrl ?? image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
              width: 4), // Spacing between the image and the message bubble
          // Message Bubble
          Expanded(
            // This allows the text to dynamically expand based on content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Replied to your story',
                  style: TextStyle(fontSize: 8, color: Colors.grey),
                ),
                SizedBox(
                  width: 90,
                  height: 120,
                  child: Image.network(
                    widget.userProfile.profileUrl ?? image,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 4, right: 30, top: 3, bottom: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true, // Allows text to wrap to the next line
                    overflow: TextOverflow.visible, // Prevents text truncation
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget repliedmessage(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14), // Same style as used for the text
      ),
      maxLines: null,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    // Layout the text to calculate the height
    textPainter.layout(maxWidth: double.infinity);

    // Get the height of the text (textPainter.height will give the height)
    double textHeight = textPainter.height;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User Image
          SizedBox(
            width: 35, // Fixed width
            height: 35, // Fixed height
            child: ClipOval(
              // Ensures the image is circular
              child: Image.network(
                widget.userProfile.profileUrl ?? image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
              width: 4), // Spacing between the image and the message bubble
          // Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reply text from different user
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      // Purple Vertical Line to separate the message and reply
                      Container(
                        width: 4, // Thickness of the line
                        height:
                            textHeight, // Height of the line is dynamic based on text
                        color: Colors.purple,
                      ),
                      const SizedBox(
                          width: 6), // Space between the line and text
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Different User",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            Text(
                              text,
                              style: const TextStyle(fontSize: 10),
                              softWrap:
                                  true, // Allows text to wrap to the next line
                              overflow: TextOverflow
                                  .visible, // Prevents text truncation
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // User's reply message
                Container(
                  margin: const EdgeInsets.only(
                      left: 10, top: 5), // Adjusted margin
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true, // Allows text to wrap to the next line
                    overflow: TextOverflow.visible, // Prevents text truncation
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
