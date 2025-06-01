import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/check_login_info.dart';
import 'package:mobile/screens/authantication/community/discover_community.dart';
import 'package:mobile/screens/authantication/email_otp_screen.dart';
import 'package:mobile/screens/authantication/signup/phone/phone_input.dart';
import 'package:mobile/screens/authantication/signup/phone/phone_verified_screen.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/messaging/controller/chat_provider.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isResend = false;
  String errorMessage = '';

  loginUser(context, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      // Perform the login and get tokens
      final data = await ProviderManager.login(context, email, password);

      if (data != null && data.containsKey('status') == false) {
        final accessToken = data['access'];
        ChatProvider().setAccessToken(accessToken);
        // Save the access token and email
        await Prefrences.setAuthToken(accessToken);
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
        bool? isLoginInfo = await Prefrences.getLoginInfoSave();
        final Phonedata =
            await ProviderManager.checkPhoneVerified(context, email);
        log("Data: $Phonedata");

        bool isPhoneVerify = Phonedata['verified'];

        if (isLoginInfo != null && isLoginInfo) {
          if (isPhoneVerify == true) {
            isLoading = false;
            notifyListeners();
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
            isLoading = false;
            notifyListeners();
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoDialogRoute(
                builder: (_) => PhoneInputScreen(
                  userId: userProfile!.id,
                  authToken: accessToken, // Safe since it's not null here
                ),
                context: context,
              ),
              (route) => false,
            );
          }
        } else {
          if (isPhoneVerify == true) {
            isLoading = false;
            notifyListeners();
            Navigator.push(
                context,
                CupertinoDialogRoute(
                    builder: (_) => CheckLoginInfoScreen(
                          userProfile: userProfile!,
                          authToken: accessToken,
                        ),
                    context: context));
          } else {
            isLoading = false;
            notifyListeners();
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoDialogRoute(
                builder: (_) => PhoneInputScreen(
                  userId: userProfile!.id,
                  authToken: accessToken, // Safe since it's not null here
                ),
                context: context,
              ),
              (route) => false,
            );
          }
        }
        // Ensure userProfile is not null before navigating
      } else {
        isLoading = false;
        notifyListeners();
        errorMessage = data['message'];
        notifyListeners();
        log("Error Message: $errorMessage");
      }
    } catch (e) {
      // debugger();
      isLoading = false;
      notifyListeners();
      errorMessage = e.toString();
      notifyListeners();
      log("Error Message: $errorMessage");
      //ToastNotifier.showErrorToast(context, e.toString());
    }
  }

  setErrorMessage(String val) {
    errorMessage = val;
    notifyListeners();
  }

  registerUser(
      context,
      String username,
      String email,
      String firstName,
      String lastName,
      // String phoneNumber,
      String password,
      String dateOfBirth) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ProviderManager.register(
          context, username, email, firstName, lastName, password, dateOfBirth);
      if (data != null) {
        final accessToken = data['access'];
        // Decode the JWT
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

        // Extract the user_id
        int userId = decodedToken['user_id'];
        await Prefrences.SetUserId(userId);
        await Prefrences.setAuthToken(accessToken);
        await Prefrences.SetUserEmail(email);
        notifyListeners();
        isLoading = false;
        notifyListeners();
        //ToastNotifier.showSuccessToast(
        //  context, "User Register successfully $email");
        // Navigator.push(
        //     context,
        //     CupertinoDialogRoute(
        //         builder: (_) => OtpScreen(
        //               userEmail: email,
        //               userID: id,
        //             ),
        //         context: context));
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (_) => EmailOtpScreen(
                      userID: userId,
                      userEmail: email,
                    ),
                context: context));
      } else {
        isLoading = false;
        notifyListeners();
        if (ProviderManager.registrationError.isNotEmpty) {
          errorMessage = ProviderManager.registrationError;
          notifyListeners();
        }
      }
    } catch (e) {
      isLoading = true;
      notifyListeners();
      errorMessage = e.toString();

      ////ToastNotifier.showErrorToast(context, e.toString());
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
      //ToastNotifier.showErrorToast(context, e.toString());
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
          errorMessage = result['status'] + '\n' + result['message'];
          //ToastNotifier.showErrorToast(context, message);
        } else {
          // debugger();
          // errorMessage = result['status'] + '\n' + result['message'];

          int userId;
          // debugger();

          // If the profile is null, fetch from the server
          if (id == null) {
            int userID = await Prefrences.getUserId() ?? 0;
            userId = userID;
          } else {
            log("UserID : $id");
            userId = id;
          }
          //ToastNotifier.showSuccessToast(context, message);
          String authToken = await Prefrences.getAuthToken() ?? '';
          isLoading = false;
          notifyListeners();
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoDialogRoute(
                  builder: (_) => PhoneInputScreen(
                        userId: userId,
                        authToken: authToken,
                      ),
                  context: context),
              (route) => false);
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     CupertinoDialogRoute(
          //         builder: (_) => MainScreen(
          //               email: email,
          //               userProfile: userProfile!,
          //               authToken: Prefrences.getAuthToken().toString(),
          //             ),
          //         context: context),
          //     (route) => false);

          //ToastNotifier.showSuccessToast(context, message);
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     CupertinoDialogRoute(
          //         builder: (_) => PhoneInputScreen(
          //               userProfile: userProfile!,
          //               authToken: Prefrences.getAuthToken().toString(),
          //             ),
          //         context: context),
          //     (route) => false);
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     CupertinoDialogRoute(
          //         builder: (_) => MainScreen(
          //               email: email,
          //               userProfile: userProfile!,
          //               authToken: Prefrences.getAuthToken().toString(),
          //             ),
          //         context: context),
          //     (route) => false);
        }
        // + '\n' + result['message'];
      } else {
        errorMessage = result['status'] + '\n' + result['message'];

        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      errorMessage = e.toString();
      //ToastNotifier.showErrorToast(context, e.toString());
    }
  }

  resendEmailVerified(context, String email) async {
    isResend = true;
    notifyListeners();
    setErrorMessage('');
    notifyListeners();
    try {
      final data = await ProviderManager.renewEmailVerified(email);
      if (data == "error") {
        errorMessage = data;
      }
      //ToastNotifier.showSuccessToast(context, data);
      isResend = false;
      notifyListeners();
    } catch (e) {
      isResend = false;
      errorMessage = e.toString();
      notifyListeners();

      //ToastNotifier.showErrorToast(context, e.toString());
    }
  }

  /// Phone Verification

  checkPhoneVerification(
      context, String email, String authToken, UserProfile userProfile) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ProviderManager.checkPhoneVerified(context, email);
      if (data != null) {
        isLoading = false;
        notifyListeners();
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoDialogRoute(
                builder: (_) =>
                    MainScreen(userProfile: userProfile, authToken: authToken),
                context: context),
            (route) => false);
      } else {
        isLoading = false;
        notifyListeners();
        errorMessage = "OTP Wrong Kindly Try Again also Check your Network...";
      }
    } catch (e) {
      //ToastNotifier.showErrorToast(context, e.toString());
      isLoading = false;
      notifyListeners();
      errorMessage = e.toString();
    }
  }

  updatePhoneVerfied(context, String email, String otp, {int? id}) async {
    isLoading = true;
    notifyListeners();
    try {
      // debugger();

      final result = await ProviderManager.updatePhoneVerified(email, otp);
      if (result != null) {
        final status = result['status'];
        // debugger();
        if (status == "error") {
          isLoading = false;
          notifyListeners();
          errorMessage = result['status'] + '\n' + result['message'];
          //ToastNotifier.showErrorToast(context, message);
        } else {
          // debugger();
          // errorMessage = result['status'] + '\n' + result['message'];

          UserPreferences userPrefs = UserPreferences();
          UserProfile? userProfile;

          // Try to get the current user profile from preferences
          userProfile = await userPrefs.getCurrentUser();
          final authToken = await Prefrences.getAuthToken();

          // debugger();
          if (userProfile == null) {
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
            //ToastNotifier.showSuccessToast(context, message);
            await Prefrences.setPhoneVerify(true);
            bool? isDiscover = await Prefrences.getDiscoverCommunity();
            isLoading = false;
            notifyListeners();
            if (isDiscover != null && isDiscover == true) {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoDialogRoute(
                      builder: (_) => MainScreen(
                          email: email,
                          userProfile: userProfile!,
                          authToken: authToken),
                      context: context),
                  (route) => false);
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoDialogRoute(
                      builder: (_) => DiscoverCommunityScreen(
                          userProfile: userProfile!, authToken: authToken),
                      context: context),
                  (route) => false);
            }
          }
          //ToastNotifier.showSuccessToast(context, message);
          else {
            await Prefrences.setPhoneVerify(true);
            bool? isDiscover = await Prefrences.getDiscoverCommunity();
            isLoading = false;
            notifyListeners();
            if (isDiscover != null && isDiscover == true) {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoDialogRoute(
                      builder: (_) => MainScreen(
                          email: email,
                          userProfile: userProfile!,
                          authToken: authToken),
                      context: context),
                  (route) => false);
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoDialogRoute(
                      builder: (_) => DiscoverCommunityScreen(
                          userProfile: userProfile!, authToken: authToken),
                      context: context),
                  (route) => false);
            }
          }
        }
        // + '\n' + result['message'];
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      errorMessage = e.toString();
      //ToastNotifier.showErrorToast(context, e.toString());
    }
  }

  resendPhoneVerified(context, String email) async {
    isResend = true;
    notifyListeners();
    setErrorMessage('');
    notifyListeners();
    try {
      final data = await ProviderManager.renewPhoneVerified(email);
      if (data == "error") {
        errorMessage = data;
      }
      //ToastNotifier.showSuccessToast(context, data);
      isResend = false;
      notifyListeners();
    } catch (e) {
      isResend = false;
      errorMessage = e.toString();
      notifyListeners();

      //ToastNotifier.showErrorToast(context, e.toString());
    }
  }

  updatePhoneNumber(context, int userId, String phoneNumber) async {
    isLoading = true;
    notifyListeners();
    setErrorMessage('');
    notifyListeners();
    try {
      final data = await ProviderManager.updatePhoneNumber(userId, phoneNumber);

      if (data == null) {
        isLoading = false;

        errorMessage =
            "Enter a valid phone number this field has no more than 15 characters.";
        notifyListeners();
      } else {
        final String? token = await Prefrences.getAuthToken();
        final userDetails = UserPreferences().getCurrentUser();
        UserProfile? userProfile;
        userDetails.then((value) => userProfile = value);
        isLoading = false;
        notifyListeners();
        Navigator.push(
            context,
            CupertinoDialogRoute(
                builder: (_) => PhoneVerifiedScreen(
                      authToken: token!,
                      userProfile: userProfile!,
                      phoneNumber: phoneNumber,
                    ),
                context: context));
      }
      //ToastNotifier.showSuccessToast(context, data);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();

      //ToastNotifier.showErrorToast(context, e.toString());
    }
  }
}
