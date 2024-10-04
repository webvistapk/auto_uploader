import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/app_snackbar.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/follower_request.dart';
import 'package:mobile/models/UserProfile/follower_request.dart';
import 'package:mobile/prefrences/prefrences.dart';
import '../../../common/utils.dart';
import '../../../models/UserProfile/followers.dart';

class follower_request_provider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isFollowLoading = false;
  String status = '';

  bool get isLoading => _isLoading;
  bool get isFollowLoading => _isFollowLoading;

  setisLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  setisFollowLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<FollowerRequestModel>> getFollowerRequestList(
      BuildContext context) async {
    final String? token = await Prefrences.getAuthToken();
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
        notifyListeners();
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
    finally{
      notifyListeners();
    }
  }
  Future<void> followRequestResponse(
      BuildContext context, int followerId, followingId, String status) async {
    final String? token = await Prefrences.getAuthToken();

    // print("following ID : ${followingId}");
    //print("following ID : ${followerId}");

    String URL =
        "${ApiURLs.baseUrl}${ApiURLs.accept_follow}${followerId.toString()}/${followingId.toString()}/";
    print(URL);
    setisLoading(true);
    final body = jsonEncode({"status": status});
    try {
      final response = await http.patch(Uri.parse(URL), body: body, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print("This is follow request response");
      if (response.statusCode == 200) {
        showSuccessSnackbar("Request Sended", context);

        setisLoading(false);
      } else if (response.statusCode == 403) {
        showErrorSnackbar("API Misplace", context);
      } else {
        showErrorSnackbar(
            "There is an Error Occured : ${response.statusCode}", context);
        print("Error Occured ${response.statusCode}");
        print(response.body);
        setisLoading(false);
      }
    } catch (e) {
      print("Exception: Error ${e}");
      print(e);
      setisLoading(false);
    }
  }


  Future<FetchResponseModel> fetchFollowRequestStatus(
      int followerId, int followingId,context) async {
    final String? token = await Prefrences.getAuthToken();
    print("First ID: $followerId");
    print("Second ID: $followingId");
    setisLoading(true);

    final response = await http.get(
      Uri.parse(
          '${ApiURLs.baseUrl}${ApiURLs.get_follow_list}$followerId/$followingId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      //print("Successful API Response: $data --");

      if (data != null && data is Map) {
        //print("inside the success response");     // Cast 'data' to Map<String, dynamic>
        Map<String, dynamic> jsonData = Map<String, dynamic>.from(data);

        if (jsonData.isNotEmpty) {
          status = FetchResponseModel.fromJson(jsonData).status.toString();
          print("Status is ${status}")   ;
          notifyListeners();
          //print("Status: $status");

          setisLoading(false);
          return FetchResponseModel.fromJson(jsonData);
        } else {
          // print('Data is empty or invalid');
          status = 'initial';
          notifyListeners();
          setisLoading(false);
          return FetchResponseModel();
        }
      } else {
        //print('Invalid response data');
        status = 'initial';
        setisLoading(false);
        return FetchResponseModel();
      }
    } else {
      // Handle HTTP errors
      // print("Error: ${response.body}");
      setisLoading(false);
      return FetchResponseModel(); // Return a default FetchResponseModel on failure
    }

  }

  Future<void> sendfollowRequest(
      BuildContext context, int followerId, int followingId) async {
    final String? token = await Prefrences.getAuthToken();
    setisLoading(true);
    setisFollowLoading(true);
   try{
     final response = await http.post(
       Uri.parse(
           "${ApiURLs.baseUrl}${ApiURLs.follow_request_endpoint}$followerId/$followingId/"),
       headers: <String, String>{
         'Content-Type': 'application/json; charset=UTF-8',
         'Authorization': 'Bearer $token',
       },
     );

     if (response.statusCode == 201) {
       setisLoading(false);
       setisFollowLoading(false);
       //print("API Hitted");
       ToastNotifier.showSuccessToast(context, "Follower Request Sended");
     } else {
       setisLoading(false);
       setisFollowLoading(false);
       ToastNotifier.showErrorToast(context, "There is an Error : ${response.statusCode}");
       //print("This is Error body: ${response.body}");
     }
   }
   catch(e){
     ToastNotifier.showErrorToast(context, "There is an Error : ${e}");
     setisFollowLoading(false);
   }

  }

}