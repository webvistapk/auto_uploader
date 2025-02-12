import 'package:flutter/material.dart';

class DiscoursePost extends StatelessWidget {
  final String username;
  final String timestamp;
  final String clubName;
  final String? imageUrl;
  final String content;
  final String profileImageUrl;

  const DiscoursePost({
    Key? key,
    required this.username,
    required this.timestamp,
    required this.clubName,
    this.imageUrl,
    required this.content,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info (Name, Time, Club Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    timestamp,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      clubName,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Post Image (if available)
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl!, fit: BoxFit.cover),
            ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          // User Profile + Actions
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              const SizedBox(width: 8),

              // Action Buttons
              IconButton(
                icon: const Icon(Icons.send, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
