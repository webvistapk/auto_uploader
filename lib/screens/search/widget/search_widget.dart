import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/controller/services/search/search_service.dart';
import 'package:mobile/screens/search/widget/search_post_widget.dart';

class SearchWidget extends StatefulWidget {
  final String query;
  final authToken;
  const SearchWidget({super.key, required this.query, this.authToken});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = 'People'; // Changed default to People
  bool isLoading = false;
  List<String> imageList = [
    'assets/images/TestImage (1).png',
    'assets/images/TestImage (2).png',
    'assets/images/TestImage (3).png',
    'assets/images/TestImage (4).png',
    'assets/images/girl-image.png',
    'assets/images/girl-image.png',
    
  ];
  Map<String, List<UserProfile>> data = {
   
    'People': [], // This will now hold user search results
     'Content': [],
    'Business': [],
    'Jobs': [],
    'Events': [],
    'Clubs': [],
    'Recents': [],
  };

  String? token;
  getAuthToken() async {
    if (widget.authToken == null) {
      token = await Prefrences.getAuthToken();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedCategory = _getCategoryName(_tabController.index);
      });
    });
    if (widget.authToken == null) {
      getAuthToken();
      _fetchSearchResults(context, widget.query, token!);
    } else {
      _fetchSearchResults(context, widget.query, widget.authToken);
    }
  }

  @override
  void didUpdateWidget(covariant SearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _fetchSearchResults(context, widget.query, widget.authToken);
    }
  }

  Future<void> _fetchSearchResults(
      context, String query, String authToken) async {
    setState(() {
      isLoading = true;
    });
    authToken = await Prefrences.getAuthToken();

    try {
      if (query.isNotEmpty) {
        final userResults =
            await SearchService.fetchSearchResults(query, authToken);

        setState(() {
          // Changed to store results in People instead of Content
          data['People'] = userResults;
          data['Recents'] = userResults;
        });
      }
    } catch (e) {
      // ToastNotifier.showErrorToast(
      //     context, "Error fetching search results: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeUser(int index) {
    setState(() {
      data[selectedCategory]!.removeAt(index);
      if (selectedCategory != 'People') {
        // Changed from Content to People
        data['People']!.removeAt(index);
      }
    });
  }

  void _navigateToProfile(BuildContext context, int userId) async {
    SearchStore.searchQuery.value = null;

    Navigator.push(
        context,
        CupertinoDialogRoute(
            builder: (_) => ProfileScreen(id: userId), context: context));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'People';
      case 1:
        return 'Content'; 
      case 2:
        return 'Business';
      case 3:
        return 'Jobs';
      case 4:
        return 'Events';
      case 5:
        return 'Clubs';
      default:
        return 'People'; // Changed default to People
    }
  }

  List<UserProfile> _searchUsers(String category) {
    return data[category]!;
  }

  @override
  Widget build(BuildContext context) {
    final results = _searchUsers(selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          physics: ScrollPhysics(),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          dividerHeight: 0,
          padding: EdgeInsets.symmetric(horizontal: 20),
          isScrollable: true,
          labelStyle: TextStyle(
              fontSize: 12,
              fontFamily: 'Greycliff CF',
              fontWeight: FontWeight.bold,
              color: Color(0xff18181)),
          unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Greycliff CF',
              color: Color(0xff848484)),
          tabs: const [
            Tab(child: Text('People')), // People is now the second tab
            Tab(child: Text('Content')),
            Tab(child: Text('Business')),
            Tab(child: Text('Jobs')),
            Tab(child: Text('Events')),
            Tab(child: Text('Clubs')),
          ],
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // You can add content specific headers here if needed
            ],
          ),
        ),
        
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : selectedCategory == 'People' && results.isEmpty
                  ? Center(
                      child: Text("No People Found!"),
                    )
                  :selectedCategory=="Content"?
                  SearchPostWidget(
                        imageList: imageList,
                      )
                  : selectedCategory != 'People'
                      ? Center(
                        child: Text("No Data Found"),
                      )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final user = results[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  user.profileUrl != null
                                      ? ApiURLs.baseUrl
                                              .replaceAll("/api/", '') +
                                          user.profileUrl.toString()
                                      : AppUtils.userImage,
                                  width: 38,
                                  height: 38,
                                ),
                              ),
                              title: Text(
                                user.username!,
                                style: TextStyle(
                                    color: Color(0xff34342F),
                                    fontFamily: 'Greycliff CF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              subtitle: Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: TextStyle(
                                      color: Color(0xff34342F), fontSize: 14)),
                              trailing: IconButton(
                                icon: const Icon(Icons.close,
                                    size: 10, color: Color(0xffB5B5B5)),
                                onPressed: () {
                                  _removeUser(index);
                                },
                              ),
                              onTap: () => _navigateToProfile(context, user.id),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
