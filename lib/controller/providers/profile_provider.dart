import 'package:flutter/material.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;

  updateProfile(context, UserProfile userProfile) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ProviderManager.updateUserProfile(userProfile);
      if (response != null) {
        isLoading = false;
        notifyListeners();
        //ToastNotifier.showSuccessToast(context, "Successfully Profile Updated");
      } else {
        isLoading = false;
        notifyListeners();
        //ToastNotifier.showErrorToast(context, "Error !");
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      //ToastNotifier.showErrorToast(context, e.toString());
    }
  }
}
