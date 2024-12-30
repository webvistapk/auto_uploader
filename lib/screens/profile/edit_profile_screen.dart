import 'package:flutter/material.dart';
import 'package:mobile/common/app_colors.dart';
import 'package:mobile/common/app_styles.dart';
import 'package:mobile/common/app_textfield.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/common/utils.dart';
import 'package:mobile/controller/providers/profile_provider.dart';
import 'package:mobile/prefrences/prefrences.dart';
import 'package:mobile/prefrences/user_prefrences.dart';
import 'package:mobile/screens/authantication/update%20password/old_password_screen.dart';
import 'package:mobile/screens/mainscreen/main_screen.dart';
import 'package:mobile/screens/search/widget/search_widget.dart';
import 'package:mobile/screens/widgets/side_bar.dart';
import 'package:mobile/screens/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';
import 'package:mobile/controller/store/search/search_store.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>();
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final UserProfile user =
        ModalRoute.of(context)!.settings.arguments as UserProfile;
    _populateControllers(user);
  }

  void _initializeControllers() {
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
  }

  void _populateControllers(UserProfile user) {
    _usernameController.text = user.username ?? '';
    _emailController.text = user.email ?? '';
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _phoneNumberController.text = user.phoneNumber ?? '';
    _descriptionController.text = user.description ?? '';
    _addressController.text = user.address ?? '';
    _cityController.text = user.city ?? '';
    _countryController.text = user.country ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(ProfileProvider pro) async {
    final UserProfile existingUser =
        ModalRoute.of(context)!.settings.arguments as UserProfile;

    final UserProfile updatedUser = UserProfile(
      id: existingUser.id,
      username:
          _usernameController.text.isNotEmpty ? _usernameController.text : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneNumberController.text,
      description: _descriptionController.text,
      address: _addressController.text,
      city: _cityController.text,
      country: _countryController.text,
    );

    try {
      final token = Prefrences.getAuthToken();
      await pro.updateProfile(context, updatedUser);
      await UserPreferences().saveCurrentUser(updatedUser);
      ToastNotifier.showSuccessToast(context, 'Profile updated successfully.');

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => MainScreen(
                    userProfile: updatedUser,
                    authToken: token.toString(),
                    selectedIndex: 4,
                  )),
          (route) => false);
    } catch (e) {
      ToastNotifier.showErrorToast(context, 'Failed to update profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onSearch: (query) => SearchStore.updateSearchQuery(query),
      ),
      drawer: const SideBar(),
      backgroundColor: AppColors.mainBgColor.withOpacity(1),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.mainBgColor, // Light blue
                  AppColors.mainBgColor, // Very light blue
                ],
              ),
            ),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: SearchStore.searchQuery,
            builder: (context, searchQuery, child) {
              if (searchQuery == null || searchQuery.isEmpty) {
                return Builder(builder: (context) {
                  var pro = context.watch<ProfileProvider>();
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Example usage of CustomAppTextField in the EditProfileScreen
                          CustomAppTextField(
                            labelText: 'Username',
                            controller: _usernameController,
                            enabled: false,
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'Email',
                            controller: _emailController,
                            enabled: false,
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'First Name',
                            controller: _firstNameController,
                            hintText: "Enter First Name",
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'Last Name',
                            controller: _lastNameController,
                            hintText: "Enter Last Name",
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'Phone Number',
                            controller: _phoneNumberController,
                            hintText: "Enter Phone Number",
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'Description',
                            controller: _descriptionController,
                            hintText: "Enter Description",
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'Address',
                            controller: _addressController,
                            hintText: "Enter Your Address",
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'City',
                            controller: _cityController,
                            hintText: "Enter Your City",
                          ),
                          const SizedBox(height: 10),
                          CustomAppTextField(
                            labelText: 'Country',
                            controller: _countryController,
                            hintText: "Enter Your Country",
                          ),

                          const SizedBox(height: 20),
                          pro.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    await _saveProfile(pro);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text('Save Changes',
                                      style: AppStyles.buttonTextStyle),
                                ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => OldPasswordScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Text('Change Password',
                                style: AppStyles.buttonTextStyle),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                });
              } else {
                return SearchWidget(
                  query: searchQuery,
                  authToken: Prefrences.getAuthToken().toString(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
