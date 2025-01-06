import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_textfield.dart';
import 'package:mobile/components/authentication_type_view.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/profile/home_screen.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/screens/widgets/tellus_logo.dart';
import 'package:provider/provider.dart';
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
  var formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _websiteUrl = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AuthProvider>();
  }

  bool x = true;
  bool y = true;

  bool isAuthType = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBgColor,
      body: Builder(builder: (context) {
        var pro = context.watch<AuthProvider>();
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const AppLogo(width: 80, height: 80),

                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // AuthenticationTypeView(
                        //     onTap: () {
                        //       setState(() {
                        //         isAuthType = !isAuthType;
                        //       });
                        //     },
                        //     isActive: isAuthType),
                        // const SizedBox(height: 30),
                        CustomAppTextField(
                          hintText: "Enter email",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your email";
                            }
                            if (_emailController.text.contains("@") &&
                                !_emailController.text.contains(".com")) {
                              return "Email is not Correct";
                            }
                            return null;
                          },
                          controller: _emailController,
                          labelText: 'Email',
                        ),
                        const SizedBox(height: 10),
                        CustomAppTextField(
                          hintText: "Enter username",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your username";
                            }
                            return null;
                          },
                          controller: _usernameController,
                          labelText: 'Username',
                        ),

                        const SizedBox(height: 10),
                        CustomAppTextField(
                          hintText: "Enter first name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your first name";
                            }
                            return null;
                          },
                          controller: _firstNameController,
                          labelText: 'First Name',
                        ),

                        const SizedBox(height: 10),
                        CustomAppTextField(
                          hintText: "Enter last name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your last name";
                            }
                            return null;
                          },
                          controller: _lastNameController,
                          labelText: 'Last Name',
                        ),

                        const SizedBox(height: 10),
                        CustomAppTextField(
                          hintText: "Enter phone number",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your phone number";
                            }
                            return null;
                          },
                          controller: _phoneNumberController,
                          labelText: 'Phone Number',
                        ),

                        const SizedBox(height: 10),
                        CustomAppTextField(
                          hintText: "Enter password",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your password";
                            }

                            if (_passwordController.text.length < 8) {
                              return "Password should must be 8 characters or above";
                            }
                            return null;
                          },
                          controller: _passwordController,
                          labelText: 'Password',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                x = !x;
                                setState(() {});
                              },
                              child: x
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility)),
                          obscureText: x,
                        ),
                        const SizedBox(height: 10),
                        if (isAuthType) ...[
                          CustomAppTextField(
                            hintText: "Enter company name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your Company name";
                              }
                              return null;
                            },
                            controller: _companyNameController,
                            labelText: 'Company Name',
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            hintText: "Enter website url",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your Website Url";
                              }
                              return null;
                            },
                            controller: _websiteUrl,
                            labelText: 'Website Url',
                          ),
                        ],
                        const SizedBox(height: 10),
                        CustomAppTextField(
                          hintText: "Enter confirm password",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter your confirm password';
                            } else if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              return "Password did not match";
                            }
                            return null;
                          },
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                y = !y;
                                setState(() {});
                              },
                              child: y
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility)),
                          obscureText: y,
                        ),
                        const SizedBox(height: 20),
                        pro.isLoading
                            ? Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : ElevatedButton(
                                onPressed: !isAuthType
                                    ? () async {
                                        if (formKey.currentState!.validate()) {
                                          FocusScope.of(context).unfocus();
                                          await pro.registerUser(
                                              context,
                                              _usernameController.text.trim(),
                                              _emailController.text.trim(),
                                              _firstNameController.text.trim(),
                                              _lastNameController.text.trim(),
                                              _phoneNumberController.text
                                                  .trim(),
                                              _passwordController.text.trim());
                                        }
                                      }
                                    : () {}, // Trigger registration on button press
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
                        const SizedBox(height: 10),
                        const TellusLogo(width: 100, height: 50),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
