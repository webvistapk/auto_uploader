import 'package:flutter/material.dart';

class RepliedStory extends StatelessWidget {
  final String text;
  final String? profileUrl;
  final String? storyImageUrl;

  const RepliedStory({
    Key? key,
    required this.text,
    this.profileUrl,
    this.storyImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                profileUrl ?? 'https://via.placeholder.com/35',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Message Bubble
          Expanded(
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
                    storyImageUrl ?? 'https://via.placeholder.com/90x120',
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
