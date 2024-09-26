import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  final userID;
  const OtpScreen({Key? key, required this.userID}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = "";
  late Timer _timer;
  int _start = 30; // Countdown start time

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

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen only within the build method
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back_ios, size: 25),
                ),
              ),
              SizedBox(height: size.height * 0.02), // Use size here
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter 6-digit code",
                      style: AppTextStyles.poppinsBold(),
                    ),
                    SizedBox(height: size.height * 0.05), // Use size here
                    Text(
                      "Enter 6-digit code that was sent to your phone",
                      style:
                          AppTextStyles.poppinsSemiBold(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.05), // Use size here
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
                          color: AppColors.grey, // Grey underline
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    otp = value;
                    log("OTP Entered: $otp");
                  },
                  onCompleted: (pin) {
                    log("OTP Completed: $pin");
                    // code completion Implemented
                  },
                ),
              ),
              SizedBox(height: size.height * 0.05), // Use size here
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: _start == 0
                    ? TextButton(
                        onPressed: () {
                          startTimer(); // Reset the timer
                          // Logic to resend the OTP code
                          log("Resend code clicked");
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
      ),
    );
  }
}
