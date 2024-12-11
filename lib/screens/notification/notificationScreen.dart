import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/notification/controller/notificationProvider.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const SideBar(),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return Center(child: Text('No Notifications'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(notification.actor.profileImage??AppUtils.userImage)
          
                ),
                title: Text(
                    '${notification.actor.firstName} ${notification.actor.lastName} ${notification.action} ${notification.reel != null
                    ? 'on Reel'
                    : notification.post != null
                        ? 'on Post: ${notification.post!.post}'
                        : notification.comment != null
                            ? 'on Comment: ${notification.comment!.content}'
                            : ''}',style: TextStyle(
                      fontSize: 12
                    ),),
                // subtitle: Text(notification.reel != null
                //     ? 'on Reel'
                //     : notification.post != null
                //         ? 'on Post: ${notification.post!.post}'
                //         : notification.comment != null
                //             ? 'on Comment: ${notification.comment!.content}'
                //             : '',style: TextStyle(fontSize: 10),),
                trailing: Text(
                  '${notification.createdAt.toLocal()}'.split(' ')[0], // Format date
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                onTap: () {
                  // Handle tap action
                  if (notification.reel != null) {
                    // Navigate to reel
                  } else if (notification.post != null) {
                    // Navigate to post
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
