import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/otp_screen.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isResend = false;

  loginUser(context, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      // Perform the login and get tokens
      final data = await ProviderManager.login(context, email, password);

      if (data != null) {
        final accessToken = data['access'];

        // Save the access token and email
        await Prefrences.SetAuthToken(accessToken);
        await Prefrences.SetUserEmail(email);

        log("Access Token: $accessToken");

        // Decode JWT to get userID
        int userID = JwtDecoder.decode(accessToken)['user_id'];

        UserPreferences userPrefs = UserPreferences();
        UserProfile? userProfile;

        // Try to get the current user profile from preferences
        userProfile = await userPrefs.getCurrentUser();

        if (userProfile == null) {
          // If the profile is null, fetch from the server
          // debugger();
          userProfile = await ProviderManager.fetchUserProfile(userID);
          // debugger();
          await userPrefs.saveCurrentUser(userProfile);
        }
        isLoading = false;
        notifyListeners();
        // Ensure userProfile is not null before navigating
        if (userProfile != null) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoDialogRoute(
              builder: (_) => MainScreen(
                email: email,
                userProfile: userProfile!,
                authToken: accessToken, // Safe since it's not null here
              ),
              context: context,
            ),
            (route) => false,
          );
        } else {
          ToastNotifier.showErrorToast(
              context, "Failed to retrieve user profile");
        }
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      // debugger();
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
        await Prefrences.SetUserEmail(email);
        notifyListeners();
        isLoading = false;
        notifyListeners();
        ToastNotifier.showSuccessToast(
            context, "User Register successfully $email");
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (_) => OtpScreen(
                      userEmail: email,
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

  updateEmailVerfied(context, String email, String otp, {int? id}) async {
    isLoading = true;
    notifyListeners();
    try {
      // debugger();

      final result = await ProviderManager.updateEmailVerified(email, otp);
      if (result != null) {
        final status = result['status'];
        // debugger();
        if (status == "error") {
          isLoading = false;
          notifyListeners();
          final message = result['status'] + '\n' + result['message'];
          ToastNotifier.showErrorToast(context, message);
        } else {
          // debugger();
          final message = result['status'] + '\n' + result['message'];

          UserPreferences userPrefs = UserPreferences();
          UserProfile? userProfile;

          // Try to get the current user profile from preferences
          userProfile = await userPrefs.getCurrentUser();
          final token = await Prefrences.getAuthToken();
          isLoading = false;
          notifyListeners();
          // debugger();
          if (token == null) {
            ToastNotifier.showSuccessToast(context, message);

            Navigator.pushAndRemoveUntil(
                context,
                CupertinoDialogRoute(
                    builder: (_) => LoginScreen(), context: context),
                (route) => false);
            return;
          } else if (userProfile == null) {
            // If the profile is null, fetch from the server
            if (id == null) {
              int userID = Prefrences.getUserId();
              userProfile = await ProviderManager.fetchUserProfile(userID);
              await userPrefs.saveCurrentUser(userProfile);
              notifyListeners();
            } else {
              int userID = id;
              userProfile = await ProviderManager.fetchUserProfile(userID);
              await userPrefs.saveCurrentUser(userProfile);
              notifyListeners();
            }
            ToastNotifier.showSuccessToast(context, message);

            Navigator.pushAndRemoveUntil(
                context,
                CupertinoDialogRoute(
                    builder: (_) => MainScreen(
                          email: email,
                          userProfile: userProfile!,
                          authToken: Prefrences.getAuthToken().toString(),
                        ),
                    context: context),
                (route) => false);
          }
          ToastNotifier.showSuccessToast(context, message);

          Navigator.pushAndRemoveUntil(
              context,
              CupertinoDialogRoute(
                  builder: (_) => MainScreen(
                        email: email,
                        userProfile: userProfile!,
                        authToken: Prefrences.getAuthToken().toString(),
                      ),
                  context: context),
              (route) => false);
        }
        // + '\n' + result['message'];
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      ToastNotifier.showErrorToast(context, e.toString());
    }
  }

  resendEmailVerified(context, String email) async {
    isResend = true;
    notifyListeners();
    try {
      final data = await ProviderManager.renewEmailVerified(email);
      ToastNotifier.showSuccessToast(context, data);
      isResend = false;
      notifyListeners();
    } catch (e) {
      isResend = false;
      notifyListeners();
      ToastNotifier.showErrorToast(context, e.toString());
    }
  }
}
