import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/store/search/search_store.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/services/search/search_service.dart';

class SearchWidget extends StatefulWidget {
  final String query;
  const SearchWidget({super.key, required this.query});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = 'All';
  bool isLoading = false;

  Map<String, List<UserProfile>> data = {
    'All': [],
    'Accounts': [],
    'Photos': [],
    'Pages': [],
    'Videos': [],
    'Slides': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedCategory = _getCategoryName(_tabController.index);
      });
    });

    _fetchSearchResults(widget.query);
  }

  @override
  void didUpdateWidget(covariant SearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _fetchSearchResults(widget.query);
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final userResults = await SearchService.fetchSearchResults(query);

      setState(() {
        data['All'] = userResults;
        data['Accounts'] = userResults;
      });
    } catch (e) {
      print("Error fetching search results: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeUser(int index) {
    setState(() {
      data[selectedCategory]!.removeAt(index);
      if (selectedCategory != 'All') {
        data['All']!.removeAt(index);
      }
    });
  }

  void _navigateToProfile(BuildContext context, int userId) {
    SearchStore.searchQuery.value = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
        settings: RouteSettings(arguments: userId),
      ),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'All';
      case 1:
        return 'Accounts';
      case 2:
        return 'Photos';
      case 3:
        return 'Pages';
      case 4:
        return 'Videos';
      case 5:
        return 'Slides';
      default:
        return 'All';
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
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Accounts'),
            Tab(text: 'Photos'),
            Tab(text: 'Pages'),
            Tab(text: 'Videos'),
            Tab(text: 'Slides'),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Implement "See all" functionality
                },
                child:
                    const Text('See all', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final user = results[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundImage:
                            NetworkImage(Utils.testImage), // Placeholder image
                      ),
                      title: Text(
                        user.username!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${user.firstName} ${user.lastName}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
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
