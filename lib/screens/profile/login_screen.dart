import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/profile/forgot_password_screen.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';
import 'package:mobile/screens/profile/register_screen.dart';
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
      backgroundColor: AppColors.mainBgColor, // Set greyish background color
      resizeToAvoidBottomInset:
          true, // Ensures content adjusts when keyboard opens
      body: Builder(
        builder: (context) {
          var pro = context.watch<AuthProvider>();

          return Column(
            children: [
              // Fixed Header
              const SizedBox(height: 20),
              const AppLogo(width: 80, height: 80),

              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter the email or username or phone#";
                            }
                            return null;
                          },
                          controller: _usernameController,
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
                              return "Please enter the password";
                            }
                            return null;
                          },
                          controller: _passwordController,
                          decoration: AppStyles.inputDecoration.copyWith(
                            labelText: 'Password',
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
                                    await pro.loginUser(
                                      context,
                                      _usernameController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(double.infinity, 50),
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
                                  builder: (_) => const ForgotPasswordScreen(),
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

              // Fixed Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
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
    );
  }
}
