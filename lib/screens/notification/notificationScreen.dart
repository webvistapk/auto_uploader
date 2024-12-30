import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/CommentModel.dart';
import 'package:mobile/screens/notification/controller/notificationProvider.dart';
import 'package:mobile/screens/profile/ReelScreen.dart';
import 'package:mobile/screens/profile/SinglePost.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _limit = 10;
  int _offset = 0;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Initially fetch notifications with the first set of data
    _fetchNotifications();
  }

  void _fetchNotifications() {
    Provider.of<NotificationProvider>(context, listen: false)
        .fetchNotifications(limit: _limit, offset: _offset);
  }

  void _loadMoreNotifications() {
    setState(() {
      _isLoadingMore = true;
      _offset +=
          _limit; // Increment offset to fetch the next set of notifications
    });

    _fetchNotifications();

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const SideBar(),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading && _offset == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          final modelNotifications = notificationProvider.notifications;

          if (modelNotifications.isEmpty) {
            return const Center(
              child: Text(
                'No Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: modelNotifications.length +
                (notificationProvider.nextOffset != -1
                    ? 1
                    : 0), // Extra item for the button
            itemBuilder: (context, index) {
              print("INdex ${index}");
              print("Length ${modelNotifications.length}");
              if (index < modelNotifications.length) {
                final notification = modelNotifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Hero(
                        tag: 'actor_${notification.actor!.id}',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(
                            notification.actor!.profileImage ??
                                AppUtils.userImage,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      //Text(notification.actio)
                      // Notification Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '${notification.actor!.firstName} ${notification.actor!.lastName} ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '${notification.action} ',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (notification.reel != null)
                                    const TextSpan(
                                      text: 'on your Reel',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  if (notification.post != null)
                                    TextSpan(
                                      text:
                                          'on your Post: ${notification.post!.post}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.createdAt.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Navigation Button
                      IconButton(
                        icon:
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        onPressed: () {
                          _navigateToDetails(notification);
                        },
                      ),
                    ],
                  ),
                );
              } else {
                // This is the "Show More" button
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: _isLoadingMore
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: _loadMoreNotifications,
                            child: const Text('Show More Notifications'),
                          ),
                  ),
                );
              }
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }

  void _navigateToDetails(notification) {
    print("Notification ${notification.action}");
    //   debugger();
    if (notification.reel != null) {
      if (notification.action == 'commented') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelScreen(
                isNotificationReel: true,
                initialIndex: 0,
                reelId: notification.reel!.id.toString(),
                commentHightlightId: notification.comment.id.toString(),
                showEditDeleteOptions: true,
                isUserScreen: false),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelScreen(
              isNotificationReel: true,
              initialIndex: 0,
              showEditDeleteOptions: true,
              isUserScreen: false,
            ),
          ),
        );
      }
    }

    //Reply for Reel
    else if (notification.action == 'replied' &&
        notification.reply.postOrReel.type == 'reel') {
      print("Reply navigated for Reel");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReelScreen(
            isNotificationReel: true,
            initialIndex: 0,
            reelId: notification.reel!.id.toString(),
            commentHightlightId: notification.comment.id.toString(),
            replyHighlightId: notification.reply.result.id.toString(),
            showEditDeleteOptions: true,
            isUserScreen: false,
          ),
        ),
      );
    }

//Reply for Post
    else if (notification.action == 'replied' &&
        notification.reply.postOrReel.type == 'post') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SinglePost(
            postId: notification.reply.postOrReel.data['id'].toString(),
            commentId: notification.comment!.id.toString(),
            replyID: notification.reply.result.id.toString(),
            onPostUpdated: () {},
          ),
        ),
      );
    } else if (notification.post != null) {
      //Navigate to commetn

      if (notification.action == 'commented') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePost(
              postId: notification.post!.id.toString(),
              commentId: notification.comment.id.toString(),
              onPostUpdated: () {},
            ),
          ),
        );
      }

      //Navigate to Post
      else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePost(
              postId: notification.post!.id.toString(),
              //commentId: notification.comment!.id.toString(),
              onPostUpdated: () {},
            ),
          ),
        );
      }
    }
  }
}
