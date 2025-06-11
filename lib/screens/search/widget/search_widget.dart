import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/models/post/post_response_model.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/controller/services/search/search_service.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/search/widget/search_post_widget.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/prefrences/prefrences.dart';

class SearchWidget extends StatefulWidget {
  final String query;
  final String? authToken;
  const SearchWidget({super.key, required this.query, this.authToken});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = 'Content';
  bool isLoading = false;
  List<UserProfile> usersResults = [];
  List<PostModel> postsResults = [];
  int _currentOffset = 0;
  final int _limit = 10;
  
  // Debounce variables
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 500);
  String _lastProcessedQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Fetch posts immediately on init without debounce
    _fetchInitialPostsData();
  }

  @override
 void didUpdateWidget(SearchWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.query != widget.query) {
    // Cancel any previous debounce timer
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    
    // If query is empty, fetch immediately (no debounce)
    if (widget.query.isEmpty) {
      _fetchDataForCurrentCategory();
    } else {
      // Apply debounce only for non-empty queries
      _debounceTimer = Timer(_debounceDelay, _fetchDataForCurrentCategory);
    }
  }
}

  // void _handleQueryChangeWithDebounce() {
  //   // Cancel any previous debounce timer
  //   if (_debounceTimer != null) {
  //     _debounceTimer!.cancel();
  //   }
    
  //   // Start a new debounce timer
  //   _debounceTimer = Timer(_debounceDelay, () {
  //     _fetchDataForCurrentCategory();
  //   });
  // }

 

   void _handleTabChange() {
    setState(() {
      selectedCategory = _getCategoryName(_tabController.index);
      if (selectedCategory == 'Content' || selectedCategory == 'People') {
        if (_debounceTimer != null) {
          _debounceTimer!.cancel();
        }
        // Only fetch if we have a query
        if (widget.query.isNotEmpty) {
          _fetchDataForCurrentCategory();
        } else {
          // Clear results when no query
           if (selectedCategory == 'People') {
            usersResults = [];
          }
        }
      }
    });
  }

  Future<void> _fetchInitialPostsData() async {
  setState(() => isLoading = true);
  try {
    final token = widget.authToken ?? await Prefrences.getAuthToken();
    // Always fetch posts, even with empty query
    await _fetchPostsResults(token);
  } catch (e) {
    debugPrint('Initial posts fetch error: $e');
  } finally {
    setState(() => isLoading = false);
  }
}

   Future<void> _fetchDataForCurrentCategory() async {
  setState(() => isLoading = true);
  try {
    final token = widget.authToken ?? await Prefrences.getAuthToken();
    
    if (selectedCategory == 'People') {
      // Only fetch users if we have a query
      if (widget.query.isNotEmpty) {
        await _fetchUsersResults(token);
      } else {
        usersResults = []; // Clear users when query is empty
      }
    } else if (selectedCategory == 'Content') {
      // Always fetch posts, even with empty query
      await _fetchPostsResults(token);
    }
  } catch (e) {
    debugPrint('Category data fetch error: $e');
  } finally {
    setState(() => isLoading = false);
  }
}

  Future<void> _fetchUsersResults(String token) async {
    try {
      final response = await SearchService.fetchSearchResults(
        widget.query,
        token,
        type: 'users',
        limit: _limit,
        offset: _currentOffset,
      );
      
      setState(() {
        usersResults = (response['users'] as List)
            .map((user) => UserProfile.fromJson(user))
            .toList();
      });
    } catch (e) {
      debugPrint('Users search error: $e');
    }
  }


  Future<void> _fetchPostsResults(String token) async {
    try {
      final response = await SearchService.fetchSearchResults(
        widget.query,
        token,
        type: 'posts',
        limit: _limit,
        offset: _currentOffset,
      );

      final postResponse = PostResponse.fromJson(response);
      setState(() {
        postsResults = postResponse.postModel ?? [];
      });
    } catch (e) {
      debugPrint('Posts search error: $e');
      setState(() => postsResults = []);
    }
  }

  void _navigateToProfile(BuildContext context, int userId) {
    Navigator.push(
      context,
      CupertinoDialogRoute(
        builder: (_) => ProfileScreen(id: userId),
        context: context,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    // Cancel any pending debounce timer when widget is disposed
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    super.dispose();
  }

  String _getCategoryName(int index) {
    switch (index) {
      case 0: return 'Content';
      case 1: return 'People';
      case 2: return 'Business';
      case 3: return 'Jobs';
      case 4: return 'Events';
      case 5: return 'Clubs';
      default: return 'Content';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          physics: const ScrollPhysics(),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          dividerHeight: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          isScrollable: true,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontFamily: 'Greycliff CF',
            fontWeight: FontWeight.bold,
            color: Color(0xff18181),
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Greycliff CF',
            color: Color(0xff848484),
          ),
          tabs: const [
            Tab(child: Text('Content')),
            Tab(child: Text('People')),
            Tab(child: Text('Business')),
            Tab(child: Text('Jobs')),
            Tab(child: Text('Events')),
            Tab(child: Text('Clubs')),
          ],
        ),
        const SizedBox(height: 40),
         Expanded(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : selectedCategory == 'People'
                ? widget.query.isEmpty
                    ? _buildEmptyState('Search for people') // Show when people tab is selected but query is empty
                    : usersResults.isEmpty
                        ? _buildEmptyState('No People Found!')
                        : _buildUsersList()
                : selectedCategory == 'Content'
                    ? postsResults.isEmpty
                        ? _buildEmptyState('No Content Found')
                        : SearchPostWidget(posts: postsResults)
                    : _buildEmptyState('Coming Soon'),
      ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      itemCount: usersResults.length,
      itemBuilder: (context, index) {
        final user = usersResults[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              user.profileUrl != null
                  ? '${user.profileUrl}'
                  : AppUtils.userImage,
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                Image.asset(AppUtils.userImage, width: 38, height: 38),
            ),
          ),
          title: Text(
            user.username ?? '',
            style: const TextStyle(
              color: Color(0xff34342F),
              fontFamily: 'Greycliff CF',
              fontWeight: FontWeight.bold,
              fontSize: 16),
          ),
          subtitle: Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              color: Color(0xff34342F),
              fontSize: 14),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 10, color: Color(0xffB5B5B5)),
            onPressed: () {
              setState(() {
                usersResults.removeAt(index);
              });
            },
          ),
          onTap: () => _navigateToProfile(context, user.id),
        );
      },
    );
  }
}