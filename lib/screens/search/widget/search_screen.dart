import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/common/app_icons.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<String> searchTerms = [
    "Apple",
    "Banana",
    "Mango",
    "Pear",
    "Watermelons",
    "Blueberries",
    "Pineapples",
    "Strawberries"
  ];

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return SearchWidget(
      query: query.toLowerCase(),
      authToken: Prefrences.getAuthToken().toString(),
    );
  }
}



class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<String> searchTerms = [
    "Apple",
    "Banana",
    "Mango",
    "Pear",
    "Watermelons",
    "Blueberries",
    "Pineapples",
    "Strawberries"
  ];

  List<String> get filteredResults {
    return searchTerms
        .where((term) => term.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
       titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
            onTap: (){},
            child: Icon(Icons.arrow_back_ios,size: 15,),
          ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                color: Color.fromRGBO(234, 232, 232, 1), 
                borderRadius: BorderRadius.circular(8.0),
                      ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      icon: Image.asset(AppIcons.search,width: 20,color: Color(0xffB0B0B0),),
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.publicSans(
                        textStyle: TextStyle(
                          fontSize: 10
                        )
                      ),
                      border: InputBorder.none,
                      
                    ),
                    onChanged: (value) {
                      setState(() {
                        query = value;
                      });
                      
                    },
                  ),
                ),
              ),

               GestureDetector(
          onTap: (){},
          child: Image.asset(AppIcons.filter,width: 20,),
        ),
            ],
          ),
        ),
        
      
      ),
      body:  SearchWidget(query: query.toLowerCase(),
      authToken: Prefrences.getAuthToken().toString(),)
    );
  }
}





