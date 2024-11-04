import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/provider_manager.dart';

class FollowerProvider extends ChangeNotifier {
  bool isLoading = false;

  getFollowersList(context, String token, int userID) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ProviderManager.fetchFollowers(token, userID);
      if (data != null) {
        return data;
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, e.toString());
      return null;
    }
  }
}
