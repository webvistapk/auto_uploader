// UserReelScreen.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:provider/provider.dart';
import '../../controller/services/post/post_provider.dart';
import '../../models/ReelPostModel.dart';
import 'ReelScreen.dart';

class UserReelScreen extends StatefulWidget {
  const UserReelScreen({Key? key}) : super(key: key);

  @override
  State<UserReelScreen> createState() => _UserReelScreenState();
}

class _UserReelScreenState extends State<UserReelScreen> {
  List<ReelPostModel> _reels = [];
  int limit = 10;
  int offset = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchReelPosts();
  }

  Future<void> _fetchReelPosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserProfile? userProfile = await UserPreferences().getCurrentUser();
      String? userId = userProfile!.id.toString();
      if (userId == null) {
        print("Error: User ID is null. Please check the preferences.");
        // Optionally, navigate the user to the login screen here.
        return;
      }

      print("UserID: $userId");

      List<ReelPostModel> fetchedReels = await Provider.of<PostProvider>(context, listen: false)
          .fetchReels(context, userId, limit, offset);

      setState(() {
        _reels.addAll(fetchedReels);
        offset += limit;
        if (fetchedReels.length < limit) _hasMore = false;
      });
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReelScreen(
      //reels: _reels,
      showEditDeleteOptions: false, // Hide edit/delete options in this context
      isUserScreen: false,
    );
  }
}
