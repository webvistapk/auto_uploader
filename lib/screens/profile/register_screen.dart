import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/profile/login_screen.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import '../widgets/app_logo.dart';
import '../../common/app_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorMessage = '';

  Future<void> _register() async {
    final String email = _emailController.text;
    final String username = _usernameController.text;
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String phoneNumber = _phoneNumberController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    try {
      final String token = await UserService.registerUser(
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (token.isNotEmpty) {
        // Store the token locally
        await AppUtils.storeAuthToken(AppUtils.authToken, token);

        // Navigate to the home page
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    const AppLogo(width: 80, height: 80),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _usernameController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Username',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _firstNameController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'First Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _lastNameController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Last Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneNumberController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Phone Number',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Confirm Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _register, // Trigger registration on button press
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text('Create Account',
                          style: AppStyles.buttonTextStyle),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) =>
                              false, // Remove all previous routes
                        );
                      },
                      child: const Text('Back to Login',
                          style: TextStyle(color: Colors.blue)),
                    ),
                    if (_errorMessage.isNotEmpty)
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
          ),
          const SizedBox(height: 10),
          const TellusLogo(width: 100, height: 50),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
