import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../../common/message_toast.dart';
import '../../../models/UserProfile/CommentModel.dart';
import '../../../prefrences/prefrences.dart';
import '../../endpoints.dart';
import 'package:http/http.dart' as http;

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isCommentLoading = false;
  List<Reply> _replies = [];
  bool _isLoading = false;
  int _nextOffset = 0;
  int _previousOffset=0;
  int _replyNextOffset = 0;

  bool get isLoading => _isLoading;
  bool get isCommentLoading => _isCommentLoading;
  List<Comment> get comments => _comments;
  List<Reply> get replies => _replies;
  int get nextOffset => _nextOffset;
  int get previousOffset=>_previousOffset;
  int get replyNextOffset => _replyNextOffset;
  bool hasNextPage=true;

  setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  setCommentLoadin(bool value) {
    _isCommentLoading = value;
    notifyListeners();
  }

   toggleReplyVisibility(int commentId) {
    int commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
       //debugger();
    
    if (commentIndex != -1) {
      Comment comment = _comments[commentIndex];
      comment.isReplyVisible = !comment.isReplyVisible;
      notifyListeners();

      // Fetch replies if not already loaded
      if (comment.isReplyVisible && !comment.isReplyLoaded) {
        fetchReplies(commentId);
      }
    }
  }

  // Future<List<Comment>> fetchComments(String postId, bool isReelScreen) async {
  //   setCommentLoadin(true);
  //   print("POst ID: $postId");
  //   final String? token = await Prefrences.getAuthToken();
  //   final url =
  //       "${ApiURLs.baseUrl}${isReelScreen ? ApiURLs.reel_comment_fetch : ApiURLs.post_comment_fetch}$postId/";
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     print("Response of Comments is Here: ${response.body} :: to Here");
  //     if (response.statusCode == 200) {
  //       setCommentLoadin(false);
  //       final data = json.decode(response.body);
  //       _comments = (data['comments'] as List)
  //           .map((comment) => Comment.fromJson(comment))
  //           .toList();

  //       // After fetching comments, fetch replies for each comment
  //       // for (var comment in _comments) {
  //       //   await fetchReplies(comment.id);  // Ensure commentId is passed as a string
  //       // }
  //       print("COmmentS ${_comments}");

  //       //print("fetch Comments triggered");
  //     } else {
  //       setCommentLoadin(false);
  //       throw Exception("Failed to load comments");
  //     }
  //   } catch (error) {
  //     setCommentLoadin(false);
  //     print(error);
  //     rethrow; // Re-throw the error to handle it in the calling code if needed
  //   }
  //   return _comments;
  // }

   List<Comment> tempCommentList = [];  // Temporary list for fetching comments only for a specific offset

 // Temporary list for fetching comments only for a specific offset
