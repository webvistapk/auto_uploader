import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/screens/authantication/login_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PhoneVerifiedScreen extends StatefulWidget {
  final String phoneNumber;
  final String authToken;
  final UserProfile userProfile;
  // Corrected type for userEmail
  const PhoneVerifiedScreen(
      {Key? key,
      required this.phoneNumber,
      required this.userProfile,
      required this.authToken})
      : super(key: key);

  @override
  State<PhoneVerifiedScreen> createState() => _PhoneVerifiedScreenState();
}

class _PhoneVerifiedScreenState extends State<PhoneVerifiedScreen> {
  String otp = "";
  late Timer _timer;
  int _start = 30; // Countdown start time
  bool isLoading = false; // Track loading state for OTP verification
  bool isResending = false; // Track loading state for OTP resend

  bool isCheckLoading = false;
  // Controller for the OTP input field
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkVerification();
  }

  checkVerification() {
    if (mounted) {
      setState(() {
        isCheckLoading = true;
      });
    }
    var pro = context.read<AuthProvider>();
    Future.microtask(() async {
      await pro.resendPhoneVerified(context, widget.userProfile.email!);
    });
    if (mounted) {
      setState(() {
        isCheckLoading = false;
      });
    }
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
  Future<void> _submitOtp(String pin, AuthProvider pro, String email) async {
    setState(() {
      isLoading = true; // Show loading indicator for OTP verification
    });

    try {
      pro.setErrorMessage('');
      await pro.updatePhoneVerfied(context, email, otp);

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
        isLoading = false; // Hide loading indicator
      });
    }
  }

  // Function to resend OTP
  Future<void> _resendOtp(String email) async {
    setState(() {
      isResending = true; // Show loading indicator for OTP resend
    });

    try {
      Provider.of<AuthProvider>(context, listen: false).setErrorMessage('');
      await Provider.of<AuthProvider>(context, listen: false)
          .resendPhoneVerified(context, email);

      // Reset the timer and clear OTP field after resend
      startTimer();
      _otpController.clear();

      log("Resent OTP to ${email}");
    } catch (e) {
      log("Error resending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP')),
      );
    } finally {
      setState(() {
        isResending = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Builder(builder: (context) {
      var pro = context.watch<AuthProvider>();
      return isCheckLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Scaffold(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Check SMS on ${widget.phoneNumber}",
                                    style: AppTextStyles.poppinsBold(),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
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
                              await _submitOtp(
                                  pin, pro, widget.userProfile.email!);
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
                                    _resendOtp(widget.userProfile.email!);
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
                        if (pro.isLoading)
                          const Center(
                            child: SpinKitCircle(
                              color: AppColors.primary,
                              size: 60.0,
                            ),
                          ),
                        if (pro.errorMessage.isNotEmpty) ...[
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            pro.errorMessage,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.poppinsRegular(
                                fontSize: 14, color: AppColors.red),
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
