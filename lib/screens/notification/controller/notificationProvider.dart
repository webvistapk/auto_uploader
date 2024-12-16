// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:mobile/controller/endpoints.dart';
// import 'package:mobile/prefrences/prefrences.dart';
// import 'package:mobile/screens/notification/model/NotificationModel.dart';
 import 'package:http/http.dart' as http;

// class NotificationProvider extends ChangeNotifier {
//   List<NotificationModel> _notifications = [];
//   bool _isLoading = false;

//   List<NotificationModel> get notifications => _notifications;
//   bool get isLoading => _isLoading;

//   Future<void> fetchNotifications() async {
//     _isLoading = true;
//     notifyListeners();
//     final String? token = await Prefrences.getAuthToken();
//     String URL = "${ApiURLs.baseUrl}${ApiURLs.notification}";

//     Uri uri = Uri.parse(URL);

//     try {
//       final response = await http.get(
//         uri, 
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token', 
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final List<dynamic> jsonNotifications = jsonResponse['notifications'];

//         _notifications = jsonNotifications
//             .map((json) => NotificationModel.fromJson(json))
//             .toList();
//       } else {
//         throw Exception('Failed to load notifications');
//       }
//     } catch (error) {
//       print('Error fetching notifications: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/notification/model/NotificationModel.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Replace with your API call
      final String? token = await Prefrences.getAuthToken();
    String URL = "${ApiURLs.baseUrl}${ApiURLs.notification}";

    Uri uri = Uri.parse(URL);

      final response = await http.get(
        uri, 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );
      final data = json.decode(response.body);

      final notificationResponse = NotificationResponse.fromJson(data);
      _notifications = notificationResponse.notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
}
}
}