import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';

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
        log("Access Token: $accessToken");
        int userID = JwtDecoder.decode(accessToken)['user_id'];
        UserPreferences userPrefs = UserPreferences();
        UserProfile? userProfile;
        userPrefs.getCurrentUser().then((value) {
          if (value != null) {
            userProfile = value;
          } else {
            Future<UserProfile> currentUser =
                ProviderManager.fetchUserProfile(userID);
            currentUser.then((value) async {
              await userPrefs.saveCurrentUser(value);
              userProfile = value;
              notifyListeners();
            });
          }
        });
        // debugger();

        ///
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoDialogRoute(
                builder: (_) =>
                    MainScreen(email: email, userProfile: userProfile!
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
          UserProfile? userProfile;
          UserPreferences userPreferences = UserPreferences();
          userPreferences.getCurrentUser().then((value) {
            userProfile = value;
            notifyListeners();
          });
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoDialogRoute(
                  builder: (_) => MainScreen(
                        email: email,
                        userProfile: userProfile!,
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
