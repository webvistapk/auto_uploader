import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:mobile/controller/services/provider_manager.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:provider/provider.dart';

import '../../../../models/UserProfile/userprofile.dart';

class PhoneInputScreen extends StatefulWidget {
  final String authToken;
  final int? userId;
  final bool isUpdatePhone;
  // String? phoneNumber;
  const PhoneInputScreen({
    Key? key,
    this.authToken = '',
    this.userId,
    this.isUpdatePhone = false,
  }) : super(key: key);
  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController controller = TextEditingController();

  final PhoneNumber initialNumber = PhoneNumber(isoCode: 'PK', dialCode: '+92');
  bool isValid = false;
  String? completeNumber;
  var formKey = GlobalKey<FormState>();
  bool isUserProfileLoading = false;

  bool isButtonEnabled = false; // Button state

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context.read<AuthProvider>();
    savingCurrentData();
    completeNumber = initialNumber.dialCode;
    controller.addListener(() {
      setState(() {
        isButtonEnabled = controller.text.trim().isNotEmpty;
      });
    });
  }

  UserProfile? userProfileDetails;

  savingCurrentData() async {
    setState(() {
      isUserProfileLoading = true;
    });
    UserPreferences userPrefs = UserPreferences();
    UserProfile? userProfile;

    // Try to get the current user profile from preferences
    userProfile = await userPrefs.getCurrentUser();

    // debugger();
    if (userProfile == null) {
      // If the profile is null, fetch from the server
      if (widget.userId == null) {
        int userID = Prefrences.getUserId();
        userProfile = await ProviderManager.fetchUserProfile(userID);
        await userPrefs.saveCurrentUser(userProfile);
        userProfileDetails = userProfile;
        setState(() {});
      } else {
        userProfile = await ProviderManager.fetchUserProfile(widget.userId!);
        await userPrefs.saveCurrentUser(userProfile);
        userProfileDetails = userProfile;
        setState(() {});
      }
    }

    //ToastNotifier.showSuccessToast(context, message);
    setState(() {
      isUserProfileLoading = false;
    });
  }

  void onPhoneNumberChanged(PhoneNumber number) {
    print("Phone Number: ${number.phoneNumber}");
    setState(() {
      completeNumber = number.phoneNumber;
    });
  }

  void onPhoneNumberSaved(PhoneNumber number) {
    print("Saved Phone Number: ${number.phoneNumber}");
  }

  @override
  void dispose() {
    controller.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Builder(builder: (context) {
        var pro = context.watch<AuthProvider>();
        return isUserProfileLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "What's your phone",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Country Selector Box
                          Container(
                            width: MediaQuery.of(context).size.width * .39,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InternationalPhoneNumberInput(
                              onInputChanged: onPhoneNumberChanged,
                              onInputValidated: (bool value) {
                                setState(() {
                                  isValid = value;
                                });
                              },
                              spaceBetweenSelectorAndTextField:
                                  0, // Remove the space between selector and text field
                              selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.DROPDOWN,
                              ),
                              initialValue: initialNumber,
                              autoValidateMode: AutovalidateMode.disabled,
                              validator: (val) {
                                return null;
                              },
                              ignoreBlank: false,
                              textFieldController: controller,
                              formatInput:
                                  false, // Disabled formatting inside the selector

                              inputDecoration: InputDecoration(
                                border: InputBorder
                                    .none, // Remove default input field border
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                              ),
                              selectorTextStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                height: 1.2, // Reduces the spacing vertically
                              ),
                            ),
                            // width: 112, // Fixed width for the country selector
                          ),

                          const SizedBox(
                              width:
                                  12), // Space between selector and input field
                          // Phone Number Input Box
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(),
                              child: TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Phone Number Field is Required";
                                    // ToastNotifier.showErrorToast(
                                    //     context, "Phone Number is Required");
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ), // Remove default border
                                  hintText: 'Enter your phone number',
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "By continuing you agree to our Privacy Policy and Terms of Service",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
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
                      ],
                      const Spacer(),
                      pro.isLoading
                          ? Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : CustomContinueButton(
                              buttonText: !widget.isUpdatePhone
                                  ? 'Send Verification OTP'
                                  : 'Update Number',
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  print(
                                      "Complete Number: $completeNumber${controller.text}");
                                  await pro.updatePhoneNumber(
                                      context,
                                      widget.userId ?? 0,
                                      '$completeNumber${controller.text}');
                                }
                              },
                              isPressed: isButtonEnabled,
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
