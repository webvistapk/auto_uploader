import 'package:flutter/material.dart';

class PrivacyOptionsSheet extends StatefulWidget {
  final String privacyPolicy; // The initial privacy policy value
  const PrivacyOptionsSheet({Key? key, required this.privacyPolicy})
      : super(key: key);

  @override
  _PrivacyOptionsSheetState createState() => _PrivacyOptionsSheetState();
}

class _PrivacyOptionsSheetState extends State<PrivacyOptionsSheet> {
  // Track the selected option
  late String selectedPrivacyOption; // Initialize based on the passed string

  // Define privacy policy options
  final List<String> privacyPolicyOptions = ['public', 'followers', 'private'];

  @override
  void initState() {
    super.initState();
    // Set the initial privacy option based on the passed value
    selectedPrivacyOption = _getOptionFromPrivacy(widget.privacyPolicy);
  }

  // Convert the privacy policy string to corresponding option text
  String _getOptionFromPrivacy(String privacy) {
    switch (privacy) {
      case 'public':
        return 'Public';
      case 'followers':
        return 'Followers';
      case 'private':
        return 'Only Me';
      default:
        return 'Public'; // Default option
    }
  }

  // Convert the option text back to the privacy policy value
  String _getPrivacyFromOption(String option) {
    switch (option) {
      case 'Public':
        return 'public';
      case 'Followers':
        return 'followers';
      case 'Only Me':
        return 'private';
      default:
        return 'public'; // Default privacy
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row with Close Button
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "Privacy",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(
                        context, _getPrivacyFromOption(selectedPrivacyOption));
                  },
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          // Privacy options with checkboxes
          Column(
            children: [
              _buildCheckboxOption(
                context,
                'Public',
                'Visible to everyone.',
              ),
              _buildCheckboxOption(
                context,
                'Followers',
                'Visible only to followers.',
              ),
              _buildCheckboxOption(
                context,
                'Only Me',
                'Visible only to you.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom method to build each checkbox option
  Widget _buildCheckboxOption(
      BuildContext context, String option, String description) {
    return CheckboxListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      activeColor: Colors.red,
      value:
          selectedPrivacyOption == option, // Check if this option is selected
      onChanged: (bool? value) {
        setState(() {
          selectedPrivacyOption = option; // Update selected option
        });
        // Call a function or do something with the selected value
        _updatePrivacyPolicy(option);
      },
    );
  }

  // Update the privacy policy value based on user selection
  void _updatePrivacyPolicy(String option) {
    String newPrivacy = _getPrivacyFromOption(option);
    // Here you can do something with the updated privacy policy, like passing it back to a parent widget or storing it
    print("Updated privacy policy: $newPrivacy");
    // You can also pass this back using Navigator.pop() if required.
    // Navigator.pop(context,
    //     newPrivacy); // Pass the updated privacy back when closing the sheet
  }
}
