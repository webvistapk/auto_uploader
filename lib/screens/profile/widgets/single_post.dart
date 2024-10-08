import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String username;
  final String location;
  final String date;
  final String caption;
  final String postImageUrl;
  final String profileImageUrl;
  final String likes;
  final String comments;
  final String shares;
  final String saved;

  const PostWidget({
    Key? key,
    required this.username,
    required this.location,
    required this.date,
    required this.caption,
    required this.postImageUrl,
    required this.profileImageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(profileImageUrl), // User Profile Image
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    location,
                    style: TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.more_horiz),
            ],
          ),
          SizedBox(height: 10),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              postImageUrl, // Post Image
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),

          // Date and Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),

              // Pagination
              Text(
                '1 of 4',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 9,
                ),
              ),

              // Interaction Icons Row
              Row(
                children: [
                  Column(
                    children: [
                      Icon(Icons.bookmark_border, size: 20),
                      Text(saved, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.favorite_border, size: 20),
                      Text(likes, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.comment, size: 20),
                      Text(comments, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Icon(Icons.share, size: 20),
                      Text(shares, style: TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Caption
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                  ),
                  children: [
                    TextSpan(
                      text: '$username ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: caption,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Comment with Avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl), // Replace with actual image
                    radius: 15,
                  ),
                  SizedBox(width: 10),

                  // Comment
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                        children: [
                          TextSpan(
                            text: '$username ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'This is a comment on a photo. I wonder if it should be the same size/color as the caption',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // View all comments link
              Text(
                'View all $comments comments',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
