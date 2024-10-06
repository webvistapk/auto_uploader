import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_size.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/profile/profile_screen.dart';
import '../../common/message_toast.dart';
import '../../controller/endpoints.dart';
import '../../prefrences/prefrences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  int currentStep = 0;
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  double passwordStrength = 0.0;
  bool _obscureText = true;
  final changeformKey = GlobalKey<FormState>();

  // Regular expression to check the password strength
  bool validatePassword(String password) {
    String pattern = r'^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  bool validateSpecialCharPassword(String password) {
    String pattern = r'(?=.*[!@#\$&*~])';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  bool validateNumberAndLetterPassword(String password) {
    // RegEx for at least one letter and one number
    String pattern = r'^(?=.*[A-Za-z])(?=.*\d)';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  // Calculate password strength based on criteria
  double calculateStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Za-z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;
    return strength;
  }

  //Check current password
  checkPassword(context, String password) async {
    try {
      String? email = await Prefrences.getUserEmail();
      final completeUrl = Uri.parse(ApiURLs.baseUrl + ApiURLs.login_endpoint);

      final body = {"username_or_email": email, "password": password};
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        // Add any other necessary headers like Authorization here if required
      };

      Response response = await http.post(completeUrl,
          body: jsonEncode(body), headers: headers);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ToastNotifier.showSuccessToast(context, "Current password is correct");
        setState(() {
          currentStep = 1;
        });
        return data;
      } else {
        ToastNotifier.showErrorToast(
            context, "Your Current Password is incorrect");
      }
    } catch (e) {
      log('Error: $e');
      ToastNotifier.showErrorToast(context, e.toString());
      return null;
    }
  }

  //Check current password
  updatePassword(context, String oldPassword, newPassword) async {
    try {
      final completeUrl = Uri.parse(ApiURLs.baseUrl + ApiURLs.update_password);
      final String? token = await Prefrences.getAuthToken();
      int? userid = await Prefrences.getUserId();
      final body = {"old_password": oldPassword, "new_password": newPassword};
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $token"
        // Add any other necessary headers like Authorization here if required
      };

      Response response =
          await http.put(completeUrl, body: jsonEncode(body), headers: headers);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ToastNotifier.showSuccessToast(
            context, "Your password changed successfully");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ProfileScreen(id: userid)));
        return data;
      } else {
        ToastNotifier.showErrorToast(
            context, "Your Current Password is incorrect");
      }
    } catch (e) {
      log('Error: $e');
      ToastNotifier.showErrorToast(context, e.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
        ),
        // drawer: const SideBar(),
        // bottomNavigationBar: BottomBar(
        //   selectedIndex: 1,
        // ),
        backgroundColor: AppColors.mainBgColor,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create password",
                  style: TextStyle(
                      color: AppColors.blackColor, fontSize: paragraph * 0.65),
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: changeformKey,
                  child: IndexedStack(
                    index: currentStep,
                    children: [
                      // Step 1: Enter current password
                      firstStepContainer(),
                      // Step 2: Enter new password
                      secondStepContainer(),
                      // Step 3: Confirm new password
                      finalStepContainer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // Old Password Screen
  Widget firstStepContainer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: currentPasswordController,
            obscureText: _obscureText,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter current password";
              }
              return null;
            },
            decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle the password visibility
                      });
                    },
                    icon: Icon(_obscureText ? Icons.lock : Icons.lock_open))),
          ),
          const SizedBox(height: 150),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (changeformKey.currentState!.validate())
                      checkPassword(context, currentPasswordController.text);
                    /*setState(() {
                      currentStep = 1;
                    });*/
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  //New Password Widget
  Widget secondStepContainer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: newPasswordController,
            obscureText: _obscureText,
            onChanged: (value) {
              setState(() {
                passwordStrength = calculateStrength(value);
              });
            },
            decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle the password visibility
                      });
                    },
                    icon: Icon(_obscureText ? Icons.lock : Icons.lock_open))),
          ),
          const SizedBox(height: 20),
          iconContainer(
            'Password must contain 8 characters',
            newPasswordController.text.length >= 8 ? true : false,
          ),
          const SizedBox(height: 5),
          iconContainer('1 letter and 1 number',
              (validateNumberAndLetterPassword(newPasswordController.text))),
          const SizedBox(height: 5),
          iconContainer('1 special character exampler:{!@#&*~}',
              validateSpecialCharPassword(newPasswordController.text)),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: passwordStrength,
            minHeight: 5,
            backgroundColor: Colors.grey[300],
            color: passwordStrength < 0.5
                ? Colors.red
                : (passwordStrength < 1 ? Colors.yellow : Colors.green),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentStep > 0) {
                        currentStep--;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
              SizedBox(
                width: paragraph * 0.5,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: validatePassword(newPasswordController.text)
                      ? () {
                          setState(() {
                            currentStep = 2;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  //Confirm Password Widget
  Widget finalStepContainer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: confirmPasswordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText:
                    newPasswordController.text == confirmPasswordController.text
                        ? null
                        : 'Passwords do not match',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText =
                            !_obscureText; // Toggle the password visibility
                      });
                    },
                    icon: Icon(_obscureText ? Icons.lock : Icons.lock_open))),
          ),
          const SizedBox(height: 150),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentStep > 0) {
                        currentStep--;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
              SizedBox(
                width: paragraph * 0.5,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (newPasswordController.text ==
                        confirmPasswordController.text) {
                      updatePassword(context, currentPasswordController.text,
                          newPasswordController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  //Icon Container
  Widget iconContainer(String text, bool valid) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.circle,
          size: valid ? 20 : 10,
          color: valid ? AppColors.greenColor : AppColors.grey,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          text,
          style: const TextStyle(color: AppColors.grey),
        ),
      ],
    );
  }
}
