import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class AddPollScreen extends StatefulWidget {
  const AddPollScreen({super.key});

  @override
  State<AddPollScreen> createState() => _AddPollScreenState();
}

class _AddPollScreenState extends State<AddPollScreen> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionsControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  String _pollDuration = '7 days';

  @override
  void dispose() {
    _questionController.dispose();
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
          title: const Center(
            child: Text(
              "Create a Poll",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Perform validation or submission logic here
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your question *'),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  hintText: 'Add question',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
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
                            child: TextFormField(
                              controller: _optionsControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Option ${index + 1}',
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                              maxLength: 30,
                            ),
                          ),
                          if (index >= 2)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
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
            ],
          ),
        ),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.poll_outlined, size: 20, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      "Pool Post",
                      style: AppTextStyles.poppinsMedium().copyWith(
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
            )));
  }
}
