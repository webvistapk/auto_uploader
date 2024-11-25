import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends ChangeNotifier {
  WebSocketChannel? _channel;
  List<MessageModel> _messages = [];
  bool _isConnected = false;

  List<MessageModel> get messages => _messages;
  bool get isConnected => _isConnected;

  // Fetch messages from the server
  Future<void> loadMessages(int chatId) async {
    try {
      String authToken = await Prefrences.getAuthToken();
      final response = await http.get(
        Uri.parse('http://147.79.117.253:8001/api/chat/$chatId/messages/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _messages = List<MessageModel>.from(
            data['messages'].map((message) => MessageModel.fromJson(message)));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // Connect to WebSocket
  void connectWebSocket(int chatId) {
    // Close existing connection if any
    _channel?.sink.close();

    // Connect to WebSocket
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://147.79.117.253:8001/ws/chat/$chatId/'),
    );

    _channel?.stream.listen((message) {
      try {
        // Decode the incoming WebSocket message
        final data = json.decode(message);
        MessageModel lastMessage = _messages.last;
        // Add new message to the list
        _messages.add(
          MessageModel(
            id: lastMessage.id, // Ensure the ID is consistent with the backend
            sender: lastMessage.sender,
            senderUsername: data['username'],
            content: data['message'],
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        // Notify listeners about new messages
        notifyListeners();
      } catch (e) {
        print('Error parsing WebSocket message: $e');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
      _reconnectWebSocket(chatId);
    }, onDone: () {
      print('WebSocket closed. Attempting to reconnect...');
      // _reconnectWebSocket(chatId);
    });
  }

  // Reconnect WebSocket if connection is lost
  void _reconnectWebSocket(int chatId) {
    Future.delayed(const Duration(seconds: 5), () {
      if (_channel == null || _channel?.closeCode != null) {
        connectWebSocket(chatId);
      }
    });
  }

  // Send a message via WebSocket and HTTP
  Future<void> sendMessage(String content, int chatId, String username) async {
    try {
      // Construct the message data
      final messageData = json.encode({
        'username': username,
        'message': content,
      });

      // Send the message via WebSocket
      _channel?.sink.add(messageData);

      // Optionally send the message via HTTP for persistence
      String? accessToken = await Prefrences.getAuthToken();
      final response = await http.post(
        Uri.parse('http://147.79.117.253:8001/api/chat/$chatId/messages/send/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to send message. Check network.");
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void addMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  // Disconnect WebSocket connection
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
