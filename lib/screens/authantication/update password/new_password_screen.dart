import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/screens/authantication/update%20password/confirm_password_screen.dart';
import 'package:mobile/screens/authantication/update%20password/widget/custom_widget.dart';

class NewPasswordScreen extends StatefulWidget {
  final String oldPassword;

  NewPasswordScreen({required this.oldPassword});

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  double passwordStrength = 0.0;
  final TextEditingController newPasswordController = TextEditingController();
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

  bool obsecure = false;
  var formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Text("New Password", style: AppTextStyles.poppinsBold()),
                      const SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obsecure,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password will not be Empty";
                          } else if (passwordStrength < 1) {
                            return "Your Password Is Week";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            passwordStrength = calculateStrength(value);
                          });
                        },
                        decoration: AppStyles.inputDecoration.copyWith(
                            labelText: 'New Password',
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obsecure =
                                        !obsecure; // Toggle the password visibility
                                  });
                                },
                                icon: Icon(obsecure
                                    ? Icons.visibility_off
                                    : Icons.visibility))),
                      ),
                      const SizedBox(height: 30),
                      iconContainer(
                        'Password must contain 8 characters',
                        newPasswordController.text.length >= 8 ? true : false,
                      ),
                      const SizedBox(height: 5),
                      iconContainer(
                          '1 letter and 1 number',
                          (validateNumberAndLetterPassword(
                              newPasswordController.text))),
                      const SizedBox(height: 5),
                      iconContainer(
                          '1 special character exampler:{!@#&*~}',
                          validateSpecialCharPassword(
                              newPasswordController.text)),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: passwordStrength,
                        minHeight: 5,
                        backgroundColor: Colors.grey[300],
                        color: passwordStrength < 0.5
                            ? Colors.red
                            : (passwordStrength < 1
                                ? Colors.yellow
                                : Colors.green),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
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
                                style:
                                    const TextStyle(color: AppColors.whiteColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formkey.currentState!.validate()) {
                                  Navigator.push(
                                      context,
                                      CupertinoDialogRoute(
                                          builder: (_) => ConfirmPasswordScreen(
                                              oldPassword: widget.oldPassword,
                                              newPassword: newPasswordController
                                                  .text
                                                  .trim()),
                                          context: context));
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
                                style:
                                    const TextStyle(color: AppColors.whiteColor),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

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
