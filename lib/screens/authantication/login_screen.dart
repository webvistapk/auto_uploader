import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/app_textfield.dart';
import 'package:mobile/common/custom_social_button.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/authantication/forgot_password_screen.dart';
import 'package:mobile/screens/authantication/register_screen.dart';
import 'package:mobile/screens/authantication/sign_up_screen.dart';
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
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Builder(builder: (context) {
        var pro = context.watch<AuthProvider>();
        return Stack(
          children: [
            // Main content
            Container(
              height: double.infinity,
              width: double.infinity,
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Login in to Pine",
                      style: AppTextStyles.poppinsBold(fontSize: 22),
                    ),
                    const SizedBox(height: 100),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomAppTextField(
                            validator: (value) {
                              return null;
                            },
                            controller: _usernameController,
                            hintText: "Enter email or username",
                          ),
                          const SizedBox(height: 20),
                          CustomAppTextField(
                            validator: (value) {
                              return null;
                            },
                            controller: _passwordController,
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
                          if (pro.errorMessage.isNotEmpty) ...[
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              key: const Key('loginErrorMessageText'),
                              pro.errorMessage,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.poppinsRegular(
                                  fontSize: 14, color: AppColors.red),
                            )
                          ],
                          const SizedBox(height: 20),
                          pro.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      pro.setErrorMessage('');
                                      if (_usernameController.text.isEmpty) {
                                        pro.setErrorMessage(
                                            'Username or Email is required');
                                      } else if (_passwordController
                                          .text.isEmpty) {
                                        pro.setErrorMessage(
                                            'Please enter password field');
                                      } else if (formKey.currentState!
                                          .validate()) {
                                        FocusScope.of(context).unfocus();

                                        await pro.loginUser(
                                          context,
                                          _usernameController.text.trim(),
                                          _passwordController.text.trim(),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.blue,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: const Text('Log in',
                                        style: AppStyles.buttonTextStyle),
                                  ),
                                ),
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.topCenter,
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
                                      fontFamily: 'Greycliff CF',
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          CustomSocialButton(textTitle: 'Continue with Phone'),
                          CustomSocialButton(textTitle: 'Continue with Apple'),
                          CustomSocialButton(textTitle: 'Continue with Google'),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  CupertinoDialogRoute(
                                      builder: (_) => SignupScreen(),
                                      context: context));
                            },
                            style: TextButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                            child: Text(
                              'Create account',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
            // Footer with fixed logo
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                width: double.infinity,
                color: AppColors.mainBgColor,
                child: Align(
                  alignment: Alignment.center,
                  child: const TellusLogo(width: 150),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
