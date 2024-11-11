import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/models/follower_following/following_model.dart';

class FollowingTile extends StatelessWidget {
  final Following following;

  const FollowingTile({
    Key? key,
    required this.following,
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
            child: following.profileImage != null &&
                    following.profileImage!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      following.profileImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.grey[700],
                        size: 30,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.grey[700],
                    size: 30,
                  ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: Text(
                  "${following.firstName}  ${following.lastName}",
                  style: AppTextStyles.poppinsMedium(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                following.username ?? "",
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
                following.isFollowing ?? false ? "Message" : "Remove",
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
