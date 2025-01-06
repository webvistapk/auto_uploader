import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/screens/authantication/signup/phone/phone_input.dart';

class PasswordInputScreen extends StatefulWidget {
  const PasswordInputScreen({Key? key}) : super(key: key);

  @override
  State<PasswordInputScreen> createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool x = true;
  bool y = true;
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      "Set Your Password",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // TextField(
                    //   obscureText: true,
                    // decoration: InputDecoration(
                    //   labelText: "Password",
                    //   border: OutlineInputBorder(),
                    // ),
                    // ),
                    TextFormField(
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
                      // labelText: 'Password',

                      obscureText: x,
                      decoration: InputDecoration(
                        hintText: "Enter password",
                        suffixIcon: GestureDetector(
                            onTap: () {
                              x = !x;
                              setState(() {});
                            },
                            child: x
                                ? Icon(
                                    Icons.visibility_off,
                                    color: Colors.black,
                                  )
                                : Icon(
                                    Icons.visibility,
                                    color: Colors.black,
                                  )),
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
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
                      // labelText: 'Confirm Password',

                      obscureText: y,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                            onTap: () {
                              y = !y;
                              setState(() {});
                            },
                            child: y
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility)),
                        hintText: "Enter confirm password",
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // TextField(
                    //   obscureText: true,
                    // decoration: InputDecoration(
                    //   labelText: "Confirm Password",
                    //   border: OutlineInputBorder(),
                    // ),
                    // ),
                  ],
                ),
                CustomContinueButton(
                  buttonText: "Submit",
                  onPressed: () {
                    // Perform submission logic here
                    Navigator.push(
                        context,
                        CupertinoDialogRoute(
                            builder: (_) => PhoneInputScreen(),
                            context: context));
                  },
                  isPressed: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
