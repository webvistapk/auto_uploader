import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/controller/store/search/search_store.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:mobile/screens/widgets/top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onSearch: (query) => SearchStore.updateSearchQuery(query),
      ),
      drawer: const SideBar(),
      backgroundColor: AppColors.mainBgColor,
      body: ValueListenableBuilder<String?>(
        valueListenable: SearchStore.searchQuery,
        builder: (context, searchQuery, child) {
          if (searchQuery == null || searchQuery.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 1),
                  Text('Welcome to Tellus',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                      'When you follow people, their content will appear here'),
                  Spacer(flex: 6)
                ],
              ),
            );
          } else {
            return SearchWidget(query: searchQuery);
          }
        },
      ),
      // bottomNavigationBar: BottomBar(
      //   selectedIndex: 0,
      // ),
    );
  }
}
