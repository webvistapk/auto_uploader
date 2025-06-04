import 'package:flutter/material.dart';
import 'package:mobile/models/UserProfile/userprofile.dart';

class SingleSelectOptionsSheet extends StatefulWidget {
  final List<String> initialValues;
  final List<Map<String, dynamic>> finalValueList;

  final String titile;

  const SingleSelectOptionsSheet(
      {Key? key,
      required this.initialValues,
      this.titile = "Privacy",
      required this.finalValueList})
      : super(key: key);

  @override
  _SingleSelectOptionsSheetState createState() =>
      _SingleSelectOptionsSheetState();
}

class _SingleSelectOptionsSheetState extends State<SingleSelectOptionsSheet> {
  late String selectedOption;

  // Only one option can be selected now (single-select radio behavior)
  List<Map<String, dynamic>> privacyOptions = [];

  @override
  void initState() {
    super.initState();
    setPrivacy();
    selectedOption = widget.initialValues.isNotEmpty
        ? widget.initialValues.first.toLowerCase()
        : 'followers';
  }

  setPrivacy() {
    privacyOptions = widget.finalValueList;
    if (mounted) return;
    setState(() {});
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
          Text(
            widget.titile,
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
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  subtitle: Text(option['count'],
                      style: const TextStyle(color: Colors.black)),
                  trailing: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.black : Colors.white,
                        border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey)),
                    child: Center(
                        child: Container(
                      height: 5,
                      width: 5,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    )),
                  ),

                  //  Icon(
                  //   isSelected
                  //       ? Icons.radio_button_checked
                  //       : Icons.radio_button_unchecked,
                  //   color: isSelected ? Colors.black : Colors.grey,
                  // ),
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
