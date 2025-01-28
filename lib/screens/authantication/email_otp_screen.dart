import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class EmailOtpScreen extends StatefulWidget {
  final String userEmail;
  final userID; // Corrected type for userEmail
  const EmailOtpScreen({Key? key, required this.userEmail, this.userID})
      : super(key: key);

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
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
      _isLoading = true;
    });

    try {
      await pro.updateEmailVerfied(context, widget.userEmail, pin,
          id: widget.userID);
      log("OTP verified successfully");
      _otpController.clear();
    } catch (e) {
      log("Error verifying OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to resend OTP
  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .resendEmailVerified(context, widget.userEmail);
      log("OTP resent successfully");
      startTimer(); // Restart timer
      _otpController.clear(); // Clear input
    } catch (e) {
      log("Error resending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP')),
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Builder(builder: (context) {
      var pro = context.watch<AuthProvider>();
      return Scaffold(
        body: FocusScope(
          // Wrap with FocusScope to manage focus properly
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.pushAndRemoveUntil(
                        //   context,
                        //   CupertinoDialogRoute(
                        //     builder: (_) => LoginScreen(),
                        //     context: context,
                        //   ),
                        //   (route) => false,
                        // );
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
                      controller: _otpController,
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
                      },
                      onCompleted: (pin) async {
                        FocusScope.of(context).unfocus(); // Unfocus here
                        await _submitOtp(pin, pro);
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: _start == 0
                        ? TextButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _resendOtp();
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
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator.adaptive()
                        // SpinKitCircle(
                        //   color: AppColors.primary,
                        //   size: 60.0,
                        // ),
                        ),
                  if (pro.errorMessage.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          pro.errorMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.poppinsRegular(
                              fontSize: 14, color: AppColors.red),
                        )
                      ],
                    )
                  ]
                ],
              ),
              if (pro.isResend)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: SpinKitCircle(
                      color: AppColors.blue,
                      size: 60.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
