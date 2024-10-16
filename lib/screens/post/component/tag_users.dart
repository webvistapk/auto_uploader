import 'package:flutter/material.dart';

class SearchableDialog extends StatefulWidget {
  const SearchableDialog({super.key});

  @override
  _SearchableDialogState createState() => _SearchableDialogState();
}

class _SearchableDialogState extends State<SearchableDialog> {
  List<Map<String, String>> _allItems =
      []; // Store all items with names and images
  List<Map<String, String>> _filteredItems =
      []; // Store filtered items for searching
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with some dummy data for demonstration
    _allItems = [
      {
        'name': 'John Doe',
        'username': '@johndoe',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Jane Smith',
        'username': '@janesmith',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Alice Johnson',
        'username': '@alicejohnson',
        'image': 'https://via.placeholder.com/150',
      },
    ];
    _filteredItems = List.from(_allItems); // Initialize filtered list
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(_allItems);
      });
    } else {
      setState(() {
        _filteredItems = _allItems.where((item) {
          return item['name']!.toLowerCase().contains(query.toLowerCase()) ||
              item['username']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            const SizedBox(),
            Text(
              "Tag People",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
              iconSize: 24,
            ),
          ],
        ),
      ),
      content: _allItems.isEmpty
          ? SizedBox(
              height: 100,
              child: Center(
                child: Text("Not Friend here"),
              ))
          : SizedBox(
              height: 300, // Increased height for better layout
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    cursorColor: Colors.grey,
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      _filterItems(value); // Call filter function
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_filteredItems.isEmpty)
                    SizedBox(
                        height: 100,
                        child: Center(
                          child: Text(
                            "Not Friend here",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Dismiss the dialog when a tile is tapped
                            Navigator.of(context).pop();
                            // You can handle the selection here, if needed
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  _filteredItems[index]
                                      ['image']!, // Get image from the map
                                ),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _filteredItems[index]
                                          ['name']!, // Full name
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      _filteredItems[index]
                                          ['username']!, // Username
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(), // Divider between items
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        // Additional actions can be added here if needed
      ],
    );
  }
}
