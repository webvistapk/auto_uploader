import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/tags/tags_provider.dart';
import 'package:mobile/models/post/tag_people.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TagBottomSheet extends StatefulWidget {
  final List<int> selectedTagUser;
  const TagBottomSheet({super.key, required this.selectedTagUser});

  @override
  State<TagBottomSheet> createState() => _TagBottomSheetState();
}

class _TagBottomSheetState extends State<TagBottomSheet> {
  List<TagUser> _allItems = [];
  List<TagUser> _filteredItems = [];

  final TextEditingController _textController = TextEditingController();

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(_allItems);
      });
    } else {
      setState(() {
        _filteredItems = _allItems.where((item) {
          return item.firstName.toLowerCase().contains(query.toLowerCase()) ||
              item.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() async {
    var pro = context.read<TagsProvider>();
    final futureUser = await UserPreferences().getCurrentUser();
    List<TagUser> tagUsers = await pro.getTagUsersList(futureUser!);

    // Remove duplicates by converting the list to a Set and back to a List
    List<TagUser> uniqueTagUsers = tagUsers.toSet().toList();

    setState(() {
      _allItems = uniqueTagUsers;
      _filteredItems = List.from(_allItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    var pro = context.watch<TagsProvider>();

    return pro.isLoading
        ? _buildShimmerEffect()
        : Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 10),
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
                    _filterItems(value);
                  },
                ),
                const SizedBox(height: 10),
                if (_filteredItems.isEmpty)
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        "No friends found",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      if (widget.selectedTagUser
                          .contains(_filteredItems[index].id)) {
                        _filteredItems.removeAt(index);
                        if (_filteredItems.isEmpty) {
                          return SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                "No friends found",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          );
                        }
                        return SizedBox(); // Skip already selected users
                      } else
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.selectedTagUser
                                  .add(_filteredItems[index].id);
                              _filteredItems.removeAt(index);
                              // ToastNotifier.showSuccessToast(context,
                              //     "User Tagged Successfully ${_filteredItems[index].firstName}");
                              print(widget.selectedTagUser);
                            });
                            Navigator.of(context).pop(); // Dismiss on selection
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                child: const Icon(Icons.person),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_filteredItems[index].firstName} ${_filteredItems[index].lastName}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      _filteredItems[index].username,
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
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
              ],
            ),
          );
  }

  // Shimmer effect widget
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
            ),
            title: Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
            subtitle: Container(
              width: double.infinity,
              height: 12,
              color: Colors.grey[300],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
