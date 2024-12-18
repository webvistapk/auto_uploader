import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/notification/model/NotificationModel.dart';
import 'package:http/http.dart' as http;


class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;  // To track loading state for "Show More"
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<NotificationModel> get notifications => _notifications;
  int _nextOffset = 0;  // Keep track of the next offset for pagination
  int get nextOffset=>_nextOffset;

  Future<void> fetchNotifications({int limit = 10, int offset = 0}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? token = await Prefrences.getAuthToken();
      String URL = "${ApiURLs.baseUrl}${ApiURLs.notification}";

      Uri uri = Uri.parse(URL).replace(queryParameters: {
        'limit': limit.toString(), // Number of notifications per page
        'offset': offset.toString(), // Offset for pagination
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notificationResponse = NotificationResponse.fromJson(data);

        // Handle the first fetch or load more notifications
        if (offset == 0) {
          _notifications = notificationResponse.notifications;
          _nextOffset = notificationResponse.nextOffset ?? 0;  // Update nextOffset
        } else {
          _notifications.addAll(notificationResponse.notifications);
          _nextOffset = notificationResponse.nextOffset ?? _nextOffset;
        }
        
        // Only allow loading more if `hasNextPage` is true
        if (!notificationResponse.hasNextPage) {
          _nextOffset = -1; // Set to -1 if there are no more notifications to load
        }
        
        // Notify listeners to update the UI
        notifyListeners();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Function to load more notifications when user taps "Show More"
  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || _nextOffset == -1) {
      return; // Do not load more if already loading or no more items
    }

    _isLoadingMore = true;
    notifyListeners();

    await fetchNotifications(offset: _nextOffset);

    _isLoadingMore = false;
    notifyListeners();
  }
}


// class NotificationProvider with ChangeNotifier {
//   List<NotificationModel> _notifications = [];
//   bool _isLoading = false;

//   List<NotificationModel> get notifications => _notifications;
//   bool get isLoading => _isLoading;

//   Future<void> fetchNotifications(int limit, int offset) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final String? token = await Prefrences.getAuthToken();
//       String URL = "${ApiURLs.baseUrl}${ApiURLs.notification}";

//       Uri uri = Uri.parse(URL).replace(queryParameters: {
//         'limit': limit.toString(), // How many notifications per page
//         'offset': offset.toString(), // Offset for pagination
//       });

//       final response = await http.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final notificationResponse = NotificationResponse.fromJson(data);

//         if (offset == 0) {
//           _notifications = notificationResponse.notifications; // Clear and load new
//         } else {
//           _notifications.addAll(notificationResponse.notifications); // Append to existing list
//         }
//       } else {
//         throw Exception('Failed to load notifications');
//       }
//     } catch (e) {
//       print('Error fetching notifications: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
