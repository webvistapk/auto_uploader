import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/models/follower_following/follower_model.dart';
import 'package:mobile/models/follower_following/following_model.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/profile/following/widget/following_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class FollowingScreen extends StatefulWidget {
  final String token;
  final UserProfile? userProfile;

  const FollowingScreen({
    Key? key,
    required this.token,
    required this.userProfile,
  }) : super(key: key);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  List<Following> followings = [];
  bool isLoading = true;
  bool isAscending = true; // Default sorting order

  @override
  void initState() {
    super.initState();
    loadFollowings();
  }

  Future<void> loadFollowings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? followingsData = prefs.getString(Prefrences.followingKey) ?? null;

    if (followingsData != null) {
      // Load followings from shared preferences if available
      List<dynamic> followingsJson = json.decode(followingsData!);
      setState(() {
        followings = followingsJson
            .map((followingJson) => Following.fromJson(followingJson))
            .toList();
        sortFollowings(); // Sort initially based on the selected order
        isLoading = false;
      });
    } else {
      // If no data in shared preferences, fetch from API
      await fetchFollowings(widget.token, widget.userProfile!.id);
    }
  }

  Future<void> fetchFollowings(String authtoken, int userID) async {
    final String token = authtoken;
    String url = "${ApiURLs.baseUrl}${ApiURLs.fetch_peoples_endpoint}$userID/";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> followingsData = data["followings"] ?? [];
        followings = followingsData
            .map((followingJson) => Following.fromJson(followingJson))
            .toList();

        await Prefrences.saveFollowings(followingsData);

        setState(() {
          sortFollowings(); // Sort after fetching data
          isLoading = false;
        });
      } else {
        print("Failed to load followings");
      }
    } catch (error) {
      print("Error fetching followings: $error");
    }
  }

  void sortFollowings() {
    setState(() {
      followings.sort((a, b) {
        int comparison = (a.username ?? '').compareTo(b.username ?? '');
        return isAscending ? comparison : -comparison;
      });
    });
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
                  Text("All Followings",
                      style: AppTextStyles.poppinsSemiBold()),
                  IconButton(
                    icon: Icon(Icons.sort_by_alpha, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        isAscending = !isAscending;
                        sortFollowings();
                      });
                    },
                  ),
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
                  : followings.isEmpty
                      ? Center(
                          child: Text(
                            "NO FOLLOWINGS FOUND!",
                            style: AppTextStyles.poppinsBold(),
                          ),
                        )
                      : ListView.builder(
                          itemCount: followings.length,
                          itemBuilder: (context, index) {
                            Following following = followings[index];
                            return FollowingTile(following: following);
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
