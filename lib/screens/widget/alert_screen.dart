import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';

class AlertScreenDialog extends StatefulWidget {
  const AlertScreenDialog({super.key});

  @override
  State<AlertScreenDialog> createState() => _AlertScreenDialogState();
}

class _AlertScreenDialogState extends State<AlertScreenDialog> {
  String? _selectedValue;
  final TextEditingController _keywordController = TextEditingController();
  List<String> hashtags = [];

  @override
  Widget build(BuildContext context) {
    bool isFormFilled = _selectedValue != null && _keywordController.text.isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20),
              child: Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Confirmation Post",
                  style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 16),
                ),
                // SizedBox(height: 20),
                // Updated hashtag display
                Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20,top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: hashtags
                        .map((hashtag) => Text(
                          hashtag,
                          style: AppTextStyles.poppinsRegular(),
                        ))
                        .toList(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose who can see your post",
                    style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 22, top: 10),
              child: Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  hint: Text(
                    "Public",
                    style: AppTextStyles.poppinsRegular()
                        .copyWith(color: Colors.grey),
                  ),
                  value: _selectedValue,
                  underline: SizedBox(),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: <String>['Public', 'Only Followers see', 'Only me']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedValue = newValue;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Keywords to Display",
                    style: AppTextStyles.poppinsSemiBold().copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 22, top: 10),
              child: TextField(
                controller: _keywordController,
                cursorColor: Colors.black,
                maxLines: 4,
                onChanged: (text) {
                  setState(() {
                    hashtags = extractHashtags(text);
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintText: "#Keyword",
                  hintStyle: AppTextStyles.poppinsRegular()
                      .copyWith(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: GestureDetector(
                onTap: isFormFilled ? () {
                  // Handle confirmation action here
                } : null,
                child: Container(
                  child: Center(
                    child: Text(
                      "Confirm",
                      style: AppTextStyles.poppinsMedium()
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isFormFilled ? Colors.red : Colors.grey,
                  ),
                  height: 50,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  child: Center(
                    child: Text(
                      "Go Back",
                      style: AppTextStyles.poppinsMedium().copyWith(
                          color: Color.fromARGB(255, 85, 51, 177)),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Color.fromARGB(255, 85, 51, 177)),
                  ),
                  height: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to show the AlertDialog
void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertScreenDialog();
    },
  );
}

List<String> extractHashtags(String text) {
  // Split the text by spaces and keep all words
  List<String> words = text.split(' ');

  // Extract hashtags from words and allow incomplete hashtags (the word being typed)
  List<String> hashtags =
      words.where((word) => word.startsWith('#')).toList
      ();

  return hashtags;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Alert Dialog Example')),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showHelpDialog(context); // Context is valid here inside Scaffold
        },
        child: Text("Show Alert Dialog"),
      ),
    );
  }
}
