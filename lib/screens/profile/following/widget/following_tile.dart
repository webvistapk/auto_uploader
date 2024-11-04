import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class FollowingTile extends StatelessWidget {
  final String username;
  final String fullName;
  final bool isFollowing;

  const FollowingTile({
    Key? key,
    required this.username,
    required this.fullName,
    required this.isFollowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 25,
            child: Icon(
              Icons.person,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: Text(
                  fullName,
                  style: AppTextStyles.poppinsMedium(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                username,
                style: AppTextStyles.poppinsRegular(),
              ),
            ],
          ),
          Spacer(),
          Container(
            height: 40,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[300],
            ),
            child: Center(
              child: Text(
                isFollowing ? "Message" : "Remove",
                style: AppTextStyles.poppinsRegular(),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
    );
  }
}
