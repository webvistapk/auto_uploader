import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/follower_request.dart';
import 'package:mobile/models/UserProfile/follower_request.dart';
import '../../../common/utils.dart';

class follower_request_provider extends ChangeNotifier{
  bool _isLoading=false;
  bool get isLoading=>_isLoading;

  setisLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<FollowerRequestModel>> getFollowerRequestList(BuildContext context) async {
    final String? token = await AppUtils.getAuthToken(AppUtils.authToken);
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];
    print("User Token $_loggedInUserId");

    String URL = "${ApiURLs.baseUrl}${ApiURLs.get_follow_list}$_loggedInUserId";

    try {
      final response = await http.get(Uri.parse(URL), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });

      if (response.statusCode == 200) {
        // Parse the JSON response into a list of FollowerRequestModel
        List<dynamic> jsonList = jsonDecode(response.body);
        List<FollowerRequestModel> requestList = jsonList
            .map((json) => FollowerRequestModel.fromJson(json))
            .toList();
        return requestList;
      } else {
        print("No Record Available");
        return [];
      }
    } catch (e) {
      print("Exception: No Record Available");
      print(e);
      return [];
    }
  }

  Future<void> acceptRequest(BuildContext context,String followerId) async {
    final String? token = await AppUtils.getAuthToken(AppUtils.authToken);
    int? _loggedInUserId = JwtDecoder.decode(token.toString())['user_id'];
    //print("User Token $_loggedInUserId");

    String URL = "${ApiURLs.baseUrl}${ApiURLs.accept_follow}${followerId}/$_loggedInUserId";
    setisLoading(true);
    try {
      final response = await http.patch(Uri.parse(URL), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });

      if (response.statusCode == 200) {
        print("Request Accepted");
        setisLoading(false);
      } else {
        print("Error Occured");
        setisLoading(false);

      }
    } catch (e) {
      print("Exception: Error");
      print(e);
      setisLoading(false);
    }
  }
}

