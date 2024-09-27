import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/profile/login_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final String userEmail; // Corrected type for userEmail
  const OtpScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = "";
  late Timer _timer;
  int _start = 30; // Countdown start time
  bool _isLoading = false; // Track loading state for OTP verification
  bool _isResending = false; // Track loading state for OTP resend

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  // Start the countdown timer
  void startTimer() {
    _start = 30; // Reset countdown time
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Function to handle OTP submission
  Future<void> _submitOtp(String pin) async {
    setState(() {
      _isLoading = true; // Show loading indicator for OTP verification
    });

    try {
      // Call the provider method to update email verification
      await Provider.of<AuthProvider>(context, listen: false)
          .updateEmailVerfied(context, widget.userEmail, pin);
      // Handle success (e.g., navigate to MainScreen)
    } catch (e) {
      // Handle error (e.g., show a toast)
      log("Error verifying OTP: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to resend OTP
  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true; // Show loading indicator for OTP resend
    });

    try {
      // Call your provider method to resend the OTP
      await Provider.of<AuthProvider>(context, listen: false)
          .resendEmailVerified(context, widget.userEmail);
      // Reset the timer
      startTimer();
      log("Resent OTP to ${widget.userEmail}");
    } catch (e) {
      log("Error resending OTP: $e");
    } finally {
      setState(() {
        _isResending = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen only within the build method
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoDialogRoute(
                            builder: (_) => LoginScreen(),
                            context: context,
                          ),
                          (route) => false,
                        );
                      },
                      child: Icon(Icons.arrow_back_ios, size: 25),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enter 6-digit code",
                          style: AppTextStyles.poppinsBold(),
                        ),
                        SizedBox(height: size.height * 0.05),
                        Text(
                          "Enter 6-digit code that was sent to your phone",
                          style: AppTextStyles.poppinsSemiBold(
                              color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Center(
                    child: Pinput(
                      length: 6,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      defaultPinTheme: PinTheme(
                        width: 40,
                        height: 55,
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        otp = value;
                        log("OTP Entered: $otp");
                      },
                      onCompleted: (pin) async {
                        log("OTP Completed: $pin");
                        await _submitOtp(pin); // Call submit OTP when completed
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: _start == 0
                        ? TextButton(
                            onPressed: () {
                              _resendOtp(); // Resend OTP when the button is pressed
                            },
                            child: Text(
                              "Resend code",
                              style: AppTextStyles.poppinsSemiBold(
                                  color: AppColors.primary),
                            ),
                          )
                        : Text(
                            "Resend code in $_start s",
                            style: AppTextStyles.poppinsSemiBold(
                                color: AppColors.grey),
                          ),
                  ),
                ],
              ),
            ),
            // Loading indicator
            if (_isResending)
              Container(
                color: Colors.black.withOpacity(0.5), // Background blur
                child: Center(
                  child: SpinKitCircle(
                    color: AppColors.primary, // Use your primary color
                    size: 60.0, // Size of the loader
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
