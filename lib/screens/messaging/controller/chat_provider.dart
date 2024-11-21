import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';

class ChatProvider with ChangeNotifier {
  final String baseUrl = "http://147.79.117.253:8001/api";
  String? accessToken;
  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  int? _currentChatId;
  bool _isLoading = false;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  int? get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;

  void setAccessToken(String token) {
    accessToken = token;
    notifyListeners();
  }

  Future<void> fetchChats() async {
    _isLoading = true; // Set loading to true when the fetch starts
    notifyListeners();

    final url = Uri.parse('$baseUrl/chat/');
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
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _chats = (data['chat'] as List)
              .map((chat) => ChatModel.fromJson(chat))
              .toList();
        } else {
          throw Exception('Error: ${data['status']}');
        }
      } else {
        throw Exception(
            'Failed to fetch chats. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching chats: $e');
    } finally {
      _isLoading = false; // Set loading to false after the fetch is complete
      notifyListeners();
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
}
