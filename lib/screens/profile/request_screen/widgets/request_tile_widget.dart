import 'package:flutter/material.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/screens/profile/request_screen/widgets/profile_pic_widgets.dart';
import 'package:provider/provider.dart';

class RequestListTile extends StatefulWidget {
  String fullName;
  String followerId;
  String status;
   RequestListTile({super.key,required this.fullName,required this.followerId,required this.status});

  @override
  State<RequestListTile> createState() => _RequestListTileState();
}

class _RequestListTileState extends State<RequestListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the profile details screen
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
          /*boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(3, 3),
              blurRadius: 10,
            ),
            *//*BoxShadow(
              //color: Colors.grey.withOpacity(0.2),
             // offset: const Offset(-3, -3),
             // blurRadius: 10,
            ),*//*
          ],*/
        ),
        child: Row(
          children: [
            // Profile Picture Widget
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                  "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=600",
                  width: paragraph*1.45,
              ),
            ),
            /*AnimatedProfilePicture(
              profileImageUrl:
                  'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=600',
              size: paragraph*1.25,
            ),*/
            const SizedBox(width: 20),
            // User Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .25,
                        child: Text(
                          widget.fullName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),

                     widget.status=='accepted'?
                     Container(
                       padding: const EdgeInsets.all(5),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(6),

                       ),
                       child: const Text(
                         "Accepted",
                         style: TextStyle(color: Colors.black),
                       ),
                     ):
                     Row(
                        children: [
                          // Accept Button
                          GestureDetector(
                            onTap: () {
                              // Accept logic
                              Provider.of<follower_request_provider>(context,listen: false).acceptRequest(context, widget.followerId);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.green,
                              ),
                              child: const Text(
                                "Accepted",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          // Reject Button
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // Reject logic
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey,
                              ),
                              child: const Text(
                                "Rejected",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )

                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
