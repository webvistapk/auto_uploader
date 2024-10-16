import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/controller/services/followers/follower_request.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:mobile/models/UserProfile/follower_request.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/profile/request_screen/widgets/request_tile_widget.dart';
import 'package:provider/provider.dart';

import '../../../common/app_size.dart';
import '../../../common/utils.dart';
import '../../../controller/store/search/search_store.dart';
import '../../../models/UserProfile/followers.dart';
import '../../search/widget/search_widget.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/top_bar.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  var userDetails;
  Future<List<FollowerRequestModel>>?
      _followRequests;

  @override
  void initState() {
    super.initState();
    _fetchFollowRequests(); // Initial fetching of data
  }

  void _fetchFollowRequests() {
    setState(() {
      _followRequests =
          Provider.of<follower_request_provider>(context, listen: false)
              .getFollowerRequestList(context);
    });
  }

  Future<void> Refresh() async {
    _fetchFollowRequests();
  }

  Future confirmFollow(int followerId, int followingId, String status,
      BuildContext context) async {
    // Show the confirm dialog
    bool shouldProceed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Follow Request",
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: paragraph * 0.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          content: Builder(builder: (context) {
            return Container(
              padding: EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Row(
                children: [
                  Flexible(child: Text("Are you sure?")),
                ],
              ),
            );
          }),
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(
                        context, false); // Close the dialog and return false
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 20),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey2,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: paragraph / 80, horizontal: paragraph),
                    child: Text("No",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 50),
                InkWell(
                  onTap: () {
                    Navigator.pop(
                        context, true); // Close the dialog and return true
                    Refresh();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.greenColor,
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 20),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey2,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: paragraph / 80, horizontal: paragraph * 0.90),
                    child: Text("Yes",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    // If the user confirmed
    if (shouldProceed == true) {
      // Show the loading dialog or update the state
      setState(() {
        Provider.of<follower_request_provider>(context, listen: false)
            .followRequestResponse(
          context,
          followerId,
          followingId,
          status,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onSearch: (query) => SearchStore.updateSearchQuery(query),
      ),
      drawer: const SideBar(),
      backgroundColor: AppColors.mainBgColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ValueListenableBuilder<String?>(
            valueListenable: SearchStore.searchQuery,
            builder: (context, searchQuery, child) {
              if (searchQuery == null || searchQuery.isEmpty) {
                return Consumer<follower_request_provider>(
                  builder: (context, Provider, child) {
                    return FutureBuilder<List<FollowerRequestModel>>(
                        future:
                            _followRequests, // Reference to the future list of requests
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child:
                                    CircularProgressIndicator()); // Show a loading spinner
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'An error occurred: ${snapshot.error}'));
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final pendingRequests = snapshot.data!
                                .where((request) => request.status == 'pending')
                                .toList();
                            if (pendingRequests.isNotEmpty) {
                              // Build a ListView with the follower requests
                              return ListView.builder(
                                itemCount: pendingRequests.length,
                                itemBuilder: (context, index) {
                                  final followerRequest =
                                      pendingRequests[index];
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      backgroundImage: NetworkImage(AppUtils
                                          .testImage), // Placeholder image
                                    ),
                                    title: Text(
                                      "${followerRequest.follower!.username}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        '${followerRequest.follower!.firstName} ${followerRequest.follower!.lastName}'),
                                    trailing: Wrap(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.check_circle,
                                            color: AppColors.greenColor,
                                            size: paragraph * 0.75,
                                          ),
                                          onPressed: () {
                                            confirmFollow(
                                                followerRequest.follower!.id,
                                                followerRequest.following!.id,
                                                "accepted",
                                                context);
                                            /*Provider.followRequestResponse(
                                        context,
                                        followerRequest.follower!.id,
                                        followerRequest.following!.id,
                                        "accepted"
                                );*/
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_forever,
                                            color: AppColors.primary,
                                            size: paragraph * 0.75,
                                          ),
                                          onPressed: () {
                                            //Reject Request
                                            confirmFollow(
                                                followerRequest.follower!.id,
                                                followerRequest.following!.id,
                                                "rejected",
                                                context);
                                          },
                                        ),
                                      ],
                                    ), // Navigate to profile on tap
                                  );

                                  /*RequestListTile(
                                                    fullName: "${followerRequest.follower?.firstName} ${followerRequest.follower?.lastName}",
                                                    followerId: followerRequest.follower!.id.toString(),
                                                    followingId:followerRequest.following!.id.toString(),
                                                    status:status
                                                  );*/
                                },
                              );
                            } else {
                              return Center(
                                child: Text('No follow requests available'),
                              );
                            }
                          } else {
                            return Center(
                              child: Text('No follow requests available'),
                            );
                          }
                        });
                  },
                );
              } else {
                return SearchWidget(
                  query: searchQuery,
                  authToken: Prefrences.getAuthToken().toString(),
                );
              }
            }),
      ),
    );
  }
}
