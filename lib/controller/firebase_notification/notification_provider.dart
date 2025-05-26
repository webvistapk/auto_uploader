import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/messaging/firebase_notification/firebase_api.dart';
import 'package:http/http.dart' as http;

class FirebaseNotificationProvider extends ChangeNotifier {
  bool isLoading = false;
  firebaseNotificationTokenSave(String authToken) async {
    isLoading = true;
    notifyListeners();
    try {
      String url = ApiURLs.baseUrl + ApiURLs.fCMTokenSave;
      final fCMToken = await FirebaseApi().getFirebaseFCMToken();

      if (fCMToken != null) {
        final headers = {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        };
        final body = {"token": fCMToken};
        // debugger();
        final response = await http.post(Uri.parse(url),
            headers: headers, body: jsonEncode(body));
        // debugger();
        isLoading = false;
        notifyListeners();
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          log("Data: $data");
          await Prefrences.setFcmToken(fCMToken);
        } else {
          log("FCM: $fCMToken");
          // debugger();
          log("Status Code: ${response.statusCode}");
          log("Data: ${response.body}");
        }
      }
    } catch (e) {
      // debugger();
      isLoading = false;
      notifyListeners();
    }
  }

  deleteNotificationToken() async {
    try {
      String authToken = await Prefrences.getAuthToken();
      String fCMToken = await Prefrences.getFcmToken();
      String url = ApiURLs.baseUrl + ApiURLs.fCMTokenDelete + fCMToken;

      if (fCMToken != null) {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken'
        };

        final body = {"token": fCMToken};
        // debugger();
        final response =
            await http.post(Uri.parse(url), headers: headers, body: body);
        // debugger();
        isLoading = false;
        notifyListeners();
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          log("Data: $data");
          await Prefrences.deleteFcmToken();
        } else {
          log("FCM: $fCMToken");
          // debugger();
          log("Status Code: ${response.statusCode}");
          log("Data: ${response.body}");
        }
      }
    } catch (e) {
      // debugger();
      isLoading = false;
      notifyListeners();
    }
  }
}
