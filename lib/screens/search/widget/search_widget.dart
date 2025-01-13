import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/controller/services/search/search_service.dart';

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
  String selectedCategory = 'Content';
  bool isLoading = false;

  Map<String, List<UserProfile>> data = {
    'Content': [],
    'People': [],
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

    print("Init State is called");
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
    // debugger();
    try {
      if (query.isNotEmpty) {
        final userResults =
            await SearchService.fetchSearchResults(query, authToken);
        print("Auth Token ${authToken}");
        print("User Results ${userResults}");
        // debugger();
        setState(() {
          data['Content'] = userResults;
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
      if (selectedCategory != 'Content') {
        data['Content']!.removeAt(index);
      }
    });
  }

  void _navigateToProfile(BuildContext context, int userId)async {
    SearchStore.searchQuery.value = null;
   
    Navigator.push(
        context,
        CupertinoDialogRoute(
            builder: (_) => ProfileScreen(id: userId), context: context,));
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => ProfileScreen(
    //       id: userId,
    //     ),
    //     settings: RouteSettings(arguments: userId),
    //   ),
    //   (Route<dynamic> route) => false, // Remove all previous routes
    // );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'Content';
      case 1:
        return 'People';
      case 2:
        return 'Business';
      case 3:
        return 'Jobs';
      case 4:
        return 'Event';
      case 5:
        return 'Clubs';
      default:
        return 'Content';
    }
  }

  List<UserProfile> _searchUsers(String category) {
    return data[category]!;
  }

  @override
  Widget build(BuildContext context) {
    // debugger();
    final results = _searchUsers(selectedCategory);

    //final recommended=_searchUsers("")
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
          labelStyle: GoogleFonts.publicSans(
              textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff18181))),
          unselectedLabelStyle: GoogleFonts.publicSans(
              textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff848484))),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   'Recents',
              //   style: GoogleFonts.publicSans(
              //     textStyle: TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.bold
              //     )
              //   ),
              // ),
              // TextButton(
              //   onPressed: () {
              //     // Implement "See all" functionality
              //   },
              //   child:
              //       const Text('See all', style: TextStyle(color: Colors.red)),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : results.isEmpty
                  ? Center(
                      child: Text("No Result Found!"),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final user = results[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              user.profileUrl == ''
                                  ? user.profileUrl.toString()
                                  : AppUtils.userImage,
                              width: 38,
                              height: 38,
                            ),
                          ),
                          title: Text(
                            user.username!,
                            style: GoogleFonts.publicSans(
                                textStyle: TextStyle(
                                    color: Color(0xff34342F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                          subtitle: Text('${user.firstName} ${user.lastName}',
                              style: GoogleFonts.publicSans(
                                  textStyle: TextStyle(
                                      color: Color(0xff34342F),
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14))),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                size: 10, color: Color(0xffB5B5B5)),
                            onPressed: () {
                              _removeUser(index);
                            },
                          ),
                          onTap: () => _navigateToProfile(
                              context, user.id), // Navigate to profile on tap
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
