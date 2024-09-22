import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/common/utils.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';

class SearchService {
  static Future<List<UserProfile>> fetchSearchResults(String query) async {
    final String? token = await Utils.getAuthToken(Utils.authToken);

    final response = await http.get(
      Uri.parse('${Utils.baseUrl}search/$query'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => UserProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
