import 'package:flutter/material.dart';

class PollScreen extends StatefulWidget {
  @override
  _PollScreenState createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  final Map<String, int> pollOptions = {
    "Option 1": 25,
    "Option 2": 25,
    "Option 3": 15,
    "Option 4": 25,
  };

  String? selectedPollOption;
  String? selectedYesNoOption;

  int get totalVotes => pollOptions.values.fold(0, (sum, value) => sum + value);

  void showPollModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Poll Title",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Poll Description",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ...pollOptions.keys.map((option) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPollOption = option;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedPollOption == option
                              ? Colors.blueAccent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selectedPollOption == option
                                  ? Colors.blueAccent
                                  : Colors.grey),
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: selectedPollOption == option
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: selectedPollOption != null
                        ? () {
                            Navigator.pop(context);
                            showYesNoModal(context);
                          }
                        : null,
                    child: const Text("Next"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showYesNoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Do you agree?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedYesNoOption = "Yes";
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedYesNoOption == "Yes"
                            ? Colors.blueAccent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selectedYesNoOption == "Yes"
                                ? Colors.blueAccent
                                : Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            color: selectedYesNoOption == "Yes"
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedYesNoOption = "No";
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedYesNoOption == "No"
                            ? Colors.blueAccent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selectedYesNoOption == "No"
                                ? Colors.blueAccent
                                : Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          "No",
                          style: TextStyle(
                            color: selectedYesNoOption == "No"
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: selectedYesNoOption != null
                        ? () {
                            Navigator.pop(context);
                            showPercentageResult(context);
                          }
                        : null,
                    child: const Text("Next"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showPercentageResult(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: pollOptions.keys.map((option) {
              double percentage = totalVotes > 0
                  ? (pollOptions[option]! / totalVotes) * 100
                  : 0.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 10,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: percentage / 100,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Poll"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showPollModal(context),
          child: const Text("Start Poll"),
        ),
      ),
    );
  }
}
