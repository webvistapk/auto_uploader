import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;

  loginUser(context, String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ProviderManager.login(context, email, password);
      if (data != null) {
        final accessToken = data['access'];
        isLoading = false;
        notifyListeners();
        await Prefrences.SetAuthToken(accessToken);

        ///
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoDialogRoute(
                builder: (_) => MainScreen(
                      accessToken: accessToken,
                    ),
                context: context),
            (route) => false);
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      ToastNotifier.showErrorToast(context, e.toString());
    }
  }
}
