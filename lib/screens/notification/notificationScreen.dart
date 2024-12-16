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
          if (notificationProvider.isLoading) {
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
            itemCount: modelNotifications.length,
            itemBuilder: (context, index) {
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
                      tag: 'actor_${notification.actor.id}',
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          notification.actor.profileImage ??
                              AppUtils.userImage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                                      '${notification.actor.firstName} ${notification.actor.lastName} ',
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
                                    style: TextStyle(fontWeight: FontWeight.bold),
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
                                notification.createdAt,
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
                      icon: const Icon(Icons.chevron_right, color: Colors.grey),
                      onPressed: () {
                        _navigateToDetails(notification);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }

  void _navigateToDetails(notification) {
    if (notification.reel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReelScreen(
            isNotificationReel: true,
            initialIndex: 0,
            reelId: notification.reel!.id.toString(),
            showEditDeleteOptions: true,
          ),
        ),
      );
    } else if (notification.post != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SinglePost(
            postId: notification.post!.id.toString(),
            onPostUpdated: () {},
          ),
        ),
  );
}
}
}