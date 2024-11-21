import 'dart:convert';
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

    // Listen for messages from the server
    _channel?.stream.listen((message) {
      final data = json.decode(message);
      print(data);
      // Handle incoming message (e.g., add to message list)
      loadMessages(chatId);
      // _messages.add(MessageModel(content: ));
      print(_messages);

      notifyListeners();
    }, onError: (error) {
      print("WebSocket error: $error");
      // Attempt to reconnect
      _reconnectWebSocket(chatId);
    }, onDone: () {
      print("WebSocket closed. Reconnecting...");
      _reconnectWebSocket(chatId);
    });
  }

  // Reconnect WebSocket if connection is lost
  void _reconnectWebSocket(int chatId) {
    connectWebSocket(chatId);
  }

  // Send a message via WebSocket and HTTP
  Future<void> sendMessage(String content, int chatId, username) async {
    try {
      // Send the message to WebSocket
      _channel?.sink.add(json.encode({
        'sender': username, // Replace with actual sender info
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      }));
      String? accessToken = await Prefrences.getAuthToken();
      // Optionally send the message to the server using HTTP (for message persistence)
      final response = await http.post(
        Uri.parse('http://147.79.117.253:8001/api/chat/$chatId/messages/send/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': content}),
      );
      if (response.statusCode == 201) {
        print("Successfully Done All");
        connectWebSocket(chatId);
      } else {
        throw Exception(["Error Sending Message Check Network"]);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
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
