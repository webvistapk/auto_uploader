// import 'package:flutter/material.dart';

// class PrivacyOptionsSheet extends StatefulWidget {
//   final List<String>
//       initialPrivacyPolicy; // Initial selected options in lowercase
//   const PrivacyOptionsSheet({Key? key, required this.initialPrivacyPolicy})
//       : super(key: key);

//   @override
//   _PrivacyOptionsSheetState createState() => _PrivacyOptionsSheetState();
// }

// class _PrivacyOptionsSheetState extends State<PrivacyOptionsSheet> {
//   late ValueNotifier<List<String>> selectedPrivacyOptions;

//   // Define all privacy options with display text and their lowercase values
//   final List<Map<String, String>> privacyOptions = [
//     {'label': 'Public', 'value': 'public'},
//     {'label': 'Followers', 'value': 'followers'},
//     {'label': 'Following', 'value': 'following'},
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // Initialize with initial privacy list or empty list
//     selectedPrivacyOptions = ValueNotifier<List<String>>(
//       widget.initialPrivacyPolicy.map((e) => e.toLowerCase()).toList(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 350,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(40),
//           topRight: Radius.circular(40),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title row with close button
//           Padding(
//             padding: const EdgeInsets.only(top: 15, right: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Spacer(),
//                 const Text(
//                   "Privacy",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context, selectedPrivacyOptions.value);
//                   },
//                   child: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Divider(),
//           // Privacy options with checkboxes supporting multiple selection
//           Expanded(
//             child: ValueListenableBuilder<List<String>>(
//               valueListenable: selectedPrivacyOptions,
//               builder: (context, selectedValues, _) {
//                 return ListView(
//                   children: privacyOptions.map((option) {
//                     final isSelected = selectedValues.contains(option['value']);
//                     return CheckboxListTile(
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             option['label']!,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             _getDescription(option['value']!),
//                             style: const TextStyle(
//                                 fontSize: 12, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                       activeColor: Colors.red,
//                       value: isSelected,
//                       onChanged: (bool? selected) {
//                         if (selected == null) return;

//                         final newSelected = List<String>.from(selectedValues);
//                         if (selected) {
//                           if (!newSelected.contains(option['value'])) {
//                             newSelected.add(option['value']!);
//                           }
//                         } else {
//                           newSelected.remove(option['value']);
//                         }
//                         selectedPrivacyOptions.value = newSelected;
//                       },
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Return description text based on option value
//   String _getDescription(String value) {
//     switch (value) {
//       case 'public':
//         return 'Visible to everyone.';
//       case 'followers':
//         return 'Visible only to followers.';
//       case 'private':
//         return 'Visible only to you.';
//       default:
//         return '';
//     }
//   }

//   @override
//   void dispose() {
//     selectedPrivacyOptions.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';

class PrivacyOptionsSheet extends StatefulWidget {
  final List<String> initialPrivacyPolicy;

  const PrivacyOptionsSheet({Key? key, required this.initialPrivacyPolicy})
      : super(key: key);

  @override
  _PrivacyOptionsSheetState createState() => _PrivacyOptionsSheetState();
}

class _PrivacyOptionsSheetState extends State<PrivacyOptionsSheet> {
  late String selectedOption;

  // Only one option can be selected now (single-select radio behavior)
  final List<Map<String, dynamic>> privacyOptions = [
    {'label': 'Followers', 'value': 'followers', 'count': '1988 people'},
    {'label': 'Public', 'value': 'public', 'count': 'Every people'},
    {'label': 'Following', 'value': 'following', 'count': '2000 people'},
  ];

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialPrivacyPolicy.isNotEmpty
        ? widget.initialPrivacyPolicy.first.toLowerCase()
        : 'followers';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Privacy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // List of options
          Expanded(
            child: ListView.builder(
              itemCount: privacyOptions.length,
              itemBuilder: (context, index) {
                final option = privacyOptions[index];
                final isSelected = selectedOption == option['value'];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    setState(() {
                      selectedOption = option['value'];
                    });
                  },
                  title: Text(option['label'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15)),
                  subtitle: Text(option['count'],
                      style: const TextStyle(color: Colors.grey)),
                  trailing: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                );
              },
            ),
          ),

          // Done button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, [selectedOption]);
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
