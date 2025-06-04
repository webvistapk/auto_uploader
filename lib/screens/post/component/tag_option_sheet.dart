import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/endpoints.dart';
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

  void _onTagUserSelected(int id) {
    setState(() {
      if (widget.selectedTagUser.contains(id)) {
        widget.selectedTagUser.remove(id); // Deselect
      } else {
        widget.selectedTagUser.add(id); // Select
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() async {
    var pro = context.read<TagsProvider>();
    final futureUser = await UserPreferences().getCurrentUser();
    var tagUsers = await pro.getTagUsersList(futureUser!);

    if (tagUsers.isEmpty) {
      debugPrint("No tag users found");
    } else {
      // Ensure unique users
      List<TagUser> uniqueTagUsers = tagUsers.toSet().toList();

      setState(() {
        _allItems = uniqueTagUsers;
        _filteredItems = List.from(_allItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var pro = context.watch<TagsProvider>();

    return pro.isLoading
        ? _buildShimmerEffect()
        : SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        "Tag People",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 24,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Search Box
                  TextField(
                    controller: _textController,
                    cursorColor: Colors.grey.shade600,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      hintText: 'Search people...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterItems,
                  ),

                  const SizedBox(height: 12),

                  // Empty State
                  if (_filteredItems.isEmpty)
                    SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          "No friends found",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),

                  // List of Users
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _filteredItems[index];
                        final isSelected =
                            widget.selectedTagUser.contains(user.id);

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade300,
                            child: user.profileImage != null &&
                                    user.profileImage!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.network(
                                      '${ApiURLs.baseUrl2}${user.profileImage!}',
                                      fit: BoxFit.cover,
                                      width: 44,
                                      height: 44,
                                    ),
                                  )
                                : const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            "${user.firstName} ${user.lastName}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            user.username,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () => _onTagUserSelected(user.id),
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.red
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                          ),
                          onTap: () => _onTagUserSelected(user.id),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: 6,
        itemBuilder: (_, __) => ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
          ),
          title: Container(
            height: 16,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.only(bottom: 6),
          ),
          subtitle: Container(
            height: 12,
            color: Colors.grey.shade300,
            width: 150,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
