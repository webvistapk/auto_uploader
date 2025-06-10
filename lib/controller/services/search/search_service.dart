import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';

class SearchService {
  // static Future<List<UserProfile>> fetchSearchResults(
  //     String query, String authToken, {required String type}) async {
  //   final token = authToken;

  //   final response = await http.get(
  //     Uri.parse('${ApiURLs.baseUrl}search/$query'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> usersJson = jsonDecode(response.body);
  //     return usersJson.map((json) => UserProfile.fromJson(json)).toList();
  //   } else {
  //     throw Exception(
  //         'Failed to load search results ${response.statusCode}${response.body}');
  //   }
  // }

  static Future<Map<String, dynamic>> fetchSearchResults(
    String query, 
    String authToken, 
    {
      required String type,
      int limit = 10,
      int offset = 0,
    }
  ) async {
    try {
      final uri = Uri.parse('${ApiURLs.baseUrl}search/')
          .replace(queryParameters: {
            'query': query,
            'type': type,
            'limit': limit.toString(),
            'offset': offset.toString(),
          });

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          return responseData;
        } else {
          throw Exception('API returned unsuccessful status: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load search results. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search request failed: $e');
    }
  }
}
