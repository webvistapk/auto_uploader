import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/post/pool/widget/custom_text_field.dart';
import 'package:provider/provider.dart';

class EmailInputScreen extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String password;

  const EmailInputScreen({
    Key? key,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.dateOfBirth,
  }) : super(key: key);

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isButtonEnabled = false; // Button state

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().errorMessage = '';

    emailController.addListener(() {
      setState(() {
        isButtonEnabled = formKey.currentState!.validate() ?? false;
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          final pro = context.watch<AuthProvider>();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Enter Your Email",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextFormField(
                          controller: emailController,
                          hintText: "example@gmail.com",
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Email Field Required";
                            } else if (!val.contains('@gmail.com')) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        if (pro.errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            pro.errorMessage,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.poppinsRegular(
                              fontSize: 14,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                    pro.isLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : CustomContinueButton(
                            buttonText: "Register",
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                pro.setErrorMessageEmpty();
                                await pro.registerUser(
                                  context,
                                  widget.username,
                                  emailController.text.trim(),
                                  widget.firstName,
                                  widget.lastName,
                                  widget.password,
                                  widget.dateOfBirth,
                                );
                              }
                            },
                            isPressed: isButtonEnabled,
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
