import 'package:flutter/material.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({Key? key}) : super(key: key);

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage>
    with SingleTickerProviderStateMixin {
  final List<String> _locations = [
    'New York, NY',
    'Boston, MA',
    'Seattle, WA',
    'Houston, TX',
    'San Francisco, CA',
    'Austin, TX',
    'Denver, CO',
    'Miami, FL',
    'Portland, OR',
  ];

  List<String> _filteredLocations = [];
  bool _searchingNearby = true;
  String _searchText = '';

  final TextEditingController _controller = TextEditingController();

  // Define colors matching the image
  final Color backgroundColor = Color(0xFFFFFFFF); // white
  final Color searchBarBgColor = Color(0xFFF2F2F7); // very light gray
  final Color primaryTextColor = Color(0xFF1C1C1E); // dark text
  final Color placeholderColor = Color(0xFFAEAEB2); // placeholder gray
  final Color iconColor = Color(0xFF8E8E93); // medium gray
  final Color searchingNearbyColor =
      Color(0xFF8E8E93); // same as icon medium gray
  final Color noMatchColor = Color(0xFFFF3B30); // red for no match

  @override
  void initState() {
    super.initState();
    _filteredLocations = [];
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchText = query.trim();
      if (_searchText.isEmpty) {
        _searchingNearby = true;
        _filteredLocations = [];
      } else {
        _searchingNearby = false;
        _filteredLocations = _locations
            .where(
                (loc) => loc.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();
      }
    });
  }

  Widget _buildLocationList() {
    if (_searchingNearby) {
      return Center(
        child: Text(
          'Searching nearby..',
          style: TextStyle(
            fontSize: 16,
            color: searchingNearbyColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else if (_filteredLocations.isEmpty) {
      return Center(
        child: Text(
          'No location matches',
          style: TextStyle(
            fontSize: 16,
            color: noMatchColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: ListView.separated(
          key: ValueKey<int>(_filteredLocations.length),
          padding: EdgeInsets.symmetric(vertical: 12),
          itemCount: _filteredLocations.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Color(0xFFDFDFE3)),
          itemBuilder: (context, index) {
            final location = _filteredLocations[index];
            return ListTile(
              title: Text(
                location,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: $location')),
                );
              },
              leading: Icon(Icons.location_on, color: iconColor),
              trailing: Icon(Icons.chevron_right, color: iconColor),
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Add Location',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: null,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: iconColor),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: searchBarBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: placeholderColor),
                  prefixIcon: Icon(Icons.search, color: iconColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: primaryTextColor,
                ),
              ),
            ),
            Expanded(child: _buildLocationList()),
          ],
        ),
      ),
    );
  }
}
