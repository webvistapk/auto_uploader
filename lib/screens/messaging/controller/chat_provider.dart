import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/messaging/controller/chat_controller.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';

class ChatProvider with ChangeNotifier {
  final String baseUrl = "http://147.79.117.253:8001";
  String? accessToken;
  List<ChatModel> _chats = [];
  List<ChatModel> _filteredChats = [];
  List<MessageModel> _messages = [];
  int? _currentChatId;
  bool _isLoading = false;

  List<ChatModel> get chats => _filteredChats;
  List<MessageModel> get messages => _messages;
  int? get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;

  void setAccessToken(String token) {
    accessToken = token;
    notifyListeners();
  }

  void markChatAsRead(int chatId) async {
    int index = chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      chats[index] = ChatModel(
        id: chats[index].id,
        name: chats[index].name,
        participants: chats[index].participants,
        isGroup: chats[index].isGroup,
        unReadMessages: false, // Mark as read
        createdAt: chats[index].createdAt,
        updatedAt: chats[index].updatedAt,
      );
      await ChatController().ReadMessages(
        chats[index].id,
      );

      notifyListeners(); // Notify UI of the change
    }
  }

  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse('$baseUrl/api/chat/');
    String? accessToken = await Prefrences.getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        log('$data');

        if (data['status'] == 'success') {
          List<dynamic> chatsData = data['chat'] as List<dynamic>;
          _chats = chatsData.map((chat) {
            final participants = chat['participants'] as List<dynamic>?;

            // Determine chat name safely
            String name = '';

            // Use existing 'name' if valid
            if (chat['name'] != null &&
                (chat['name'] as String).trim().isNotEmpty) {
              name = chat['name'];
              log("Using existing chat name: $name");
            } else {
              // Try to get username from participants safely
              if (participants != null && participants.length > 1) {
                final username = participants[1]['username'];
                name =
                    (username != null && username.toString().trim().isNotEmpty)
                        ? username.toString()
                        : "Unknown";
                log("Using second participant's username: $name");
              } else if (participants != null && participants.isNotEmpty) {
                final username = participants[0]['username'];
                name =
                    (username != null && username.toString().trim().isNotEmpty)
                        ? username.toString()
                        : "Unknown";
                log("Using first participant's username: $name");
              } else {
                name = "Unknown";
                log("No participants found, using fallback name: $name");
              }
            }

            chat['name'] = name;

            return ChatModel.fromJson(chat);
          }).toList();

          _filteredChats = _chats;
          _isLoading = false;
          notifyListeners();
        } else {
          _isLoading = false;
          notifyListeners();
          throw Exception('Error: ${data['status']}');
        }
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception(
            'Failed to fetch chats. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Error fetching chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> fetchChats() async {
  //   _isLoading = true; // Set loading to true when the fetch starts
  //   notifyListeners();

  //   final url = Uri.parse('$baseUrl/api/chat/');
  //   String? accessToken = await Prefrences.getAuthToken();

  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     // debugger();
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       log('$data');
  //       // debugger();
  //       if (data['status'] == 'success') {
  //         _isLoading = false; // Set loading to true when the fetch starts
  //         notifyListeners();
  //         _chats = (data['chat'] as List).map((chat) {
  //           if (chat['name'] == null) {
  //             log("Using second participant's username: ${chat['participants'][1]['username']}");
  //             chat['name'] = chat['participants'][1]['username'] ?? "UnKnown";
  //           } else {
  //             chat['name'] = chat['name'] ?? "Unnamed Chat";
  //             log("Using existing or fallback chat name: ${chat['name']}");
  //           }
  //           return ChatModel.fromJson(chat);
  //         }).toList();
  //         _filteredChats = _chats;
  //         notifyListeners();
  //       } else {
  //         _isLoading = false; // Set loading to true when the fetch starts
  //         notifyListeners();
  //         throw Exception('Error: ${data['status']}');
  //       }
  //     } else {
  //       _isLoading = false; // Set loading to true when the fetch starts
  //       notifyListeners();
  //       throw Exception(
  //           'Failed to fetch chats. Status Code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     _isLoading = false; // Set loading to true when the fetch starts
  //     notifyListeners();
  //     throw Exception('Error fetching chats: $e');
  //   } finally {
  //     _isLoading = false; // Set loading to false after the fetch is complete
  //     notifyListeners();
  //   }
  // }

  void filterChats(String query) {
    if (query.isEmpty) {
      _filteredChats = _chats; // Reset to original list
    } else {
      _filteredChats = _chats.where((chat) {
        final name = chat.name?.toLowerCase() ?? '';
        final participantNames = chat.participants
            .map((p) =>
                '${p.firstName.toLowerCase()} ${p.lastName.toLowerCase()}')
            .join(' ');

        return name.contains(query.toLowerCase()) ||
            participantNames.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  ReadMessages(int chatId) async {
    try {
      final url = '$baseUrl/api/chat/messages/read/$chatId/';

      String? authToken = await Prefrences.getAuthToken();
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchMessages(int chatId) async {
    _currentChatId = chatId;
    final url = Uri.parse('$baseUrl/chat/$chatId/messages/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _messages = (data['messages'] as List)
            .map((msg) => MessageModel.fromJson(msg))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentChatId == null) return;
    final url = Uri.parse('$baseUrl/chat/$_currentChatId/messages/send/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );
      if (response.statusCode == 201) {
        fetchMessages(_currentChatId!); // Refresh messages
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  static Future createNewChat({
    required String name,
    required List<int> participants,
    required bool isGroup,
  }) async {
    final url = Uri.parse('${ApiURLs.baseUrl}chat/new/');
    final authToken = await Prefrences.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
    final body = jsonEncode({
      "name": name,
      "participants": participants,
      "is_group": isGroup,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle success
        // debugger();
        final data = jsonDecode(response.body);
        return data;
      } else {
        // Handle error
        // debugger();
        throw Exception(
            'Failed to create chat. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (error) {
      // debugger();
      rethrow;
    }
  }
}
