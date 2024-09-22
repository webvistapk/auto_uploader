import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/common/utils.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String)? onSearch;

  const TopBar({super.key, this.onSearch});

  @override
  _TopBarState createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch?.call(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Utils.mainBgColor,
      elevation: 0,
      automaticallyImplyLeading: false, // Remove the default back button
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu,
                color: Colors.black), // Custom menu button
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: _onSearchChanged, // Use debounce logic
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.message, color: Colors.red),
          onPressed: () {},
        ),
      ],
    );
  }
}
