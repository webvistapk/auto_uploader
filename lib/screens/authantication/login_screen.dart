import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_textfield.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/authantication/forgot_password_screen.dart';
import 'package:mobile/screens/authantication/register_screen.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import 'package:provider/provider.dart';
import '../widgets/app_logo.dart';
import '../../common/app_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool visible = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.mainBgColor, // Set greyish background color
        resizeToAvoidBottomInset:
            false, // Prevent resizing when keyboard is open
        body: Builder(
          builder: (context) {
            var pro = context.watch<AuthProvider>();

            return Column(
              children: [
                // Fixed Header
                const SizedBox(height: 20),
                const AppLogo(width: 80, height: 80),

                // Scrollable content (form and fields)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          CustomAppTextField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the email or username or phone#";
                              }
                              return null;
                            },
                            controller: _usernameController,
                            labelText: 'Email or Username',
                            hintText: "Enter email or username",
                            // contentPadding: const EdgeInsets.symmetric(
                            //     vertical: 20, horizontal: 16),
                          ),
                          const SizedBox(height: 20),
                          CustomAppTextField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the password";
                              }
                              return null;
                            },
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: "Enter password",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  visible = !visible;
                                });
                              },
                              child: Icon(
                                visible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            obscureText: !visible,
                          ),
                          const SizedBox(height: 20),
                          pro.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      await pro.loginUser(
                                        context,
                                        _usernameController.text.trim(),
                                        _passwordController.text.trim(),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text('Log in',
                                      style: AppStyles.buttonTextStyle),
                                ),
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
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

                // Fixed Footer (remains stable when keyboard appears)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoDialogRoute(
                                  builder: (_) => RegisterScreen(),
                                  context: context));
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        child: const Text(
                          'Create account',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const TellusLogo(width: 100, height: 50),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
