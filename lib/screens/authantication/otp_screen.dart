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
  final String userEmail;
  final userID; // Corrected type for userEmail
  const OtpScreen({Key? key, required this.userEmail, this.userID})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = "";
  late Timer _timer;
  int _start = 30; // Countdown start time
  bool _isLoading = false; // Track loading state for OTP verification
  bool _isResending = false; // Track loading state for OTP resend

  // Controller for the OTP input field
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>();
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
    _otpController.dispose(); // Dispose of the controller
    super.dispose();
  }

  // Function to handle OTP submission
  Future<void> _submitOtp(String pin, AuthProvider pro) async {
    setState(() {
      _isLoading = true; // Show loading indicator for OTP verification
    });

    try {
      await pro.updateEmailVerfied(context, widget.userEmail, otp,
          id: widget.userID);

      // Clear OTP field after successful submission
      _otpController.clear();

      // Handle success (e.g., navigate to MainScreen)
    } catch (e) {
      log("Error verifying OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to resend OTP
  Future<void> _resendOtp() async {
    Focus.of(context).unfocus();
    setState(() {
      _isResending = true; // Show loading indicator for OTP resend
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .resendEmailVerified(context, widget.userEmail);

      // Reset the timer and clear OTP field after resend
      startTimer();
      _otpController.clear();

      log("Resent OTP to ${widget.userEmail}");
    } catch (e) {
      log("Error resending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP')),
      );
    } finally {
      setState(() {
        _isResending = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Builder(builder: (context) {
        var pro = context.watch<AuthProvider>();
        return Scaffold(
          body: Stack(
            children: [
              Column(
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
                      child: const Icon(Icons.arrow_back_ios, size: 25),
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
                      controller: _otpController, // Attach the controller
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      defaultPinTheme: PinTheme(
                        width: 40,
                        height: 55,
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        decoration: const BoxDecoration(
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
                        Focus.of(context).unfocus();
                        await _submitOtp(
                            pin, pro); // Call submit OTP when completed
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: _start == 0
                        ? TextButton(
                            onPressed: _resendOtp,
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
                  SizedBox(height: size.height * 0.05),
                  if (pro.isLoading)
                    const Center(
                      child: SpinKitCircle(
                        color: AppColors.primary,
                        size: 60.0,
                      ),
                    ),
                ],
              ),
              if (pro.isResend)
                Container(
                  color: Colors.black.withOpacity(0.5), // Background blur
                  child: const Center(
                    child: SpinKitCircle(
                      color: AppColors.blue, // Use your primary color
                      size: 60.0, // Size of the loader
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
