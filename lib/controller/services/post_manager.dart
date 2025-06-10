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
    required String postField,
    required List<int> peopleTags,
    required List<String> keywordsList,
    required List<String> privacyPost,
    required String location,
    required List<File> mediaFiles,
    String? postTitle,
    String? postDescription,
    String? pollTitle,
    String? pollDescription,
    List<String>? pollOptions,
    required List<String> interactions,
    required List<String> dmReplies, // Interaction options
    required List<String> dmComments,
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
    if (pollTitle != null && pollDescription != null && pollOptions != null) {
      request.fields['poll_title'] = pollTitle;
      request.fields['poll_description'] = pollDescription;

      // Add option values
      // debugger();
      for (var i = 0; i < pollOptions.length; i++) {
        request.fields['polls[$i]'] = pollOptions[i];
      }
    }
    if (interactions.isNotEmpty) {
      request.fields['interactions'] = interactions.join(',').toLowerCase();
    }
    
    if (dmReplies.isNotEmpty) {
      String dmReply = jsonEncode(dmReplies);
      print(dmReply);
      request.fields['dm_privacy'] = dmReply;
    }
    if (dmComments.isNotEmpty) {
      String dmComment = jsonEncode(dmComments);
      request.fields['comments_privacy'] = dmComment;
    }

    request.fields['post'] = postField;
    request.fields['location'] = location;
    if (privacyPost.isNotEmpty) {
      // Encode the list to a JSON string
      String privacyValue = jsonEncode(privacyPost);

// Add the privacy field as text
      request.fields['privacy'] = privacyValue;
    }

    if (postTitle != null && postDescription != null) {
      request.fields['post_title'] = postTitle;
      request.fields['post_description'] = postDescription;
    }
    request.fields['keywords'] = keywordsList.join(',');
    if (peopleTags.isEmpty) {
    } else {
      request.fields['tags'] = peopleTags.join(',');
    }
    if (mediaFiles.isNotEmpty) {
// Add media files
      for (var file in mediaFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          file.path,
          filename: basename(file.path), // Use path's basename as the filename
        ));
      }
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
    required String postField,
    required List<int> peopleTags,
    required List<String> keywordsList,
    required List<String> privacyPost,
    required List<File> mediaFiles,
    required String description,
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

    request.fields['post'] = postField;
    if (privacyPost.isNotEmpty) {
      // Encode the list to a JSON string
      String privacyValue = jsonEncode(privacyPost);

// Add the privacy field as text
      request.fields['privacy'] = privacyValue;
    }
    request.fields['description'] = description;

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
    required List<String> privacyPost,
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

    if (privacyPost.isEmpty) {
    } else {
      // Encode the list to a JSON string
      String privacyValue = jsonEncode(privacyPost);

// Add the privacy field as text
      request.fields['privacy'] = privacyValue;
    }

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

  Future newReposted(
      {required String type,
      required int postId,
      required String token}) async {
    String url = "${ApiURLs.baseUrl}${ApiURLs.new_reposted}$type/$postId/";

    // Prepare headers
    final headers = {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'Content-type': 'application/json'
    };
    final response = await http.post(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
