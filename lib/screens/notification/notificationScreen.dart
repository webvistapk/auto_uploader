import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/CommentModel.dart';
import 'package:mobile/screens/notification/controller/notificationProvider.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const SideBar(),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                        notification.actor.profileImage ?? AppUtils.userImage),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${notification.actor.firstName} ${notification.actor.lastName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${notification.action} ',
                        ),
                        if (notification.reel != null)
                          const TextSpan(
                              text: 'on your Reel',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        if (notification.post != null)
                          TextSpan(
                              text: 'on your Post: ${notification.post!.post}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        if (notification.comment != null)
                          TextSpan(
                              text:
                                  'on Comment: ${notification.comment!.content}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    '${notification.createdAt.toLocal()}'.split(' ')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    onPressed: () {
                      if (notification.reel != null) {
                        // Navigate to reel
                      } else if (notification.post != null) {
                        // Navigate to post
                      }
                    },
                  ),
                  onTap: () {
                    if (notification.reel != null) {
                      // Navigate to reel
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReelScreen(
                            isNotificationReel: true,
                            initialIndex: 0,
                            reelId: notification.reel!.id
                                .toString(), // Pass the reel ID here
                            showEditDeleteOptions: true,
                          ),
                        ),
                      );
                    } else if (notification.post != null) {
                      // Navigate to post

                      //print("Comment ID is HERE: ${notification.comment!.id.toString()}");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SinglePost(
                                  postId: notification.post!.id.toString(),
                                  onPostUpdated: () {})));
                    } else if (notification.post != null &&
                        notification.comment != null) {
                      print(
                          "Comment ID is HERE2: ${notification.comment!.id.toString()}");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SinglePost(
                                  postId: notification.post!.id.toString(),
                                  commentId:
                                      notification.comment!.id.toString(),
                                  onPostUpdated: () {})));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}
