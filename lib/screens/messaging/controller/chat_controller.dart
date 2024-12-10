import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';
import 'package:mobile/screens/messaging/inbox.dart';
import 'package:mobile/screens/messaging/model/chat_model.dart';
import 'package:mobile/screens/messaging/model/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends ChangeNotifier {
  WebSocketChannel? _channel;
  List<MessageModel> _messages = [];
  bool _isConnected = false;
  bool _isMessageLoading = false;
  bool _isLoading = false;
  bool _isSending = false;

  List<MessageModel> get messages => _messages;
  bool get isConnected => _isConnected;
  bool get isMessageLoading => _isMessageLoading;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  // Fetch messages from the server
  // Updated method to handle pagination and new response structure

  Future createNewChat(
    context, {
    required String name,
    required List<int> participants,
    required bool isGroup,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ChatProvider.createNewChat(
          name: name, participants: participants, isGroup: isGroup);

      if (response != null) {
        final chat = response['chat'];
        ChatModel userNewChat = ChatModel.fromJson(chat);
        _isLoading = false;
        notifyListeners();
        UserProfile? userProfile = await UserPreferences().getCurrentUser();
        ToastNotifier.showSuccessToast(context, "Successfully Created Chat");
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (_) => InboxScreen(
                    userProfile: userProfile!, chatModel: userNewChat),
                context: context));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      ToastNotifier.showErrorToast(context, e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(int chatId,
      {int offset = 0, int limit = 10}) async {
    _isMessageLoading = true;
    notifyListeners();
    try {
      String authToken = await Prefrences.getAuthToken();
      final response = await http.get(
        Uri.parse(
            'http://147.79.117.253:8001/api/chat/$chatId/messages/?offset=$offset&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          _isMessageLoading = false;
          notifyListeners();
          final newMessages = List<MessageModel>.from(
            data['messages'].map((message) => MessageModel.fromJson(message)),
          );
          // Append new messages to the existing list
          if (offset == 0) {
            // First load or refresh
            _messages = newMessages;
          } else {
            // Pagination: Append messages
            _messages.addAll(newMessages);
          }

          notifyListeners();

          // Handle pagination
          if (data['has_next_page'] != null && data['has_next_page']) {
            log('More messages are available. Next offset: ${data['next_offset']}');
          } else {
            log('No more messages to load.');
          }
        }
      } else {
        _isMessageLoading = false;
        notifyListeners();
        throw Exception(
            "Failed to load messages. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _isMessageLoading = false;
      notifyListeners();
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
        debugger();
        // Decode the incoming WebSocket message
        final data = json.decode(message);

        // Step 1: Create the message from WebSocket data
        final newMessages = List<MessageModel>.from(
          data['data'].map((message) => MessageModel.fromJson(message)),
        );

        // Step 2: Add the received message to the list
        _messages.addAll(newMessages);

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
      _reconnectWebSocket(chatId);
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

  Future<void> sendMessage(String content, int chatId, List<File> files) async {
    _isSending = true;
    notifyListeners();
    try {
      // Step 1: Prepare the message and files for sending via form-data
      final uri = Uri.parse(
          'http://147.79.117.253:8001/api/chat/$chatId/messages/send/');
      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer ${await Prefrences.getAuthToken()}',
        })
        ..fields['message'] = content;

      if (files.isNotEmpty) {
        // Add files to the request if any
        for (var file in files) {
          // Assuming the files are images or documents and you can specify a key
          request.files
              .add(await http.MultipartFile.fromPath('files', file.path));
        }
      }

      // Step 2: Send the message via HTTP POST request
      final response = await request.send();

      if (response.statusCode == 201) {
        // Parse the response body
        final responseBody = await response.stream.bytesToString();
        final messageData = json
            .decode(responseBody)['data']; // Extract 'data' from the response
        _channel?.sink.add(json.encode({
          'data':
              messageData, // Send the complete 'data' object as per your structure
        }));
// Step 3: Add the sent message to the list
        MessageModel sentMessage = MessageModel.fromJson(messageData);
        _messages.add(sentMessage);
        _isSending = false;
        notifyListeners();

// Step 4: Send the entire message data through WebSocket
      } else {
        _isSending = false;
        notifyListeners();
        throw Exception(
            'Failed to send message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _isSending = false;
      notifyListeners();
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