fetchComments(String postId, bool isReelScreen, {int limit = 10, int offset = 0, bool isFromFindMyPage = false, bool isNext = true}) async {
  setLoading(true);
  print("Post ID: $postId");

  final String? token = await Prefrences.getAuthToken();
  final url = "${ApiURLs.baseUrl}${isReelScreen ? ApiURLs.reel_comment_fetch : ApiURLs.post_comment_fetch}$postId/";
  print("Limit: $limit");
  print("Offset: $offset");

  try {
    //   debugger();
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
      //debugger();
      if (isFromFindMyPage) {
        tempCommentList = commentResponse.comments;
      } else {
        if (isNext) {
          // Append next comments
          if (offset == 0) {
            _comments = commentResponse.comments;
          } else {
            _comments.addAll(commentResponse.comments);
          }
          // Update next offset if there are more comments
          if (commentResponse.hasNextPage) {
            _nextOffset = offset + limit;  // Continue loading next comments
          } else {
            _nextOffset = -1;  // No more comments, set to -1
            hasNextPage=commentResponse.hasNextPage;
          }
        } else {
          // Prepend previous comments
          _comments.insertAll(0, commentResponse.comments);
          // Calculate previous offset for backward navigation
          _previousOffset = offset - limit >= 0 ? offset - limit : 0;
        }
      }

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

  return isFromFindMyPage ? tempCommentList : _comments;
}



  Future<void> fetchReplies(int commentId, {int limit =10, offset=0}) async {
    setCommentLoadin(true);
    print("Comment ID: ${commentId}");
    final String? token = await Prefrences.getAuthToken();
    final url =
        "${ApiURLs.baseUrl}${ApiURLs.post_comment_reply_fetch}${commentId.toString()}/";

    try {
      final response = await http.get(
        Uri.parse(url).replace(
          queryParameters: {
            'limit': limit.toString(),
          'offset': offset.toString(),
          }
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("API HITTED SUCCESSFULLY");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Replies List1: ${response.body}");

        ReplyModel replyResponse = ReplyModel.fromJson(data);
      print("COmments Length ${_comments}");

      
      // If offset is 0, clear the existing comments and load new ones
      if (offset == 0) {
        _replies = replyResponse.reply;
        _replyNextOffset=replyResponse.nextOffset??0;
      } else {
        _replies.addAll(replyResponse.reply); // Append new comments
        _replyNextOffset=replyResponse.nextOffset??_replyNextOffset;
      }
      // If there are no more comments, set the nextOffset to -1
      //debugger();
      if (!replyResponse.hasNextPage) {
        _replyNextOffset = -1;
      }

        // _replies = (data['reply'] as List)
        //     .map((reply) => Reply.fromJson(reply))
        //     .toList();

         print("Replies List: ${response.body}");

        final index =
            _comments.indexWhere((comment) => comment.id == commentId);
        if (index != -1) {
          final currentComment = _comments[index];
          _comments[index] = Comment(
              id: currentComment.id,
              username: currentComment.username,
              avatarUrl: currentComment.avatarUrl,
              commentText: currentComment.commentText,
              replies: _replies, // Update the replies
              timeAgo: currentComment.timeAgo,
              isLiked: currentComment.isLiked,
              likeCount: currentComment.likeCount,
              replyCount: currentComment.replyCount,
              isReplyVisible: currentComment.isReplyVisible,
              isReplyLoaded: currentComment.isReplyLoaded);
          notifyListeners(); // Notify listeners for UI update
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

void loadPreviousComments(String postId, int commentIdToHighlight, int limit, {bool isReel=false}) async {
  // Ensure no unnecessary fetches
  if (_previousOffset <= 0) {
    print("No previous comments available.");
    return;
  }

  // Calculate the offset for fetching previous comments
   int previousOffset = _previousOffset - limit;
  // if (previousOffset < 0) {
  //   previousOffset = 0; // Ensure offset is not negative
  // }

  try {
    // Fetch previous comments
    await fetchComments(
      postId,
      isReel,
      limit: limit,
      offset: previousOffset,
      isFromFindMyPage: false,
      isNext: false,
      
    );
  } catch (error) {
    print("Error loading previous comments: $error");
  }
}


void loadNextComments(String postId,{bool isReel=false}) async {
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
      isFromFindMyPage: false, // Not a specific comment search
      isNext: true, // Indicating next comments
    );
    //_nextOffset += 10;

    // Update UI after fetching
    
  } catch (error) {
    print("Error loading next comments: $error");
  }
}

 
  Future<int> findPageForComment({
  required String postId,
  required int commentId,
  required int limit,
  bool isNext = true,
  bool isReel=false // Flag to indicate if we're going forward or backward
}) async {
  print("fetch post is called");
  int offset = 0;
//debugger();
  // Loop through comments in batches until the desired comment is found
  while (true) {
    // Fetch comments for the current batch with the current offset
    final comments = await fetchComments(postId, isReel, limit: limit, offset: offset, isFromFindMyPage: true, isNext: isNext);

    // Check if any of the comments in this batch match the commentId
    if (comments.any((comment) => comment.id == commentId)) {
      // Reset _comments and set the current batch with the found comment
      _comments = comments;
      _nextOffset =  offset+10 ; // Save the offset for the next fetch
      _previousOffset=offset;
      // After resetting, call fetchComments to reload the comments from the found offset
      break; // Exit the loop since we've found the comment
    }
      await fetchComments(postId, isReel, limit: limit, offset: offset, isNext: isNext);

    // Exit the loop if there are no more comments left to fetch
    if (comments.length < limit) break;

    // Increment or decrement offset to fetch the next or previous batch of comments
    offset = isNext ? offset + limit : offset - limit;
  }

  throw Exception("Comment not found");
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
        ToastNotifier.showSuccessToast(context, "Comment added successfully");
        fetchComments(postId, isReelScreen);
      } else {
        ToastNotifier.showErrorToast(context, "Failed to add comment");
      }
    } catch (error) {
      ToastNotifier.showErrorToast(context, "Error: $error");
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
        ToastNotifier.showSuccessToast(context, "comment deleted successfully");
        fetchComments(postId, isReelScreen);
        notifyListeners();
      } else {
        // Show error message if deletion failed
        ToastNotifier.showErrorToast(
            context, "Sorry comment is not deleted. Please Try Again!");

        notifyListeners();
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error: $e");
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
        ToastNotifier.showSuccessToast(
            context, "comment reply deleted successfully");
        fetchReplies(commentId);
        Comment comment =
            comments.firstWhere((comment) => comment.id == commentId);
        comment.replyCount--;
        if (comment.replyCount == 0) {
          comment.isReplyVisible = false;
        }
        notifyListeners();
      } else {
        // Show error message if deletion failed
        ToastNotifier.showErrorToast(
            context, "Sorry comment reply is not deleted. Please Try Again!");

        notifyListeners();
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error: $e");
    }
  }

  Future<void> likeComment(
      int commentId, BuildContext context, bool isReply) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      String URL = isReply
          ? "${ApiURLs.baseUrl}${ApiURLs.new_like}reply/${commentId.toString()}/"
          : "${ApiURLs.baseUrl}${ApiURLs.new_like}comment/${commentId.toString()}/";

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
          if (isReply) {
            final replyIndex = comments[commentIndex]
                .replies
                .indexWhere((reply) => reply.id == commentId);
            if (replyIndex != -1) {
              comments[commentIndex].replies[replyIndex].isReplyLiked = true;
              comments[commentIndex].replies[replyIndex].replyLikeCount += 1;
            }
          } else {
            comments[commentIndex].isLiked = true;
            comments[commentIndex].likeCount += 1;
          }

          notifyListeners();
        }
        //ToastNotifier.showSuccessToast(context, "Liked Successfully");
      } else {
        throw Exception('Failed to like comment');
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Unsuccessful Like: ${e}");
    }
  }

  Future<void> dislikeComment(
      int commentId, replyId, BuildContext context, bool isReply) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      String URL = isReply
          ? "${ApiURLs.baseUrl}${ApiURLs.dislike}reply/${replyId.toString()}/"
          : "${ApiURLs.baseUrl}${ApiURLs.dislike}comment/${commentId.toString()}/";

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
          if (isReply) {
          
          final comment = _comments[commentIndex];
          final replyIndex = comment.replies.indexWhere((r) => r.id == replyId);
          if (replyIndex != -1) {
            // Update the reply state
            comment.replies[replyIndex] = Reply(
              id: comment.replies[replyIndex].id,
              replierName: comment.replies[replyIndex].replierName,
              content: comment.replies[replyIndex].content,
              replierImage: comment.replies[replyIndex].replierImage,
              isReplyLiked: false, // Mark as liked
              replyLikeCount: comment.replies[replyIndex].replyLikeCount -
                  1, // Increment like count
            );

            // Update the comment in the provider
            _comments[commentIndex] = Comment(
              id: comment.id,
              username: comment.username,
              avatarUrl: comment.avatarUrl,
              commentText: comment.commentText,
              replies: comment.replies, // Updated replies
              timeAgo: comment.timeAgo,
              isLiked: comment.isLiked,
              likeCount: comment.likeCount,
              replyCount: comment.replyCount,
              isReplyVisible: comment.isReplyVisible,
              isReplyLoaded: comment.isReplyLoaded,
            );

            notifyListeners();
          
            }
          } else {
            comments[commentIndex].isLiked = false;
            comments[commentIndex].likeCount -= 1;
          }

          notifyListeners();
        }
        //ToastNotifier.showSuccessToast(context, "Disliked Successfully");
      } else {
        throw Exception('Failed to dislike comment');
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Unsuccessful Dislike: ${e}");
    }
  }

  Future<void> likeReply(
      int replyId, int commentId, BuildContext context) async {
    try {
      // Call the API to like the comment
      //await ApiService.likeComment(commentId); // Replace with your API logic
      final String? token = await Prefrences.getAuthToken();
      String URL = "${ApiURLs.baseUrl}${ApiURLs.new_like}reply/$replyId/";

      // Update the local state after a successful API call
      final response = await http.post(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final commentIndex = _comments.indexWhere((c) => c.id == commentId);
        if (commentIndex != -1) {
          final comment = _comments[commentIndex];
          final replyIndex = comment.replies.indexWhere((r) => r.id == replyId);
          if (replyIndex != -1) {
            // Update the reply state
            comment.replies[replyIndex] = Reply(
              id: comment.replies[replyIndex].id,
              replierName: comment.replies[replyIndex].replierName,
              content: comment.replies[replyIndex].content,
              replierImage: comment.replies[replyIndex].replierImage,
              isReplyLiked: true, // Mark as liked
              replyLikeCount: comment.replies[replyIndex].replyLikeCount +
                  1, // Increment like count
            );

            // Update the comment in the provider
            _comments[commentIndex] = Comment(
              id: comment.id,
              username: comment.username,
              avatarUrl: comment.avatarUrl,
              commentText: comment.commentText,
              replies: comment.replies, // Updated replies
              timeAgo: comment.timeAgo,
              isLiked: comment.isLiked,
              likeCount: comment.likeCount,
              replyCount: comment.replyCount,
              isReplyVisible: comment.isReplyVisible,
              isReplyLoaded: comment.isReplyLoaded,
            );

            notifyListeners();
          }
        }
      } else {
        throw Exception('Failed to like comment');
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Faild : ${e}");
    }
  }

}

