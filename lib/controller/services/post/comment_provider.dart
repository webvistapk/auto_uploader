import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../../common/message_toast.dart';
import '../../../models/UserProfile/CommentModel.dart';
import '../../../prefrences/prefrences.dart';
import '../../endpoints.dart';
import 'package:http/http.dart' as http;


class CommentProvider extends ChangeNotifier{
  //Comment Provider starts here

  List<Comment> _comments = [];
  bool _isCommentLoading = false;
  List<Reply> _replies=[];
  List<Comment> get comments => _comments;
  bool get isCommentLoading => _isCommentLoading;
  setCommentLoadin(bool value){
    _isCommentLoading = value;
    notifyListeners();
  }

  Future<List<Comment>> fetchComments(String postId,bool isReelScreen) async {
    setCommentLoadin(true);
    // print("POst ID: $postId");
    final String? token = await Prefrences.getAuthToken();
    final url = "${ApiURLs.baseUrl}${isReelScreen?ApiURLs.reel_comment_fetch:ApiURLs.post_comment_fetch}$postId/";
    try {
      final response = await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      //print("Response ${response.body}");
      if (response.statusCode == 200) {
        setCommentLoadin(false);
        final data = json.decode(response.body);
        _comments = (data['comments'] as List)
            .map((comment) => Comment.fromJson(comment))
            .toList();

            // After fetching comments, fetch replies for each comment
      for (var comment in _comments) {
        await fetchReplies(comment.id);  // Ensure commentId is passed as a string
      }
        print("COmmentS ${_comments}");

        //print("fetch Comments triggered");

      } else {
        setCommentLoadin(false);
        throw Exception("Failed to load comments");
      }
    } catch (error) {
      setCommentLoadin(false);
      print(error);
      rethrow; // Re-throw the error to handle it in the calling code if needed
    }
    return _comments;
  }


 Future<void> fetchReplies(int commentId) async {
  setCommentLoadin(true);
  print("Comment ID: ${commentId}");
  final String? token = await Prefrences.getAuthToken();
  final url = "${ApiURLs.baseUrl}${ApiURLs.post_comment_reply_fetch}${commentId.toString()}/";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("API HITTED SUCCESSFULLY");
    if (response.statusCode == 200) {

      final data = json.decode(response.body);
       print("Replies List1: ${response.body}");

      _replies = (data['reply'] as List)
          .map((reply) => Reply.fromJson(reply))
          .toList();

        print("Replies List: ${response.body}");

      // Find the target comment and update its replies
      final index = _comments.indexWhere((comment) => comment.id == commentId);

      if (index != -1) {
        final currentComment = _comments[index];
        _comments[index] = Comment(
        id: currentComment.id,
        username: currentComment.username,
        avatarUrl: currentComment.avatarUrl,
        commentText: currentComment.commentText,
        replies: _replies,  // Update the replies
        timeAgo: currentComment.timeAgo,
  );
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


  Future<void> addComment(String postId, bool isReelScreen,{
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
        Uri.parse('${ApiURLs.baseUrl}${isReelScreen?ApiURLs.reel_comment_add:ApiURLs.post_comment_add}$postId/'),
      );
      request.headers['Authorization']='Bearer $token';
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
        fetchComments(postId,isReelScreen);
      } else {
        ToastNotifier.showErrorToast(context, "Failed to add comment");
      }
    } catch (error) {
      ToastNotifier.showErrorToast(context, "Error: $error");
    }
  }


  void deleteComment(String commentId, BuildContext context,String postId,bool isReelScreen) async {
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
        fetchComments(postId,isReelScreen);
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
}