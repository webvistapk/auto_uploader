import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/UserProfile/post_model.dart';
import 'package:mobile/prefrences/prefrences.dart';
import '../../../common/message_toast.dart';
import '../../endpoints.dart';
import 'package:http/http.dart' as http;

class PostProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<PostModel>> getPost(BuildContext context) async {
    print("Fetching API");
    final String? token = await Prefrences.getAuthToken();

    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];

    String URL = "${ApiURLs.baseUrl}${ApiURLs.get_post}$_loggedInUserId";
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
}
