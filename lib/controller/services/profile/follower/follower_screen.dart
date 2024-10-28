import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  final Map<String, dynamic> data = {
    "followers": [
      {
        "id": 2,
        "username": "testuser2",
        "first_name": "Test",
        "last_name": "User2",
        "isFollowing": true
      },
      {
        "id": 3,
        "username": "kashif",
        "first_name": "Kashif",
        "last_name": "Mahar",
        "isFollowing": false
      },
      {
        "id": 4,
        "username": "afrasiyabkk",
        "first_name": "Afrasiyab",
        "last_name": "Kakakhel",
        "isFollowing": false
      }
    ],
    "status": "success"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Followers"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Large profile icon at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data["followers"].length,
              itemBuilder: (context, index) {
                var follower = data["followers"][index];
                return FollowerTile(
                  username: follower["username"],
                  fullName:
                      "${follower["first_name"]} ${follower["last_name"]}",
                  isFollowing: follower["isFollowing"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FollowerTile extends StatelessWidget {
  final String username;
  final String fullName;
  final bool isFollowing;

  const FollowerTile({
    Key? key,
    required this.username,
    required this.fullName,
    required this.isFollowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        radius: 25,
        child: Icon(
          Icons.person,
          color: Colors.grey[700],
        ),
      ),
      title: Text(
        username,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(fullName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFollowing) ...[
            TextButton(
                onPressed: () {},
                child: Text(
                  'Follow',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ))
          ],
          // Conditionally show Follow/Message button based on isFollowing status
          isFollowing
              ? ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  child: Text("Message"),
                )
              : ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  child: Text("Remove"),
                ),

          // ElevatedButton(
          //   onPressed: () {},
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(horizontal: 12),
          //     backgroundColor: Colors.transparent,
          //     foregroundColor: Colors.blue,
          //     elevation: 0,
          //     side: BorderSide(color: Colors.blue),
          //   ),
          //   child: Text("Follow"),
          // ),

          SizedBox(width: 8),
          // Remove Button
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

void main() {
  runApp(MaterialApp(
    home: FollowersScreen(),
  ));
}
