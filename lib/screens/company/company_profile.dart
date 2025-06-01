import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/screens/company/components/company_overview.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final pages = [
    CompanyOverViewScreen(),
    Center(child: Text("Services")),
    Center(child: Text("Jobs")),
    Center(child: Text("Clubs")),
    Center(child: Text("People")),
    Center(child: Text("Calendar")),
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 6,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_back_ios, size: 22),
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://t3.ftcdn.net/jpg/01/91/85/06/360_F_191850653_IkzN9vZTtOtJ8NTKLKOp8PlaY8iCk6Ls.jpg"),
                      radius: 50,
                    ),
                    Icon(Icons.more_horiz, size: 22),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Aligning text to the start
                children: [
                  Text(
                    "Company Name",
                    style: AppTextStyles.poppinsMedium().copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text("New York, New York",
                      style: AppTextStyles.poppinsRegular(fontSize: 13)),
                ],
              ),
              SizedBox(height: 10),
              Theme(
                data: ThemeData(
                  tabBarTheme: TabBarTheme(
                    labelColor:
                        Colors.black, // Set the color for the selected tab
                    unselectedLabelColor:
                        Colors.grey, // Set the color for unselected tabs
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                          color: Colors.black, width: 2.0), // Indicator color
                    ),
                  ),
                ),
                child: TabBar(
                  isScrollable:
                      false, // Set to false to stretch the tabs evenly
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: 8), // Padding for labels
                  indicatorWeight: 1.0,
                  labelStyle: AppTextStyles.poppinsRegular(),
                  // isScrollable:
                  //     false, // Set to false to stretch the tabs evenly
                  // labelPadding:
                  //     EdgeInsets.symmetric(horizontal: 8), // Padding for labels
                  // indicatorWeight: 1.0,
                  // labelStyle: AppTextStyles.poppinsRegular(),
                  // labelColor:
                  //     Colors.black, // Set the color for the selected tab
                  // unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(
                      child: Text(
                        "Overview",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                        child: Text(
                      "Services",
                      overflow: TextOverflow.ellipsis,
                    )),
                    Tab(
                        child: Text(
                      "Jobs",
                      overflow: TextOverflow.ellipsis,
                    )),
                    Tab(
                        child: Text(
                      "Clubs",
                      overflow: TextOverflow.ellipsis,
                    )),
                    Tab(
                        child: Text(
                      "People",
                      overflow: TextOverflow.ellipsis,
                    )),
                    Tab(
                        child: Text(
                      "Calendar",
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TabBarView(
                    children: pages,
                  ),
                ),
              ),
            ],
          ),
          // Bottom navigation bar
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.token_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color.fromARGB(255, 115, 51, 126),
            unselectedItemColor: Colors.grey[500],
            backgroundColor: Colors.black,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}
