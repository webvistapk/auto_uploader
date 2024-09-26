import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
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

  registerUser(context, String username, String email, String firstName,
      String lastName, String phoneNumber, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ProviderManager.register(
          context, username, email, firstName, lastName, phoneNumber, password);
      if (data != null) {
        final id = data['id'];

        await Prefrences.SetUserId(id);
        isLoading = false;
        notifyListeners();
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (_) => OtpScreen(
                      userID: id,
                    ),
                context: context));
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = true;
      notifyListeners();

      ToastNotifier.showErrorToast(context, e.toString());
    }
  }

  checkEmailVerification(context, String email) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ProviderManager.checkEmailVerified(context, email);
      if (data) {
        ToastNotifier.showSuccessToast(context, "Again Welcome! to our App");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString(Prefrences.authToken);
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoDialogRoute(
                builder: (_) => MainScreen(accessToken: accessToken),
                context: context),
            (route) => false);
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, e.toString());
    }
  }
}
