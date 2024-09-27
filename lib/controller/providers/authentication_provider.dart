import 'package:flutter/cupertino.dart';
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
        await Prefrences.SetUserEmail(email);

        ///
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoDialogRoute(
                builder: (_) => MainScreen(
                      email: email,
                      // accessToken: accessToken,
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
        await Prefrences.SetUserEmail(email);
        ToastNotifier.showSuccessToast(
            context, "User Register successfully $email");
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (_) => OtpScreen(
                      userEmail: email,
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
        isLoading = false;
        notifyListeners();
        return data;
      } else {
        isLoading = false;
        notifyListeners();
        return data;
      }
    } catch (e) {
      ToastNotifier.showErrorToast(context, e.toString());
      isLoading = false;
      notifyListeners();
    }
  }

  updateEmailVerfied(context, String email, String otp) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await ProviderManager.updateEmailVerified(email, otp);
      if (result != null) {
        final status = result['status'];
        if (status == "error") {
          isLoading = false;
          notifyListeners();
          final message = result['status'] + '\n' + result['message'];
          ToastNotifier.showErrorToast(context, message);
        } else {
          isLoading = false;
          notifyListeners();
          final message = result['status'] + '\n' + result['message'];
          ToastNotifier.showSuccessToast(context, message);
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoDialogRoute(
                  builder: (_) => MainScreen(
                        email: email,
                      ),
                  context: context),
              (route) => false);
        }
        // + '\n' + result['message'];
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  resendEmailVerified(context, String email) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ProviderManager.renewEmailVerified(email);
      ToastNotifier.showSuccessToast(context, data);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      ToastNotifier.showErrorToast(context, e.toString());
    }
  }
}
