import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:path/path.dart';

class PostManager {
  final String baseUrl;

  PostManager() : baseUrl = ApiURLs.baseUrl;

  Future<dynamic> createPost({
    required String postTitle,
    required List<int> peopleTags,
    required List<String> keywordsList,
    required String privacyPost,
    required List<File> mediaFiles,
    required String token, // Bearer token for authorization
  }) async {
    String url = baseUrl + ApiURLs.create_new_post;

    // Prepare headers
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'multipart/form-data',
    };

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    // Add fields

    request.fields['post'] = postTitle;
    request.fields['privacy'] = privacyPost;

    request.fields['keywords'] = keywordsList.join(',');
    if (peopleTags.isEmpty) {
    } else {
      request.fields['tags'] = peopleTags.join(',');
    }

    // Add media files
    for (var file in mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath(
        'media',
        file.path,
        filename: basename(file.path), // Use path's basename as the filename
      ));
    }

    try {
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Check the response status
      // debugger();
      if (response.statusCode == 201) {
        log('Post created successfully: ${response.body}');

        return jsonDecode(response.body);
      } else {
        // debugger();
        log('Failed to create post: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (error) {
      // debugger();
      print('Error occurred: $error');
      return null;
    }
  }

  Future<dynamic> createReel({
    required String postTitle,
    required List<int> peopleTags,
    required List<String> keywordsList,
    required String privacyPost,
    required List<File> mediaFiles,
    required String token, // Bearer token for authorization
  }) async {
    String url = baseUrl + ApiURLs.create_new_reel_endpoint;

    // Prepare headers
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'multipart/form-data',
    };

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    // Add fields

    request.fields['post'] = postTitle;
    request.fields['privacy'] = privacyPost;

    request.fields['keywords'] = keywordsList.join(',');
    if (peopleTags.isEmpty) {
    } else {
      request.fields['tags'] = peopleTags.join(',');
    }

    // Add media files
    for (var file in mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: basename(file.path), // Use path's basename as the filename
      ));
    }

    try {
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Check the response status
      // debugger();
      if (response.statusCode == 200) {
        log('Reel created successfully: ${response.body}');

        return jsonDecode(response.body);
      } else {
        // debugger();
        log('Failed to create Reel: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (error) {
      // debugger();
      print('Error occurred: $error');
      return null;
    }
  }

  Future<dynamic> createStory({
    required List<int> peopleTags,
    required String privacyPost,
    required List<File> mediaFiles,
    required String token, // Bearer token for authorization
  }) async {
    String url = baseUrl + ApiURLs.create_new_story_endpoint;

    // Prepare headers
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'multipart/form-data',
    };

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    // Add fields

    request.fields['privacy'] = privacyPost;

    if (peopleTags.isEmpty) {
    } else {
      request.fields['tags'] = peopleTags.join(',');
    }

    // Add media files
    for (var file in mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: basename(file.path), // Use path's basename as the filename
      ));
    }

    try {
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Check the response status
      // debugger();
      if (response.statusCode == 200) {
        log('Story created successfully: ${response.body}');

        return jsonDecode(response.body);
      } else {
        // debugger();
        log('Failed to create Story: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (error) {
      // debugger();
      print('Error occurred: $error');
      return null;
    }
  }
}
