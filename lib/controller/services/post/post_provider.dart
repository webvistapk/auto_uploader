import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/controller/services/post_manager.dart';
import 'package:mobile/prefrences/prefrences.dart';

class PostProvider extends ChangeNotifier {
  bool isLoading = false;

  createNewPost(context,
      {required String postTitle,
      required List<int> peopleTags,
      required List<String> keywordsList,
      required String privacyPost,
      required List<File> mediaFiles}) async {
    try {
      isLoading = true;
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
        isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print(e.toString());
      return null;
    }
  }
}