class ReplyProvider extends ChangeNotifier{
 List<Comment> _comments = [];
  bool _isCommentLoading = false;
  List<Reply> _replies = [];
  bool _isLoading = false;
  int _nextOffset = 0;
  int _previousOffset=0;
  int _replyNextOffset = 0;

  bool get isLoading => _isLoading;
  bool get isCommentLoading => _isCommentLoading;
  List<Comment> get comments => _comments;
  List<Reply> get replies => _replies;
  int get nextOffset => _nextOffset;
  int get previousOffset=>_previousOffset;
  int get replyNextOffset => _replyNextOffset;

setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  setCommentLoadin(bool value) {
    _isCommentLoading = value;
    notifyListeners();
  }


  Future<void> fetchReplies(int commentId, {int limit =10, offset=0,bool isReply=false}) async {
    setCommentLoadin(true);
    print("Comment ID: ${commentId}");
    final String? token = await Prefrences.getAuthToken();
    final url =
        "${ApiURLs.baseUrl}${ApiURLs.post_comment_reply_fetch}${commentId.toString()}/";

    try {
      final response = await http.get(
        Uri.parse(url).replace(
          queryParameters: {
            'limit': limit.toString(),
          'offset': offset.toString(),
          }
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("API HITTED SUCCESSFULLY");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Replies List1: ${response.body}");

        ReplyModel replyResponse = ReplyModel.fromJson(data);
      print("COmments Length ${_comments}");

      
      // If offset is 0, clear the existing comments and load new ones
      if (offset == 0) {
        _replies = replyResponse.reply;
        _replyNextOffset=replyResponse.nextOffset??0;
      } else {
        _replies.addAll(replyResponse.reply); // Append new comments
        _replyNextOffset=replyResponse.nextOffset??_replyNextOffset;
      }
      // If there are no more comments, set the nextOffset to -1
      //debugger();
      if (!replyResponse.hasNextPage) {
        _replyNextOffset = -1;
      }

        // _replies = (data['reply'] as List)
        //     .map((reply) => Reply.fromJson(reply))
        //     .toList();

         print("Replies List: ${response.body}");

        final index =
            _comments.indexWhere((comment) => comment.id == commentId);
        if (index != -1) {
          final currentComment = _comments[index];
          _comments[index] = Comment(
              id: currentComment.id,
              username: currentComment.username,
              avatarUrl: currentComment.avatarUrl,
              commentText: currentComment.commentText,
              replies: _replies, // Update the replies
              timeAgo: currentComment.timeAgo,
              isLiked: currentComment.isLiked,
              likeCount: currentComment.likeCount,
              replyCount: currentComment.replyCount,
              isReplyVisible: currentComment.isReplyVisible,
              isReplyLoaded: currentComment.isReplyLoaded);
          notifyListeners(); // Notify listeners for UI update
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


void toggleReplyVisibility(int commentId) {
  // Find the index of the comment
  int commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
  
  if (commentIndex != -1) {
    Comment comment = _comments[commentIndex];
    
    // Toggle visibility
    comment.isReplyVisible = !comment.isReplyVisible;
    notifyListeners();

    // Fetch replies if the replies are not loaded and visibility is enabled
    if (comment.isReplyVisible && !comment.isReplyLoaded) {
      fetchReplies(commentId);
      comment.isReplyLoaded = true; // Mark replies as loaded after fetching
    }
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
        ToastNotifier.showSuccessToast(
            context, "Comment reply added successfully");
        fetchReplies(commentId);
        //Comment comment =
          //  comments.firstWhere((comment) => comment.id == commentId);
        //comment.replyCount++;
      } else {
        ToastNotifier.showErrorToast(context, "Failed to add comment reply");
      }
    } catch (error) {
      ToastNotifier.showErrorToast(context, "Error: $error");
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
        ToastNotifier.showSuccessToast(
            context, "comment reply deleted successfully");
        fetchReplies(commentId);
        Comment comment =
            comments.firstWhere((comment) => comment.id == commentId);
        comment.replyCount--;
        if (comment.replyCount == 0) {
          comment.isReplyVisible = false;
        }
        notifyListeners();
      } else {
        // Show error message if deletion failed
        ToastNotifier.showErrorToast(
            context, "Sorry comment reply is not deleted. Please Try Again!");

        notifyListeners();
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error: $e");
    }
  }


  Future<void> likeReply(int replyId, int commentId, BuildContext context) async {
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
      final commentIndex = _comments.indexWhere((comment) => comment.id == commentId);
      if (commentIndex != -1) {
        final replyIndex = _comments[commentIndex]
            .replies
            .indexWhere((reply) => reply.id == replyId);
        if (replyIndex != -1) {
          // Update the reply state directly
          _comments[commentIndex].replies[replyIndex].isReplyLiked = true;
          _comments[commentIndex].replies[replyIndex].replyLikeCount += 1;

          // Call notifyListeners() to update the UI
          notifyListeners();
        }
      }
    } else {
      throw Exception('Failed to like reply');
    }
  } catch (e) {
    ToastNotifier.showErrorToast(context, "Failed to like reply: ${e}");
  }
}

  Future<void> dislikeComment(
      int commentId, replyId, BuildContext context, bool isReply) async {
    try {
      final String? token = await Prefrences.getAuthToken();
      String URL = isReply
          ? "${ApiURLs.baseUrl}${ApiURLs.dislike}reply/${replyId.toString()}/"
          : "${ApiURLs.baseUrl}${ApiURLs.dislike}comment/${commentId.toString()}/";

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
          if (isReply) {
          
          final comment = _comments[commentIndex];
          final replyIndex = comment.replies.indexWhere((r) => r.id == replyId);
          if (replyIndex != -1) {
            // Update the reply state
            comment.replies[replyIndex] = Reply(
              id: comment.replies[replyIndex].id,
              replierName: comment.replies[replyIndex].replierName,
              content: comment.replies[replyIndex].content,
              replierImage: comment.replies[replyIndex].replierImage,
              isReplyLiked: false, // Mark as liked
              replyLikeCount: comment.replies[replyIndex].replyLikeCount -
                  1, // Increment like count
            );

            // Update the comment in the provider
            _comments[commentIndex] = Comment(
              id: comment.id,
              username: comment.username,
              avatarUrl: comment.avatarUrl,
              commentText: comment.commentText,
              replies: comment.replies, // Updated replies
              timeAgo: comment.timeAgo,
              isLiked: comment.isLiked,
              likeCount: comment.likeCount,
              replyCount: comment.replyCount,
              isReplyVisible: comment.isReplyVisible,
              isReplyLoaded: comment.isReplyLoaded,
            );

            notifyListeners();
          
            }
          } else {
            comments[commentIndex].isLiked = false;
            comments[commentIndex].likeCount -= 1;
          }

          notifyListeners();
        }
        //ToastNotifier.showSuccessToast(context, "Disliked Successfully");
      } else {
        throw Exception('Failed to dislike comment');
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Unsuccessful Dislike: ${e}");
    }
  }






}