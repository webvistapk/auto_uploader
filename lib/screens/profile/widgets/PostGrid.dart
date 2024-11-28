import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controller/endpoints.dart';
import '../../../models/UserProfile/post_model.dart';
import '../../advance_video_player.dart';
import '../user_post_screen.dart';
import '../../../controller/services/post/post_provider.dart';

class PostGrid extends StatefulWidget {
  final String filterType;
  final String userId;

  PostGrid({
    super.key,
    required this.filterType,
    required this.userId,
  });

  @override
  _PostGridState createState() => _PostGridState();
}

class _PostGridState extends State<PostGrid> {
  final ScrollController _scrollController = ScrollController();
  List<PostModel> _allPosts = [];
  int _offset = 0;
  final int _limit = 10;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMorePosts) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoadingMore = true);
    try {
      List<PostModel> newPosts =
          await Provider.of<PostProvider>(context, listen: false)
              .getPost(context, widget.userId, _limit, _offset);

      setState(() {
        _allPosts.addAll(newPosts);
        _offset += newPosts.length;
        _isLoadingMore = false;
        if (newPosts.isEmpty) _hasMorePosts = false;
      });
    } catch (error) {
      setState(() => _isLoadingMore = false);
      print("Error fetching posts: $error");
    }
  }

  List<PostModel> _getFilteredPosts() {
    if (widget.filterType == "image") {
      return _allPosts
          .where(
              (post) => post.media.any((media) => media.mediaType == 'image'))
          .toList();
    } else if (widget.filterType == "video") {
      return _allPosts
          .where(
              (post) => post.media.any((media) => media.mediaType == 'video'))
          .toList();
    }
    return _allPosts;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _getFilteredPosts();

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPostScreen(
                        posts: filteredPosts,
                        initialIndex: index,
                        filterType: widget.filterType,
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'profile_images_$index',
                  child: Container(
                    color: Colors.grey[300],
                    child: post.media.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator.adaptive())
                        : post.media[0].mediaType == 'video'
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayerWidget(
                                    videoUrl: "${post.media[0].file}",
                                  ),
                                  const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ],
                              )
                            : Image.network(
                                "${ApiURLs.baseUrl.replaceAll("/api/", '')}${post.media[0].file}",
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoadingMore)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
