import 'package:flutter/material.dart';

class InteractionsBottomSheet extends StatefulWidget {
  final List<String>? initialSelectedOptions;
  final List<Map<String, String>>? finalOptions;

  const InteractionsBottomSheet({
    Key? key,
    this.initialSelectedOptions,
    this.finalOptions,
  }) : super(key: key);

  @override
  _InteractionsBottomSheetState createState() =>
      _InteractionsBottomSheetState();
}

class _InteractionsBottomSheetState extends State<InteractionsBottomSheet> {
  late Set<String> selectedOptions;
  late List<Map<String, String>> options;

  @override
  void initState() {
    super.initState();

    // Default options if none provided
    options = (widget.finalOptions == null || widget.finalOptions!.isEmpty)
        ? [
            {'label': 'Post', 'value': 'post', 'count': ''},
            {'label': 'Reel', 'value': 'reel', 'count': ''},
          ]
        : widget.finalOptions!;

    selectedOptions = widget.initialSelectedOptions != null
        ? widget.initialSelectedOptions!.map((e) => e.toLowerCase()).toSet()
        : <String>{};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Choose Options',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final value = option['value']!.toLowerCase();
                final isSelected = selectedOptions.contains(value);
                final count = option['count'] ?? '';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedOptions.remove(value);
                      } else {
                        selectedOptions.add(value);
                      }
                    });
                  },
                  title: Text(
                    option['label'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: count.isNotEmpty
                      ? Text(
                          count,
                          style: const TextStyle(color: Colors.black),
                        )
                      : null,
                  trailing: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.black : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        height: 5,
                        width: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedOptions.isNotEmpty ? Colors.black : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: selectedOptions.isNotEmpty
                    ? () {
                        Navigator.pop(context, selectedOptions.toList());
                      }
                    : null, // Disabled when no selection
                child: const Text(
                  'Done',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
