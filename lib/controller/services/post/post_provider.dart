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
import '../../../models/ReelPostModel.dart';
import '../../../models/UserProfile/CommentModel.dart';
import '../../endpoints.dart';
import 'package:http/http.dart' as http;

class PostProvider extends ChangeNotifier {
  PostModel? _post;
  List<PostModel>? _posts;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  PostModel? get post => _post;
  List<PostModel>? get posts => _posts;
  List<ReelPostModel>? _reels;

  List<ReelPostModel>? get reels => _reels;
  setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setPost(List<PostModel> posts) {
    _posts = posts;
    notifyListeners();
  }

  Future<List<PostModel>> fetchFollowerPost(BuildContext context,
      {int limit = 10, int offset = 0}) async {
    setIsLoading(true);

    final String? token = await Prefrences.getAuthToken();
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    // API endpoint for fetching follower posts
    String URL =
        "${ApiURLs.baseUrl}${ApiURLs.get_follower_posts}$_loggedInUserId/";

    // Construct the URI with pagination parameters
    Uri uri = Uri.parse(URL).replace(queryParameters: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });

    try {
      final response = await http.get(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<PostModel> followerPosts = (data['posts'] as List)
            .map((postJson) => PostModel.fromJson(postJson))
            .toList();
        print("Response of Follower Posts: ${response.body}");

        // Update the list of posts and notify listeners
        setPost(followerPosts);

        return followerPosts;
      } else {
        throw Exception("Failed to fetch follower posts");
      }
    } catch (e) {
      setIsLoading(false);
      ToastNotifier.showErrorToast(context, "Error: $e");
      print("Error fetching follower posts: $e");
      return []; // Return an empty list on error
    } finally {
      setIsLoading(
          false); // Make sure to set loading to false even if there was an error
    }
  }

  // Future<List<PostModel>> fetchFollowerPost(BuildContext context,
  //     {int limit = 10, int offset = 0}) async {
  //   final String? token = await Prefrences.getAuthToken();
  //   int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

  //   // API endpoint for fetching follower posts
  //   String URL =
  //       "${ApiURLs.baseUrl}${ApiURLs.get_follower_posts}$_loggedInUserId/";

  //   // Construct the URI with pagination parameters
  //   Uri uri = Uri.parse(URL).replace(queryParameters: {
  //     'limit': limit.toString(),
  //     'offset': offset.toString(),
  //   });

  //   setIsLoading(true);

  //   try {
  //     final response = await http.get(uri, headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $token",
  //     });

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       List<PostModel> followerPosts = (data['posts'] as List)
  //           .map((postJson) => PostModel.fromJson(postJson))
  //           .toList();
  //       print("Response ${response.body}");
  //       // Cache or update the follower posts
  //       setPosts(followerPosts);

  //       return followerPosts;
  //     } else {
  //       throw Exception("Failed to fetch follower posts");
  //     }
  //   } catch (e) {
  //     ToastNotifier.showErrorToast(context, "Error: $e");
  //     print("Error fetching follower posts: $e");
  //     return [];
  //   } finally {
  //     setIsLoading(false);
  //   }
  // }

  createNewPost(context,
      {required String postTitle,
      required List<int> peopleTags,
      required List<String> keywordsList,
      required String privacyPost,
      required List<File> mediaFiles,
      String? pollTitle,
      String? pollDescription,
      List<String>? pollOptions,
      required List<String>? interactions}) async {
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
            token: token,
            pollTitle: pollTitle,
            pollDescription: pollDescription,
            pollOptions: pollOptions,
            interactions: interactions!);

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

  createNewStory(context,
      {required List<int> peopleTags,
      required String privacyPost,
      required List<File> mediaFiles}) async {
    try {
      _isLoading = true;
      notifyListeners();
      log(" $privacyPost, $mediaFiles");
      final token = await Prefrences.getAuthToken();
      // debugger();
      if (token != null) {
        final response = await PostManager().createStory(
            peopleTags: peopleTags,
            privacyPost: privacyPost,
            mediaFiles: mediaFiles,
            token: token);

        if (response != null) {
          log("Story: $response");

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

  Future<List<PostModel>> getPost(
      BuildContext context, String id, limit, offset) async {
    print("Fetching API");

    final String? token = await Prefrences.getAuthToken();
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    // Base URL and API path
    String URL = "${ApiURLs.baseUrl}${ApiURLs.get_post}${_loggedInUserId}";

    // Add query parameters for pagination (limit and offpage)
    Uri uri = Uri.parse(URL).replace(queryParameters: {
      'limit': limit.toString(), // How many posts per page
      'offset': offset.toString() // Offset for pagination
    });

    print("Fetching API with URI: $uri");

    try {
      final response = await http.get(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });

      print("Response Data of UserPost ${response.body}");

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);

        print(jsonList);
        log("Post Data: ${jsonList['posts']}");

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

  Future<List<ReelPostModel>> fetchFollowersReels(BuildContext context) async {
    final String? token = await Prefrences.getAuthToken();
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    // Base URL and API path
    String URL =
        "${ApiURLs.baseUrl}${ApiURLs.get_follower_reel_post}$_loggedInUserId";

    // Add query parameters for pagination (limit and offset)
    Uri uri = Uri.parse(URL);

    try {
      final response = await http.get(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });

      print(response.body);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        print("REEL GETTED SUCCESSFULLY");
        // print(jsonList);
        //log("Reel Data: ${jsonList['reels']}"); // Log the correct data

        List<ReelPostModel> reelList = [];
        for (var reelJson in jsonList['reels']) {
          // Change 'posts' to 'reels'
          final reel = ReelPostModel.fromJson(reelJson);
          reelList.add(reel);
        }
        print("PROVIDER REEL :${reelList}");

        notifyListeners();
        return reelList;
      } else {
        return [];
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error: $e");
      print(e);
      return []; // Return an empty list on exception
    } finally {
      setIsLoading(false);
    }
  }

  Future<List<ReelPostModel>> fetchReels(
      BuildContext context, String id, int limit, int offset) async {
    final String? token = await Prefrences.getAuthToken();

    // Base URL and API path
    String URL = "${ApiURLs.baseUrl}${ApiURLs.get_reel_post}$id";

    // Add query parameters for pagination (limit and offset)
    Uri uri = Uri.parse(URL).replace(queryParameters: {
      'limit': limit.toString(), // How many posts per page
      'offset': offset.toString() // Offset for pagination
    });

    try {
      final response = await http.get(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });

      print(response.body);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body);
        print("REEL FETCHED SUCCESSFULLY");

        // Convert JSON to ReelPostModel list
        List<ReelPostModel> reelList = [];
        for (var reelJson in jsonList['reels']) {
          final reel = ReelPostModel.fromJson(reelJson);
          reelList.add(reel);
        }

        // Update the provider's state
        if (_reels == null) {
          _reels = reelList; // Initialize _reels if null
        } else {
          _reels!.addAll(reelList); // Append new data for pagination
        }

        notifyListeners();
        return reelList;
      } else {
        return [];
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "There is an Error: $e");
      print(e);
      return []; // Return an empty list on exception
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> deletePost(
      String postId, BuildContext context, bool isReelPost) async {
    final String? token = await Prefrences.getAuthToken();

    String URL =
        "${ApiURLs.baseUrl}${isReelPost ? ApiURLs.delete_reel : ApiURLs.delete_post}$postId/";
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

  void setSinglePost(PostModel post) {
    _post = post;
    notifyListeners();
  }

  // Modify your getSinglePost method to only fetch the post if it isn't already available in the list
  Future<void> getSinglePost(String postID) async {
    final String? token = await Prefrences.getAuthToken();
    setIsLoading(true);
    String URL = "${ApiURLs.baseUrl}${ApiURLs.get_single_post}$postID/";
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
        print("RESPONSE OF POST: ${response.body}");
        // Assign the post directly to the _post variable
        _post = PostModel.fromJson(data['posts']);
        // Optionally add to the list of posts
        _posts?.add(_post!); // If you want to keep the post in the list
        notifyListeners();
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw e;
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> newLikes(int postId, BuildContext context) async {
    final String? token = await Prefrences.getAuthToken();
    print("POst ID is : ${postId}");

    // API endpoint to like a post
    String URL = "${ApiURLs.baseUrl}${ApiURLs.new_like}post/${postId}/";
    Uri uri = Uri.parse(URL);

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //final int newLikesCount = data['likes_count']; // Extract new like count

        // Find the post in _posts and update it
        final postIndex = _posts!.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _posts?[postIndex].likesCount += 1;
          _posts?[postIndex].isLiked =
              true; // Assuming you want to mark it as liked
          notifyListeners();
        } else {
          print("Post index is wrong");
        }

        // Notify listeners to refresh UI (if you're using Provider)
        notifyListeners();
      } else {
        throw Exception("Failed to like post");
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Error: $e");
    }
  }

  Future<void> userDisLikes(int postId, BuildContext context) async {
    final String? token = await Prefrences.getAuthToken();
    print("POst ID is : ${postId}");

    // API endpoint to like a post
    String URL =
        "${ApiURLs.baseUrl}${ApiURLs.dislike}post/${postId.toString()}/";

    Uri uri = Uri.parse(URL);

    try {
      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("API HITtED");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // final int newLikesCount = data['likes_count']; // Extract new like count

        // Find the post in _posts and update it

        final postIndex = _posts!.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          print("Post Index ${postIndex}");

          _posts?[postIndex].likesCount -= 1;
          _posts?[postIndex].isLiked =
              false; // Assuming you want to mark it as liked
          ToastNotifier.showSuccessToast(context, "Post Disliked Successfully");
        } else {
          print("Post index is wrong");
          ToastNotifier.showErrorToast(context, "Post Disliked Faild");
        }

        // Notify listeners to refresh UI (if you're using Provider)
        notifyListeners();
      } else {
        throw Exception("Failed to dislike post");
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Error: $e");
    }
  }

  Future<void> reelLike(int reelID, BuildContext context, int reelIndex) async {
    final String? token = await Prefrences.getAuthToken();
    //print("Reel ID ${postID}");
    String URL = "${ApiURLs.baseUrl}${ApiURLs.new_like}reel/$reelID/";

    // print("Post ID in Like ${postID}");

    try {
      final response = await http.post(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("API HITTED");
      if (response.statusCode == 200) {
        // _reels?[reelIndex].isLiked = true;
        _reels?[reelIndex].likesCount += 1;
        _reels?[reelIndex].isLiked = true;

        // Notify listeners to update UI
        notifyListeners();
      } else {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Error liking the post: $e");
      notifyListeners();
      print(e);
    }
  }

  Future<void> reelDisLike(
      int reelID, BuildContext context, int reelIndex) async {
    final String? token = await Prefrences.getAuthToken();
    //print("Reel ID ${postID}");
    String URL = "${ApiURLs.baseUrl}${ApiURLs.dislike}reel/$reelID/";

    // print("Post ID in Like ${postID}");

    try {
      final response = await http.delete(
        Uri.parse(URL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("API HITTED");
      if (response.statusCode == 200) {
        // _reels?[reelIndex].isLiked = true;
        _reels?[reelIndex].likesCount -= 1;
        _reels?[reelIndex].isLiked = false;

        // Notify listeners to update UI
        notifyListeners();
      } else {
        throw Exception('Failed to dislike reel');
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, "Error disliking the post: $e");
      notifyListeners();
      print(e);
    }
  }

  List<PostModel> _cachedPosts = [];

  List<PostModel> get cachedPosts => _cachedPosts;

  void setPosts(List<PostModel> posts) {
    _cachedPosts = posts;
    notifyListeners();
  }

  void addPosts(List<PostModel> posts) {
    _cachedPosts.addAll(posts);
    notifyListeners();
  }

  void clearPosts() {
    _cachedPosts.clear();
    notifyListeners();
  }

  getPostById(int id) {}
}
