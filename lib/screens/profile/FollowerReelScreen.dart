// FollowerReelScreen.dart
import 'package:flutter/material.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:provider/provider.dart';
import '../../controller/services/post/post_provider.dart';
import '../../models/ReelPostModel.dart';
import 'ReelScreen.dart';

class FollowerReelScreen extends StatefulWidget {
  const FollowerReelScreen({Key? key}) : super(key: key);

  @override
  State<FollowerReelScreen> createState() => _FollowerReelScreenState();
}

class _FollowerReelScreenState extends State<FollowerReelScreen> {
  List<ReelPostModel> _reels = [];

  @override
  void initState() {
    super.initState();
    _fetchReelPosts();
  }

  Future<void> _fetchReelPosts() async {
    try {
     Future<UserProfile?> userProfile=UserPreferences().getCurrentUser();
      UserProfile? currentUserID; 
      userProfile.then((value){
        currentUserID=value!;
      });
      
      List<ReelPostModel> fetchedReels = await Provider.of<PostProvider>(context, listen: false)
          .fetchFollowersReels(context,currentUserID!.id);
      setState(() {
        _reels = fetchedReels;
      });
    } catch (e) {
      print("Error fetching reels: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReelScreen(
     // reels: _reels,
      showEditDeleteOptions: false, // Hide edit/delete options in this context
      isUserScreen: false,
    );
  }
}
