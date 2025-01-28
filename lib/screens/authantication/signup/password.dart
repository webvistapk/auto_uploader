import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/screens/authantication/signup/email.dart';

class PasswordInputScreen extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;
  final String dateOfBirth;

  const PasswordInputScreen({
    Key? key,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  }) : super(key: key);

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isPressed = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            onChanged:
                _updateIsPressed, // Update button state when form changes
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Set Your Password",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: "Password",
                      hint: "Enter password",
                      isPasswordVisible: _isPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your password";
                        }
                        if (value.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: "Confirm Password",
                      hint: "Re-enter password",
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your confirm password";
                        }
                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                CustomContinueButton(
                  buttonText: "Continue",
                  onPressed: isPressed
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              CupertinoDialogRoute(
                                builder: (_) => EmailInputScreen(
                                  username: widget.username,
                                  firstName: widget.firstName,
                                  lastName: widget.lastName,
                                  password: _passwordController.text.trim(),
                                  dateOfBirth: widget.dateOfBirth,
                                ),
                                context: context,
                              ),
                            );
                          }
                        }
                      : null, // Disable the button if not pressed
                  isPressed: isPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: GestureDetector(
              onTap: onVisibilityToggle,
              child: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black,
              ),
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 8), // Space between the field and error message
        Builder(
          builder: (context) {
            final error =
                (Form.of(context).validate() as FormFieldState?)?.errorText;
            return error != null
                ? Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _updateIsPressed() {
    setState(() {
      isPressed = _formKey.currentState?.validate() ?? false;
    });
  }
}
