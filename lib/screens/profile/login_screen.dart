import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/screens/profile/forgot_password_screen.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';
import 'package:mobile/screens/profile/register_screen.dart';
import 'dart:convert';

import 'package:mobile/screens/widgets/tellus_logo.dart';
import '../widgets/app_logo.dart';
import '../../common/app_styles.dart';
import '../../common/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variable to store error message
  String _errorMessage = '';

  // Method to handle login
  Future<void> _login(usernameText, passwordText) async {
    isLoading = true;
    setState(() {});
    String username = usernameText;
    String password = passwordText;

    // if (Utils.devMode) {
    //   username = username;
    //   password = password;
    // } else {
    //   username = _usernameController.text;
    //   password = _passwordController.text;
    // }

    final Uri url = Uri.parse('${ApiURLs.baseUrl}${ApiURLs.login_endpoint}');

    try {
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username_or_email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['access'];
        isLoading = false;
        setState(() {});
        AppUtils.storeAuthToken(AppUtils.authToken, token);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  bool visible = false;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor, // Set greyish background color
      body: Column(
        children: [
          const Spacer(flex: 2), // Adjust the flex values to control spacing
          const AppLogo(
              width: 80,
              height: 80), // Position the logo higher with smaller size
          const SizedBox(height: 30),
          const Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter The Email or Username or Phone#";
                      }
                      return null;
                    },
                    controller: _usernameController, // Added controller
                    decoration: AppStyles.inputDecoration.copyWith(
                      labelText: 'Username, email, phone number',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter The Password";
                      }
                      return null;
                    },
                    controller: _passwordController, // Added controller

                    decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Password',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              visible = !visible;
                              setState(() {});
                            },
                            child: !visible
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility))),
                    obscureText: !visible ? true : false,
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            // debugger();
                            if (formKey.currentState!.validate()) {
                              _login(_usernameController.text.trim(),
                                  _passwordController.text.trim());
                            }
                          }, // Call _login method on button press
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .blue, // Set login button background to blue
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  50), // Updated border radius
                            ),
                          ),
                          child: const Text('Log in',
                              style: AppStyles.buttonTextStyle),
                        ),
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()));
                        // Navigator.pushNamed(context, Routes.forgotPassword);
                      },
                      child: Text(
                        'Forgot password?',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //       builder: (context) => const ForgotPasswordScreen()),
                  //   (Route<dynamic> route) =>
                  //       false, // Remove all previous routes
                  // );
                  //   },
                  //   child: const Text('Forgot password?'),
                  // ),
                  if (_errorMessage.isNotEmpty) // Display error message if any
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 5), // Pushes the below content to the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                      (Route<dynamic> route) =>
                          false, // Remove all previous routes
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(50), // Updated border radius
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  child: const Text('Create account',
                      style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 10),
                const TellusLogo(width: 100, height: 50),
                const SizedBox(
                    height:
                        20), // Adjust this value to add some spacing at the bottom if needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
