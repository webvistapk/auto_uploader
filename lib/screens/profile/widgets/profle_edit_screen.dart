import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/controller/endpoints.dart';
import 'package:mobile/controller/services/profile/user_service.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/profile/mainscreen/main_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  final String imageUrl;
  final UserProfile? userProfile;
  final String authToken;

  const ProfileEditScreen({
    Key? key,
    required this.imageUrl,
    required this.userProfile,
    required this.authToken,
  }) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImageFile;
  bool isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = pickedFile;
        isUploading = true; // Start uploading
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final url =
        Uri.parse('${ApiURLs.baseUrl}${ApiURLs.user_profile_image_endpoint}');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${widget.authToken}'
      ..files.add(
          await http.MultipartFile.fromPath('profile_image', imageFile.path));

    final response = await request.send();

    setState(() => isUploading = false); // Stop uploading

    if (response.statusCode == 200) {
      final updatedProfile = await _fetchUserProfile(widget.userProfile!.id);
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoDialogRoute(
          builder: (_) => MainScreen(
            userProfile: updatedProfile,
            authToken: widget.authToken,
            selectedIndex: 4,
          ),
          context: context,
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile image")),
      );
    }
  }

  _fetchUserProfile(int userId) async {
    UserProfile? userProfile = await UserService.fetchUserProfile(userId);
    UserPreferences().saveCurrentUser(userProfile);
    return userProfile;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, widget.userProfile),
        ),
        title: Text("Edit Profile", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Choose from Gallery'),
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Take a Photo'),
                        onTap: () {
                          _pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: _selectedImageFile != null
                  ? FileImage(File(_selectedImageFile!.path))
                  : NetworkImage(widget.imageUrl) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: isUploading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitCircle(color: Colors.white, size: 50.0),
                      SizedBox(height: 10),
                      Text(
                        "Uploading photo...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
