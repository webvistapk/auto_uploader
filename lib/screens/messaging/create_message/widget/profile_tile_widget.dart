import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final String? profileImage; // Null for default avatar
  final String displayName;
  final String username;
  final bool showCheckbox; // Determines if the checkbox is visible
  final bool isChecked; // External state for the checkbox
  final VoidCallback onPressedTile; // Tap action handler
  final ValueChanged<bool> onChecked; // Checkbox state handler

  const ProfileTile({
    Key? key,
    this.profileImage,
    required this.displayName,
    required this.username,
    required this.showCheckbox,
    required this.isChecked,
    required this.onPressedTile,
    required this.onChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (!showCheckbox) onPressedTile();
        },
        child: Column(
          children: [
            Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage!) : null,
                  backgroundColor: Colors.grey[300],
                  child: profileImage == null
                      ? const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (username.isNotEmpty)
                        Text(
                          username,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),

                // Optional Checkbox
                if (showCheckbox)
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      onChecked(value ?? false);
                    },
                  ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
