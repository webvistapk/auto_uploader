import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../common/message_toast.dart';
import '../../../models/UserProfile/CommentModel.dart';
import '../../../prefrences/prefrences.dart';
import '../../endpoints.dart';
import 'package:http/http.dart' as http;

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isCommentLoading = false;
  bool _isUpdatePreviousOffset = true;
  List<Reply> _replies = [];
  final Map<int, GlobalKey> _commentKeys = {};
  bool _isLoading = false;
  int _nextOffset = 0;
  int _previousOffset = 0;
  int _replyNextOffset = 0;
  int _commentCount=0;

  bool get isLoading => _isLoading;
  int get commentCount => _commentCount;
  bool get isCommentLoading => _isCommentLoading;
  bool get isUpdatePreviousOffset => _isUpdatePreviousOffset;
  List<Comment> get comments => _comments;
  List<Reply> get replies => _replies;
  int get nextOffset => _nextOffset;
  int get previousOffset => _previousOffset;
  int get replyNextOffset => _replyNextOffset;
  bool hasNextPage = true;
  bool hasPreviousPage = true;
  Map<int, GlobalKey> get commentKeys => _commentKeys;

  setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  setCommentCount(int value) {
    _commentCount = value;
    notifyListeners();
  }

  setCommentLoadin(bool value) {
    _isCommentLoading = value;
    notifyListeners();
  }
  initializeComments(
    String postId,
    bool isReelScreen, {
    int limit = 10,
    int? offset = 0,
    bool isFromFindMyPage = false,
    bool isNext = true,
  }) async {
    _comments = [];
    await fetchComments(
      postId,
      isReelScreen,
      limit: 10,
      offset: offset,
    );
  }

  // Temporary list for fetching comments only for a specific offset
  fetchComments(String postId, bool isReelScreen,
      {int limit = 10, int? offset = 0, bool isNext = false}) async {
    setLoading(true);
    print("Post ID: $postId");

    final String? token = await Prefrences.getAuthToken();
    final url =
        "${ApiURLs.baseUrl}${isReelScreen ? ApiURLs.reel_comment_fetch : ApiURLs.post_comment_fetch}$postId/";
    print("Limit: $limit");
    print("Offset: $offset");

    try {
      //  debugger();
      final response = await http.get(
        Uri.parse(url).replace(
          queryParameters: {
            'limit': limit.toString(),
            'offset': offset.toString(),
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      // debugger();
      if (response.statusCode == 200) {
        setCommentLoadin(false);

        final data = json.decode(response.body);
        CommentModel commentResponse = CommentModel.fromJson(data);

        print("Previous Offset Before ${commentResponse.previousOffset}");
        //debugger();
        if (offset == 0) {
          _isUpdatePreviousOffset = false;
        }
        if (!isNext) {
          if (offset == 0) {
            _comments = commentResponse.comments;
            hasNextPage = commentResponse.hasNextPage;
            _nextOffset = commentResponse.nextOffset ?? _nextOffset;
            if (_isUpdatePreviousOffset) {
              _previousOffset =
                  commentResponse.previousOffset ?? _previousOffset;
              hasPreviousPage = commentResponse.hasPreviousPage;
            } else {
              _previousOffset = 0;
              hasPreviousPage = false;
            }
          } else {
            _comments.addAll(commentResponse.comments); // Append new comments
            hasNextPage = commentResponse.hasNextPage;

            _nextOffset = commentResponse.nextOffset ?? _nextOffset;
            if (_isUpdatePreviousOffset) {
              _previousOffset =
                  commentResponse.previousOffset ?? _previousOffset;
              hasPreviousPage = commentResponse.hasPreviousPage;
            } else {
              _previousOffset = 0;
              hasPreviousPage = false;
            }
          }
        } else {
          _comments.insertAll(0, commentResponse.comments);

          _nextOffset = commentResponse.nextOffset ?? _nextOffset;
          if (_isUpdatePreviousOffset) {
            _previousOffset = commentResponse.previousOffset ?? _previousOffset;
            hasPreviousPage = commentResponse.hasPreviousPage;
          } else {
            _previousOffset = 0;
            hasPreviousPage = false;
          }
        }
        //debugger();
        for (var comment in _comments) {
          _commentKeys[comment.id] = GlobalKey();
        }

        setCommentCount(commentResponse.totalCount);
        print("comment Key of 1 ${_commentKeys[34]!.currentContext}");
        
        // Notify listeners to update UI
        notifyListeners();
      } else {
        setCommentLoadin(false);
        throw Exception("Failed to load comments");
      }
    } catch (error) {
      print("Error: $error");
      rethrow;
    } finally {
      setLoading(false);
    }

    return _comments;
  }


  void loadPreviousComments(String postId, int commentIdToHighlight, int limit,
      {bool isReel = false}) async {
    int previousOffset = _previousOffset - limit;
    if (previousOffset < 0) {
      previousOffset = 0; // Ensure offset is not negative
    }

    try {
      // Fetch previous comments
      await fetchComments(postId, isReel,
          limit: limit, offset: previousOffset, isNext: true);
    } catch (error) {
      print("Error loading previous comments: $error");
    }
  }

  void loadNextComments(String postId, {bool isReel = false}) async {
    // Ensure no duplicate or unnecessary fetches
    if (nextOffset == -1) {
      print("No more comments to load.");
      return;
    }

    try {
      // Fetch the next batch of comments (10 at a time)
      int newNextOffset = _nextOffset;
      await fetchComments(
        postId,
        isReel, // Assuming this is for a post and not a reel
        limit: 10, // Fetch only 10 comments
        offset: newNextOffset, // Use the current next offset
      );
      //_nextOffset += 10;

      // Update UI after fetching
    } catch (error) {
      print("Error loading next comments: $error");
    }
  }

  Future<void> addComment(
    String postId,
    bool isReelScreen, {
    required String content,
    //required List<String> keywords,
    File? media,
    required BuildContext context,
  }) async {
    try {
      // print("POST ID : ${postId}");
      final String? token = await Prefrences.getAuthToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiURLs.baseUrl}${isReelScreen ? ApiURLs.reel_comment_add : ApiURLs.post_comment_add}$postId/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['postId'] = postId;
      request.fields['content'] = content;
      //request.fields['keywords'] = keywords.join(',');
      //request.fields['tags']="2";

      if (media != null) {
        request.files.add(
          await http.MultipartFile.fromPath('media', media.path),
        );
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        //ToastNotifier.showSuccessToast(context, "Comment added successfully");
        fetchComments(postId, isReelScreen);
      } else {
        //ToastNotifier.showErrorToast(context, "Failed to add comment");
      }
    } catch (error) {
      //ToastNotifier.showErrorToast(context, "Error: $error");
    }
  }

  void deleteComment(String commentId, BuildContext context, String postId,
      bool isReelScreen) async {
    final String? token = await Prefrences.getAuthToken();

    String URL = "${ApiURLs.baseUrl}${ApiURLs.delete_post_comment}$commentId/";
    //setIsLoading(true);
    print("COMMENT ID: ${commentId}");
    try {
      // Make the DELETE request
      final response = await http.delete(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Show success message
        //ToastNotifier.showSuccessToast(context, "comment deleted successfully");
        fetchComments(postId, isReelScreen);
        notifyListeners();
      } else {
        // Show error message if deletion failed
        //ToastNotifier.showErrorToast(
        // context, "Sorry comment is not deleted. Please Try Again!");

        notifyListeners();
      }
    } catch (e) {
      //ToastNotifier.showErrorToast(context, "There is an Error: $e");
    }
  }

  Future<void> likeComment(int commentId, BuildContext context) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      String URL =
          "${ApiURLs.baseUrl}${ApiURLs.new_like}comment/${commentId.toString()}/";

      final response = await http.post(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final commentIndex =
            comments.indexWhere((comment) => comment.id == commentId);
        if (commentIndex != -1) {
          comments[commentIndex].isLiked = true;
          comments[commentIndex].likeCount += 1;

          notifyListeners();
        }
        //ToastNotifier.showSuccessToast(context, "Liked Successfully");
      }
    } catch (e) {
      //ToastNotifier.showErrorToast(context, "Unsuccessful Like: ${e}");
      print(e);
    }
  }

  Future<void> dislikeComment(
      int commentId, replyId, BuildContext context) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      String URL =
          "${ApiURLs.baseUrl}${ApiURLs.dislike}comment/${commentId.toString()}/";

      final response = await http.delete(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final commentIndex =
            comments.indexWhere((comment) => comment.id == commentId);
        if (commentIndex != -1) {
          comments[commentIndex].isLiked = false;
          comments[commentIndex].likeCount =
              (comments[commentIndex].likeCount > 0)
                  ? comments[commentIndex].likeCount - 1
                  : 0;

          notifyListeners();
        }
        //ToastNotifier.showSuccessToast(context, "Disliked Successfully");
      }
    } catch (e) {
      //ToastNotifier.showErrorToast(context, "Unsuccessful Dislike: ${e}");
      print(e);
    }
  }
}

class ReplyProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isCommentLoading = false;
  List<Reply> _replies = [];
  bool _isLoading = false;
  int _nextOffset = 0;
  int _previousOffset = 0;
  int _replyNextOffset = 0;
  bool _isUpdatePreviousOffset = true;
  int _replyCount = 0;

  int get replyCount => _replyCount;
  bool get isLoading => _isLoading;
  bool get isCommentLoading => _isCommentLoading;
  List<Comment> get comments => _comments;
  List<Reply> get replies => _replies;
  int get nextOffset => _nextOffset;
  int get previousOffset => _previousOffset;
  int get replyNextOffset => _replyNextOffset;
  bool isReplyVisible = false;
  bool get isUpdatePreviousOffset => _isUpdatePreviousOffset;
  bool hasNextPage = true;
  bool hasPreviousPage = true;

  setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  setReplyCount(int value) {
    _replyCount = value;
    notifyListeners();
  }

  setCommentLoadin(bool value) {
    _isCommentLoading = value;
    notifyListeners();
  }

  Future<void> fetchReplies(int commentId, BuildContext context,
      {int limit = 10,
      offset = 0,
      bool isReel = false,
      bool isNext = false}) async {
    setCommentLoadin(true);
    print("Comment ID: ${commentId}");
    final String? token = await Prefrences.getAuthToken();
    final url =
        "${ApiURLs.baseUrl}${ApiURLs.post_comment_reply_fetch}${commentId.toString()}/";

    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("API HITTED SUCCESSFULLY");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Replies List1: ${response.body}");
        //debugger();
        ReplyModel replyResponse = ReplyModel.fromJson(data);
        // print("COmments Length ${_comments}");
        if (offset == 0) {
          _isUpdatePreviousOffset = false;
        }
        if (!isNext) {
          if (offset == 0) {
            _replies = replyResponse.reply;
            hasNextPage = replyResponse.hasNextPage;
            _nextOffset = replyResponse.nextOffset ?? _nextOffset;
            if (_isUpdatePreviousOffset) {
              _previousOffset = replyResponse.previousOffset ?? _previousOffset;
              hasPreviousPage = replyResponse.hasPreviousPage;
            } else {
              _previousOffset = 0;
              hasPreviousPage = false;
            }
          } else {
            _replies.addAll(replyResponse.reply); // Append new comments
            hasNextPage = replyResponse.hasNextPage;

            _nextOffset = replyResponse.nextOffset ?? _nextOffset;
            if (_isUpdatePreviousOffset) {
              _previousOffset = replyResponse.previousOffset ?? _previousOffset;
              hasPreviousPage = replyResponse.hasPreviousPage;
            } else {
              _previousOffset = 0;
              hasPreviousPage = false;
            }
          }
        } else {
          _replies.insertAll(0, replyResponse.reply);

          _nextOffset = replyResponse.nextOffset ?? _nextOffset;
          if (_isUpdatePreviousOffset) {
            _previousOffset = replyResponse.previousOffset ?? _previousOffset;
            hasPreviousPage = replyResponse.hasPreviousPage;
          } else {
            _previousOffset = 0;
            hasPreviousPage = false;
          }
          debugger();
          final commentProvider =
            Provider.of<CommentProvider>(context, listen: false);
        int commentIndex = commentProvider.comments
            .indexWhere((comment) => comment.id == commentId);
        _comments = commentProvider.comments;
        Comment comment = _comments[commentIndex];
          setReplyCount(comment.replyCount);
        }
      } else {
        throw Exception("Failed to fetch replies");
      }
    } catch (error) {
      print("Error fetching replies: $error");
      rethrow;
    } finally {
      setCommentLoadin(false);
    }
  }

  initializeReply(int commentId, bool isReelScreen, BuildContext context,
      {int limit = 10, int? offset = 0}) async {
    _replies = [];
    await fetchReplies(
      commentId,
      context,
      isReel: isReelScreen,
      limit: 10,
      offset: offset,
    );
  }

  toggleReplyVisibility(int commentId, BuildContext context) {
    //debugger();
    fetchReplies(commentId,context);
    // Find the index of the comment
    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);
    int commentIndex = commentProvider.comments
        .indexWhere((comment) => comment.id == commentId);
    _comments = commentProvider.comments;
    if (commentIndex != -1) {
      Comment comment = _comments[commentIndex];
      // Toggle visibility
      comment.isReplyVisible = !comment.isReplyVisible;
      notifyListeners();

      // Fetch replies if the replies are not loaded and visibility is enabled
      if (comment.isReplyVisible && !comment.isReplyLoaded) {
        fetchReplies(commentId, context);
        comment.isReplyLoaded = true; // Mark replies as loaded after fetching
      }
    }
    notifyListeners();
  }

  void loadNextReply(int commentId,BuildContext context, {bool isReel = false}) async {
    // Ensure no duplicate or unnecessary fetches
    if (nextOffset == -1) {
      print("No more comments to load.");
      return;
    }

    try {
      // Fetch the next batch of comments (10 at a time)
      int newNextOffset = _nextOffset;
      await fetchReplies(
        commentId,
        context,
        isReel: isReel, // Assuming this is for a post and not a reel
        limit: 10, // Fetch only 10 comments
        offset: newNextOffset, // Use the current next offset
      );
    } catch (error) {
      print("Error loading next replies: $error");
    }
  }

  void loadPreviousReply(int commentId, int limit, BuildContext context,
      {bool isReel = false}) async {
    int previousOffset = _previousOffset - limit;
    if (previousOffset < 0) {
      previousOffset = 0; // Ensure offset is not negative
    }

    try {
      // Fetch previous comments
      await fetchReplies(commentId, context,
          isReel: isReel, limit: limit, offset: previousOffset, isNext: true);
    } catch (error) {
      print("Error loading previous replies: $error");
    }
  }

  Future<void> replyComment(
    int commentId,
    bool isReelScreen, {
    required String content,
    //required List<String> keywords,
    File? media,
    required BuildContext context,
  }) async {
    try {
      setCommentLoadin(true);
      print("Comment POST ID : ${commentId}");
      final String? token = await Prefrences.getAuthToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiURLs.baseUrl}${ApiURLs.new_post_comment_reply}${commentId.toString()}/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      //request.fields['postId'] = commentId.toString();
      request.fields['content'] = content;
      //request.fields['keywords'] = keywords.join(',');
      //request.fields['tags']="2";

      if (media != null) {
        request.files.add(
          await http.MultipartFile.fromPath('media', media.path),
        );
      }
      //debugger();
      final response = await request.send();
      if (response.statusCode == 201) {
        //ToastNotifier.showSuccessToast(
        // context, "Comment reply added successfully");
        //debugger();
        final commentProvider =
            Provider.of<CommentProvider>(context, listen: false);
        int commentIndex = commentProvider.comments
            .indexWhere((comment) => comment.id == commentId);
        _comments = commentProvider.comments;
        Comment comment = _comments[commentIndex];
        comment.replyCount++;
        await fetchReplies(commentId,context);
        setCommentLoadin(false);
        notifyListeners();
      } else {
        //ToastNotifier.showErrorToast(context, "Failed to add comment reply");
      }
    } catch (error) {
      //ToastNotifier.showErrorToast(context, "Error: $error");
    } finally {
      setCommentLoadin(false);
    }
  }

  void deleteCommentReply(int replyId, commentId, BuildContext context) async {
    final String? token = await Prefrences.getAuthToken();

    String URL =
        "${ApiURLs.baseUrl}${ApiURLs.delete_post_comment_reply}${replyId.toString()}/";
    //setIsLoading(true);
    print("COMMENT ID: ${replyId}");
    try {
      // Make the DELETE request
      final response = await http.delete(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Show success message
        //ToastNotifier.showSuccessToast(
        // context, "comment reply deleted successfully");
        fetchReplies(commentId,context);
        Comment comment =
            comments.firstWhere((comment) => comment.id == commentId);
        comment.replyCount--;
        if (comment.replyCount == 0) {
          comment.isReplyVisible = false;
        }
        notifyListeners();
      } else {
        // Show error message if deletion failed
        //ToastNotifier.showErrorToast(
        // context, "Sorry comment reply is not deleted. Please Try Again!");

        notifyListeners();
      }
    } catch (e) {
      //ToastNotifier.showErrorToast(context, "There is an Error: $e");
    }
  }

  Future<void> likeReply(
      int replyId, int commentId, BuildContext context) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      String URL = "${ApiURLs.baseUrl}${ApiURLs.new_like}reply/$replyId/";

      // Call the API to like the reply
      final response = await http.post(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Find the comment and the reply
        print("Respons of Like ${response.body}");
        final commentIndex =
            _comments.indexWhere((comment) => comment.id == commentId);
        if (commentIndex != -1) {
          final replyIndex = _comments[commentIndex]
              .replies
              .indexWhere((reply) => reply.id == replyId);
          if (replyIndex != -1) {
            // Update the reply state directly
            final currentReply = _comments[commentIndex].replies[replyIndex];
            currentReply.isReplyLiked = true;
            currentReply.replyLikeCount += 1;

            // Call notifyListeners() to update the UI
            notifyListeners();
          }
        }
      }
    } catch (e) {
      //ToastNotifier.showErrorToast(context, "Failed to like reply: ${e}");
    }
  }

  Future<void> dislikeReply(
      int commentId, replyId, BuildContext context) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      String URL =
          "${ApiURLs.baseUrl}${ApiURLs.dislike}reply/${replyId.toString()}/";

      final response = await http.delete(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
//debugger();
      if (response.statusCode == 200) {
        final commentIndex =
            _comments.indexWhere((comment) => comment.id == commentId);
        if (commentIndex != -1) {
          final replyIndex = _comments[commentIndex]
              .replies
              .indexWhere((reply) => reply.id == replyId);
          if (replyIndex != -1) {
            // Update the reply state directly
            final currentReply = _comments[commentIndex].replies[replyIndex];
            currentReply.isReplyLiked = false;
            currentReply.replyLikeCount = (currentReply.replyLikeCount > 0)
                ? currentReply.replyLikeCount - 1
                : 0;
          }

          notifyListeners();
        }
        //ToastNotifier.showSuccessToast(context, "Disliked Successfully");
      }
    } catch (e) {
      //ToastNotifier.showErrorToast(context, "Unsuccessful Dislike: ${e}");
      print(e);
    }
  }
}
