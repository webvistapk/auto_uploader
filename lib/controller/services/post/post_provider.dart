import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post_manager.dart';
import 'package:mobile/prefrences/prefrences.dart';

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/UserProfile/SinglePostModel.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/prefrences/prefrences.dart';
import '../../../common/message_toast.dart';
import '../../endpoints.dart';
import 'package:http/http.dart' as http;

class PostProvider extends ChangeNotifier {
  PostDetails? _post;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  PostDetails? get post => _post;

  setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  createNewPost(context,
      {required String postTitle,
      required List<int> peopleTags,
      required List<String> keywordsList,
      required String privacyPost,
      required List<File> mediaFiles}) async {
    try {
      _isLoading = true;
      notifyListeners();
      log("$postTitle, $peopleTags, $keywordsList, $privacyPost, $mediaFiles");
      final token = await Prefrences.getAuthToken();
      // debugger();
      if (token != null) {
        final response = await PostManager().createPost(
            postTitle: postTitle,
            peopleTags: peopleTags,
            keywordsList: keywordsList,
            privacyPost: privacyPost,
            mediaFiles: mediaFiles,
            token: token);

        if (response != null) {
          log("Post: $response");

          return response;
        }
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print(e.toString());
      return null;
    }
  }

  createNewReel(context,
      {required String postTitle,
      required List<int> peopleTags,
      required List<String> keywordsList,
      required String privacyPost,
      required List<File> mediaFiles}) async {
    try {
      _isLoading = true;
      notifyListeners();
      log("$postTitle, $peopleTags, $keywordsList, $privacyPost, $mediaFiles");
      final token = await Prefrences.getAuthToken();
      // debugger();
      if (token != null) {
        final response = await PostManager().createReel(
            postTitle: postTitle,
            peopleTags: peopleTags,
            keywordsList: keywordsList,
            privacyPost: privacyPost,
            mediaFiles: mediaFiles,
            token: token);

        if (response != null) {
          log("Reel: $response");

          return response;
        }
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print(e.toString());
      return null;
    }
  }

  Future<List<PostModel>> getPost(BuildContext context, String id) async {
    print("Fetching API");
    final String? token = await Prefrences.getAuthToken();

    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    String URL = "${ApiURLs.baseUrl}${ApiURLs.get_post}${id}";
    print("Fetching API");
    try {
      final response = await http.get(Uri.parse(URL), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);

        print(jsonList);
        log("Post Data: ${jsonList['posts']}");
        // debugger();

        List<PostModel> postList = [];
        for (var postJson in jsonList['posts']) {
          final post = PostModel.fromJson(postJson);
          postList.add(post);
        }

        notifyListeners();
        return postList;
      } else {
        return [];
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error: $e");
      print(e);
      return [];
    } finally {
      setIsLoading(false);
    }
  }

  void deletePost(String postId, BuildContext context) async {
    final String? token = await Prefrences.getAuthToken();

    String URL = "${ApiURLs.baseUrl}${ApiURLs.delete_post}$postId/";
    setIsLoading(true);
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
        ToastNotifier.showSuccessToast(context, "Post deleted successfully");
        //getPost(context);
        setIsLoading(false);
      } else {
        // Show error message if deletion failed
        ToastNotifier.showErrorToast(
            context, "Sorry post is not deleted. Please Try Again!");

        setIsLoading(false);
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error: $e");

      setIsLoading(false);
    }
  }

  Future<void> getSinglePost(String postID) async {
    final String? token = await Prefrences.getAuthToken();
    setIsLoading(true);
    String URL = "${ApiURLs.baseUrl}${ApiURLs.get_single_post}${postID}/";
    try {
      final response = await http.get(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _post = PostDetails.fromJson(data['posts']);
        print(_post);
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw e;
    } finally {
      setIsLoading(false);
    }
  }
}
