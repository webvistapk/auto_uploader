import 'dart:convert';
import 'dart:developer';

import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:http/http.dart' as http;

class ProviderManager {
  static login(context, String email, String password) async {
    try {
      final completeUrl = Uri.parse(ApiURLs.baseUrl + ApiURLs.login_endpoint);

      final payload = {"username_or_email": email, "password": password};

      // final headers = {
      //   'Content-Type': 'application/json; charset=UTF-8',
      // };

      final response = await http.post(
        completeUrl, body: payload,
        // headers: headers
      );
      // debugger();
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ToastNotifier.showSuccessToast(context, "Login Successfully");
        return data;
      } else if (response.statusCode == 400) {
        // debugger();
        final message = data['message'];
        ToastNotifier.showErrorToast(context, message);
        return null;
      }
    } catch (e) {
      debugger();
      ToastNotifier.showErrorToast(context, e.toString());
      return null;
    }
  }
}
