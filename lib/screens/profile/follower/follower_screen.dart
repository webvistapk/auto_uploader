import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/models/follower_following/follower_model.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/profile/follower/widgets/follower_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class FollowersScreen extends StatefulWidget {
  // final List<Follower>? followersList;
  final token;
  final UserProfile? userProfile;
  const FollowersScreen({
    Key? key,
    required this.token,
    required this.userProfile,
  }) : super(key: key);
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<Follower> followers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFollowers();
  }

  Future<void> loadFollowers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? followersData = prefs.getString(Prefrences.followerKey) ?? null;

    if (followersData != null) {
      // Load followers from shared preferences if available
      List<dynamic> followersJson = json.decode(followersData!);
      setState(() {
        followers = followersJson
            .map((followerJson) => Follower.fromJson(followerJson))
            .toList();
        isLoading = false;
      });
    } else {
      log("followersData: $followersData");
      // If no data in shared preferences, fetch from API
      await fetchFollowers(widget.token, widget.userProfile!.id);
    }
  }

  Future<void> fetchFollowers(authtoken, userID) async {
    final String token = authtoken;
    String url = "${ApiURLs.baseUrl}${ApiURLs.fetch_peoples_endpoint}$userID/";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      // debugger();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> followersData = data["followers"] ?? [];
        followers = followersData
            .map((followerJson) => Follower.fromJson(followerJson))
            .toList();

        await Prefrences.saveFollowers(followersData);

        setState(() {
          isLoading = false;
        });
      } else {
        print("Failed to load followers");
      }
    } catch (error) {
      print("Error fetching followers: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      weight: 2,
                    ),
                  ),
                  Text("All Followers", style: AppTextStyles.poppinsSemiBold()),
                  SizedBox(),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: isLoading
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: FollowerShimmerTile(),
                        );
                      },
                    )
                  : followers.isEmpty
                      ? Center(
                          child: Text(
                            "NO FOLLOWERS FOUND!",
                            style: AppTextStyles.poppinsBold(),
                          ),
                        )
                      : ListView.builder(
                          itemCount: followers.length,
                          itemBuilder: (context, index) {
                            Follower follower = followers[index];
                            return FollowerTile(
                              follower: follower,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class FollowerShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 25,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .30,
                height: 12,
                color: Colors.grey[300],
              ),
              SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width * .20,
                height: 12,
                color: Colors.grey[300],
              ),
            ],
          ),
          Spacer(),
          Container(
            height: 40,
            width: 100,
            color: Colors.grey[300],
          ),
          SizedBox(width: 8),
          Icon(Icons.more_vert, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
