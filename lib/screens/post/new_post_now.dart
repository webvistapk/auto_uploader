// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile/common/message_toast.dart';
// import 'package:mobile/controller/services/post/post_provider.dart';
// import 'package:mobile/models/UserProfile/userprofile.dart';
// import 'package:mobile/prefrences/prefrences.dart';
// import 'package:mobile/screens/mainscreen/main_screen.dart';
// import 'package:mobile/screens/post/pool/add_pools.dart';
// import 'package:provider/provider.dart';

// class NewPostNow extends StatefulWidget {
//   final String postField; // Title of the post
//   final List<int> peopleTags; // List of tagged users
//   final List<String> keywordsList; // List of keywords
//   final List<String> privacyPost; // Privacy policy (e.g., Public, Private)
//   final List<File> mediaFiles; // List of media files
//   final List<String> interactions; // Interaction options
//   final List<String> dmReplies; // Interaction options
//   final List<String> dmComments; // Interaction options
//   final UserProfile userProfile;
//   final bool isPoll;
//   final String location;
//   const NewPostNow({
//     super.key,
//     required this.postField,
//     required this.peopleTags,
//     required this.keywordsList,
//     required this.privacyPost,
//     required this.mediaFiles,
//     required this.interactions,
//     required this.userProfile,
//     this.isPoll = false,
//     required this.location,
//     required this.dmReplies,
//     required this.dmComments,
//   });
//   @override
//   _NewPostNowState createState() => _NewPostNowState();
// }

// class _NewPostNowState extends State<NewPostNow> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     context.read<PostProvider>();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Post'),
//       ),
//       body: Builder(builder: (context) {
//         var pro = context.watch<PostProvider>();
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Inside your build method, replace the TextFormField and ElevatedButton parts with:

//                   TextFormField(
//                     controller: _titleController,
//                     decoration: InputDecoration(
//                       labelText: 'Post Title',
//                       labelStyle: TextStyle(color: Colors.grey.shade800),
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.white70),
//                       ),
//                     ),
//                     style: const TextStyle(color: Colors.black),
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Post Title is required';
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 16.0),

//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: InputDecoration(
//                       labelText: 'Post Description',
//                       labelStyle: TextStyle(color: Colors.grey.shade800),
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.white70),
//                       ),
//                     ),
//                     style: const TextStyle(color: Colors.black),
//                     maxLines: 5,
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Post Description is required';
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 24.0),

//                   ElevatedButton(
//                     onPressed: isLoading
//                         ? null
//                         : () async {
//                             if (_formKey.currentState!.validate()) {
//                               // Logic to handle post submission
//                               setState(() {
//                                 isLoading = true;
//                               });
//                               final title = _titleController.text.trim();
//                               final description =
//                                   _descriptionController.text.trim();

//                               print("Post Title: $title");
//                               print("Post Description: $description");
//                               if (widget.isPoll) {
//                                 setState(() {
//                                   isLoading = false;
//                                 });

//                                 Navigator.push(
//                                     context,
//                                     CupertinoDialogRoute(
//                                         builder: (_) => AddPollScreen(
//                                               postField: widget.postField,
//                                               selectedTagUsers:
//                                                   widget.peopleTags,
//                                               keywordList: widget.keywordsList,
//                                               privacyPolicy: widget.privacyPost,
//                                               mediaFiles: widget.mediaFiles,
//                                               userProfile: widget.userProfile,
//                                               interactions: widget.interactions,
//                                               postTitle: title,
//                                               postDescription: description,
//                                               location: widget.location,
//                                               dmReplies: widget.dmReplies,
//                                               dmComments: widget.dmComments,
//                                             ),
//                                         context: context));
//                               } else {
//                                 final response = await pro.createNewPost(
//                                     context,
//                                     postField: widget.postField,
//                                     peopleTags: widget.peopleTags,
//                                     keywordsList: widget.keywordsList,
//                                     privacyPost: widget.privacyPost,
//                                     mediaFiles: widget.mediaFiles,
//                                     postTitle: title,
//                                     dmReplies: widget.dmReplies,
//                                     dmComments: widget.dmComments,
//                                     postDescription: description,
//                                     interactions: widget.interactions,
//                                     location: widget.location);

//                                 if (response != null) {
//                                   //ToastNotifier.showSuccessToast(
//                                   // context, "Post Successfully posted!");
//                                   setState(() {
//                                     isLoading = false;
//                                   });
//                                   _titleController.clear();
//                                   _descriptionController.clear();
//                                   final token = await Prefrences.getAuthToken();
//                                   Navigator.pushAndRemoveUntil(
//                                       context,
//                                       CupertinoDialogRoute(
//                                           builder: (_) => MainScreen(
//                                               userProfile: widget.userProfile!,
//                                               authToken: token),
//                                           context: context),
//                                       (route) => false);
//                                 } else {
//                                   setState(() {
//                                     isLoading = false;
//                                   });
//                                   //ToastNotifier.showErrorToast(
//                                   // context, "Network Problem. Try again.");
//                                 }
//                                 // Clear fields after submission

//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                       content:
//                                           Text('Post submitted successfully!')),
//                                 );
//                               }
//                             }

//                             // Handle button press logic here
//                           },
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       backgroundColor:
//                           widget.isPoll ? Colors.black : Colors.black,
//                     ),
//                     child: Container(
//                       height: 60,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: widget.isPoll ? Colors.black : Colors.black,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: isLoading
//                             ? [
//                                 CircularProgressIndicator.adaptive(
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 ),
//                               ]
//                             : [
//                                 Icon(
//                                   widget.isPoll
//                                       ? Icons.arrow_circle_right_outlined
//                                       : Icons.arrow_upward,
//                                   size: 20,
//                                   color: Colors.white,
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Text(
//                                   widget.isPoll ? "Next" : "Post Now",
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
