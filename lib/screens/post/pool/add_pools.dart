import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/controller/services/post/post_provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/post/pool/widget/custom_text_field.dart';
import 'package:provider/provider.dart';

class AddPollScreen extends StatefulWidget {
  final String postField;
  final List<int> selectedTagUsers;
  final List<String> keywordList;
  final String privacyPolicy;
  final List<File> mediaFiles;
  final UserProfile userProfile;
  final List<String> interactions;
  const AddPollScreen({
    super.key,
    required this.postField,
    required this.selectedTagUsers,
    required this.keywordList,
    required this.privacyPolicy,
    required this.mediaFiles,
    required this.userProfile,
    required this.interactions,
  });

  @override
  State<AddPollScreen> createState() => _AddPollScreenState();
}

class _AddPollScreenState extends State<AddPollScreen> {
  final _pollTitleController = TextEditingController();
  final _pollDescriptionController = TextEditingController();
  final List<TextEditingController> _optionsControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  String _pollDuration = '7 days';

  final formKey = GlobalKey<FormState>();
  List<String> pollOptions = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PostProvider>();
  }

  @override
  void dispose() {
    _pollTitleController.dispose();
    _pollDescriptionController.dispose();
    for (final controller in _optionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionsControllers.length < 4) {
      setState(() {
        _optionsControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add up to 4 options only.')),
      );
    }
  }

  void _removeOption(int index) {
    if (index >= 2 && index < _optionsControllers.length) {
      setState(() {
        _optionsControllers[index].dispose();
        _optionsControllers.removeAt(index);
      });
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size * 1;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "Create a Poll",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        var pro = context.watch<PostProvider>();
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Poll Title *'),

                  CustomTextFormField(
                    controller: _pollTitleController,
                    hintText: 'Add your Title',
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Poll Description *'),
                  CustomTextFormField(
                    controller: _pollDescriptionController,
                    hintText: 'Add your Description',
                    maxLength: 140,
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Options *'),
                  SizedBox(
                    height: _optionsControllers.length <= 1
                        ? size.height * .15
                        : _optionsControllers.length >= 1 &&
                                _optionsControllers.length <= 2
                            ? size.height * .25
                            : size.height * .35,
                    child: ListView.builder(
                      itemCount: _optionsControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: _optionsControllers[index],
                                  hintText: 'Option ${index + 1}',
                                  maxLength: 30,
                                ),
                              ),
                              if (index >= 2)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeOption(index),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (_optionsControllers.length < 4)
                    ElevatedButton(
                      onPressed: _addOption,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                      child: const Text(
                        '+ Add option',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16.0),
                  // const Text('Poll duration'),
                  // DropdownButtonFormField<String>(
                  //   value: _pollDuration,
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       _pollDuration = newValue!;
                  //     });
                  //   },
                  //   decoration: const InputDecoration(
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     hintText: 'Select duration',
                  //     border: OutlineInputBorder(),
                  //     contentPadding:
                  //         EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  //   ),
                  //   items: <String>['7 days', '1 day', '14 days', '30 days']
                  //       .map<DropdownMenuItem<String>>((String value) {
                  //     return DropdownMenuItem<String>(
                  //       value: value,
                  //       child: Text(value),
                  //     );
                  //   }).toList(),
                  // ),
                  // const SizedBox(height: 16.0),
                  const Text(
                    "We don’t allow requests for political opinions, medical information, or other sensitive data.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 16.0),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: GestureDetector(
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = !isLoading;
                            });
                            pollOptions = _optionsControllers
                                .map((controller) => controller.text)
                                .toList();
                            print("Poll Options: $pollOptions");
                            final response = await pro.createNewPost(context,
                                postField: widget.postField,
                                peopleTags: widget.selectedTagUsers,
                                keywordsList: widget.keywordList,
                                privacyPost: widget.privacyPolicy,
                                mediaFiles: widget.mediaFiles,
                                pollTitle: _pollTitleController.text.trim(),
                                pollDescription:
                                    _pollDescriptionController.text.trim(),
                                pollOptions: pollOptions,
                                interactions: widget.interactions);

                            if (response != null) {
                              ToastNotifier.showSuccessToast(
                                  context, "Post Successfully posted!");
                              setState(() {
                                isLoading = false;
                              });
                              final token = await Prefrences.getAuthToken();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoDialogRoute(
                                      builder: (_) => MainScreen(
                                          userProfile: widget.userProfile,
                                          authToken: token),
                                      context: context),
                                  (route) => false);
                            }
                          }
                        },
                        child: Container(
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.poll_outlined,
                                        size: 20, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      "Pool Post",
                                      style: AppTextStyles.poppinsMedium()
                                          .copyWith(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
