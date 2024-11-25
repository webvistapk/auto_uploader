import 'package:flutter/material.dart';

class RepliedMessage extends StatelessWidget {
  final String text;
  final String? profileUrl; // User profile image URL

  const RepliedMessage({
    Key? key,
    required this.text,
    this.profileUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14),
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
            width: 35,
            height: 35,
            child: ClipOval(
              child: Image.network(
                profileUrl ??
                    "https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-image-182145777.jpg", // Default image URL
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
                // Reply text from a different user
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      // Purple Vertical Line to separate the message and reply
                      Container(
                        width: 4,
                        height: textHeight,
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
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // User's reply message
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 5),
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
                    softWrap: true,
                    overflow: TextOverflow.visible,
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
