import 'package:flutter/material.dart';

class InteractionsBottomSheet extends StatefulWidget {
  final List<String>? initialSelectedOptions; // Parameter for initial values

  InteractionsBottomSheet({this.initialSelectedOptions});

  @override
  _InteractionsBottomSheetState createState() =>
      _InteractionsBottomSheetState();
}

class _InteractionsBottomSheetState extends State<InteractionsBottomSheet> {
  late ValueNotifier<Set<String>> selectedOptions;

  // Define available options
  final List<String> options = ['Comments', 'Polls'];

  @override
  void initState() {
    super.initState();
    // Initialize with the provided initialSelectedOptions or an empty set
    selectedOptions = ValueNotifier<Set<String>>(
      widget.initialSelectedOptions != null
          ? widget.initialSelectedOptions!.toSet()
          : {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
                  "Choose Options",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, selectedOptions.value.toList());
                  },
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          // Options with checkboxes
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return _buildCheckboxOption(context, options[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Custom method to build each checkbox option
  Widget _buildCheckboxOption(BuildContext context, String option) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: selectedOptions,
      builder: (context, selectedSet, _) {
        return CheckboxListTile(
          title: Text(
            option,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          activeColor: Colors.blue,
          value:
              selectedSet.contains(option), // Check if this option is selected
          onChanged: (bool? selected) {
            if (selected == true) {
              selectedSet.add(option);
            } else {
              selectedSet.remove(option);
            }
            selectedOptions.value = {...selectedSet}; // Update the set
          },
        );
      },
    );
  }

  @override
  void dispose() {
    selectedOptions.dispose(); // Dispose ValueNotifier to prevent memory leaks
    super.dispose();
  }
}
