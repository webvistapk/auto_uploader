import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mobile/common/custom_continue_button.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class PhoneInputScreen extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const PhoneInputScreen(
      {Key? key,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.password})
      : super(key: key);
  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController controller = TextEditingController();
  final PhoneNumber initialNumber = PhoneNumber(isoCode: 'US');
  bool isValid = false;
  String? completeNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AuthProvider>();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Builder(builder: (context) {
        var pro = context.watch<AuthProvider>();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        showFlags: false, // Set this to true if you want flags
                        setSelectorButtonAsPrefixIcon: false,
                      ),
                      initialValue: initialNumber,
                      autoValidateMode: AutovalidateMode.disabled,
                      ignoreBlank: false,
                      textFieldController: controller,
                      formatInput:
                          false, // Disabled formatting inside the selector
                      inputDecoration: InputDecoration(
                        border: InputBorder
                            .none, // Remove default input field border
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      selectorTextStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.2, // Reduces the spacing vertically
                      ),
                    ),
                    width: 112, // Fixed width for the country selector
                  ),

                  const SizedBox(
                      width: 12), // Space between selector and input field
                  // Phone Number Input Box
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none, // Remove default border
                          hintText: 'Enter your phone number',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
              const Spacer(),
              pro.isLoading
                  ? Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : CustomContinueButton(
                      buttonText: 'Send Verification Text',
                      onPressed: () async {
                        if (completeNumber!.isEmpty || completeNumber == null) {
                          ToastNotifier.showErrorToast(
                              context, "Phone Number is Required");
                        } else {
                          FocusScope.of(context).unfocus();
                          await pro.registerUser(
                              context,
                              widget.username,
                              widget.email,
                              widget.firstName,
                              widget.lastName,
                              completeNumber!,
                              widget.password);
                        }
                      },
                      isPressed: true,
                    ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      }),
    );
  }
}
