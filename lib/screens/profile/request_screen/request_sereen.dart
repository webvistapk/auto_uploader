import 'package:flutter/material.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:mobile/models/UserProfile/follower_request.dart';
import 'package:mobile/screens/profile/request_screen/widgets/request_tile_widget.dart';
import 'package:provider/provider.dart';

import '../../../models/UserProfile/followers.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  var userDetails;
  Future<List<FollowerRequestModel>>? _followRequests; // Changed to a list of requests


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _followRequests = Provider.of<follower_request_provider>(context, listen: false).getFollowerRequestList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              "Follow requests",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Use FutureBuilder to fetch and display follower requests
          FutureBuilder<List<FollowerRequestModel>>(
            future: _followRequests, // Reference to the future list of requests
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show a loading spinner
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('An error occurred: ${snapshot.error}')
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                // Build a ListView with the follower requests
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final followerRequest = snapshot.data![index];
                      String status=followerRequest.status.toString();
                      return RequestListTile(
                        fullName: "${followerRequest.follower?.firstName} ${followerRequest.follower?.lastName}",
                        followerId: followerRequest.follower!.id.toString(),
                        status:status
                      );
                    },
                  ),
                );
              } else {
                return Center(
                  child: Text('No follow requests available'),
                );
              }
            },
          ),

          ],
        ),
      ),
    );
  }
}
